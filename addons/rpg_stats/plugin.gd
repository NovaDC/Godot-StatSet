@tool

extends EditorPlugin

## The name of this plugin, as indicated by the plugin folder name.
const PLUGIN_NAME := "rpg_stats"

## The icon of this plugin.
const PLUGIN_ICON :Texture2D = preload("./icon.svg")

var _inspector:StatSetEditorInspectorPlugin = null

func _get_plugin_name():
	return PLUGIN_NAME

func _get_plugin_icon():
	return PLUGIN_ICON

func _enable_plugin() -> void:
	_try_add()

func _disable_plugin() -> void:
	_try_remove()

func _enter_tree() -> void:
	if EditorInterface.is_plugin_enabled(PLUGIN_NAME):
		_try_add()

func _exit_tree() -> void:
	_try_remove()

func _try_add():
	if _inspector == null:
		_inspector = StatSetEditorInspectorPlugin.new()
		add_inspector_plugin(_inspector)

func _try_remove():
	if _inspector != null:
		remove_inspector_plugin(_inspector)
		_inspector = null
