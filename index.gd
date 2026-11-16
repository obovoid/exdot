@tool
extends EditorPlugin

var dock_content = preload("./scenes/console_dock.tscn")

var compiler : ExdotCompiler

var context_menu: EditorContextMenuPlugin
var crash_unsubscriber : Variant # Callable | null
var exdot_loader : ExdotResourceLoader
var exdot_saver : ExdotResourceSaver
var highlighter : ExdotHighlighter
var editor_dock : EditorDock
var inspector_plugin : EditorInspectorPlugin
var exdot_language : ScriptLanguageExtension

func _ensure_config() -> void:
	if FileAccess.file_exists(Config.CONFIG_PATH):
		# test_config auto-loads the config.
		EXDOT.test_config()
		return

	EXDOT.setup_config()
	EXDOT.save_config()

func _ensure_paths() -> void:
	var home = EXDOT.r_path("HOME")
	var dir = DirAccess.open(home)
	var paths = [
		EXDOT.r_path("SOURCE"),
		EXDOT.r_path("OUTPUT"),
		EXDOT.r_path("WORKSPACE"),
		"res://.exdot/" # additional path for workspace configurations. Must not be configurable!
	]
	
	for path in paths:
		if dir.dir_exists(path):
			continue
		dir.make_dir(path)

func _register_context_menu() -> void:
	context_menu = preload("./editor/plugin/context_menu.gd").new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, context_menu)

func _remove_context_menu() -> void:
	if context_menu:
		remove_context_menu_plugin(context_menu)
	context_menu = null

func _register_console_dock() -> void:
	editor_dock = EditorDock.new()
	editor_dock.title = "EXDOT Console"
	editor_dock.dock_icon = preload("./assets/exdot.svg")
	editor_dock.available_layouts = EditorDock.DOCK_LAYOUT_HORIZONTAL
	editor_dock.default_slot = EditorDock.DOCK_SLOT_BOTTOM
	
	var content = dock_content.instantiate()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.custom_minimum_size.y = 45.0
	
	editor_dock.add_child(content)
	add_dock(editor_dock)

func _unregister_console_dock() -> void:
	remove_dock(editor_dock)
	editor_dock.queue_free()
	editor_dock = null

func _save_external_data() -> void:
	if EXDOT.get_config_value(SAP.CONFIG_ACP.COMPILER, SAP.CONFIG_ACP.COMPILE_ON_SAVE) == true:
		if compiler:
			compiler.build_all()

func _initialize() -> void:
	if EXDOT.INITIALIZED == EXDOT.STATUS.INITIALIZED or EXDOT.INITIALIZED == EXDOT.STATUS.INITIALIZING:
		return
	EXDOT.INITIALIZED = EXDOT.STATUS.INITIALIZING
	
	crash_unsubscriber = EXDOT.subscribe(SAP.CONFIG_ACP.EXDOT_CRASHED, _uninitialize)
	print_debug("Crash reporter subscribed")
	
	EXDOT._init_config()
	_ensure_config()
	
	Cache.init()
	
	_ensure_paths()
	
	Workspace.init()
	Collect.init()
	
	_register_context_menu()
	
	exdot_language = preload("./editor/language/exdot_script_language.gd").new()
	EXDOT.language = exdot_language
	Engine.register_script_language(exdot_language)
	
	highlighter = ExdotHighlighter.new()
	EditorInterface.get_script_editor().register_syntax_highlighter(highlighter)
	
	exdot_loader = ExdotResourceLoader.new()
	ResourceLoader.add_resource_format_loader(exdot_loader)
	exdot_saver = ExdotResourceSaver.new()
	ResourceSaver.add_resource_format_saver(exdot_saver)
	
	_register_console_dock()
	inspector_plugin = preload("./editor/ui/editor_inspector.gd").new()
	add_inspector_plugin(inspector_plugin)
	
	await get_tree().process_frame
	ExdotConsole.init()
	
	compiler = ExdotCompiler.new()
	ExdotTests.start()
	
	EXDOT.INITIALIZED = EXDOT.STATUS.INITIALIZED

func _uninitialize() -> void:
	if EXDOT.INITIALIZED == EXDOT.STATUS.UNINITIALIZED or EXDOT.INITIALIZED == EXDOT.STATUS.UNINITIALIZING:
		return
	EXDOT.INITIALIZED = EXDOT.STATUS.UNINITIALIZING
	print_debug("uninitializing started...")
	
	ExdotConsole.exit()
	EXDOT.language = null
	
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null
		
	_unregister_console_dock()
	_remove_context_menu()
	
	Workspace.flush()
	Cache.reset()
	
	if highlighter:
		EditorInterface.get_script_editor().unregister_syntax_highlighter(highlighter)

	if exdot_language:
		Engine.unregister_script_language(exdot_language)
		exdot_language = null

	if exdot_saver != null:
		ResourceSaver.remove_resource_format_saver(exdot_saver)
		exdot_saver = null
	
	if exdot_loader:
		ResourceLoader.remove_resource_format_loader(exdot_loader)
		exdot_loader = null
	
	EXDOT.send_event("uninitialize")
	
	if crash_unsubscriber is Callable:
		crash_unsubscriber.call()
		print_debug("Crash reporter unsubscribed.")
		crash_unsubscriber = null
	EXDOT.INITIALIZED = EXDOT.STATUS.UNINITIALIZED

func _enable_plugin() -> void:
	_initialize()

func _disable_plugin() -> void:
	_uninitialize()

func _enter_tree() -> void:
	_initialize()

func _exit_tree() -> void:
	_uninitialize()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_CRASH:
			_uninitialize()
