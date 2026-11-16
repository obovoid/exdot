@tool
extends EditorContextMenuPlugin
var icon := preload("../../assets/exdot.svg")
var attach := preload("./attach.gd").new()

func _popup_menu(paths: PackedStringArray) -> void:
	if paths.is_empty():
		return
	add_context_menu_item("Attach EXDOT Script", _attach_exdot_script, icon)

func _attach_exdot_script(nodes: Array) -> void:
	for node in nodes:
		# TODO: add node attach shortcut.
		attach._attach_exdot_script(node)
