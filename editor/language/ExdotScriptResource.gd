@tool
class_name ExdotScriptResource
extends ScriptExtension

var _source_code := ""
var _language = ScriptLanguage

func _init(language: ScriptLanguage = null) -> void:
	_language = language

func _get_language() -> ScriptLanguage:
	assert(_language != null)
	return _language

func set_language(language: ScriptLanguageExtension) -> void:
	assert(language != null)
	_language = language

func _update_exports() -> void:
	pass

func _get_documentation() -> Array[Dictionary]:
	return []

func _can_instantiate() -> bool:
	# EXDOT scripts cannot be instantiated.
	return false

func _editor_can_reload_from_file() -> bool:
	return true

func _get_base_script() -> Script:
	return null

func _get_global_name() -> StringName:
	return &""

func _get_instance_base_type() -> StringName:
	return &""

func _inherits_script(script: Script) -> bool:
	return false

func _has_source_code() -> bool:
	return true

func _get_source_code() -> String:
	return _source_code

func _set_source_code(code: String) -> void:
	_source_code = code

func _reload(keep_state: bool) -> Error:
	return OK

func _is_tool() -> bool:
	return false

func _is_valid() -> bool:
	return true

func _is_abstract() -> bool:
	return false

func _has_method(method: StringName) -> bool:
	return false

func _has_static_method(method: StringName) -> bool:
	return false

func _get_method_info(method: StringName) -> Dictionary:
	return {}

func _get_script_method_list() -> Array[Dictionary]:
	return []

func _get_script_property_list() -> Array[Dictionary]:
	return []

func _has_script_signal(signal_name: StringName) -> bool:
	return false

func _get_script_signal_list() -> Array[Dictionary]:
	return []

func _get_property_default_value(property: StringName) -> Variant:
	return null

func _get_rpc_config() -> Variant:
	return {}
