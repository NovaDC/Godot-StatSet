@tool
class_name StatDisplayDefault
extends StatDisplayBase

var _display_label_ref:Label = null
var _display_prog_bar_ref:ProgressBar = null

func _update_display():
	visible = not (stat_set == null or stat_prototype == null)
	if visible:
		if _display_label_ref == null:
			_display_label_ref = Label.new()
		if _display_label_ref.get_parent() != self:
			add_child(_display_label_ref)
		_display_label_ref.set_anchors_preset(PRESET_FULL_RECT)
		if stat_prototype is StatPrototypeNumeric:
			if _display_prog_bar_ref == null:
				_display_prog_bar_ref = ProgressBar.new()
			if _display_prog_bar_ref.get_parent() != self:
				add_child(_display_prog_bar_ref)
			_display_prog_bar_ref.set_anchors_preset(PRESET_FULL_RECT)
			_display_prog_bar_ref.allow_greater = true
			_display_prog_bar_ref.allow_lesser = true
		else:
			if _display_prog_bar_ref != null:
				_display_prog_bar_ref.queue_free()

		_display_label_ref.text = stat_prototype.name + ": " + str(stat_set.get_stat(stat_prototype))
		if _display_prog_bar_ref != null:
			if (not is_inf(stat_prototype.minimum)) and (not is_inf(stat_prototype.minimum)):
				_display_prog_bar_ref.visible = true
				_display_prog_bar_ref.min_value = stat_prototype.minimum
				_display_prog_bar_ref.max_value = stat_prototype.maximum
				_display_prog_bar_ref.step = 1 if stat_prototype.intiger_truncated else 0.01
				_display_prog_bar_ref.value = get_current_value()
			else:
				_display_prog_bar_ref.visible = false
	else:
		if _display_label_ref != null:
			_display_label_ref.queue_free()
		if _display_prog_bar_ref != null:
			_display_prog_bar_ref.queue_free()
