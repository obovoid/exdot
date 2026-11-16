@tool
extends RefCounted

var captured_positional: Array = []
var captured_named: Dictionary = {}
var zero_argument_calls := 0


func run_test(test: TestRunner) -> void:
	test.describe("Command Registration", func():

		var registered: bool = ExdotConsole.register_command(
			"parser_test",
			Callable(self, "_capture_arguments"),
			"Parser test command",
			[
				{
					"name": "item",
					"type": TYPE_STRING,
					"required": true
				},
				{
					"name": "count",
					"type": TYPE_INT,
					"named": true
				},
				{
					"name": "title",
					"type": TYPE_STRING,
					"named": true
				},
				{
					"either": [
						{
							"name": "skip",
							"type": TYPE_BOOL
						},
						{
							"name": "force",
							"type": TYPE_BOOL
						}
					]
				}
			]
		)

		test.it("should register the command", func():
			test.expect(registered).toBeTrue()
		)

		test.it("should parse positional arguments", func():
			var parsed := ExdotConsole.parse_arguments(
                "parser_test hello"
			)

			test.expect(parsed.error).toBeEmpty()
			test.expect(parsed.positional.size()).toBeLiteral(1)
			test.expect(parsed.positional).toContain("hello")
		)

		test.it("should parse named integer arguments", func():
			var parsed := ExdotConsole.parse_arguments(
                "parser_test hello --count 42"
			)

			test.expect(parsed.error).toBeEmpty()
			test.expect(parsed.named.get("count")).toBeLiteral(42)
			test.expect(parsed.named.get("count")).toBeType(TYPE_INT)
		)

		test.it("should parse boolean flags", func():
			var parsed := ExdotConsole.parse_arguments(
                "parser_test hello --skip"
			)

			test.expect(parsed.error).toBeEmpty()
			test.expect(parsed.named.get("skip")).toBeTrue()
		)

		test.it("should reject invalid integer arguments", func():
			var parsed := ExdotConsole.parse_arguments(
                "parser_test hello --count abc"
			)

			test.expect_not(parsed.error).toBeEmpty()
		)

		test.it("should generate correct command metadata", func():
			var info := ExdotConsole.get_command("parser_test")

			test.expect(info.get("min")).toBeLiteral(1)
			test.expect(info.get("max")).toBeLiteral(4)
		)
		
		test.it("should reject missing required arguments", func():
			var parsed := ExdotConsole.parse_arguments("parser_test")

			test.expect_not(parsed.error).toBeEmpty()
		)
		
		test.it("should reject conflicting flags", func():
			var parsed := ExdotConsole.parse_arguments(
		        "parser_test hello --skip --force"
			)

			test.expect_not(parsed.error).toBeEmpty()
		)
		
		test.it("should successfully unregister this command", func():
			ExdotConsole.unregister_command("parser_test")
			
			test.expect_not(ExdotConsole.is_command_registered("parser_test")).toBeTrue()
		)
	)

func _capture_arguments(positional: Array, named: Dictionary) -> void:
	captured_positional = positional
	captured_named = named

func _capture_positional(positional: Array) -> void:
	captured_positional = positional

func _capture_zero_arguments() -> void:
	zero_argument_calls += 1
