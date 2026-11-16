class_name ExdotTests extends RefCounted

static var TEST_BASE_DIR : String

const tests = {
	"plugin": [
		#"console_parser_test.gd"
	],
	"compiler": [
		"tokenizer_test.gd"
	]
}

static func consume_token(token_array: Array) -> Variant:
	return token_array.pop_front()

static func consume_newline_token(token_array: Array) -> Error:
	if token_array.is_empty():
		return ERR_DOES_NOT_EXIST
	
	var token = token_array[0]
	if token.type != ExdotToken.Type.NEWLINE:
		return ERR_INVALID_DATA
	
	token_array.pop_front()
	return OK

class TestResult:
	enum Status {
		PASSED,
		FAILED,
		SKIPPED
	}
	
	var description: String
	var status : Status = Status.SKIPPED
	var reason := ""
	
	func _init(test_description: String) -> void:
		description = test_description
	
	func passed() -> bool:
		return status == Status.PASSED
	
	func failed() -> bool:
		return status == Status.FAILED
	
	func skipped() -> bool:
		return status == Status.SKIPPED

static var runner : TestRunner

static func start(force := false) -> void:
	if not ExdotConsole.is_command_registered("run_test"):
		ExdotConsole.register_command("run_test", start_force, "Run a Plugin test. This will make various tests, ensuring that everything works as intended.")
	
	var run_tests = EXDOT.CONFIG.get_value(SAP.CONFIG_ACP.DEVEL, SAP.CONFIG_ACP.RUN_TESTS)
	if not run_tests and not force:
		return
	
	# little trick to get the absolute path that we need to run scripts from relative paths.
	var instance = ExdotTests.new()
	TEST_BASE_DIR = instance.get_script().get_path().get_base_dir()
	
	var test_start := Time.get_ticks_msec()
	
	runner = TestRunner.new()
	
	### self test
	runner.describe("Testrunner selftest", func():
		runner.it("should test if a value is true", func():
			runner.expect(true).toBeTrue()
		)
		
		runner.it("should test if a string is empty and negate the result", func():
			runner.expect_not("ABCDEF").toBeEmpty()
		)
		
		runner.it("should test if a value matches a literal exactly", func():
			runner.expect(64).toBeLiteral(64)
		)
		
		runner.it("should test if a value is a exact type and negate the result", func():
			runner.expect_not(128).toBeType(TYPE_STRING)
		)
		
		runner.it("should test if a value contains a Variant", func():
			runner.expect("counting").toContain("count")
		)
		
		runner.it("should detect failed assertions", func():
			var isolated := TestRunner.new()
			isolated.muted = true
			isolated.it("should intentionally fail", func():
				isolated.expect(false).toBeTrue()
			)
			
			runner.expect(isolated.tests).toBeLiteral(1)
			runner.expect(isolated.failed_tests).toBeLiteral(1)
			runner.expect(isolated.passed_tests).toBeLiteral(0)
		)

		runner.it("should support also descriptions", func():
			var isolated := TestRunner.new()
			isolated.muted = true

			isolated.it("parent test", func(also: Callable):
				isolated.expect(true).toBeTrue()

				also.call("should validate another condition")
				isolated.expect(42).toBeLiteral(42)
			)

			runner.expect(isolated.tests).toBeLiteral(1)
			runner.expect(isolated.passed_tests).toBeLiteral(1)
			runner.expect(isolated.assertions).toBeLiteral(2)

			runner.expect(isolated._results.is_empty()).toBeTrue()
		)
	)
	
	for folder in tests:
		var scripts = tests[folder]
		for script: String in scripts:
			var absolute_path = TEST_BASE_DIR + "/" + folder + "/" + script
			if script.get_extension() != "gd":
				continue
			var loaded_script = load(absolute_path) as Script
			
			if loaded_script == null:
				push_error(XERROR.TESTS.ERR_SCRIPT_LOAD % absolute_path)
				continue
			
			if not loaded_script.can_instantiate():
				push_error(XERROR.TESTS.ERR_SCRIPT_INSTANTIATION % absolute_path)
				continue
				
			if not loaded_script.is_tool():
				push_error(XERROR.TESTS.ERR_TEST_MUST_BE_A_TOOL_SCRIPT)
				continue
			
			var inst = loaded_script.new()
			if not inst.has_method("run_test"):
				push_error(XERROR.TESTS.MISSING_RUN_TEST_METHOD % absolute_path)
				continue

			inst.run_test(runner)

	var consumed_time = Time.get_ticks_msec() - test_start
	runner.summary(consumed_time)

static func start_force() -> void:
	return start(true)
