@tool
class_name StatSetEditorInspectorPlugin
extends EditorInspectorPlugin

## A [PackedScene] of the the [StatSet] editing controll to use in the inspector.
const STAT_SET_EDITOR := preload("res://addons/rpg_stats/sets/stat_set_editor.tscn")

var _latest_window_ref:Window = null

func _can_handle(object:Object):
	return object is StatSet

func _popup_editor(stat_set:StatSet):
	if _latest_window_ref == null or _latest_window_ref.is_queued_for_deletion():
		_latest_window_ref = Window.new()
	if _latest_window_ref.get_parent() == null:
		EditorInterface.get_base_control().add_child(_latest_window_ref)
	_latest_window_ref.hide()
	if not _latest_window_ref.close_requested.is_connected(_latest_window_ref.queue_free):
		_latest_window_ref.close_requested.connect(_latest_window_ref.queue_free)
	if not _latest_window_ref.go_back_requested.is_connected(_latest_window_ref.queue_free):
		_latest_window_ref.go_back_requested.connect(_latest_window_ref.queue_free)

	var editor:Control = _latest_window_ref.find_child("*StatSetEditorBrief*", false, false)
	if editor == null:
		editor = STAT_SET_EDITOR.instantiate()
		editor.name = "StatSetEditorBrief"
	if editor.get_parent() != _latest_window_ref:
		_latest_window_ref.add_child(editor)
	editor.stat_set = stat_set

	_latest_window_ref.transient = true
	_latest_window_ref.exclusive = true
	_latest_window_ref.wrap_controls = true
	_latest_window_ref.keep_title_visible = true
	_latest_window_ref.always_on_top = false
	_latest_window_ref.force_native = true
	_latest_window_ref.title = "Stat Set Editor"
	_latest_window_ref.popup_centered()

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
