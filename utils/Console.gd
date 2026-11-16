@tool
class_name ExdotConsole
extends RefCounted

## Public API: ExdotConsole.register_command(), unregister_command(), execute(),
## write(), error(), clear(), help(), get_commands(), get_command().
## Positional-only callbacks receive one Array[String] with their arguments.
## Callbacks for commands with named_arguments receive positional and named arguments separately.
## minimum = -1 and maximum = -2 infer limits from argument labels; maximum = -1 means unlimited.

static var _commands := {}
static var _listener = null
static var _ready := false
static var _initialized := false

static func log(...variants: Array[Variant]) -> void:
	var target : String = EXDOT.CONFIG.get_value(SAP.CONFIG_ACP.DEVEL, SAP.CONFIG_ACP.CONSOLE_OUTPUT_TARGET)
	if target == "godot":
		for s in variants:
			print(s)
	elif target == "exdot":
		echo(variants)

static func _cmd_static_guards_passed(name: String, callback: Callable) -> bool:
	if name.is_empty() or name.contains(" ") or name.contains("\t"):
		push_error(XERROR.CONSOLE.INVALID_COMMAND_NAME % name)
		return false
	
	if not callback.is_valid():
		push_error(XERROR.CONSOLE.INVALID_CALLBACK % name)
		return false
	
	if _commands.has(name):
		push_warning(XERROR.CONSOLE.INVALID_CALLBACK % name)
		return false
	
	return true

static func _validate_argument(argument: Dictionary, used_names: Array[String]) -> bool:
	var name := str(argument.get("name", ""))
	
	if name.is_empty():
		push_error(XERROR.CONSOLE.EMPTY_ARGUMENT_NAME)
		return false

	if (name.contains(" ") or name.contains("\t") or name.contains("=") or name.begins_with("-")):
		push_error(XERROR.CONSOLE.INVALID_ARGUMENT_NAME % name)
		return false

	if used_names.has(name):
		push_error(XERROR.CONSOLE.DUPLICATE_ARGUMENT % name)
		return false

	var type: int = argument.get("type", TYPE_STRING)

	if type not in [
		TYPE_STRING,
		TYPE_INT,
		TYPE_FLOAT,
		TYPE_BOOL,
	]:
		push_error(XERROR.CONSOLE.ERR_UNSUPPORTED_TYPE % name)
		return false

	used_names.append(name)
	return true

static func _valid_argument(value: Variant) -> Dictionary:
	return {
		"valid": true,
		"value": value
	}

static func _get_argument_schema(command: Dictionary) -> Dictionary:
	var positional : Array[Dictionary] = []
	var named : Dictionary = {}
	var groups : Array[Dictionary] = []
	
	for entry in command.get("args", []):
		if entry.has("either"):
			groups.append(entry)
			
			for choice in entry["either"]:
				named[choice["name"]] = choice
		elif entry.get("named", false):
			named[entry["name"]] = entry
		else:
			positional.append(entry)
	
	return {
		"positional": positional,
		"named": named,
		"groups": groups
	}

static func _register_command_group_either(group: Dictionary, used_names: Array[String], auto_min: int, auto_max: int) -> Variant:
	var choices: Array = group["either"]
	if choices.size() < 2:
		push_error(XERROR.CONSOLE.ERR_MISSING_CHOICE)
		return false
	
	for choice in choices:
		if not choice is Dictionary:
			push_error(XERROR.CONSOLE.ERR_INVALID_CHOICE)
			return false
		
		if not choice.get("named", true):
			push_error(XERROR.CONSOLE.ERR_UNNAMED_CHOICE)
			return false
		
		choice["named"] = true
		if not _validate_argument(choice, used_names):
			return false
	
	if group.get("required", false):
		auto_min += 1
	
	auto_max += 1
	
	return {
		"auto_min": auto_min,
		"auto_max": auto_max
	}

