@tool
@icon("../iconproto.svg")
class_name StatPrototypeNumeric
extends StatPrototype

## StatPrototypeNumeric
##
## A [StatPrototype] specifically built for numeric stats.[br]
## Instances of this class can be used in a [StatSet] to define a stat's metadata.[br]
## Unlike the base [StatPrototype], this class asserts that the value is always numeric
## (either [int] or [float]), and constrains it's possible values within the
## [member maximum] and [member minimum] values.[br]
## See [StatPrototype] for more information about how [StatPrototype]s should be used.

## The minimum value for this stat.
@export var minimum:float = -INF:
	get:
		return minimum
	set(_value):
		minimum = _value
		notify_property_list_changed()

## The maximum value for this stat.
@export var maximum:float = INF:
	get:
		return maximum
	set(_value):
		maximum = _value
		notify_property_list_changed()

## When set, the value will be rounded to the nearest whole number (regardless of type).
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

func value_from_string(string:String) -> Variant:
	var value = str_to_var(string)
	assert(typeof(value) in [TYPE_INT, TYPE_FLOAT])
	return value

func string_from_value(value:Variant) -> String:
	assert(typeof(value) in [TYPE_INT, TYPE_FLOAT])
	return str(value)

