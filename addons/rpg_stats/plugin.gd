@tool

extends EditorPlugin

## The name of this plugin, as indicated by the plugin folder name.
const PLUGIN_NAME := "rpg_stats"

## The icon of this plugin.
const PLUGIN_ICON :Texture2D = preload("./icon.svg")

var _inspector:StatSetEditorInspectorPlugin = null

const ENSURE_SCRIPT_DOCS:Array[Script] = [
	preload("./prototype/stat_prototype.gd"),
	preload("./prototype/stat_prototype_numeric.gd"),
	preload("./sets/inspector_plugin.gd"),
	preload("./sets/stat_set.gd"),
	preload("./sets/stat_set_display_default.gd"),
	preload("./stat/stat_display_base.gd"),
	preload("./stat/stat_display_default.gd"),
]

# Every once ands a while the script docs simply refuse to update properly.
# This nudges the docs into a ensuring that the important scripts added by
# this addon are actually loaded.
func _ensure_script_docs():
	var edit := get_editor_interface().get_script_editor()
	for scr in ENSURE_SCRIPT_DOCS:
		edit.update_docs_from_script(scr)

func _get_plugin_name():
	return PLUGIN_NAME

func _get_plugin_icon():
	return PLUGIN_ICON

func _enable_plugin() -> void:
	_ensure_script_docs()
	_try_add()

func _disable_plugin() -> void:
	_try_remove()

func _enter_tree() -> void:
	_ensure_script_docs()
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