static func register_command(name: String, callback: Callable, description: String = "", arguments : Array = [], minimum: int = -1, maximum : int = -2) -> bool:
	# skipping invalid cmd names
	name = name.strip_edges().to_lower()
	if not _cmd_static_guards_passed(name, callback):
		return false
	
	var normalized : Array[Dictionary] = []
	var used_names : Array[String] = []
	var auto_min := 0
	var auto_max := 0
	var positional_optional := false
	
	for entry in arguments:
		if not entry is Dictionary:
			push_error(XERROR.CONSOLE.INVALID_ARGUMENT_TYPE)
			return false
		
		var group : Dictionary = entry.duplicate(true)
		
		if group.has("either"):
			var values = _register_command_group_either(group, used_names, auto_min, auto_max)
			if not values:
				# Errors already pushed in subfunction
				return false
				
			auto_min = values.auto_min
			auto_max = values.auto_max
		else:
			if not _validate_argument(group, used_names):
				return false
			
			var required : bool = group.get("required", false)
			var named : bool = group.get("named", false)
			
			if not named:
				if required and positional_optional:
					push_error(XERROR.CONSOLE.ERR_POSITIONAL_MISPLACED)
					return false
				
				if not required:
					positional_optional = true
			
			if required:
				auto_min += 1
			
			auto_max += 1
		
		normalized.append(group)
	
	var min_count := auto_min if minimum == -1 else minimum
	var max_count := auto_max if maximum == -2 else maximum
	if min_count < 0 or max_count < -1:
		push_error(XERROR.CONSOLE.INVALID_ARGUMENT_LIMITS % name)
		return false
	
	if max_count >= 0 and max_count < min_count:
		push_error(XERROR.CONSOLE.ERR_MIN_OVER_MAX)
		return false
	
	if min_count > auto_max:
		push_error(XERROR.CONSOLE.ERR_MIN_OVER_ARGUMENTS)
		return false
	
	_commands[name] = {
		"callback": callback,
		"description": description,
		"args": normalized,
		"min": min_count,
		"max": max_count
	}
	
	if _ready:
		EXDOT.send_event(SAP.CONSOLE_COMMANDS_CHANGED)
	
	return true

static func unregister_command(name: String) -> void:
	name = name.to_lower()
	if not _commands.has(name):
		push_warning("ExdotConsole: Failed to unregister command '%s'. That command does not exist." % name)
		return
	_commands.erase(name)
	if _ready:
		EXDOT.send_event(SAP.CONSOLE_COMMANDS_CHANGED)

static func get_commands() -> Dictionary:
	return _commands.duplicate(true)

static func get_command(name: String) -> Dictionary:
	return _commands.get(name.to_lower(), {}).duplicate(true)

static func usage(name: String) -> String:
	name = name.to_lower()
	var command := _commands.get(name, {})
	if command.is_empty():
		return name

	for entry in command.get("args", []):
		var required: bool = entry.get("required", false)
		var label := ""

		if entry.has("either"):
			var options: Array[String] = []

			for choice in entry["either"]:
				var option := "--" + str(choice["name"])

				if choice.get("type", TYPE_STRING) != TYPE_BOOL:
					option += ": " + type_string(choice.get("type", TYPE_STRING))

				options.append(option)

			label = " | ".join(options)

		else:
			label = str(entry["name"])

			if entry.get("named", false):
				label = "--" + label

			var type: int = entry.get("type", TYPE_STRING)

			if type != TYPE_BOOL or not entry.get("named", false):
				label += ": " + type_string(type)

		if required:
			name += " <%s>" % label
		else:
			name += " [%s?]" % label

	if command.get("max", 0) == -1:
		name += " [...]"

	return name

static func execute(input: String) -> void:
	var parsed := parse_arguments(input)
	if not str(parsed.get("error", "")).is_empty():
		error(str(parsed.error))
		return
	var name: String = parsed.command
	if name.is_empty():
		return
	execute_command(name, parsed.positional, parsed.named)

static func execute_command(name: String, args: Array, named_args: Dictionary = {}) -> void:
	name = name.to_lower()
	if not _commands.has(name):
		error(XERROR.CONSOLE.UNKNOWN_COMMAND % name)
		return
	
	var info := _commands.get(name, {})
	var schema := _get_argument_schema(info)
	
	var positional : Array = schema.positional
	var named : Dictionary = schema.named
	var groups : Array = schema.groups
	
	for argument_name in named_args:
		if not named.has(argument_name):
			error(XERROR.CONSOLE.UNKNOWN_ARGUMENT % argument_name)
			return
	
	for argument_name in named:
		var definition : Dictionary = named[argument_name]
		
		if definition.get("required", false):
			if not named_args.has(argument_name):
				error(XERROR.CONSOLE.MISSING_ARGUMENT % definition["name"])
				return
	
	for group in groups:
		var selected := 0
		
		for choice in group["either"]:
			if named_args.has(choice["name"]):
				selected += 1
		
		if selected > 1:
			error(XERROR.CONSOLE.CONFLICTING_ARGUMENTS % usage(name))
			return
		
		if group.get("required", false) and selected == 0:
			error(XERROR.CONSOLE.ERR_UNSELECTED_REQUIRED_ARGUMENT)
			return
		
	var count := args.size()
	for argument_name in named_args: # BUG: Counting might be wrong. if positional argument is needed an optional named argument could fulfill the count without meeting the requirements
		var inside_group := false
		
		for group in groups:
			for choice in group["either"]:
				if choice["name"] == argument_name:
					inside_group = true
					break
			
			if inside_group:
				break
		
		if not inside_group:
			count += 1
	
	for group in groups:
		for choice in group["either"]:
			if named_args.has(choice["name"]):
				count += 1
				break
	
	var minimum : int = info["min"]
	var maximum : int = info["max"]
	
	if count < minimum or (maximum >= 0 and count > maximum):
		error(XERROR.CONSOLE.INVALID_ARGUMENTS % usage(name))
		return
	var callback : Callable = info["callback"]
	if not callback.is_valid():
		error(XERROR.CONSOLE.ERR_UNAVAILABLE_COMMAND % name)
		return
	
	if args.is_empty() and positional.is_empty():
		callback.call()
	elif not named.is_empty():
		callback.call(args, named_args)
	elif not positional.is_empty():
		callback.call(args)
	else:
		callback.call(args)

