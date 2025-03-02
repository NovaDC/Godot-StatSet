@tool

extends EditorPlugin

const PLUGIN_NAME := "rpg_stats"
var _inspector:StatSetEditorInspectorPlugin = null

func _try_add():
	if _inspector == null:
		_inspector = StatSetEditorInspectorPlugin.new()
		add_inspector_plugin(_inspector)

func _try_remove():
	if _inspector != null:
		remove_inspector_plugin(_inspector)
		_inspector = null

func _get_plugin_name():
	return PLUGIN_NAME

func _enable_plugin() -> void:
	_try_add()

func _disable_plugin() -> void:
	_try_remove()

func _enter_tree() -> void:
	if EditorInterface.is_plugin_enabled(PLUGIN_NAME):
		_try_add()

func _exit_tree() -> void:
	_try_remove()
