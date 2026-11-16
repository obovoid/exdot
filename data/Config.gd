@tool
class_name Config
extends RefCounted

const CONFIG_PATH = "res://.exdot/exdot.cfg"
var CONFIG_FILE = ConfigFile

var _configuration_list := [
	{
		section = SAP.CONFIG_ACP.DEFAULT,
		key = SAP.CONFIG_ACP.HOME_DIR,
		initial_value = "res://",
		value_type = TYPE_STRING
	},
	{
		section = SAP.CONFIG_ACP.COMPILER,
		key = SAP.CONFIG_ACP.SOURCE_DIR,
		initial_value = "src",
		value_type = TYPE_STRING
	},
	{
		section = SAP.CONFIG_ACP.COMPILER,
		key = SAP.CONFIG_ACP.OUTPUT_DIR,
		initial_value = "out",
		value_type = TYPE_STRING
	},
	{
		section = SAP.CONFIG_ACP.COMPILER,
		key = SAP.CONFIG_ACP.COMPILE_ON_SAVE,
		initial_value = false,
		value_type = TYPE_BOOL
	},
	{
		section = SAP.CONFIG_ACP.DEVEL,
		key = SAP.CONFIG_ACP.RUN_TESTS,
		initial_value = false,
		value_type = TYPE_BOOL
	},
	{
		section = SAP.CONFIG_ACP.DEVEL,
		key = SAP.CONFIG_ACP.CONSOLE_OUTPUT_TARGET,
		initial_value = "godot",
		value_type = TYPE_STRING
	}
]

func reset_configuration() -> void:
	if not CONFIG_FILE is ConfigFile:
		return push_error(XERROR.CONFIG.ERR_UNINITIALIZED)
	for configuration in _configuration_list:
		CONFIG_FILE.set_value(configuration.section, configuration.key, configuration.initial_value)

func test() -> void:
	for configuration in _configuration_list:
		var has_section = CONFIG_FILE.has_section(configuration.section)
		var has_key = CONFIG_FILE.has_section_key(configuration.section, configuration.key)
		
		if has_section == false or has_key == false:
			CONFIG_FILE.set_value(configuration.section, configuration.key, configuration.initial_value)
			print_debug("Created new section or sectionkey for missing configuration data.")
			continue
		
		if configuration.value_type == -1:
			# no type check needed if any value is allowed
			continue
		
		var value = CONFIG_FILE.get_value(configuration.section, configuration.key)
		var typeof_value = typeof(value)
		if typeof_value != configuration.value_type:
			print_debug("Type mismatch detected. Generating Error.")
			EXDOT.send_event(SAP.CONFIG_ACP.EXDOT_CRASHED)
			push_error(XERROR.CONFIG.ERR_TYPE_MISMATCH % [
					configuration.value_type, configuration.section, configuration.key, typeof_value, configuration.value_type
				]
			)

func _register_commands() -> void:
	for configuration in _configuration_list:
		var cmd_name = configuration.key
		const prefixes = ["set:", "get:"]
		for n in prefixes.size():
			var full_command = prefixes[n] + cmd_name
			match prefixes[n]:
				"set:":
					if ExdotConsole.is_command_registered(full_command):
						return
					
					ExdotConsole.register_command(
						full_command, 
						set_config_value_by_command.bind(configuration.section, cmd_name, configuration.value_type), 
						"Overwrite the value for '%s'. It will be saved to disk and used instead of the default value." % cmd_name,
						[
							{
								"name": "value",
								"type": configuration.value_type,
								"required": true
							}
						]
					)
				"get:":
					if ExdotConsole.is_command_registered(full_command):
						return
					
					ExdotConsole.register_command(
						full_command,
						get_config_value_by_command.bind(configuration.section, cmd_name, configuration.value_type),
						"Get the value for '%s'. It will be printed to the EXDOT Console." % cmd_name
					)

func set_config_value_by_command(config_value: Array, section: String, key: String, expected_type: Variant.Type) -> void:
	var err = ExdotConsole.error
	var value = str(config_value[0])
	var default_error = XERROR.CONFIG.ERR_SET_FAILED
		
	if not value:
		return err.call(default_error % ['nil', key])
	var set_err = default_error % [value, key]
	
	var final_value;
	
	match type_string(expected_type):
		"bool":
			if value != "false" and value != "true":
				return err.call(set_err)
			final_value = bool(true if value == "true" else false)
		"int":
			if value.contains(".") or value.is_valid_int() == false:
				return err.call(set_err)
			final_value = int(value)
		"float":
			if not value.contains(".") or value.is_valid_float() == false:
				return err.call(set_err)
			final_value = float(value)
		"String":
			var raw_string := Convert.as_string_raw(value)
			if raw_string.contains('"') or raw_string.contains("'") or raw_string.is_valid_int() or raw_string.is_valid_float():
				return err.call(set_err)
			final_value = String(raw_string)
		_:
			return err.call(XERROR.CONFIG.ERR_UNHANDLED_TYPE % type_string(expected_type))
	
	var previous_value = get_value(section, key)
	set_value(section, key, final_value)
	var error = save()
	if error != OK:
		return push_error(XERROR.CONFIG.ERR_SAVE_FAILED % error_string(error))
	ExdotConsole.write("Successfully set the new value for '%s' from '%s' to '%s'." % [key, previous_value, final_value], "set:%s" % key)

func get_config_value_by_command(section: String, key: String, expected_type: Variant.Type) -> void:
	ExdotConsole.write(
		Convert.with_type(
			str(
				get_value(section, key)
			), expected_type
		),
		"get:%s" % key
	)

func _init() -> void:
	_configuration_list.make_read_only()
	CONFIG_FILE = ConfigFile.new()
	
	var error = CONFIG_FILE.load(CONFIG_PATH)
	if error != OK:
		match error_string(error):
			"ERR_FILE_NOT_FOUND":
				pass # Initial Config is created above
			_:
				push_error(error_string(error))
	
	_register_commands()

## intended unsafe setter to overwrite a value in the configuration file.
func set_value(section: String, key: String, value: Variant) -> void:
	CONFIG_FILE.set_value(section, key, value)

func get_value(section: String, key: String) -> Variant:
	return CONFIG_FILE.get_value(section, key)

func save() -> Error:
	var error = CONFIG_FILE.save(CONFIG_PATH)
	return error
