class_name Convert
extends RefCounted

static func with_type(value: String, type: Variant.Type) -> String:
	match type_string(type):
		"String":
			return as_string(value)
		"int", "float":
			return as_number(value)
		"bool":
			return as_bool(value)
		"nil":
			return as_nil(value)
	
	push_error("Unhandled type conversion '%s'. Warning treated as error." % type_string(type))
	return value

static func _strip_string(value: String) -> String:
	if value.begins_with("\"") or value.begins_with("'"):
		value = value.substr(1)
	if value.ends_with("\"") or value.ends_with("'"):
		value = value.substr(value.length(), -1)
	return value

static func as_string(value: String) -> String:
	return '"%s"' % _strip_string(value)

static func as_string_raw(value: String) -> String:
	return _strip_string(value)

static func as_number(value: String) -> String:
	return _strip_string(value)

static func as_bool(value: String) -> String:
	var first_value = value
	value = _strip_string(value)
	if value != "true" and value != "false":
		push_error("Invalid conversion. Cannot convert '%s' to false or true. Returning false as default. Warning treated as error." % first_value)
		return "false"
	return value

static func as_nil(value: String) -> String:
	return "null" 
