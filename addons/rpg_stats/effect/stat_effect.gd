@tool

extends Resource
class_name StatEffect

## INTENDED AS ABSTRACT
## A method used to retreve the effect nome for this effect.[br]
## The effect name is not the unique identifier for the effect,
## and can change in diffrent contexts, as it's really intended for use in displays.
func get_effect_name(prototype:StatPrototype, statset:StatSet) -> String:
	assert(false, "ABSTRACT")
	return ""

## INTENDED ABSTRACT
## Returns waether or not this effect would change (effect) the [param prototype] on the given
## [StatSet] [param statset] when getting the value.[br]
## NOTE: THIS SHOULD NOT CHANGE THE STAT SET AT ALL, THIS IS ONLY USED TO SEE WEATHER
## OR NOT THIS WOULD CHANGE THE STAT.
func get_effects_getting_stat(prototype:StatPrototype, statset:StatSet) -> bool:
	assert(false, "ABSTRACT")
	return false

## INTENDED ABSTRACT
## Returns waether or not this effect would change (effect) the [param prototype] on the given
## [StatSet] [param statset] when setting the value.[br]
## NOTE: THIS SHOULD NOT CHANGE THE STAT SET AT ALL, THIS IS ONLY USED TO SEE WEATHER
## OR NOT THIS WOULD CHANGE THE STAT.
func get_effects_setting_stat(prototype:StatPrototype, statset:StatSet) -> bool:
	assert(false, "ABSTRACT")
	return false

## The numeric order to apply this effect (compared to all other effects),
## to the [param prototype] on the given [StatSet] [param statset] when getting the value.[br]
## Smaller (more negitive) priorties are always ealrier than larger (more positive) priorties.
## This defaults to 0.
func get_effects_getting_priorty(prototype:StatPrototype, statset:StatSet) -> int:
	return 0

## The numeric order to apply this effect (compared to all other effects),
## to the [param prototype] on the given [StatSet] [param statset] when setting the value.[br]
## Smaller (more negitive) priorties are always ealrier than larger (more positive) priorties.
## This defaults to 0.
func get_effects_setting_priorty(prototype:StatPrototype, statset:StatSet) -> int:
	return 0

## INTENDED ABSTRACT
## Returns the value from the given [StatSet] [param statset] when effecting the getting of that stat.[br]
## This fucntion will only be called if [method get_effects_getting_stat] returns true for the same
## [param prototype] and [param statset].[br]
## NOTE: [param stat_value] is the value that the effect should modify,
## not the value currently in [param statset].[br]
## NOTE: [param statset] is here for the sake of chjecking what other [StatPrototype]s are inside.
## It's heavily advised against reading any [i]values[/i] from [param statset] in this function, 
## and reading [param prototype] from [param statset] if [param statset] is a [StatSetEffectable]
## will result in infinite recursion!
func pre_stat_get(prototype:StatPrototype, statset:StatSet, stat_value:Variant) -> Variant:
	assert(false, "ABSTRACT")
	return null

### INTENDED ABSTRACT
## Returns the value from the given [StatSet] [param statset] when effecting the setting of that stat.[br]
## This fucntion will only be called if [method get_effects_setting_stat] returns true for the same
## [param prototype] and [param statset].[br]
## NOTE: This method should [b]NOT[/b] set the [param statset] itself! This will cause inifnite recursion.
## This method only returns the [param stat_value] after this effect effects it.
## NOTE: [param stat_value] is the value that the effect should modify,
## not the value currently in [param statset].[br]
## NOTE: [param statset] is here for the sake of chjecking what other [StatPrototype]s are inside.
## It's heavily advised against reading any [i]values[/i] from [param statset] in this function, 
## and reading [param prototype] from [param statset] if [param statset] is a [StatSetEffectable]
## will result in infinite recursion!
func pre_stat_set(prototype:StatPrototype, statset:StatSet, stat_value:Variant) -> Variant:
	assert(false, "ABSTRACT")
	return null

## Returns the class name or path to a [PackedScene] or [Script] resource to instainate
## as a display for this effect.[br]
## Returning an empty string will result in the default display being used.
func get_effect_display_type(statset:StatSet, display_context:="") -> String:
	return ""
