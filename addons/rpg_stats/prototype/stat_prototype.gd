@tool
@icon("../iconproto.svg")
class_name StatPrototype
extends Resource

## StatPrototype
##
## This is a base class for all stats. Instances of this class (or it's children) are used
## in [StatSet]s to define stats. The [StatPrototype] instance itself
## doesn't store the [i]current[/i] value of the stat,
## instead storing any kind of metadata about a stat
## (ex. name, default value, max / min value if applicable).[br]
## This class can be inherited to make a more specific behaviour for a stat.[br]
## for an example of this, see the implementation of [StatPrototypeNumeric], which
## defines a stat that has specifically numeric types and a numeric max and min.

## The name of this stat prototype.[br]
## NOTE: This is not the unique identifier for a stat! This is only intended for use in displays.
@export var name := "":
	get:
		return name
	set(_value):
		var value_changed := false
		if name != _value:
			value_changed = true
		name = _value
		if value_changed:
			emit_changed()
## The default value for this stat.
@export var default_value:Variant = null: get = _get_default_value, set = _set_default_value

## A dict mapping display contexts to the display type to use.
## The key of [code]""[/code] acts as the default.br[]
## When there is not default nor override for the specific context,
## the [member StatSet.display_default_class_name] is used.[br]
## NOTE: Changing this may not [method emit_changed].
@export var display_type := {}
## A class, class name, scene, or anything else that can be accepted by
## [method NovaTools.instantiate_this] to be instantiated and used as the
## editor controll of this stat prototype.[br]
## Its expected that the instanitated node has a member called [code]prototype[/code] to be
## provided with a reference to a instance of this [StatPrototype].
## NOTE: Changing this may not [method emit_changed].
@export var editing_display_type := "res://addons/rpg_stats/prototype/stat_prototype_editor.tscn"

var _default_value:Variant = null

func _get_default_value() -> Variant:
	return _default_value

func _set_default_value(value:Variant):
	var value_changed := false
	if typeof(_default_value) != typeof(value) or _default_value != value:
		value_changed = true
	_default_value = value
	if value_changed:
		emit_changed()

## INTENDED VIRTUAL
## A method that conttrains the [param value] to a valid value for this [StatPrototype].
func constrain(value:Variant) -> Variant:
	return value

## INTENDED VIRTUAL
## A method that determine if the [param value] would
## be constrained modified if constrained for this [StatPrototype].[br]
## defaults to simply compairing the given [param value] to the result of [method constrain]
## and returning if the type or value differ.
func will_be_constrained(value:Variant) -> bool:
	var constrained = constrain(value)
	return typeof(constrained) != typeof(value) or constrained != value

## INTENDED VIRTUAL
## A method that takes a string value and converts it
## to a variant value applicable to this [StatPrototype].
## The inverse of [method string_from_value].
func value_from_string(string:String) -> Variant:
	return str_to_var(string)

## INTENDED VIRTUAL
## A method that takes a [Variant] value and converts it
## to a string value applicable to this [StatPrototype].
## The inverse of [method value_from_string].
func string_from_value(value:Variant) -> String:
	return var_to_str(value)
