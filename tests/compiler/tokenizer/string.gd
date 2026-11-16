@tool
extends RefCounted


func _contains_string_token(tokens: Array) -> bool:
	for current in tokens:
		if current != null and current.type == ExdotToken.Type.STRING:
			return true

	return false

func _contains_error_token(tokens: Array) -> bool:
	for current in tokens:
		if current != null and current.type == ExdotToken.Type.ERROR:
			return true
	
	return false

func run_sub_test(runner: TestRunner, compiler: ExdotCompiler) -> void:
	var tokens = compiler.generate_tokens_from_string('"Hello World!"')
	
	var token = ExdotTests.consume_token(tokens)
	runner.it("should be a String of value \"Hello World!\"", func():
		runner.expect(token.literal).toBeLiteral("Hello World!")
		runner.expect(token.lexeme).toBeLiteral("\"Hello World!\"")
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be an EOF Token", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
	)
	
	tokens = compiler.generate_tokens_from_string("'Hello World!'")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String of value \'Hello World!\'", func():
		runner.expect(token.literal).toBeLiteral("Hello World!")
		runner.expect(token.lexeme).toBeLiteral("\'Hello World!\'")
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be an EOF Token", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
	)
	
	tokens = compiler.generate_tokens_from_string("\"new\\nline\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String with a newline split", func():
		runner.expect(token.literal).toBeLiteral("new\nline")
		runner.expect(token.lexeme).toBeLiteral("\"new\\nline\"")
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be an EOF Token", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
	)

	tokens = compiler.generate_tokens_from_string("\'new\\nline\'")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String with a newline split", func():
		runner.expect(token.literal).toBeLiteral("new\nline")
		runner.expect(token.lexeme).toBeLiteral("\'new\\nline\'")
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be an EOF Token", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
	)
	
	tokens = compiler.generate_tokens_from_string("\"tab\\tline\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String with a tab line", func():
		runner.expect(token.literal).toBeLiteral("tab\tline")
		runner.expect(token.lexeme).toBeLiteral("\"tab\\tline\"")
	)

	tokens = compiler.generate_tokens_from_string("\"carriage return\\rline\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String with a carriage return", func():
		runner.expect(token.literal).toBeLiteral("carriage return\rline")
		runner.expect(token.lexeme).toBeLiteral("\"carriage return\\rline\"")
	)

	tokens = compiler.generate_tokens_from_string("\"escaped backslash \\\\ line\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a String with a escaped backslash", func():
		runner.expect(token.literal).toBeLiteral("escaped backslash \\ line")
		runner.expect(token.lexeme).toBeLiteral("\"escaped backslash \\\\ line\"")
	)
	
	tokens = compiler.generate_tokens_from_string('""')
	token = ExdotTests.consume_token(tokens)

	runner.it("should support an empty string", func(also: Callable):
		runner.expect(token.literal).toBeLiteral("")
		
		also.call("should preserve both quotation marks")
		runner.expect(token.lexeme).toBeLiteral('""')
	)

	tokens = compiler.generate_tokens_from_string("\"Hello \\\"World\\\"!\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should support escaped double quotes", func(also: Callable):
		runner.expect(token.literal).toBeLiteral('Hello "World"!')
		
		also.call("should preserve the escape sequences")
		runner.expect(token.lexeme).toBeLiteral("\"Hello \\\"World\\\"!\"")
	)

	tokens = compiler.generate_tokens_from_string("'It\\'s working!'")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should support escaped single quotes", func(also: Callable):
		runner.expect(token.literal).toBeLiteral("It's working!")
		
		also.call("should preserve the original lexeme")
		runner.expect(token.lexeme).toBeLiteral("'It\\'s working!'")
	)

	tokens = compiler.generate_tokens_from_string("\"It's a beautiful day!\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should support mixed quotation marks", func():
		runner.expect(token.literal).toBeLiteral("It's a beautiful day!")
	)

	tokens = compiler.generate_tokens_from_string("\"Hello\\nWorld\\t!\\rEnd\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should support multiple escape sequences", func(also: Callable):
		runner.expect(token.literal).toBeLiteral("Hello\nWorld\t!\rEnd")
		
		also.call("should preserve the original escaped lexeme")
		runner.expect(token.lexeme).toBeLiteral("\"Hello\\nWorld\\t!\\rEnd\"")
	)

	# Unicode characters
	tokens = compiler.generate_tokens_from_string('"日本語 🌸 ÄÖÜ"')
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should support Unicode characters", func(also: Callable):
		runner.expect(token.literal).toBeLiteral("日本語 🌸 ÄÖÜ")
		
		also.call("should preserve Unicode in the lexeme")
		runner.expect(token.lexeme).toBeLiteral('"日本語 🌸 ÄÖÜ"')
	)
	
	
	tokens = compiler.generate_tokens_from_string(
	    '"first" "second"'
	)

	var count_test = runner.it("should tokenize two separate strings", func():
		runner.expect(tokens.size()).toBeLiteral(3)
	)

	runner.it("should preserve both string values", func(also: Callable):
		var first = tokens[0]
		var second = tokens[1]
		var eof = tokens[2]

		runner.expect(first.type).toBeLiteral(ExdotToken.Type.STRING)
		runner.expect(first.literal).toBeLiteral("first")

		also.call("should parse the second string")
		runner.expect(second.type).toBeLiteral(ExdotToken.Type.STRING)
		runner.expect(second.literal).toBeLiteral("second")

		also.call("should end with EOF")
		runner.expect(eof.type).toBeLiteral(ExdotToken.Type.EOF)
	, [count_test])



	var invalid_strings := [
		{
			"name": "unterminated double-quoted string",
			"source": '"Hello World'
		},
		{
			"name": "unterminated single-quoted string",
			"source": "'Hello World"
		},
		{
			"name": "invalid escaped backslash",
			"source": "'Invalid\\'"
		}
	]

	for entry in invalid_strings:
		runner.it("should reject %s" % entry["name"], func():
			var result = compiler.generate_tokens_from_string(
				entry["source"]
			)

			runner.expect_not(_contains_string_token(result)).toBeTrue()
			runner.expect(_contains_error_token(result)).toBeTrue()
		)
	
	tokens = compiler.generate_tokens_from_string('"Hello World')

	# little extra tests for invalid strings that should keep a somewhat viable lexeme.
	
	var error_test = runner.it("should report an unterminated string", func():
		runner.expect(_contains_error_token(tokens)).toBeTrue()
	)

	token = ExdotTests.consume_token(tokens)

	runner.it("should preserve the invalid string lexeme", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.ERROR)

		also.call("should preserve the original source")
		runner.expect(token.lexeme).toBeLiteral('"Hello World')
	, [error_test])
	##############

	tokens = compiler.generate_tokens_from_string("\"Hello\\\\\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should handle a trailing escaped backslash", func(also: Callable):
		runner.expect(token.literal).toBeLiteral("Hello\\")
		
		also.call("should preserve the complete lexeme")
		runner.expect(token.lexeme).toBeLiteral("\"Hello\\\\\"")
	)
	
	tokens = compiler.generate_tokens_from_string("\"Hello\\\\\\\"World\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should handle consecutive backslash escapes", func():
		runner.expect(token.literal).toBeLiteral("Hello\\\"World")
		runner.expect(token.lexeme).toBeLiteral("\"Hello\\\\\\\"World\"")
	)
	
	tokens = compiler.generate_tokens_from_string("\"     \"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should handle multiple whitespaces", func():
		runner.expect(token.literal).toBeLiteral("     ")
		runner.expect(token.lexeme).toBeLiteral("\"     \"")
	)

	tokens = compiler.generate_tokens_from_string("\"123.45\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should handle numbers inside strings as a string.", func():
		runner.expect(token.literal).toBeLiteral("123.45")
		runner.expect(token.lexeme).toBeLiteral("\"123.45\"")
	)
	
	var lorem_long_text := "Lorem ipsum dolor sit amet. ".repeat(400)
	tokens = compiler.generate_tokens_from_string("\"" + lorem_long_text + "\"")
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should handle long Strings without cutting them off.", func(also: Callable):
		runner.expect(token.literal).toBeLiteral(lorem_long_text)
		runner.expect(token.lexeme).toBeLiteral("\"" + lorem_long_text + "\"")
		
		also.call("should be of type string")
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.STRING)
	)

	tokens = compiler.generate_tokens_from_string("\"Hello\\nWorld\" 123")
	
	count_test = runner.it("should tokenize a string followed by a number", func():
		runner.expect(tokens.size()).toBeLiteral(3)
	)

	ExdotTests.consume_token(tokens)

	runner.it("should preserve the position after an escaped newline", func():
		var number = ExdotTests.consume_token(tokens)

		runner.expect(number.type).toBeLiteral(ExdotToken.Type.INT)
		runner.expect(number.line).toBeLiteral(1)
		runner.expect(number.literal).toBeLiteral(123)
	, [count_test])
