@tool
class_name ExdotResourceLoader
extends ResourceFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["exd", "exdot"])

func _handles_type(type: StringName) -> bool:
	return type == &"Resource" or type == &"Script"

func _get_resource_type(path: String) -> String:
	if path.get_extension().to_lower() in _get_recognized_extensions():
		return "Script"
	
	return ""

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	
	var script := ExdotScriptResource.new()
	script.set_language(EXDOT.language)
	script._set_source_code(file.get_as_text())
	
	return script