## Splits command text on unquoted whitespace and removes surrounding quotes.
static func _tokenize(input: String) -> Dictionary:
	var tokens: Array[String] = []
	var token := ""
	var quote := ""
	var token_started := false
	var escaped := false
	for index in range(input.length()):
		var character := input.substr(index, 1)
		if escaped:
			token += character
			escaped = false
			continue
		if not quote.is_empty() and character == "\\" and index + 1 < input.length():
			var next_character := input.substr(index + 1, 1)
			if next_character == quote or next_character == "\\":
				escaped = true
				token_started = true
				continue
		if quote.is_empty() and (character == "\"" or character == "'"):
			quote = character
			token_started = true
		elif not quote.is_empty() and character == quote:
			quote = ""
		elif quote.is_empty() and character.strip_edges().is_empty():
			if token_started:
				tokens.append(token)
				token = ""
				token_started = false
		else:
			token += character
			token_started = true
	if token_started:
		tokens.append(token)
	var parse_error := ""
	if not quote.is_empty():
		parse_error = "Unclosed %s quote." % quote
	return {"tokens": tokens, "error": parse_error}

static func _convert_argument_value(value: String, type: int) -> Dictionary:
	match type:
		TYPE_INT:
			if not value.is_valid_int():
				return {"error": "Expected integer, got '%s'." % value}

			return {"value": int(value), "error": ""}

		TYPE_FLOAT:
			if not value.is_valid_float():
				return {"error": "Expected float, got '%s'." % value}

			return {"value": float(value), "error": ""}

		TYPE_BOOL:
			match value.to_lower():
				"true", "1":
					return {"value": true, "error": ""}
				"false", "0":
					return {"value": false, "error": ""}
				_:
					return {"error": "Expected boolean, got '%s'." % value}

		TYPE_STRING, TYPE_NIL:
			return {"value": value, "error": ""}

		_:
			return {"error": "Unsupported argument type: %s" % type}



