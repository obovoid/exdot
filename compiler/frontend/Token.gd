@tool
class_name ExdotToken extends ExdotCompiler

enum Type {
	EOF,
	ERROR,
	IDENTIFIER,
	STRING,
	INT,
	FLOAT,
	
	VAR,
	READONLY,
	FUNC,
	HOIST,
	HOISTED,
	ON,
	IMPORT,
	FROM,
	TO,
	EXPORT,
	INTERFACE,
	TYPE,
	WITH,
	AS,
	MATCHES,
	MATCH,
	IF,
	ELSE,
	ELIF,
	FOR,
	WHILE,
	RETURN,
	AWAIT,
	TRUE,
	FALSE,
	NULL,
	LEFT_PAREN,
	RIGHT_PAREN,
	LEFT_BRACE,
	RIGHT_BRACE,
	LEFT_BRACKET,
	RIGHT_BRACKET,
	COLON,
	COLON_EQUAL,
	DOUBLE_COLON,
	COMMA,
	DOT,
	EQUAL,
	EQUAL_EQUAL,
	PLUS,
	MINUS,
	STAR,
	SLASH,
	BIGGER_THAN,
	SMALLER_THAN,
	QUESTION,
	PERCENT,
	DOUBLE_QUESTION,
	ARROW,
	INDENT,
	DEDENT,
	NEWLINE,
	TYPEOF,
	NODE,
	RESOURCE,
	SCENE,
	AUDIO,
	NEGATION,
	PASS,
	USING,
	IS
}

var type: Type
var lexeme: String
var literal: Variant
var line: int
var column: int

func ifget(token_variable: String, fallback: Variant) -> Variant:
	match token_variable:
		"type":
			return fallback if not type else type
		"lexeme":
			return fallback if not lexeme else lexeme
		"literal":
			return fallback if not literal else literal
		"line":
			return fallback if not line else line
		"column":
			return fallback if not column else column
		_:
			push_warning("ifget on Token was used with an invalid token_variable. Token does not specify '%s'" % token_variable)
			return fallback
