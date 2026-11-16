@tool
class_name EXDOT
extends RefCounted

const TYPE_VARIANT = -1

static var CONFIG: Config
static var INITIALIZED := -1
static var language : ScriptLanguageExtension

enum STATUS {
	SUCCESS,
	FAILED,
	INITIALIZING,
	INITIALIZED,
	UNINITIALIZING,
	UNINITIALIZED
}

static func _init_config(force: bool = false) -> void:
	if CONFIG and not force:
		return
	
	CONFIG = Config.new()

static func setup_config() -> void:
	CONFIG.reset_configuration()

static func test_config() -> void:
	CONFIG.test()

static func set_config_value(section: String, key: String, value: Variant) -> void:
	CONFIG.set_value(section, key, value)

static func save_config() -> Error:
	return CONFIG.save()

static func get_config_value(section: String, key: String) -> Variant:
	return CONFIG.get_value(section, key)

static func r_path(path_identifier: String) -> String:
	match path_identifier:
		"HOME":
			return get_config_value(SAP.CONFIG_ACP.COMPILER, SAP.CONFIG_ACP.HOME_DIR)
		"SOURCE":
			return get_config_value(SAP.CONFIG_ACP.COMPILER, SAP.CONFIG_ACP.SOURCE_DIR)
		"OUTPUT":
			return get_config_value(SAP.CONFIG_ACP.COMPILER, SAP.CONFIG_ACP.OUTPUT_DIR)
		"WORKSPACE":
			return "res://.exdot/" # value must not be configurable.
		_:
			return ""

static func connect_paths(path_identifier: Array[String]):
	var p : String
	for path in path_identifier:
		p += r_path(path)
	return p

static var _subscribers := {}
static func subscribe(what: String, callable: Callable) -> Callable:
	if not _subscribers.has(what):
		_subscribers[what] = []

	_subscribers[what].append(callable)

	var unsubscribe = func() -> void:
		_subscribers[what].erase(callable)

	return unsubscribe

static func send_event(what: String, ...parameters) -> void:
	if not _subscribers.has(what):
		return
	for subscriber in _subscribers[what]:
		if not subscriber or not (subscriber is Callable):
			return
		if subscriber.get_argument_count() > 0:
			subscriber.callv(parameters)
		else:
			subscriber.call()
