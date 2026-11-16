@tool
extends RefCounted

func run_sub_test(runner: TestRunner, compiler: ExdotCompiler) -> void:
	var tokens = compiler.generate_tokens_from_string("")
	
	runner.it("should not be any empty array", func():
		runner.expect(tokens.size()).toBeLiteral(1)
	)
	
	var token = tokens.get(0)
	runner.it("should not be nil/null token", func():
		runner.expect_not(token).toBeType(TYPE_NIL)
	)
	
	runner.it("should be an EOF Token", func():
		runner.expect(token.type).toBeLiteral(ExdotToken.Type.EOF)
	)
	
	runner.it("should have the correct lexeme", func():
		runner.expect(token.lexeme).toBeEmpty()
	)
	
	runner.it("should have the correct line number", func():
		runner.expect(token.line).toBeLiteral(1)
	)
	
	runner.it("should have the correct column number", func():
		runner.expect(token.column).toBeLiteral(1)
	)
	
	runner.it("should have nil/null as a literal value", func():
		runner.expect(token.literal).toBeType(TYPE_NIL)
	)
