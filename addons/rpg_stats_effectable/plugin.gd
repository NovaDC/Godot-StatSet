@tool
extends EditorPlugin

## The name of this plugin, as indicated by the plugin folder name.
const PLUGIN_NAME := "rpg_stats"

## The icon of this plugin.
const PLUGIN_ICON :Texture2D = preload("./icon.svg")

const ENSURE_SCRIPT_DOCS:Array[Script] = [
	preload("./effect/stat_effect.gd"),
	preload("./set/stat_set_effectable.gd"),
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

func _enter_tree():
	_ensure_script_docs()

func _enable_plugin():
	_ensure_script_docs()