## Returns a command and its positional and named arguments.
static func parse_arguments(input: String) -> Dictionary:
	var tokenized := _tokenize(input)
	var parsed := {
		"command": "",
		"positional": [],
		"named": {},
		"has_arguments": false,
		"error": tokenized.error,
	}

	var tokens: Array = tokenized.tokens
	if tokens.is_empty():
		return parsed

	parsed.command = str(tokens.pop_front()).to_lower()
	parsed.has_arguments = not tokens.is_empty()

	if not parsed.error.is_empty():
		return parsed

	if not _commands.has(parsed.command):
		parsed.error = XERROR.CONSOLE.UNKNOWN_COMMAND % parsed.command
		return parsed

	var schema := _get_argument_schema(_commands[parsed.command])

	var positional_definitions: Array = schema.positional
	var named_definitions: Dictionary = schema.named
	var grouped_definitions: Array = schema.groups

	var named_started := false
	var index := 0

	while index < tokens.size():
		var token: String = str(tokens[index])

		if token.begins_with("--"):
			named_started = true

			var argument := token.substr(2)
			var value := ""
			var has_value := false

			# Supports --name=value
			if argument.contains("="):
				var separator := argument.find("=")
				value = argument.substr(separator + 1)
				argument = argument.substr(0, separator)
				has_value = true

			if not named_definitions.has(argument):
				parsed.error = XERROR.CONSOLE.UNKNOWN_ARGUMENT % argument
				return parsed

			if parsed.named.has(argument):
				parsed.error = XERROR.CONSOLE.DUPLICATE_ARGUMENT % argument
				return parsed

			var definition: Dictionary = named_definitions[argument]
			var type: int = definition.get("type", TYPE_STRING)

			# Boolean arguments can be used as flags.
			if type == TYPE_BOOL and not has_value:
				value = "true"
				has_value = true

				# Optionally consume an explicit boolean value.
				if index + 1 < tokens.size():
					var next: String = str(tokens[index + 1])

					if next.to_lower() in ["true", "false", "1", "0"]:
						value = next
						index += 1

			elif not has_value:
				if index + 1 < tokens.size():
					var next: String = str(tokens[index + 1])

					if not next.begins_with("--"):
						value = next
						has_value = true
						index += 1

			if not has_value:
				parsed.error = XERROR.CONSOLE.ERR_MISSING_VALUE % argument
				return parsed

			var converted := _convert_argument_value(value, type)

			if not converted.error.is_empty():
				parsed.error = XERROR.CONSOLE.ERR_ARGUMENT_CONVERT_FAILED % [
					argument, converted.error
				]
				return parsed

			parsed.named[argument] = converted.value

		else:
			if named_started:
				parsed.error = XERROR.CONSOLE.ERR_POSITIONAL_MISPLACED
				return parsed

			var position: int = parsed.positional.size()

			if position >= positional_definitions.size():
				parsed.error = XERROR.CONSOLE.TOO_MANY_POSITIONAL_ARGUMENTS
				return parsed

			var definition: Dictionary = positional_definitions[position]
			var type: int = definition.get("type", TYPE_STRING)

			var converted := _convert_argument_value(token, type)

			if not converted.error.is_empty():
				parsed.error = XERROR.CONSOLE.ERR_ARGUMENT_CONVERT_FAILED % [
					definition.name, converted.error
				]
				return parsed

			parsed.positional.append(converted.value)

		index += 1

	# Validate required positional arguments.
	for i in positional_definitions.size():
		var definition: Dictionary = positional_definitions[i]

		if definition.get("required", false) and i >= parsed.positional.size():
			parsed.error = XERROR.CONSOLE.MISSING_REQUIRED_ARGUMENT % definition.name
			return parsed

	# Validate either groups.
	var grouped_names: Dictionary = {}

	for group in grouped_definitions:
		var selected: Array[String] = []
		var options: Array[String] = []

		for choice in group["either"]:
			var argument: String = choice.name
			grouped_names[argument] = true
			options.append("--" + argument)

			if parsed.named.has(argument):
				selected.append(argument)

		if selected.size() > 1:
			parsed.error = XERROR.CONSOLE.ERR_CONTRADICTORY_ARGUMENTS % ", ".join(selected)
			return parsed

		if group.get("required", false) and selected.is_empty():
			parsed.error = XERROR.CONSOLE.ERR_REQUIRED_MUTUALLY_MISSING % " or ".join(options)
			return parsed

	# Validate required named arguments outside either groups.
	for argument in named_definitions:
		if grouped_names.has(argument):
			continue

		var definition: Dictionary = named_definitions[argument]

		if definition.get("required", false) and not parsed.named.has(argument):
			parsed.error = XERROR.CONSOLE.MISSING_REQUIRED_ARGUMENT % argument
			return parsed

	return parsed


static func write(message: String, command: String = "") -> void:
	var stamp := "[color=dim_gray]%s[/color]" % Time.get_time_string_from_system()
	var prefix := " [color=#aaaaaa]%s:[/color]" % command if not command.is_empty() else ""
	EXDOT.send_event(SAP.ADD_MESSAGE, "%s%s %s" % [stamp, prefix, message])

static func _escape_bbcode(value: String) -> String:
	return value.replace("[", "[lb]")

static func error(message: String) -> void:
	write("[color=red]ERROR: %s[/color]" % _escape_bbcode(message))

static func warning(message: String) -> void:
	write("[color=yellow]WARNING: %s[/color]" % _escape_bbcode(message))

static func clear() -> void:
	EXDOT.send_event(SAP.CLEAR_CONSOLE)

static func help() -> void:
	var names := _commands.keys()
	names.sort()
	write("[color=gold]Available commands:[/color]", "help")
	for name in names:
		var description: String = _commands[name].get("description", "")
		write(" [color=light_blue]%s[/color] - %s" % [_escape_bbcode(usage(name)), _escape_bbcode(description)], "help")

static func echo(args: Array) -> void:
	var text := PackedStringArray()
	for argument in args:
		text.append(str(argument))
	write(_escape_bbcode(" ".join(text)), "echo")

static func _on_command_execute(name: String, args: Array) -> void:
	execute_command(name, args)

