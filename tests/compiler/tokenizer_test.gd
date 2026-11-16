@tool
extends RefCounted

const base_folder = "compiler"

var compiler : ExdotCompiler
var tokens : Array

func run_test(test: TestRunner) -> void:
	
	var sub_tests = [
		"tokenizer/empty_test.gd",
		"tokenizer/number.gd",
		"tokenizer/string.gd"
	]
	
	compiler = ExdotCompiler.new()
	
	for sub_path in sub_tests:
		var script := "%s/%s/%s" % [ExdotTests.TEST_BASE_DIR, base_folder, sub_path]
		test.describe("Tokenizing/Lexing Test for file \"%s\"" % script , func():
			var state := {
				"script": null,
				"instance": null
			}
			
			var extension_test = test.it("must be a .gd script", func():
				test.expect(sub_path.get_extension()).toBeLiteral("gd")
			)

			var type_test = test.it("must not be null", func():
				state["script"] = load(script) as Script
				test.expect_not(state["script"]).toBeType(TYPE_NIL)
			, [extension_test])
			
			var instantiate_test = test.it("can instantiate", func():
				test.expect(state["script"].can_instantiate()).toBeTrue()
			, [type_test])
			
			var tool_test = test.it("must be a tool", func():
				test.expect(state["script"].is_tool()).toBeTrue()
			, [instantiate_test])
			
			var method_test = test.it("must have a run_sub_test(...) method", func():
				state["instance"] = state["script"].new()
				test.expect(state["instance"].has_method("run_sub_test")).toBeTrue()
			, [tool_test])

			if method_test.passed():
				state["instance"].run_sub_test(test, compiler)
		)
