@tool
class_name StatPrototype
extends Resource

## The name of this stat prototype.[br]
## NOTE: This is not the unique identifier for a stat! This is only intended for use in displays.
@export var name := "":
	get:
		return name
	set(_value):
		var changed := false
		if name != _value:
			changed = true
		name = _value
		if changed:
			emit_changed()
@export var default_value:Variant = null: get = _get_default_value, set = _set_default_value

#These properties bellow arn't "observable" (aka they may not call the changed event when changed!
@export var display_type := {} #a dict mapping display contexts to the display type to use
@export var editing_display_type := "res://addons/rpg_stats/prototype/stat_prototype_editor.tscn"

var _default_value:Variant = null

func _get_default_value() -> Variant:
	return _default_value

func _set_default_value(value:Variant):
	var 	changed := false
	if typeof(_default_value) != typeof(value) or _default_value != value:
		changed = true
	_default_value = value
	if changed:
		emit_changed()

func constrain(value:Variant) -> Variant:
	return value

func will_be_constrained(value:Variant) -> bool:
	return constrain(value) != value

func from_string(str:String) -> Variant:
	return str_to_var(str)

func as_string(value:Variant) -> String:
	return var_to_str(value)
