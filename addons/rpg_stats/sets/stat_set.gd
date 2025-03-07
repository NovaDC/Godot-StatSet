@tool
class_name StatSet
extends Node

## Called before [b]any[/b] stat is changed on this [StatSet].[br]
## To subscribe to specific stats, see [method get_pre_signal] and subscribe to that.[br]
## NOTE: when adding a stat for the first time, it's [param previous_value] will be the same
## as the [member StatPrototype.default_value]
signal pre_stat_change(stat:StatPrototype, previous_value:Variant, working_value:Variant)
## Called after [b]any[/b] stat is changed on this [StatSet].[br]
## To subscribe to specific stats, see [method get_post_signal] and subscribe to that.[br]
## NOTE: when adding a stat for the first time, it's [param previous_value] will be the same
## as the [member StatPrototype.default_value]
signal post_stat_change(stat:StatPrototype, previous_value:Variant, working_value:Variant)
## Called whenever a stat is added to this [StatSet].[br]
## This signal is also sent when this [Node] is [method _ready] for
## each existing stat already in the stat_set.
signal stat_added(stat:StatPrototype)
## Called whenever a stat is erased (removed) from this [StatSet].[br]
## This signal is also sent before this [Node] exits the tree for every stat.
signal stat_erased(stat:StatPrototype)
## Called whenever a prototype in this [StatSet] is changed.[br]
## Note the difference between this and a change in a value.
## This will only be called when a prototype in the [StatSet] is edited.[br]
## Commoly used for editor tools, as opposed actual monitoring of this [StatSet].
signal post_prototype_change(proto:StatPrototype)


@export var _stat_mapping := {} #statprototype to the working value
@export var _stat_pre_signals := {} #statprototype to signals
@export var _stat_post_signals := {} #statprototype to signals

## A readonly view of the internal dict used by this stat set for values of stats.
## Modifying this [Dictionary] itself will not effect the stat set, as it is a readonly copy,
## however, modifying the prototypes will, as it is not a deep copy.
@export var stat_mapping:Dictionary:
	get = _dictionary_but_wrapped_why,
	set = _nop
## A readonly view of the internal dict used by this stat set for the pre set signals for
## individual stats.[br]
## Modifying this [Dictionary] itself will not effect the stat set, as it is a readonly copy,
## however, modifying the prototypes or signals will, as it is not a deep copy.
@export var stat_pre_signals:Dictionary:get = pre_signal_dictionary, set = _nop
## A readonly view of the internal dict used by this stat set for the post set signals for
## individual stats.[br]
## Modifying this [Dictionary] itself will not effect the stat set, as it is a readonly copy,
## however, modifying the prototypes or signals will, as it is not a deep copy.
@export var stat_post_signals:Dictionary:get = post_signal_dictionary, set = _nop



## The default class name or path to a [PackedScene] or [Script] [Resource].
@export var display_default_class_name := "StatDisplayDefault"

func _nop(_ignored):
	pass

func _dictionary_but_wrapped_why() -> Dictionary:
	return dictionary()

func _set_signals_for(proto:StatPrototype):
	if proto not in _stat_pre_signals:
		_stat_pre_signals[proto] = Signal()
	if proto not in _stat_post_signals:
		_stat_post_signals[proto] = Signal()

func _del_signals_for(proto:StatPrototype):
	if proto in _stat_pre_signals:
		_stat_pre_signals.erase(proto)
	if proto in _stat_post_signals:
		_stat_post_signals.erase(proto)

func _call_pre_signal_for(proto:StatPrototype, previous_value:Variant, working_value:Variant):
	var sig := _stat_pre_signals.get(proto, null) as Signal
	if sig != null and not sig.is_null():
		sig.emit(proto, previous_value, working_value)

func _call_post_signal_for(proto:StatPrototype, previous_value:Variant, working_value:Variant):
	var sig := _stat_post_signals.get(proto, null) as Signal
	if sig != null and not sig.is_null():
		sig.emit(proto, previous_value, working_value)

func _assert_unconstrained_exception(test:bool, proto:StatPrototype, value:Variant):
	assert(test, "Value %s must not be outside of stat %s's constraints!"%[value, proto.name])

