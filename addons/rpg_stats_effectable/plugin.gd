@tool
extends EditorPlugin

## The name of this plugin, as indicated by the plugin folder name.
const PLUGIN_NAME := "rpg_stats"

## The icon of this plugin.
const PLUGIN_ICON :Texture2D = preload("./icon.svg")

func _get_plugin_name():
	return PLUGIN_NAME

func _get_plugin_icon():
	return PLUGIN_ICON
