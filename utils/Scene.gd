@tool
class_name Scene
extends RefCounted

static func save(root: Node, path: String) -> void:
	var scene := PackedScene.new()
	var error := scene.pack(root)
	if error != OK:
		push_error("Scene could not be packed!")
		return
	error = ResourceSaver.save(scene, path)
	if error != OK:
		push_error("Scene could not be saved!")
