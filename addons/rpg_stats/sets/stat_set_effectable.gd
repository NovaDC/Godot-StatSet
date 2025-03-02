@tool

extends StatSet
class_name StatSetEffectable

@export var effects:Array[StatEffect] = []

func __getter_sorter(a:StatEffect, b:StatEffect, proto:StatPrototype):
	var p_a := a.get_effects_getting_priorty(proto, self)
	var p_b := b.get_effects_getting_priorty(proto, self)
	return p_a < p_b or (p_a == p_b and a.get_effect_name(proto, self) < b.get_effect_name(proto, self))

func __setter_sorter(a:StatEffect, b:StatEffect, proto:StatPrototype):
	var p_a := a.get_effects_setting_priorty(proto, self)
	var p_b := b.get_effects_setting_priorty(proto, self)
	return p_a < p_b or (p_a == p_b and a.get_effect_name(proto, self) < b.get_effect_name(proto, self))

func get_applicable_getting_effects_ordered(proto:StatPrototype) -> Array[StatEffect]:
	var applicable = effects.filter(func (x:StatEffect): return x.get_effects_getting_stat(proto, self))
	applicable.sort_custom(__getter_sorter.bind(proto))
	return applicable

func get_applicable_setting_effects_ordered(proto:StatPrototype) -> Array[StatEffect]:
	var applicable = effects.filter(func (x:StatEffect): return x.get_effects_setting_stat(proto, self))
	applicable.sort_custom(__setter_sorter.bind(proto))
	return applicable

func __effected_value_getting(proto:StatPrototype, value:Variant, assert_unconstrained:=false) -> Variant:
	for fx in get_applicable_getting_effects_ordered(proto):
		value = fx.pre_stat_get(proto, self, value)
		if assert_unconstrained:
			__raise_common_assert_unconstrained_exception(not proto.will_be_constrained(value), proto, value)
		value = proto.constrain(value)
	return value

func __effected_value_setting(proto:StatPrototype, value:Variant, assert_unconstrained:=false) -> Variant:
	for fx in get_applicable_setting_effects_ordered(proto):
		value = fx.pre_stat_get(proto, self, value)
		if assert_unconstrained:
			__raise_common_assert_unconstrained_exception(not proto.will_be_constrained(value), proto, value)
		value = proto.constrain(value)
	return value

func get_stat(proto:StatPrototype, strict := false) -> Variant:
	return __effected_value_getting(proto, super.get_stat(proto, strict))

func set_stat(proto:StatPrototype, value:Variant = null, assert_unconstrained:=false):
	super.set_stat(proto, __effected_value_setting(proto, value, assert_unconstrained), false)

func set_stats(stat_mapping:Dictionary, assert_unconstrained:=false):
	# Its more efficent to redo the loop as the assertion fo \constraints and the effecting of values work more efficently that way when also keeping in mind all assertion have to happen before commintng every value
	stat_mapping = stat_mapping.duplicate()
	for p in stat_mapping.keys():
		stat_mapping[p] = __effected_value_setting(p, stat_mapping[p], assert_unconstrained)
	for p in stat_mapping.keys():
		set_stat(p, stat_mapping[p], assert_unconstrained)


## Similar to [method dictionary], but returns the a dict with [b]effected[/b] values.[br]
## This also means that [method dictionary] will always mirror the uneffected values, spite
## [method set_stat], [method set_stats] and [method get_stat]
## beign overiden to returned the effected values.
func effected_dictionary(deep_copy := false) -> Dictionary:
	var d := {}
	for proto in prototypes():
		d[proto] = get_stat(proto) if not deep_copy else get_stat(proto).duplicate(true)
	return d
