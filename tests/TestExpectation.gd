@tool
class_name TestExpectation extends RefCounted

var actual: Variant
var message := ""
var negated: bool
var runner: TestRunner

var _passed := false
var _message := ""

func _init(value: Variant, test_runner: TestRunner, negate := false) -> void:
	actual = value
	runner = test_runner
	negated = negate
	
func _evaluate(condition: bool, message: String) -> TestExpectation:
	_passed = not condition if negated else condition
	_message = message
	
	runner._check(_passed, _message)
	return self

func toBeTrue() -> TestExpectation:
	return _evaluate(
		actual == true,
		"Expected %s to %sbe true" % [
			str(actual),
			"not " if negated else "",
		]
	)

func toBeLiteral(expected: Variant) -> TestExpectation:
	var valid = typeof(actual) == typeof(expected)
	return _evaluate(
		valid and actual == expected,
		"Expected %s to %sbe %s" % [
			str(actual),
			"not " if negated else "",
			str(expected)
		]
	)

func toBeType(expected: Variant) -> TestExpectation:
	var valid = expected is Variant.Type
	return _evaluate(
		valid and typeof(actual) == expected,
		"Expected %s to %sbe of type %s" % [
			str(actual),
			"not " if negated else "",
			str(type_string(expected) if valid else "Invalid Type provided for this test.")
		]
	)

func toBeEmpty() -> TestExpectation:
	var valid := actual is String or actual is Array or actual is Dictionary
	var empty : bool = valid and actual.is_empty()
	
	return _evaluate(
		empty,
		"Expected value to %sbe empty" % [
			"not " if negated else ""
		]
	)

func toContain(expected: Variant) -> TestExpectation:
	var valid := (actual is String and expected is String) or actual is Array
	
	return _evaluate(
		valid and expected in actual,
		"Expected %s to %sbe in %s" % [
			str(expected),
			"not " if negated else "",
			str(actual)
		]
	)
