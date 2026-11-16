@tool
extends RefCounted

func run_sub_test(runner: TestRunner, compiler: ExdotCompiler) -> void:
	# do not add indents to this test!!!
	var tokens = compiler.generate_tokens_from_string("""
123
123.45
0.5
1_000
1_000.25
0xFF
0xff
0xDEAD_BEEF
1e10
1E10
1e+10
1e-10
1.5e10
1.5e-3
# Invalid numbers
1e
1e+
0x
0xGG
1__000
123.45.67
""")
	
	var token = ExdotTests.consume_token(tokens)
	runner.it("should be a newline token", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.NEWLINE)
		also.call("should be on line 1")
		runner.expect(token.line).toBeLiteral(1)
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '123'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.INT)
		also.call("should be on line 2")
		runner.expect(token.line).toBeLiteral(2)
		also.call("should be literal 123")
		runner.expect(token.literal).toBeLiteral(123)
		also.call("should be lexeme \"123\"")
		runner.expect(token.lexeme).toBeLiteral("123")
	)
	
	# one more newline check. After this one we will skip future newlines and expect them to be there.
	token = ExdotTests.consume_token(tokens)
	runner.it("should be a newline token", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.NEWLINE)
		also.call("should be on line 2")
		runner.expect(token.line).toBeLiteral(2)
	)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '123.45'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 3")
		runner.expect(token.line).toBeLiteral(3)
		also.call("should be literal 123.45")
		runner.expect(token.literal).toBeLiteral(123.45)
		also.call("should be lexeme \"123.45\"")
		runner.expect(token.lexeme).toBeLiteral("123.45")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '0.5'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 4")
		runner.expect(token.line).toBeLiteral(4)
		also.call("should be literal 0.5")
		runner.expect(token.literal).toBeLiteral(0.5)
		also.call("should be lexeme \"0.5\"")
		runner.expect(token.lexeme).toBeLiteral("0.5")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '1000'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.INT)
		also.call("should be on line 5")
		runner.expect(token.line).toBeLiteral(5)
		also.call("should be literal 1000")
		runner.expect(token.literal).toBeLiteral(1000)
		also.call("should be lexeme \"1_000\"")
		runner.expect(token.lexeme).toBeLiteral("1_000")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '1000.25'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 6")
		runner.expect(token.line).toBeLiteral(6)
		also.call("should be literal 1000.25")
		runner.expect(token.literal).toBeLiteral(1000.25)
		also.call("should be lexeme \"1_0000.25\"")
		runner.expect(token.lexeme).toBeLiteral("1_000.25")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '255'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.INT)
		also.call("should be on line 7")
		runner.expect(token.line).toBeLiteral(7)
		also.call("should be literal 255")
		runner.expect(token.literal).toBeLiteral(255)
		also.call("should be lexeme \"0xFF\"")
		runner.expect(token.lexeme).toBeLiteral("0xFF")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '255'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.INT)
		also.call("should be on line 8")
		runner.expect(token.line).toBeLiteral(8)
		also.call("should be literal 255")
		runner.expect(token.literal).toBeLiteral(255)
		also.call("should be lexeme \"0xff\"")
		runner.expect(token.lexeme).toBeLiteral("0xff")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the number '3735928559'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.INT)
		also.call("should be on line 9")
		runner.expect(token.line).toBeLiteral(9)
		also.call("should be literal 3735928559")
		runner.expect(token.literal).toBeLiteral(3735928559)
		also.call("should be lexeme \"0xDEAD_BEEF\"")
		runner.expect(token.lexeme).toBeLiteral("0xDEAD_BEEF")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '10000000000.0'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 10")
		runner.expect(token.line).toBeLiteral(10)
		also.call("should be literal 10000000000.0")
		runner.expect(token.literal).toBeLiteral(10000000000.0)
		also.call("should be lexeme \"1e10\"")
		runner.expect(token.lexeme).toBeLiteral("1e10")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '10000000000.0'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 11")
		runner.expect(token.line).toBeLiteral(11)
		also.call("should be literal 10000000000.0")
		runner.expect(token.literal).toBeLiteral(10000000000.0)
		also.call("should be lexeme \"1E10\"")
		runner.expect(token.lexeme).toBeLiteral("1E10")
	)
	
	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '10000000000.0'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 12")
		runner.expect(token.line).toBeLiteral(12)
		also.call("should be literal 10000000000.0")
		runner.expect(token.literal).toBeLiteral(10000000000.0)
		also.call("should be lexeme \"1e+10\"")
		runner.expect(token.lexeme).toBeLiteral("1e+10")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '0.0000000001'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 13")
		runner.expect(token.line).toBeLiteral(13)
		also.call("should be literal 0.0000000001")
		runner.expect(token.literal).toBeLiteral(0.0000000001)
		also.call("should be lexeme \"1e-10\"")
		runner.expect(token.lexeme).toBeLiteral("1e-10")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '15000000000.0'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 14")
		runner.expect(token.line).toBeLiteral(14)
		also.call("should be literal 15000000000.0")
		runner.expect(token.literal).toBeLiteral(15000000000.0)
		also.call("should be lexeme \"1.5e10\"")
		runner.expect(token.lexeme).toBeLiteral("1.5e10")
	)

	ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should be the float '0.0015'", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.FLOAT)
		also.call("should be on line 15")
		runner.expect(token.line).toBeLiteral(15)
		also.call("should be literal 0.0015")
		runner.expect(token.literal).toBeLiteral(0.0015)
		also.call("should be lexeme \"1.5e-3\"")
		runner.expect(token.lexeme).toBeLiteral("1.5e-3")
	)

	ExdotTests.consume_newline_token(tokens)
	
	# From here on we will not check if the line is correct anymore.
	token = ExdotTests.consume_token(tokens)
	runner.it("comment should make a newline", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.NEWLINE)
	)

	ExdotTests.consume_newline_token(tokens)
	
	# Testing invalid numbers
	var error_string = "Invalid number \"%s\""
	for i in range(6):
		token = ExdotTests.consume_token(tokens)
		
		runner.it("should generate an error token", func(also: Callable):
			runner.expect(token.type).toBeLiteral(ExdotToken.Type.ERROR)
			also.call("should have a specific lexeme. \"tokenized lexeme\":\"%s\"" % token.ifget("lexeme", "<null>"))
			runner.expect_not(token.lexeme).toBeEmpty()
			also.call("should have a specific error message")
			runner.expect(token.literal).toBeLiteral(error_string % token.ifget("lexeme", "<null>"))
		)
		
		ExdotTests.consume_newline_token(tokens)
	
	token = ExdotTests.consume_token(tokens)
	runner.it("should create an EOF token", func(also: Callable):
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
		also.call("should not have an tokens left.")
		runner.expect(tokens).toBeEmpty()
	)
