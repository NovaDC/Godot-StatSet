@tool

extends EditorInspectorPlugin
class_name StatSetEditorInspectorPlugin

const STAT_SET_EDITOR_BRIEF = preload("res://addons/rpg_stats/sets/stat_set_editor_brief.tscn")

func _can_handle(object):
	return object is StatSet

func _parse_category(object, category):
	if category == "stat_set.gd":
		var editor_brief = STAT_SET_EDITOR_BRIEF.instantiate()
		editor_brief.stat_set = object
		add_custom_control(editor_brief)
