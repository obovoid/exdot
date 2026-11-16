@tool
class_name TestRunner extends RefCounted

var tests := 0
var passed_tests := 0
var failed_tests := 0
var skipped_tests := 0
var assertions := 0
var muted := false

var _description := ""
var _it := ""
var _current_failed := false
var _in_test := false
var _pending_also := ""
var _results: Array[Dictionary] = []

func describe(description: String, callback: Callable) -> void:
	if not callback.is_valid():
		push_error(XERROR.TESTS.INVALID_DESCRIBE_CALLBACK)
		return

	var previous_description := _description
	_description = description

	ExdotConsole.log("\n%s" % description)
	callback.call()
	_description = previous_description

func it(description: String, callback: Callable, dependencies : Array[ExdotTests.TestResult] = [], condition: Callable = Callable()) -> ExdotTests.TestResult:
	var test_result := ExdotTests.TestResult.new(description)
	tests += 1

	for dependency in dependencies:
		if not dependency.passed():
			test_result.status = ExdotTests.TestResult.Status.SKIPPED
			test_result.reason = "Dependency not passed: %s" % dependency.description
			
			skip(description, test_result.reason)
			return test_result

	if condition.is_valid() and not condition.call():
		test_result.status = ExdotTests.TestResult.Status.SKIPPED
		test_result.reason = "Custom condition not satisfied!"
		
		skip(description, test_result.reason)
		return test_result

	_it = description
	_current_failed = false
	_in_test = true
	_pending_also = ""
	_results.clear()

	var previous_assertions := assertions

	if not callback.is_valid():
		_check(false, "Invalid test callback")
	elif callback.get_argument_count() == 0:
		callback.call()
	elif callback.get_argument_count() == 1:
		callback.call(Callable(self, "_also"))
	else:
		_check(false, "Test callback accepts too many arguments")

	if _pending_also != "":
		_check(false, "also() has no following assertion")

	if assertions == previous_assertions:
		_check(false, "Test contains no assertions")

	if _current_failed:
		failed_tests += 1
	else:
		passed_tests += 1
	
	if not muted:
		var status := "FAIL" if _current_failed else "PASS"
		ExdotConsole.log("\t[%s] %s" % [status, _it])
		
		var children : Array[Dictionary] = []
		for result in _results:
			if result["also"] != "":
				children.append(result)
		
		for i in children.size():
			var result := children[i]
			var is_last := i == children.size() - 1
			var branch := "└─" if is_last else "├─"
			var symbol := "✓" if result["passed"] else "✗"
			
			ExdotConsole.log(
				"			%s %s %s" % [
					branch,
					symbol,
					result["also"]
				]
			)
			
			if not result["passed"]:
				var prefix := "\t\t\t\t\t 𝓲 " if is_last else "\t\t\t│\t\t𝓲 "
				var msg = "%s%s" % [prefix, result["message"]]
				ExdotConsole.log(
					msg
				)
				test_result.status = ExdotTests.TestResult.Status.FAILED
				test_result.reason = msg

	_in_test = false
	_it = ""
	_pending_also = ""
	_results.clear()
	
	if test_result.status != ExdotTests.TestResult.Status.FAILED:
		test_result.status = ExdotTests.TestResult.Status.PASSED if not _current_failed else ExdotTests.TestResult.Status.FAILED
	
	return test_result

func skip(description: String, reason: String) -> void:
	tests += 1
	skipped_tests += 1
	
	if not muted:
		ExdotConsole.log(
			"\t[SKIP] %s" % description
		)
		ExdotConsole.log(
			"\t\t\t\t\t 𝓲 %s" % reason
		)

func _also(description: String) -> void:
	if not _in_test:
		push_error(XERROR.TESTS.ERR_ALSO_NOT_IN_TEST)
		return
	
	_pending_also = description

func _check(condition: bool, message: String) -> bool:
	if not _in_test:
		push_error(XERROR.TESTS.MISPLACED_OR_MISSING_ASSERTION)
		return false

	assertions += 1

	if not condition:
		_current_failed = true

	_results.append({
		"passed": condition,
		"message": message,
		"also": _pending_also
	})
	
	_pending_also = ""
	return condition

func expect(actual: Variant) -> TestExpectation:
	return TestExpectation.new(actual, self, false)

func expect_not(actual: Variant) -> TestExpectation:
	return TestExpectation.new(actual, self, true)

func summary(consumed_time := -1.0) -> void:
	ExdotConsole.log("\n========== TEST RESULTS ==========")
	ExdotConsole.log("Tests:      %d" % tests)
	ExdotConsole.log("Passed:     %d" % passed_tests)
	ExdotConsole.log("Failed:     %d" % failed_tests)
	ExdotConsole.log("Skipped:    %d" % skipped_tests)
	ExdotConsole.log("Assertions: %d" % assertions)
	ExdotConsole.log("Consumed:   %dms" % consumed_time)
	ExdotConsole.log("==================================")

	if failed_tests == 0:
		ExdotConsole.log("All tests passed!")
	else:
		ExdotConsole.log("%d test(s) failed!" % failed_tests)

func reset() -> void:
	tests = 0
	passed_tests = 0
	failed_tests = 0
	skipped_tests = 0
	assertions = 0

	_description = ""
	_it = ""
	_current_failed = false
	_in_test = false
