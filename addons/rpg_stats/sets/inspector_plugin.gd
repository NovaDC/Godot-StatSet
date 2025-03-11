@tool
class_name StatSetEditorInspectorPlugin
extends EditorInspectorPlugin

## A [PackedScene] of the the [StatSet] editing controll to use in the inspector.
const STAT_SET_EDITOR := preload("res://addons/rpg_stats/sets/stat_set_editor.tscn")

var _latest_window_ref:Window = null

func _can_handle(object:Object):
	return object is StatSet

func _popup_editor(stat_set:StatSet):
	if _latest_window_ref != null:
		_latest_window_ref.queue_free()
	var window := Window.new()
	EditorInterface.get_base_control().add_child(window)
	window.hide()
	window.force_native = true
	window.title = "Stat Set Editor"
	window.always_on_top	= true
	window.child_controls_changed()
	window.close_requested.connect(window.queue_free)
	var editor := STAT_SET_EDITOR.instantiate()
	editor.stat_set = stat_set
	window.add_child(editor)
	window.popup_centered(Vector2i.ONE * 300)
	_latest_window_ref = window

func _parse_category(object, category):
	if category == "stat_set.gd":
		var editor_brief := STAT_SET_EDITOR.instantiate()
		editor_brief.stat_set = object
		add_custom_control(editor_brief)
		var popout_button := Button.new()
		popout_button.pressed.connect(_popup_editor.bind(object))
		popout_button.text = "Edit..."
		popout_button.icon = NovaTools.get_editor_icon_named("Stretch")
		popout_button.expand_icon = true
		add_custom_control(popout_button)
