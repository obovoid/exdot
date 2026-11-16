@tool
extends Control

@export var line_edit : LineEdit
@export var suggestions : PanelContainer
@export var item_list : ItemList
@export var console : RichTextLabel
@export var clear_console_button : Button

const MAX_HISTORY := 32
var command_history : Array[String] = []
var history_index := -1
var _unsubscribers: Array = []

func _ready() -> void:
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.text_submitted.connect(_submit)
	line_edit.gui_input.connect(_on_line_edit_input)
	clear_console_button.pressed.connect(ExdotConsole.clear)
	console.bbcode_enabled = true
	console.scroll_following = true
	_unsubscribers.append(EXDOT.subscribe(SAP.ADD_MESSAGE, _add_message))
	_unsubscribers.append(EXDOT.subscribe(SAP.CLEAR_CONSOLE, _clear_output))
	_unsubscribers.append(EXDOT.subscribe(SAP.CONSOLE_COMMANDS_CHANGED, _refresh_suggestions))
	Cache.put("console-ready", true)
	_refresh_suggestions()
	
	console.meta_clicked.connect(_console_url_clicked)

func _clear_output() -> void:
	console.clear()

func _console_url_clicked(meta: Variant) -> void:
	var url := str(meta)
	
	if not url.begins_with("res://"):
		push_warning("Aborted: Unhandled URL click Event executed.")
		return
	
	var parts:= url.rsplit(":", true, 2)
	if parts.size() != 3:
		push_error("Error: Failed to open URL. Invalid URL split size -> %s" % url)
		return
	
	var path := parts[0]
	var line := int(parts[1])
	var column := int(parts[2])
	
	if not FileAccess.file_exists(path):
		ExdotConsole.error("File not found: %s" % path)
		return
	
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		
		if resource is Script:
			EditorInterface.edit_script(
				resource,
				line,
				column
			)
			return
		
		if resource != null:
			EditorInterface.edit_resource(resource)
			return
	
	EditorInterface.select_file(path)
	const warning = "Click Event might have resulted in an unexpected behaviour. This is because no valid ResourceLoader was found."
	push_warning(warning)
	ExdotConsole.warning(warning)
	console.scroll_to_line(console.get_line_count())

func _exit_tree() -> void:
	for unsubscribe in _unsubscribers:
		if unsubscribe is Callable:
			unsubscribe.call()
	_unsubscribers.clear()

func _add_message(message: String) -> void:
	if not console.text.is_empty() or console.text.ends_with("\n") == false:
		console.append_text("\n")
	
	console.append_text(message)

func _on_text_changed(_text: String) -> void:
	_refresh_suggestions()

func _refresh_suggestions() -> void:
	item_list.clear()
	var parsed := ExdotConsole.parse_arguments(line_edit.text.strip_edges())
	var query: String = parsed.command
	if query.is_empty():
		suggestions.hide()
		return
	var commands := ExdotConsole.get_commands()
	var names := commands.keys()
	names.sort()
	if parsed.has_arguments and commands.has(query):
		# command signature
		item_list.add_item(ExdotConsole.usage(query))
		item_list.set_item_tooltip(0, commands[query].get("description", ""))
	else:
		for name in names:
			if str(name).begins_with(query):
				var index := item_list.add_item(ExdotConsole.usage(name))
				item_list.set_item_tooltip(index, commands[name].get("description", ""))
	suggestions.visible = item_list.item_count > 0

func _submit(value: String) -> void:
	var input := value.strip_edges()
	if input.is_empty():
		return
	command_history.push_front(input)
	if command_history.size() > MAX_HISTORY:
		command_history.pop_back()
	history_index = -1
	line_edit.clear()
	suggestions.hide()
	ExdotConsole.execute(input)
	line_edit.grab_focus()
	
	# wait 1 frame before putting the mode back to editing
	await Engine.get_main_loop().process_frame
	line_edit.edit()

func _on_line_edit_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	
	match event.keycode:
		KEY_TAB:
			var parsed := ExdotConsole.parse_arguments(line_edit.text.strip_edges())
			if parsed.command.is_empty() or parsed.has_arguments:
				return
			var names := ExdotConsole.get_commands().keys()
			names.sort()
			for name in names:
				if str(name).begins_with(parsed.command):
					line_edit.text = str(name) + " "
					line_edit.set_caret_column(line_edit.text.length())
					_refresh_suggestions()
					line_edit.accept_event()
					return
		KEY_UP:
			if command_history.is_empty():
				return
			history_index = mini(history_index +1, command_history.size() -1)
			_show_history()
			line_edit.accept_event()
		KEY_DOWN:
			if history_index < 0:
				return
			history_index -= 1
			if history_index < 0:
				line_edit.clear()
			else:
				_show_history()
			line_edit.accept_event()
			
func _show_history() -> void:
	line_edit.text = command_history[history_index]
	line_edit.set_caret_column(line_edit.text.length())
	_refresh_suggestions()
