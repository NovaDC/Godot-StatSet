@tool
class_name StatSetEffectable
extends StatSet


@export var effects:Array[StatEffect] = []

func _getter_sorter(a:StatEffect, b:StatEffect, proto:StatPrototype) -> bool:
	var p_a := a.effect_getting_priority(proto, self)
	var p_b := b.effect_getting_priority(proto, self)
	if p_a != p_b:
		return p_a < p_b

	var i_a := effects.find(a)
	var i_b := effects.find(b)
	if i_a > 0 and i_b > 0 and i_a != i_b:
		return i_a < i_b

	return a.get_effect_name(proto, self) < b.get_effect_name(proto, self)

func _setter_sorter(a:StatEffect, b:StatEffect, proto:StatPrototype):
	var p_a := a.effect_setting_priority(proto, self)
	var p_b := b.effect_setting_priority(proto, self)
	if p_a != p_b:
		return p_a < p_b
	var i_a := effects.find(a)
	var i_b := effects.find(b)
	if i_a > 0 and i_b > 0 and i_a != i_b:
		return i_a < i_b
	return a.get_effect_name(proto, self) < b.get_effect_name(proto, self)

func applicable_getting_effects_ordered(proto:StatPrototype) -> Array[StatEffect]:
	var applicable = effects.filter(func (x): return x.get_effects_getting_stat(proto, self))
	applicable.sort_custom(_getter_sorter.bind(proto))
	return applicable

func applicable_setting_effects_ordered(proto:StatPrototype) -> Array[StatEffect]:
	var applicable = effects.filter(func (x): return x.get_effects_setting_stat(proto, self))
	applicable.sort_custom(_setter_sorter.bind(proto))
	return applicable

func _effected_value_getting(proto:StatPrototype,
										value:Variant,
										assert_unconstrained:=false
										) -> Variant:
	for fx in applicable_getting_effects_ordered(proto):
		value = fx.effect_getting(value, proto, self)
		if assert_unconstrained:
			_assert_unconstrained_exception(not proto.will_be_constrained(value), proto, value)
		value = proto.constrain(value)
	return value

func _effected_value_setting(proto:StatPrototype,
										value:Variant,
										assert_unconstrained:=false
										) -> Variant:
	for fx in applicable_setting_effects_ordered(proto):
		value = fx.effect_setting(value, proto, self)
		if assert_unconstrained:
			_assert_unconstrained_exception(not proto.will_be_constrained(value), proto, value)
		value = proto.constrain(value)
	return value

func get_stat(proto:StatPrototype, strict := false) -> Variant:
	return _effected_value_getting(proto, super.get_stat(proto, strict))

func get_raw_stat(proto:StatPrototype, strict := false) -> Variant:
	return super.get_stat(proto, strict)

func set_stat(proto:StatPrototype, value:Variant = null, assert_unconstrained:=false):
	super.set_stat(proto, _effected_value_setting(proto, value, assert_unconstrained), false)

func set_raw_stat(proto:StatPrototype, value:Variant = null, assert_unconstrained:=false):
	super.set_stat(proto, value, assert_unconstrained)

func reset_raw_stat(proto:StatPrototype, assert_unconstrained:=false):
	super.reset_stat(proto, assert_unconstrained)

func set_stats(stat_mapping:Dictionary, assert_unconstrained:=false):
	# Its more efficient to redo the loop as the assertion
	# of constraints and the effecting of values work more efficiently
	# that way when also keeping in mind all assertion have to happen before committing every value
	stat_mapping = stat_mapping.duplicate()
	for p in stat_mapping.keys():
		stat_mapping[p] = _effected_value_setting(p, stat_mapping[p], assert_unconstrained)
	for p in stat_mapping.keys():
		set_stat(p, stat_mapping[p], assert_unconstrained)


## Similar to [method dictionary], but returns the a dict with [b]effected[/b] values.[br]
## This also means that [method dictionary] will always mirror the unaffected values, spite
## [method set_stat], [method set_stats] and [method get_stat]
## begin overiden to returned the effected values.
func effected_dictionary(deep_copy := false) -> Dictionary:
	var d := {}
	for proto in prototypes():
		d[proto] = get_stat(proto) if not deep_copy else get_stat(proto).duplicate(true)
	return d
