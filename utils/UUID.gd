@tool
class_name UUID # UUID system should be UUID v4 RFC 9562. No real tests made for now. Looked right in first few generations.
extends RefCounted

var new_uuid: StringName
func _generate_uuid() -> String:
	var crypto := Crypto.new()
	var bytes := crypto.generate_random_bytes(16)

	# mark version 4
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	# set rfc
	bytes[8] = (bytes[8] & 0x3F) | 0x80

	var hex := bytes.hex_encode()
	var uuid = "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12)
	]
	
	self.new_uuid = uuid
	return uuid

func key(): ## returns the last generated UUID. Probably gonna be removed. Do not use if not needed.
	return self.new_uuid

func generate() -> String: ## Generates a new UUID V4. Collisions are still possible. Always store used UUIDs and check if a new UUID collides with the generated list.
	return _generate_uuid()
