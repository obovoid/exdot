@tool
class_name ExdotTokenizer extends ExdotCompiler

var source: String
var start := 0
var current := 0
var line := 1
var column := 1
var start_line := 1
var start_column := 1
var pending_tokens: Array[ExdotToken] = []
var indent_stack: Array[int] = [0]
var at_line_start := true

func _init(code: String) -> void:
	source = code

func set_source(code: String) -> void:
	source = code

func scan_token() -> ExdotToken:
	if not pending_tokens.is_empty():
		return pending_tokens.pop_front()
	
	if at_line_start:
		_handle_line_start()
		at_line_start = false
		
		if not pending_tokens.is_empty():
			return pending_tokens.pop_front()
		
	_skip_inline_whitespace()
	_mark_start()
	
	if _is_at_end():
		if indent_stack.size() > 1:
			indent_stack.pop_back()
			return _make_token(ExdotToken.Type.DEDENT)
		
		return _make_token(ExdotToken.Type.EOF)
	
	var c := _advance()
	
	if c == "\n":
		at_line_start = true
		return _make_token(ExdotToken.Type.NEWLINE)
	
	# if char starts with valid identifier char
	if _is_alpha(c):
		return _identifier()
	if _is_digit(c):
		return _number()

	# handle single chars
	match c:
		"(":
			return _make_token(ExdotToken.Type.LEFT_PAREN)
		")":
			return _make_token(ExdotToken.Type.RIGHT_PAREN)
		"{":
			return _make_token(ExdotToken.Type.LEFT_BRACE)
		"}":
			return _make_token(ExdotToken.Type.RIGHT_BRACE)
		"[":
			return _make_token(ExdotToken.Type.LEFT_BRACKET)
		"]":
			return _make_token(ExdotToken.Type.RIGHT_BRACKET)
		":":
			if _match("="):
				return _make_token(ExdotToken.Type.COLON_EQUAL)
			if _match(":"):
				return _make_token(ExdotToken.Type.DOUBLE_COLON)
			return _make_token(ExdotToken.Type.COLON)
		",":
			return _make_token(ExdotToken.Type.COMMA)
		".":
			return _make_token(ExdotToken.Type.DOT)
		"=":
			if _match("="):
				return _make_token(ExdotToken.Type.EQUAL_EQUAL)
			return _make_token(ExdotToken.Type.EQUAL)
		"-":
			if _match(">"):
				return _make_token(ExdotToken.Type.ARROW)
			return _make_token(ExdotToken.Type.MINUS)
		"+":
			return _make_token(ExdotToken.Type.PLUS)
		"*":
			return _make_token(ExdotToken.Type.STAR)
		"/":
			return _make_token(ExdotToken.Type.SLASH)
		"?":
			if _match("?"):
				return _make_token(ExdotToken.Type.DOUBLE_QUESTION)
			return _make_token(ExdotToken.Type.QUESTION)
		">":
			return _make_token(ExdotToken.Type.BIGGER_THAN)
		"<":
			return _make_token(ExdotToken.Type.SMALLER_THAN)
		"!":
			return _make_token(ExdotToken.Type.NEGATION)
		"%":
			return _make_token(ExdotToken.Type.PERCENT)
		"\"":
			return _string("\"")
		"\'":
			return _string("\'")
	return _error_token("Unexpected character: %s" % c)

func _string(string_opener: String) -> ExdotToken:
	var value := ""
	var error := ""
	
	while not _is_at_end():
		var c := _advance()
		
		if (
			c == "\"" and string_opener == "\""
			) or (
			c == "\'" and string_opener == "\'"
		): # closing string
			if not error.is_empty():
				return _error_token(error)
			
			var token := _make_token(ExdotToken.Type.STRING)
			token.literal = value
			return token
		
		if c == "\n":
			at_line_start = true
			return _error_token("Unterminated string.")
		
		if c != "\\":
			value += c
			continue
		
		if _is_at_end():
			return _error_token("Unterminated escape sequence.")
		
		var escaped := _advance()
		match escaped:
			"n":
				value += "\n"
			"r":
				value += "\r"
			"t":
				value += "\t"
			"0":
				value += String.chr(0)
			"\"":
				value += "\""
			"\'":
				value += "\'"
			"\\":
				value += "\\"
			_:
				if error.is_empty():
					error = "Invalid escape sequence: \\%s" % escaped
		
		if escaped == "\n":
			at_line_start = true
			return _error_token("Unterminated string.")
	return _error_token("Unterminated string.")

func _skip_inline_whitespace() -> void:
	while not _is_at_end():
		match _peek():
			" ", "\t", "\r":
				_advance()
			
			"#":
				while _peek() != "\n" and not _is_at_end():
					_advance()
			
			_:
				return

