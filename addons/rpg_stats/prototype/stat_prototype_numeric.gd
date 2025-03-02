@tool

extends StatPrototype
class_name StatPrototypeNumeric

@export var minimum:float = -INF:
	get:
		return minimum
	set(_value):
		minimum = _value
		notify_property_list_changed()
@export var maximum:float = INF:
	get:
		return maximum
	set(_value):
		maximum = _value
		notify_property_list_changed()
@export var intiger_truncated := false

func _get_default_value() -> Variant:
	if _default_value is not int and _default_value is not float:
		_default_value = 0
	return super._get_default_value()

func _validate_property(property: Dictionary) -> void:
	if property["name"] == "default_value":
		property["type"] = TYPE_FLOAT
		property["hint"] = PROPERTY_HINT_RANGE
		property["hint_string"] = "%s,%s,0.0001,or_greater,or_less" % [minimum, maximum]

func constrain(value:Variant) -> Variant:
	assert(typeof(value) in [TYPE_INT, TYPE_FLOAT])
	value = clamp(value, minimum, maximum)
	return snapped(value, 1) if intiger_truncated else value

func from_string(str:String) -> Variant:
	var value = str_to_var(str)
	assert(typeof(value) in [TYPE_INT, TYPE_FLOAT])
	return value

func as_string(value:Variant) -> String:
	assert(typeof(value) in [TYPE_INT, TYPE_FLOAT])
	return str(value)
