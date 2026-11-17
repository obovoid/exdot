@tool
class_name ExdotResourceSaver
extends ResourceFormatSaver

func _recognize(resource: Resource) -> bool:
	return resource is ExdotScriptResource

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	if resource is ExdotScriptResource:
		return PackedStringArray(["exd", "exdot"])
	return PackedStringArray([])

func _save(resource: Resource, path: String, flags: int) -> Error:
	if not resource is ExdotScriptResource:
		return ERR_INVALID_PARAMETER
	
	var script := resource as ExdotScriptResource
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	
	file.store_string(script._get_source_code())
	
	if file.get_error() != OK:
		return file.get_error()
	return OK
