@tool
## XERROR is a library for error messages. [br]
## it is supposed to be used together with tests and also to avoid duplicate error messages.
class_name XERROR

const TESTS = {
	"INVALID_DESCRIBE_CALLBACK": "Invalid describe callback",
	"MISPLACED_OR_MISSING_ASSERTION": "Assertions must be inside it()",
	"ERR_SCRIPT_LOAD": "Unable to load test script: %s",
	"ERR_SCRIPT_INSTANTIATION": "Unable to instantiate test script: %s",
	"MISSING_RUN_TEST_METHOD": "Test script has no run_test() method: \"%s\" - are you sure that it is a test script?",
	"MISSING_RUN_SUB_TEST_METHOD": "Test script has no run_sub_test() method: \"%s\" - are you sure that it is a sub test script?",
	"ERR_ALSO_NOT_IN_TEST": "also() can only be used inside it()",
	"ERR_TEST_MUST_BE_A_TOOL_SCRIPT": "Testscript is not exposed as a tool. It must be marked as a tool to be able to run it inside the editor."
}

const CONSOLE = {
	"INVALID_COMMAND_NAME": "ExdotConsole: Invalid command name: '%s'",
	"INVALID_CALLBACK": "ExdotConsole: Invalid callback for: '%s'",
	"EMPTY_ARGUMENT_NAME": "ExdotConsole: Argument name cannot be empty.",
	"INVALID_ARGUMENT_NAME": "ExdotConsole: Invalid argument name '%s'.",
	"DUPLICATE_ARGUMENT": "ExdotConsole: Duplicate argument '%s'.",
	"ERR_UNSUPPORTED_TYPE": "ExdotConsole: Unsupported type for '%s'.",
	"ERR_MISSING_CHOICE": "ExdotConsole: 'either' requires 2 or more choices.",
	"ERR_INVALID_CHOICE": "ExdotConsole: Invalid choice in 'either'.",
	"ERR_UNNAMED_CHOICE": "ExdotConsole: 'either' choices must be named.",
	"INVALID_ARGUMENT_TYPE": "ExdotConsole: Arguments must be dictionaries.",
	"ERR_POSITIONAL_MISPLACED": "ExdotConsole: Positional arguments must come first.",
	"INVALID_ARGUMENT_LIMITS": "ExdotConsole: Invalid argument limits for command '%s'",
	"ERR_MIN_OVER_MAX": "ExdotConsole: Maximum cannot be smaller than minimum.",
	"ERR_MIN_OVER_ARGUMENTS": "ExdotConsole: Minimum exceeds the available arguments.",
	"UNKNOWN_COMMAND": "Unknown Command: %s. (Try 'help')",
	"UNKNOWN_ARGUMENT": "Unknown argument '--%s'.",
	"MISSING_ARGUMENT": "Missing argument: '%s'.",
	"MISSING_REQUIRED_ARGUMENT": "Missing required argument: %s",
	"CONFLICTING_ARGUMENTS": "Conflicting arguments. Usage: %s",
	"ERR_UNSELECTED_REQUIRED_ARGUMENT": "One argument from the group is required.",
	"INVALID_ARGUMENTS": "Invalid arguments. Usage: %s",
	"ERR_UNAVAILABLE_COMMAND": "Command '%s' is unavailable.",
	"ERR_MISSING_VALUE": "Missing value for --%s",
	"ERR_ARGUMENT_CONVERT_FAILED": "Argument --%s: %s",
	"ERR_TOO_MANY_POSITIONAL_ARGUMENTS": "Too many positional arguments.",
	"ERR_CONTRADICTORY_ARGUMENTS": "Arguments are mutually exclusive: %s",
	"ERR_REQUIRED_MUTUALLY_MISSING": "One of these arguments is required: %s" ## % " or ".join(options)
}

const INSPECTOR = {
	"UNKNOWN_RESOURCE_UID": "Unknown resource UID: ",
	"ERR_SCRIPT_LOAD": "Could not load Exdot script: "
}

const CONFIG = {
	"ERR_UNINITIALIZED": "reset failed. Config file was never initiated!",
	"ERR_TYPE_MISMATCH": "Type mismatch detected! Expected type integer '%s' for section '[%s]' and key '%s'. Type integer was changed to '%s' but must be type integer '%s'!",
	"ERR_SAVE_FAILED": "Saving new Configuration file failed! %s",
	"ERR_SET_FAILED": "Can't set '%s' as new value for '%s'.",
	"ERR_UNHANDLED_TYPE": "Unhandled Type: Can't handle expected type '%s'. It is not handled by this function."
}

const WORKSPACE = {
	"ERR_CREATE_FILE": "Failed to create workspace file.",
	"UNKNOWN_IDENTIFIER": "Unknown identifier: %s",
	"ERR_IDENTIFIER_TYPE_MISMATCH": "Identifier is not an Array: %s",
	"ERR_UNKNOWN_SECTION": "Unknown workspace section: %s",
	"ERR_FILESYSTEM_WRITE": "Failed to write workspace: %s",
}
