@tool
extends EditorContextMenuPlugin

func _popup_menu(paths: PackedStringArray) -> void:
	if paths.size() != 1:
		return
	
	var path := paths[0]
	if path.get_extension() != "exd" and path.get_extension() != "exdot":
		return
	
	add_context_menu_item("Open Exdot", _open_exdot.bind(path))

func _open_exdot(path: String) -> void:
	print("Open Exdot: ", path)
