@tool
class_name StatSetDisplayDefault
extends VBoxContainer

## StatSetDisplayDefault
##
## A default and example implementation of [Control] based display for a [StatSet].[br]
## This should be compatible with any possible [member StatPrototype.stat_display]
## (as, ideally, any display for a [StatSet] should be), and arranges the displays in a simple
## vertical stack (via [VBoxContainer]).[br]
## The display will consistently update itself as the [member StatSet] changes,
## and will work in editor.

## The [StatSet] to display.
@export var stat_set:StatSet = null:
	get:
		return stat_set
	set(_value):
		if stat_set != _value and stat_set != null:
			if stat_set.stat_added.is_connected(_make_stat_display):
				stat_set.stat_added.disconnect(_make_stat_display)
			if stat_set.stat_erased.is_connected(_kill_stat_display):
				stat_set.stat_erased.disconnect(_kill_stat_display)
			if stat_set.post_prototype_change.is_connected(_redo_stat_display):
				stat_set.post_prototype_change.disconnect(_redo_stat_display)
		stat_set = _value
		if stat_set != null:
			if not stat_set.stat_added.is_connected(_make_stat_display):
				stat_set.stat_added.connect(_make_stat_display)
			if not stat_set.stat_erased.is_connected(_kill_stat_display):
				stat_set.stat_erased.connect(_kill_stat_display)
			if not stat_set.post_prototype_change.is_connected(_redo_stat_display):
				stat_set.post_prototype_change.connect(_redo_stat_display)

var _managed_nodes:Array[Node] = []

func _enter_tree():
	_force_update()

func _ready():
	_force_update()

func _redo_stat_display(proto:StatPrototype):
	_kill_stat_display(proto)
	_make_stat_display(proto)

func _make_stat_display(proto:StatPrototype):
	if not _managed_nodes.any(func (n:Node): return n.stat_prototype == proto):
		var c = stat_set.get_stat_display(proto)
		_managed_nodes.append(c)
		c.stat_set = stat_set
		c.stat_prototype = proto
		add_child(c)

func _kill_stat_display(proto:StatPrototype):
	for c in _managed_nodes.filter(func (n): return n.stat_prototype == proto):
		_managed_nodes.erase(c)
		c.queue_free()

func _force_update():
	for n in _managed_nodes:
		n.queue_free()
	_managed_nodes.clear()
	if stat_set != null:
		for proto in stat_set.prototypes():
			_make_stat_display(proto)
