class_name Workspace
extends RefCounted
## Manages persistent workspace data.
## Only identifiers defined in TEMPLATE are allowed.

const TEMPLATE : Dictionary = {
	script_map = {}
}

const CACHE_KEY : String = "exdot"

enum Action {
	Put,
	Insert
}

const file_path : String = "res://.exdot/exdot.json"

static func init() -> void:	
	_load()

static func _load() -> void:
	var workspace : Dictionary = TEMPLATE.duplicate(true)
	
	if FileAccess.file_exists(file_path):
		var content := FileAccess.get_file_as_string(file_path)
		var json := JSON.new()
		
		if json.parse(content) == OK and json.data is Dictionary:
			for section in TEMPLATE:
				var value : Variant = json.data.get(section)
				
				if typeof(value) == typeof(TEMPLATE[section]):
					workspace[section] = value
		else:
			push_warning("Workspace file contains invalid JSON.")
			
	Cache.put(CACHE_KEY, workspace)
	
	if not FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.WRITE)
		
		if file == null:
			push_error(XERROR.WORKSPACE.ERR_CREATE_FILE)
			return
		
		file.store_string(JSON.stringify(workspace, "\t"))
		file.close()

static func store(section: String, identifier: String, action: Action, value: Variant) -> void:
	if not _valid_section(section):
		return
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	var entries : Dictionary = workspace[section]
	
	match action:
		Action.Put:
			entries[identifier] = value
		Action.Insert:
			if not entries.has(identifier):
				push_error(XERROR.WORKSPACE.UNKNOWN_IDENTIFIER % identifier)
				return
			
			if not entries[identifier] is Array:
				push_error(XERROR.WORKSPACE.ERR_IDENTIFIER_TYPE_MISMATCH % identifier)
				return
			
			entries[identifier].append(value)
			
	workspace[section] = entries
	Cache.put(CACHE_KEY, workspace)

static func pull(section: String, identifier: String) -> Variant:
	if not _valid_section(section):
		return null
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	return workspace[section].get(identifier)

static func pull_all(section: String) -> Variant:
	if not _valid_section(section):
		return null
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	return workspace.get(section)

static func has(section: String, identifier: String) -> bool:
	if not _valid_section(section):
		return false
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	return workspace[section].has(identifier)

static func _valid_section(section: String) -> bool:
	if not TEMPLATE.has(section):
		push_error(XERROR.WORKSPACE.ERR_UNKNOWN_SECTION % section)
		return false
	return true

static func flush() -> void:
	if not Cache.has(CACHE_KEY):
		push_warning("Workspace cache is unavailable. Skipping Flush.")
		return
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	
	if file == null:
		push_error(XERROR.WORKSPACE.ERR_FILESYSTEM_WRITE % error_string(FileAccess.get_open_error()))
		return
	
	file.store_string(JSON.stringify(workspace, "\t"))
	file.close()

static func delete(section: String, identifier: String) -> bool:
	if not _valid_section(section):
		return false
	
	var workspace : Dictionary = Cache.pull(CACHE_KEY)
	return workspace[section].erase(identifier)
