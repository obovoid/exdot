@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is ExdotContext

func _parse_begin(object: Object) -> void:
	var context := object as ExdotContext
	
	var button := Button.new()
	button.text = "Open Exdot Script"
	button.icon = EditorInterface.get_editor_theme().get_icon("Script", "EditorIcons")
	
	button.pressed.connect(
		func():
			_open_exdot(context.source_path)
	)
	
	add_custom_control(button)

func _open_exdot(path: String) -> void:
	if path.is_empty():
		push_warning("Source Path is not set!")
		return

	if path.begins_with("uid://"):
		var uid := ResourceUID.text_to_id(path)

		if not ResourceUID.has_id(uid):
			push_error(XERROR.INSPECTOR.UNKNOWN_RESOURCE_UID + path)
			return

		path = ResourceUID.get_id_path(uid)

	var script := ResourceLoader.load(path, "Script") as Script
	if script == null:
		push_error(XERROR.INSPECTOR.ERR_SCRIPT_LOAD + path)
		return

	EditorInterface.edit_script(script)