func _handle_line_start() -> void: # Bug a empty indented line could cause a dedent. Check for actual code first.
	var indent := 0

	while not _is_at_end():
		match _peek():
			" ":
				indent += 1
				_advance()
			"\t":
				indent += 4
				_advance()
			_:
				break

	if _is_at_end() or _peek() == "\n" or _peek() == "#":
		return
	
	_mark_start()
	
	var current_indent := indent_stack.back()

	if indent > current_indent:
		indent_stack.append(indent)
		pending_tokens.append(_make_token(ExdotToken.Type.INDENT))

	elif indent < current_indent:
		while indent_stack.size() > 1 and indent < indent_stack.back():
			indent_stack.pop_back()
			pending_tokens.append(_make_token(ExdotToken.Type.DEDENT))

		if indent != indent_stack.back():
			pending_tokens.append(
				_error_token("Invalid indentation level.")
			)

func _mark_start() -> void:
	start = current
	start_line = line
	start_column = column

func _advance() -> String:
	var c := source[current]
	
	if c == "\n":
		line += 1
		column = 1
	else:
		column += 1
	
	current += 1
	return c

func _peek() -> String:
	if _is_at_end():
		return ""
	
	return source[current]

func _peek_next() -> String:
	if current +1 >= source.length():
		return ""
	
	return source[current +1]

func _match(expected: String) -> bool:
	if _is_at_end() or source[current] != expected:
		return false

	_advance()
	return true

func _is_at_end() -> bool:
	return current >= source.length()

func _make_token(type: ExdotToken.Type) -> ExdotToken:
	var token := ExdotToken.new()
	token.type = type
	token.lexeme = source.substr(start, current - start)
	token.line = start_line
	token.column = start_column
	
	return token

## gets if a string is a valid identifier alpha but not numeric.
func _is_alpha(c: String) -> bool:
	return Helper.is_alpha(c)

func _is_digit(c: String) -> bool:
	return Helper.is_digit(c)

func _is_alpha_numeric(c: String) -> bool:
	return Helper.is_alpha_numeric(c)

func _identifier() -> ExdotToken:
	while _is_alpha_numeric(_peek()):
		_advance()
	
	var text := source.substr(start, current-start)
	if SAP.KEYWORDS.has(text):
		return _make_token(SAP.KEYWORDS[text])
	
	return _make_token(ExdotToken.Type.IDENTIFIER)

func _advance_until_error_token_completed():
	while _peek() != " " and _peek() != "" and _peek() != "\n":
		_advance()

func _number() -> ExdotToken:
	# First digit was already consumed before entering _number().

	# Hex: 0xFF
	if source[start] == "0" and _peek().to_lower() == "x":
		return _hex_number()

	# Remaining integer digits / separators.
	if not _consume_decimal_tail():
		return _invalid_number()

	# Fraction: 123.45
	if _peek() == ".":
		_advance()

		# Don't allow 123.
		if not _is_digit(_peek()):
			return _invalid_number()

		if not _consume_decimal_tail():
			return _invalid_number()

	# Exponent: 1e10 / 1.5e-3
	if _peek().to_lower() == "e":
		_advance()

		if _peek() == "+" or _peek() == "-":
			_advance()

		if not _is_digit(_peek()):
			return _invalid_number()

		# Consume first exponent digit here.
		_advance()

		if not _consume_decimal_tail():
			return _invalid_number()

	if _peek() == ".":
		return _invalid_number()

	if _is_number_suffix(_peek()):
		return _invalid_number()

	return _finish_decimal_number()

func _consume_decimal_tail() -> bool:
	while true:
		var c := _peek()

		if _is_digit(c):
			_advance()
			continue

		if c == "_":
			# "_" must always be between digits.
			if not _is_digit(_peek_next()):
				return false

			_advance()
			continue

		break

	return true

func _hex_number() -> ExdotToken:
	# Current points at x/X.
	_advance()

	if not _is_hexadecimal_char(_peek()):
		return _invalid_number()

	while true:
		var c := _peek()

		if _is_hexadecimal_char(c):
			_advance()
			continue

		if c == "_":
			if not _is_hexadecimal_char(_peek_next()):
				return _invalid_number()

			_advance()
			continue

		break

	if _is_number_suffix(_peek()):
		return _invalid_number()

	var text := source.substr(start, current - start)
	var normalized := text.replace("_", "")

	var token := _make_token(ExdotToken.Type.INT)
	token.literal = normalized.hex_to_int()

	return token

func _finish_decimal_number() -> ExdotToken:
	var text := source.substr(start, current - start)
	var normalized := text.replace("_", "")

	var token;

	if "." in normalized or "e" in normalized.to_lower():
		token = _make_token(ExdotToken.Type.FLOAT)
		token.literal = normalized.to_float()
	else:
		token = _make_token(ExdotToken.Type.INT)
		token.literal = normalized.to_int()

	return token as ExdotToken

func _is_number_suffix(c: String) -> bool:
	if c.is_empty():
		return false

	return Helper.is_alpha(c) or c == "_"

func _invalid_number() -> ExdotToken:
	_advance_until_error_token_completed()

	var text := source.substr(start, current - start)

	return _error_token(
		'Invalid number "%s"' % text
	)

func _is_hexadecimal_char(c: String):
	return Helper.is_hexadecimal_char(c)

func _error_token(errmsg: String) -> ExdotToken:
	var et := _make_token(ExdotToken.Type.ERROR)
	et.literal = errmsg
	return et
