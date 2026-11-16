@tool
class_name ExdotHighlighter
extends EditorSyntaxHighlighter

enum PRIORITY_TOKENS {
	NUMBER,
	BINDING_NODE,
	OPERATOR,
	KEYWORD,
	TYPE_OR_FUNCTION,
	STRING,
	COMMENT
}

func _create() -> EditorSyntaxHighlighter:
	return ExdotHighlighter.new()

func _get_name() -> String:
	return "exdot"

func _get_supported_languages() -> PackedStringArray:
	return PackedStringArray(["exdot"])
	
var highlights : Dictionary
var text : String

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var result := {}
	var editor := get_text_edit()
	if editor == null:
		return result
	
	text = editor.get_line(line)
	highlights = {}
	
	_add_strings_and_comments()
	_add_operators()
	_add_numbers()
	_add_keywords()
	_add_binding_nodes()
	_add_builtin_functions()
	_add_builtin_types()
	
	var previous_color := SAP.COLORS.DEFAULT
	for n in range(text.length() +1):
		var color: Color = SAP.COLORS.DEFAULT
		
		if highlights.has(n):
			color = highlights[n].color
		
		if color != previous_color:
			result[n] = {
				"color": color
			}
			
			previous_color = color
	
	return result

func _is_valid_node_type(type_name: String) -> bool:
	return ClassDB.class_exists(type_name) and ClassDB.is_parent_class(type_name, "Node")

func _get_binding_name(start: int) -> String:
	var content = text.substr(start)
	var end = text.length()
	var pos := start
	
	while pos < text.length():
		var c = text[pos]
		if c == ">" or c == "=":
			return text.substr(start + 1, pos - start - 1)
		
		pos += 1
		
	return ""

func _is_valid_binding(start: int, end: int) -> bool:
	var pos := start +1
	while pos < end -1:
		var c = text[pos]
		
		if c == "\"" or c == "'":
			pos = _find_string_end(pos, c)
			continue
		
		if c == " " or c == "\t":
			return false
		
		pos += 1
	return true

func _add_binding_nodes() -> void:
	var start := 0
	while true:
		start = text.find("<", start)
		if start == -1:
			return
		
		
		var end := text.find(">", start +1)
		if end == -1:
			return
		
		end += 1
		var valid := _is_valid_binding(start, end) and _is_valid_node_type(_get_binding_name(start))
		
		_set_color_in_range(start, end, SAP.COLORS.BINDING_NODE if valid else SAP.COLORS.INVALID, PRIORITY_TOKENS.BINDING_NODE)
		start = end

func _find_string_end(start: int, opening_char: String) -> int:
	var escaped := false
	
	for i in range(start +1, text.length()):
		var c := text[i]
		
		if escaped:
			escaped = false
			continue
		
		if c == "\\":
			escaped = true
			continue
		
		if c == "\"" and opening_char == "\"" or c == "'" and opening_char == "'":
			return i + 1
	return text.length()

func _add_strings_and_comments() -> void:
	var pos := 0
	while pos < text.length():
		var c := text[pos]

		if c == "#":
			_set_color_in_range(pos, text.length(), SAP.COLORS.COMMENT, PRIORITY_TOKENS.COMMENT)
			return
		if c == "\"" or c == "'":
			var end := _find_string_end(pos, c)
			_set_color_in_range(pos, end, SAP.COLORS.STRING, PRIORITY_TOKENS.STRING)

			pos = end
			continue
		pos += 1

func _add_keywords() -> void:
	var keywords = SAP.KEYWORDS.keys()
	for keyword: String in keywords:
		var pos := text.find(keyword)
		var key_length := keyword.length()
		
		while pos != -1:
			var end := pos + key_length
			
			if not _validate_keyword_formatting(keyword, pos):
				pos = text.find(keyword, end)
				continue
			
			_set_color_in_range(pos, end, SAP.COLORS.FLOWKEYWORD if SAP.CONTROL_FLOW_KEYWORDS.has(keyword) else SAP.COLORS.KEYWORD, PRIORITY_TOKENS.KEYWORD)
			pos = text.find(keyword, end)

func _add_numbers() -> void:
	var pos := 0
	
	while pos < text.length():
		if text[pos].is_valid_int() == false:
			pos += 1
			continue
		
		var start := pos
		while pos < text.length() and (text[pos].is_valid_int() or text[pos] == "."):
			pos += 1
		
		var end := pos
		var before := ""
		var after := ""
		
		if start > 0:
			before = text[start - 1]
		
		if end < text.length():
			after = text[end]
		
		if Helper.is_alpha_numeric(before) or Helper.is_alpha_numeric(after):
			continue
		
		_set_color_in_range(start, end, SAP.COLORS.NUMBER, PRIORITY_TOKENS.NUMBER)

func _add_builtin_functions() -> void:
	for builtin: String in SAP.BUILTIN_FUNCTIONS:
		_handle_builtin_iteration(builtin, true)

func _add_builtin_types() -> void:
	for builtin: String in SAP.BUILTIN_TYPES:
		_handle_builtin_iteration(builtin, false)

func _handle_builtin_iteration(builtin: String, is_function : bool) -> void:
		var pos = text.find(builtin) as int
		
		while pos != -1:
			var end : int = pos + builtin.length()
			
			if not _validate_keyword_formatting(builtin, pos):
				pos = text.find(builtin, end)
				continue
			
			var next := end
			while next < text.length() and text[next] == " ":
				next += 1
			
			if is_function and (next >= text.length() or text[next] != "("):
				pos = text.find(builtin, end)
				continue
		
			_set_color_in_range(pos, end, SAP.COLORS.FUNCTION if is_function else SAP.COLORS.TYPE, PRIORITY_TOKENS.TYPE_OR_FUNCTION)
			pos = text.find(builtin, end)

func _validate_keyword_formatting(keyword: String, pos: int) -> bool:
	var start := pos
	var end := pos + keyword.length()

	var before_valid := start == 0 or not _is_identifier_char(text[start - 1])
	var after_valid := end >= text.length() or not _is_identifier_char(text[end])
	return before_valid and after_valid

func _is_identifier_char(c: String) -> bool:
	return c == "_" or c.to_lower() != c.to_upper() or c.is_valid_int()
	
func _add_operators() -> void:
	for operator: String in SAP.OPERATORS:
		var pos := text.find(operator)
		
		while pos != -1:
			var end := pos + operator.length()
			
			_set_color_in_range(pos, end, SAP.COLORS.OPERATOR, PRIORITY_TOKENS.OPERATOR)
			pos = text.find(operator, end)

func _set_color_in_range(start: int, end: int, color: Color, TokenPriority: PRIORITY_TOKENS) -> void:
	for n in range(start, end):
		if highlights.has(n):
			var data = highlights[n]
			if data.priority > TokenPriority:
				continue

		highlights[n] = {
			"priority": TokenPriority,
			"color": color
		}
