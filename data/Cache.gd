class_name Cache
extends RefCounted

static var _store : Dictionary

static func _cache_is_valid(value: Variant):
	return typeof(value) != TYPE_NIL

static func pull(property: StringName) -> Variant:
	return _store[property]

static func put(property: StringName, value: Variant) -> void:
	_store[property] = value

static func has(property: StringName, check_valid := true) -> bool:
	if not _store.has(property):
		return false
	if check_valid:
		return _cache_is_valid(_store[property])
	return true

static func remove(property: StringName, keep_identifier := false) -> void:
	if keep_identifier:
		put(property, null)
	else:
		_store.erase(property)

static func reset() -> void:
	_store = {}
	
static func init() -> void:
	_store = {}