static func _register_defaults() -> void:
	if not _commands.has("echo"):
		register_command("echo", echo, "Print text to the console", [{
			"name": "text",
			"type": TYPE_STRING
		}], 0, -1)
	if not _commands.has("help"):
		register_command("help", help, "List all commands and their arguments")
	if not _commands.has("clear"):
		register_command("clear", clear, "Clear the console output")
	if not _commands.has("findstr"):
		register_command("findstr", find_string, "Finds a provided String in a provided File or Directory Path.", [
			{
				"name": "Path",
				"type": TYPE_STRING,
				"required": true
			},
			{
				"name": "Query",
				"type": TYPE_STRING,
				"required": true
			},
			{
				"name": "Include_Hidden",
				"type": TYPE_BOOL,
				"required": false
			}
		])

## returns one or multiple paths as a PackedStringArray. Returns an Empty PackedStringArray([]) if the operation fails. Errors will be sent into the EXDOT Console.
static func _prefix_path(prefix: String, packed_string: PackedStringArray, optional_delimiter := "") -> PackedStringArray:
	if not prefix is String or not packed_string is PackedStringArray:
		ExdotConsole.error("Wrong usage of _prefix_path(). One or more argument types are wrong.")
		return PackedStringArray([])
	
	prefix = prefix + optional_delimiter
	var packed_paths = PackedStringArray([])
	
	for value in packed_string:
		packed_paths.append(prefix + value)
	return packed_paths

static func _recursive_add_file_paths(shared_file_paths: PackedStringArray, paths: Array[String], include_hidden: bool) -> void:
	for path in paths:
		var folder := DirAccess.open(path)
		if folder == null:
			ExdotConsole.error("Failed to open Directory '%s'. Error: %s" % [path, error_string(DirAccess.get_open_error())])
			continue
		
		folder.include_hidden = include_hidden
		var current_dir = folder.get_current_dir()
		var files: PackedStringArray = _prefix_path(current_dir, folder.get_files(), "/" if path != "res://" else "")
		shared_file_paths.append_array(files)
		var folder_stack = _prefix_path(current_dir, folder.get_directories(), "/")
		
		if folder_stack.size() > 0:
			_recursive_add_file_paths(shared_file_paths, folder_stack, include_hidden)


static func find_string(args: Array) -> void:
	var path := args[0] as String
	var query := args[1] as String
	var include_hidden = args.size() == 3 and args[2] == true

	if query.is_empty():
		ExdotConsole.error("Can't search for an empty String!")
		return

	var file_paths := PackedStringArray()

	if DirAccess.dir_exists_absolute(path):
		_recursive_add_file_paths(file_paths, [path], include_hidden)
	else:
		file_paths.append(path)

	var results := PackedStringArray()

	for file_path in file_paths:
		var file := FileAccess.open(file_path, FileAccess.READ)

		if file == null:
			ExdotConsole.error("Failed to read '%s': %s" % [
				file_path,
				FileAccess.get_open_error()
			])
			continue

		var lines := file.get_as_text().split("\n")
		file.close()

		for i in range(lines.size()):
			var line := lines[i]
			var at := 0

			while true:
				var pos := line.find(query, at)

				if pos == -1:
					break

				# removes previously matched text
				var before := line.substr(0, pos)
				var match_text := line.substr(pos, query.length())
				var after := line.substr(pos + query.length())

				# escape bbcode
				before = before.replace("[", "[lb]")
				match_text = match_text.replace("[", "[lb]")
				after = after.replace("[", "[lb]")

				var highlighted := "%s[color=yellow]%s[/color]%s" % [
					before,
					match_text,
					after
				]

				var result := "[url=%s:%d:%d]%s[/url]:%d:%d  %s" % [
					file_path,
					i + 1,
					pos + query.length() + 1,
					file_path.get_file(),
					i + 1,
					pos + 1,
					highlighted
				]

				results.append(result)
				at = pos + query.length()

	for result in results:
		ExdotConsole.write(result, "findstr")

static func is_command_registered(command_name: String) -> bool:
	return _commands.has(command_name)

static func init() -> void:
	if _initialized:
		return
	_initialized = true
	_register_defaults()
	while not Cache.has("console-ready"):
		await Engine.get_main_loop().process_frame
	
	_ready = true
	_listener = EXDOT.subscribe(SAP.EXECUTE_COMMAND, _on_command_execute)
	EXDOT.send_event(SAP.CONSOLE_COMMANDS_CHANGED)

static func exit() -> void:
	_ready = false
	_initialized = false
	if _listener is Callable:
		_listener.call()
	_listener = null
	_commands = {}
