class_name Collect
extends RefCounted


static func _collect_path_to_uuid() -> void:
	var uuids = Workspace.pull_all("script_map")
	var path_to_uuid : Dictionary = {}
	for uuid in uuids.keys():
		path_to_uuid[uuids[uuid]] = uuid
	
	Cache.put(SAP.PATH_TO_UUID, path_to_uuid)

static func init() -> void:
	_collect_path_to_uuid()
