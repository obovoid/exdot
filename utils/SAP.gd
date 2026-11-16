@tool
class_name SAP
extends RefCounted

## SAP stands for Static Access Point. Instead of throwing strings everywhere we gather strings that repeat alot here.
## That way if something changes we only need to change it here.

const CONSOLE_COMMANDS_CHANGED = "console_commands_changed"
const ADD_MESSAGE = "add_message"
const CLEAR_CONSOLE = "clear_console"
const EXECUTE_COMMAND = "execute_command"
const PATH_TO_UUID = "path_to_uuid"

static var CONFIG_ACP: Dictionary = {
	# Sections
	COMPILER = "compiler",
	DEFAULT = "default",
	DEVEL = "devel",
	
	# Keys
	SOURCE_DIR = "source_dir",
	OUTPUT_DIR = "output_dir",
	COMPILE_ON_SAVE = "compile_on_save",
	EXDOT_CRASHED = "exdot_crashed",
	HOME_DIR = "home_dir",
	RUN_TESTS = "run_tests",
	CONSOLE_OUTPUT_TARGET = "console_output_target"
}

const KEYWORDS := {
	"using": ExdotToken.Type.USING,
	"var": ExdotToken.Type.VAR,
	"readonly": ExdotToken.Type.READONLY,
	"func": ExdotToken.Type.FUNC,
	"hoist": ExdotToken.Type.HOIST,
	"hoisted": ExdotToken.Type.HOISTED,
	"on": ExdotToken.Type.ON,
	"import": ExdotToken.Type.IMPORT,
	"from": ExdotToken.Type.FROM,
	"to": ExdotToken.Type.TO,
	"export": ExdotToken.Type.EXPORT,
	"interface": ExdotToken.Type.INTERFACE,
	"type": ExdotToken.Type.TYPE,
	"typeof": ExdotToken.Type.TYPEOF,
	"with": ExdotToken.Type.WITH,
	"as": ExdotToken.Type.AS,
	"matches": ExdotToken.Type.MATCHES,
	"match": ExdotToken.Type.MATCH,
	"if": ExdotToken.Type.IF,
	"else": ExdotToken.Type.ELSE,
	"elif": ExdotToken.Type.ELIF,
	"for": ExdotToken.Type.FOR,
	"while": ExdotToken.Type.WHILE,
	"return": ExdotToken.Type.RETURN,
	"await": ExdotToken.Type.AWAIT,
	"true": ExdotToken.Type.TRUE,
	"false": ExdotToken.Type.FALSE,
	"null": ExdotToken.Type.NULL,
	"node": ExdotToken.Type.NODE,
	"resource": ExdotToken.Type.RESOURCE,
	"scene": ExdotToken.Type.SCENE,
	"audio": ExdotToken.Type.AUDIO,
	"pass": ExdotToken.Type.PASS,
	"is": ExdotToken.Type.IS
}

# Put longest Operators first
const OPERATORS := [
	":=",
	"-=",
	"+=",
	"*=",
	"/=",
	"==",
	"!=",
	">=",
	"<=",
	"->",
	"=",
	":",
	"*",
	"+",
	"-",
	"!",
	"|",
	"&",
	"%"
]

const CONTROL_FLOW_KEYWORDS := [
	"if",
	"elif",
	"else",
	"for",
	"while",
	"match",
	"matches",
	"return",
	"await",
	"readonly",
	"to",
	"with",
	"pass",
]

const BUILTIN_FUNCTIONS := [
	"print",
	"len",
	"range",
	"str",
	"min",
	"max",
]

const BUILTIN_TYPES := [
	"Int",
	"Float",
	"Bool",
	"String",
	"Variant",
	"Void",
	"Vector2",
	"Vector3",
	"CharacterBody3D"
]

const COLORS := {
	"KEYWORD" = Color(1.0, 0.485, 0.609, 1.0),
	"FLOWKEYWORD" = Color(0.95, 0.6, 0.95),
	"STRING" = Color(0.9, 0.8, 0.45),
	"COMMENT" = Color(0.55, 0.55, 0.55),
	"FUNCTION" = Color(0.70, 0.3, 1.0),
	"TYPE" = Color(0.0, 0.793, 0.0, 1.0),
	"NUMBER" = Color(0.7, 1.0, 0.8, 1.0),
	"BINDING_NODE" = Color(0.357, 0.554, 0.993, 1.0),
	"OPERATOR" = Color(0.5, 0.8, 1.0),
	"INVALID" = Color(1.0, 0.4, 0.3, 1.0),
	"DEFAULT" = Color.WHITE
}
