@tool
class_name StatDisplayBase
extends PanelContainer

@export var stat_set:StatSet = null:
	get:
		return stat_set
	set(_value):
		if stat_set == null and _value == null:
			if stat_set.post_stat_change.is_connected(_update_hook):
				stat_set.post_stat_change.disconnect(_update_hook)
			if stat_set.stat_added.is_connected(_update_hook):
				stat_set.stat_added.disconnect(_update_hook)
			if stat_set.stat_erased.is_connected(_update_hook):
				stat_set.stat_erased.disconnect(_update_hook)
		stat_set = _value
		if stat_set != null:
			if not stat_set.post_stat_change.is_connected(_update_hook):
				stat_set.post_stat_change.connect(_update_hook)
			if not stat_set.stat_added.is_connected(_update_hook):
				stat_set.stat_added.connect(_update_hook)
			if not stat_set.stat_erased.is_connected(_update_hook):
				stat_set.stat_erased.connect(_update_hook)
		_update_display()
@export var stat_prototype:StatPrototype = null:
	get:
		return stat_prototype
	set(_value):
		stat_prototype = _value
		_update_display()

func get_current_value(default:Variant = null) -> Variant:
	if stat_set == null or stat_prototype == null:
		return default
	return stat_set.get_stat(stat_prototype)

func _update_hook(stat:StatPrototype, _ignored1 = null, _ignored2 = null):
	if stat == stat_prototype or stat == null:
		_update_display()

func _ready():
	_update_display.call_deferred()

func _update_display():
	pass
