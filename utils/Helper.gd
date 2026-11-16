class_name Helper extends RefCounted

#region Compilerfunctions
# WARNING: In use by the tokenizer. Changes to this function may break the tokenizer.
## takes one digit as String [br]
## Accepts: [0-9] [br]
## returns if the digit matches one of the accepted digits ##
static func is_digit(c: String) -> bool:
	if c.is_empty():
		return false
	
	var n := c.unicode_at(0)
	return n >= 48 and n <= 57 # 0-9

# WARNING: In use by the tokenizer. Changes to this function may break the tokenizer.
## takes one char as String [br]
## Accepts: [A-Z] [a-z] [_$] [br]
## returns if the char matches one of the accepted chars in the list.
static func is_alpha(c: String) -> bool:
	if c.is_empty():
		return false
	
	var n := c.unicode_at(0)
	return (
		n >= 65 and n <= 90 or # A-Z
		n >= 97 and n <= 122 or # a-z
		n == 95 or n == 36 # _ or $
	)

# WARNING: In use by the tokenizer. Changes to this function may break the tokenizer.
## takes one digit or char as string [br]
## Accepts: [A-Z] [a-z] [_$] [0-9]
## returns if the char or digit matches one of the accepted values.
static func is_alpha_numeric(c: String) -> bool:
	if c.is_empty():
		return false
	return is_alpha(c) or is_digit(c)

# WARNING: In use by the tokenizer. Changes to this function may break the tokenizer.
## takes one digit or char as string [br]
## Accepts: [A-F] [a-f] [0-9]
## returns if the char or digit matches one of the accepted values.
static func is_hexadecimal_char(c: String) -> bool:
	if c.is_empty():
		return false
	
	var n := c.unicode_at(0)
	return (
		n >= 65 and n <= 70 or # A-F
		n >= 97 and n <= 102 or #  a-f
		is_digit(c)
	)
#endregion