func _on_prototype_changed(proto:StatPrototype):
	post_prototype_change.emit(proto)

func _validate_property(property: Dictionary):
	#always read only in the inspector
	if property["name"] in ["_stat_mapping",
									"_stat_pre_signals",
									"_stat_post_signals",
									"stat_mapping",
									"stat_pre_signals",
									"stat_post_signals"
									]:
		property["usage"] |= PROPERTY_USAGE_READ_ONLY

	#never save when saving resource
	if property["name"] in ["_stat_pre_signals",
									"_stat_post_signals",
									"stat_mapping",
									"stat_pre_signals",
									"stat_post_signals"
									]:
		property["usage"] &= ~PROPERTY_USAGE_STORAGE

	#never show in editor
	if property["name"] in ["_stat_mapping", "_stat_pre_signals", "_stat_post_signals"]:
		property["usage"] &= ~PROPERTY_USAGE_EDITOR

## Gets the value of the stat with the given [param proto] [StatPrototype].[br]
## If [param strict], (the default) the value will assert that the stat must
## already be in this [StatSet].
## Otherwise, the default of the [param proto] will be returned if a value is not
## already set in this [StatSet]
func get_stat(proto:StatPrototype, strict := true) -> Variant:
	if _stat_mapping.has(proto):
		return _stat_mapping[proto]
	assert(not strict, "Prototype %s nor found in stat set %s when getting" % [proto, self])
	return proto.default_value

## Weather or not the given [param proto] [StatPrototype] has a set value in the [StatSet].
func has_stat(proto:StatPrototype) -> bool:
	return _stat_mapping.has(proto)

## Sets the given [param value] of the given [param proto] [StatPrototype] in this [StatSet].[br]
## Using this method ensures that all proper signals will be emitted and that
## the stat set initialises the stat properly, if it's being added.[br]
## If [param assert_unconstrained], this function will assert that the [param value] will
## [b]not[/b] be contrrained by the prototype when setting.
func set_stat(proto:StatPrototype,
					value:Variant = null,
					assert_unconstrained:=false
					):
	#USE THIS WHEN POSSIBLE!
	#THIS ENSURE VALUES ARE PROPERLY CONTRAINED! USE THIS EVEN WHEN EXTENDING THIS CLASS!
	if assert_unconstrained:
		_assert_unconstrained_exception(not proto.will_be_constrained(value), proto, value)
	value = proto.constrain(value)
	var old = _stat_mapping[proto] if has_stat(proto) else proto.default_value

	if not has_stat(proto):
		proto.changed.connect(_on_prototype_changed.bind(proto))
		stat_added.emit(proto)
	_set_signals_for(proto) #JIC

	_call_pre_signal_for(proto, old, value)
	pre_stat_change.emit(proto, old, value)
	_stat_mapping[proto] = value
	post_stat_change.emit(proto, old, value)
	_call_post_signal_for(proto, old, value)

## Tries to erase the value for the given [param proto] [StatPrototype] in this [StatSet].[br]
## Returns [true] if anything was removed.
func erase_stat(proto:StatPrototype) -> bool:
	var erased := _stat_mapping.erase(proto)
	if erased:
		_del_signals_for(proto)
		proto.changed.disconnect(_on_prototype_changed.bind(proto))
		stat_erased.emit(proto)
	return erased

## Similar to [method Dictionary.keys], this method returns all the
## [param proto] [StatPrototype]s that have a set value in this [StatSet].
func prototypes() -> Array[StatPrototype]: #AKA keys
	var keys:Array[StatPrototype] = []
	keys.assign(_stat_mapping.keys()) # The only way to typecast a typed array in godot somehow
	return keys

## Similar to [method Dictionary.values], this method returns all the
## values in this [StatSet].
func values() -> Array[Variant]:
	return prototypes().map(func (x:StatPrototype): return get_stat(x))

## Similar to [method Dictionary.duplicate], this method
## returns a copy of the internal [Dictionary], mapping
## [StatPrototype]s to their set values.
func dictionary(deep_copy := false) -> Dictionary:
	return _stat_mapping.duplicate(deep_copy)

