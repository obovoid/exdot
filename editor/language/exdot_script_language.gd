@tool
extends ScriptLanguageExtension

var script_class := preload("./ExdotScriptResource.gd")

func _get_comment_delimiters() -> PackedStringArray:
	return PackedStringArray(["#"])

func _get_string_delimiters() -> PackedStringArray:
	return PackedStringArray([
		"\" \"",
		"' '"
	])

func _get_reserved_words() -> PackedStringArray:
	return PackedStringArray(
		[
			"var",
			"readonly",
			"func",
			"hoist",
			"hoisted",
			"from",
			"import",
			"to",
			"export",
			"interface",
			"type",
			"typeof",
			"with",
			"as",
			"matches",
			"if",
			"elif",
			"else",
			"for",
			"while",
			"match",
			"return",
			"await",
			"true",
			"false",
			"null",
			"node",
			"resource",
			"scene",
			"audio",
			"using",
			"is"
		]
	)

func _is_control_flow_keyword(keyword: String) -> bool:
	return keyword in [
		"if",
		"elif",
		"else",
		"for",
		"while",
		"match",
		"return",
		"await",
		"hoist",
		"hoisted",
	]

func _add_global_constant(name: StringName, value: Variant) -> void:
	return

func _add_named_global_constant(name: StringName, value: Variant) -> void:
	return

func _auto_indent_code(code: String, from_line: int, to_line: int) -> String:
	return code

func _can_inherit_from_file() -> bool:
	return false

func _can_make_function() -> bool:
	return false

func _complete_code(code: String, path: String, owner: Object) -> Dictionary:
	return {}

func _debug_get_current_stack_info() -> Array[Dictionary]:
	return []

func _debug_get_error() -> String:
	return ""

func _debug_get_globals(max_subitems: int, max_depth: int) -> Dictionary:
	return {}

func _debug_get_stack_level_count() -> int:
	return 0

func _debug_get_stack_level_function(level: int) -> String:
	return ""

func _debug_get_stack_level_instance(level: int) -> int:
	return 0

func _debug_get_stack_level_line(level: int) -> int:
	return 0

func _debug_get_stack_level_locals(level: int, max_subitems: int, max_depth: int) -> Dictionary:
	return {}

func _debug_get_stack_level_members(level: int, max_subitems: int, max_depth: int) -> Dictionary:
	return {}

func _debug_get_stack_level_source(level: int) -> String:
	return ""

func _debug_parse_stack_level_expression(level: int, expression: String, max_subitems: int, max_depth: int) -> String:
	return ""

func _find_function(function: String, code: String) -> int:
	return -1

func _finish() -> void:
	return

func _frame() -> void:
	return

func _get_built_in_templates(object: StringName) -> Array[Dictionary]:
	return []

func _get_extension() -> String:
	return "exdot"

func _get_global_class_name(path: String) -> Dictionary:
	return {}

func _get_name() -> String:
	return "exdot"

func _get_public_annotations() -> Array[Dictionary]:
	return []

func _get_public_constants() -> Dictionary:
	return {}
	
func _create_script() -> Object:
	var script = script_class.new()
	script._language = self
	return script

func _get_public_functions() -> Array[Dictionary]:
	return []

func _get_type() -> String:
	return "exdot"

func _handles_global_class_type(type: String) -> bool:
	return false

func _init() -> void:
	# Do stuff
	return

func _is_using_templates() -> bool:
	# Probably if the script would start like godot with "extends Node" and starting functions. 
	# Will probably be true soon, so that EXDOT doesn't start with nothing.
	return false

func _make_template(template: String, class__name: String, base_class_name: String) -> Script:
	return null

func _lookup_code(code: String, symbol: String, path: String, owner: Object) -> Dictionary:
	return {}

func _make_function(class__name: String, function_name: String, function_args: PackedStringArray) -> String:
	return ""

func _open_in_external_editor(script: Script, line: int, column: int) -> Error:
	# Not planned for now
	return FAILED

func _overrides_external_editor() -> bool:
	return false

func _profiling_get_accumulated_data(info_array: int, info_max: int) -> int:
	return 0

func _profiling_get_frame_data(info_array: int, info_max: int) -> int:
	return 0

func _profiling_set_save_native_calls(enable: bool) -> void:
	return

func _profiling_start() -> void:
	return

func _profiling_stop() -> void:
	return

func _reload_all_scripts() -> void:
	return

func _reload_scripts(scripts: Array, soft_reload: bool) -> void:
	return

func _reload_tool_script(script: Script, soft_reload: bool) -> void:
	return

func _remove_named_global_constant(name: StringName) -> void:
	return

func _supports_builtin_mode() -> bool:
	return false

func _supports_documentation() -> bool:
	# EXDOT Documentation only much later a topic.
	return false

func _thread_enter() -> void:
	return

func _thread_exit() -> void:
	return

func _validate(script: String, path: String, validate_functions: bool, validate_errors: bool, validate_warnings: bool, validate_safe_lines: bool) -> Dictionary:
	return {}

func _validate_path(path: String) -> String:
	return path