## This method returns a copy of the internal [Dictionary]
## mapping [StatPrototype]s to their generated pre-set [Signal].[br]
## To get a pre-set [Signal] for a single [StatPrototype], see
## [method get_pre_signal].
func pre_signal_dictionary() -> Dictionary:
	return _stat_pre_signals.duplicate()

## This method returns a copy of the internal [Dictionary]
## mapping [StatPrototype]s to their generated posy-set [Signal].[br]
## To get a post-set [Signal] for a single [StatPrototype], see
## [method get_post_signal].
func post_signal_dictionary() -> Dictionary:
	return _stat_post_signals.duplicate()

## Retrieve the specific pre-set [Signal] for the given
## [param proto] [StatPrototype] in this [StatSet].
func get_pre_signal(proto:StatPrototype) -> Signal:
	_set_signals_for(proto)
	return _stat_pre_signals[proto]

## Retrieve the specific post-set [Signal] for the given
## [param proto] [StatPrototype] in this [StatSet].
func get_post_signal(proto:StatPrototype) -> Signal:
	_set_signals_for(proto)
	return _stat_post_signals[proto]

func _ready():
	for init_proto in prototypes():
		init_proto.changed.connect(_on_prototype_changed.bind(init_proto))
		stat_added.emit(init_proto)
		_set_signals_for(init_proto)

func _exit_tree():
	for final_proto in prototypes():
		stat_erased.emit(final_proto)

## Similar to [method Dictionary.get], gets the set value
## of [param proto] [StatPrototype] in this [StatSet], or returns
## [param default] if there is no associated value.
func get_stat_default(proto:StatPrototype, default:Variant = null) -> Variant:
	if not has_stat(proto):
		return default
	return get_stat(proto)

## Similar to [method Dictionary.get_or_add], gets the set value
## of [param proto] [StatPrototype] in this [StatSet], or adds it with the value of
## [param default] if there is no associated value.[br]
## [param assert_unconstrained] acts the same as it does in [method set_stat].
func get_stat_or_add(proto:StatPrototype,
							default:Variant = null,
							assert_unconstrained:=false
							) -> Variant:
	if not has_stat(proto):
		#Do it this way so that way its easy to extend for
		#effectable statsets and ensures that the signal for adding is called
		set_stat(proto, default, assert_unconstrained)
		return default
	return get_stat(proto)

## Sets stats in bulk using the given [param stat_mapping] of [StatPrototype]s to
## their new [Variant] values.[br]
## Unlike using [method set_stat] repeatedly, this will [param assert_unconstrained]
## before anything is ever set. Otherwise, this is a convenience function
## for bulk setting fo stats.
func set_stats(stat_mapping:Dictionary, assert_unconstrained:=false):
	if assert_unconstrained:
		#never set if anything going to be asserted, so check first before setting
		for p in stat_mapping.keys():
			_assert_unconstrained_exception(not p.will_be_constrained(stat_mapping[p]), p, stat_mapping[p])
	for p in stat_mapping.keys():
		set_stat(p, stat_mapping[p], assert_unconstrained)

## Set (or add) the given [param proto] [StatPrototype]
## to it's [member StatPrototype.default_value].[br]
## [param assert_unconstrained] acts the same as it does in [method set_stat].
func reset_stat(proto:StatPrototype, assert_unconstrained:=false):
	set_stat(proto, proto.default_value, assert_unconstrained)

## Returns all the [method prototypes] with the given [param name].[br]
## As multiple [StatPrototype]s can have the same [member StatPrototype.name], this
## returns an [Array] of possible [StatPrototype]s, including a empty one if
## no valid [StatPrototype]s were found.
func protoypes_named(name:String) -> Array[StatPrototype]:
	return prototypes().filter(func (x:StatPrototype): return x.name == name)

## Retrieve the a new appropriate [StatDisplayBase]
## instance for the given [param proto] [StatPrototype].
func get_stat_display(proto:StatPrototype,
							display_context := ""
							) -> StatDisplayBase: #a class name to insintate
	var name_or_path:StringName = ""
	if display_context in proto.display_type:
		name_or_path = proto.display_type[display_context]
	else:
		name_or_path = proto.display_type[""] if "" in proto.display_type else display_default_class_name
	return NovaTools.instantiate_this(name_or_path) as StatDisplayBase
