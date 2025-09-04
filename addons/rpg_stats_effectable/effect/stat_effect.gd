@tool
@icon("../icon.svg")
class_name StatEffect
extends Resource

## StatEffect
##
## A 'effect' that can be applied to a [StatSetEffectable].[br]
## This can (and must, to achieve anything of value)
## be inherited in order to refine the behaviour of the effect.[br]
## Then, an instance of that effect can be applied (appended) to a
## [member StatSetEffectable.effects] [Array].[br]
## Read the documentation for each method of this class
## for more information on what to extend and how.[br]
## Note that the default behaviour of [StatEffect] "effect"s no stats
## and leaves values unchanged.[br]

## INTENDED AS ABSTRACT
## A method used to retrieve the effect nome for this effect.[br]
## NOTE: The effect name is not the unique identifier for the effect,
## and can change in diffrent contexts, as it's really intended for use in displays and the editor.
func get_effect_name(prototype:StatPrototype, statset:StatSet) -> String:
	assert(false, "ABSTRACT")
	return ""

## Returns the class name or path to a [PackedScene] or [Script] resource to instainate
## as a display for this effect.[br]
## Returning an empty string will result in the default display being used.
func get_effect_display_type(statset:StatSet, display_context:="") -> String:
	return ""

## INTENDED VIRTUAL
## Returns weather or not this effect would change (effect) the [param prototype] on the given
## [StatSet] [param statset] when getting the value.[br]
## NOTE: THIS SHOULD NOT CHANGE THE STAT SET AT ALL, THIS IS ONLY USED TO SEE WEATHER
## OR NOT THIS WOULD CHANGE THE STAT.
func is_effecting_getting(working_value:Variant, prototype:StatPrototype, statset:StatSet) -> bool:
	return false

## INTENDED VIRTUAL
## Returns weather or not this effect would change (effect) the [param prototype] on the given
## [StatSet] [param statset] when setting the value.[br]
## NOTE: THIS SHOULD NOT CHANGE THE STAT SET AT ALL, THIS IS ONLY USED TO SEE WEATHER
## OR NOT THIS WOULD CHANGE THE STAT.
func is_effecting_setting(working_value:Variant, prototype:StatPrototype, statset:StatSet) -> bool:
	return false

## INTENDED VIRTUAL
## The numeric order to apply this effect (compared to all other effects),
## to the [param prototype] on the given [StatSet] [param statset] when getting the value.[br]
## Smaller (more negative) priorties are always earlier than larger (more positive) priorties.
## This defaults to 0.
func effect_getting_priority(prototype:StatPrototype, statset:StatSet) -> int:
	return 0

## INTENDED VIRTUAL
## The numeric order to apply this effect (compared to all other effects),
## to the [param prototype] on the given [StatSet] [param statset] when setting the value.[br]
## Smaller (more negative) priorties are always earlier than larger (more positive) priorties.
## This defaults to 0.
func effect_setting_priority(prototype:StatPrototype, statset:StatSet) -> int:
	return 0

## INTENDED VIRTUAL
## Returns the value from the given [StatSet] [param statset]
## when effecting the getting of that stat.[br]
## This function will only be called if [method get_effects_getting_stat] returns true for the same
## [param prototype] and [param statset].[br]
## NOTE: [param stat_value] is the value that the effect should modify,
## not the value currently in [param statset].[br]
## NOTE: [param statset] is here for the sake of checking what other [StatPrototype]s are inside.
## It's heavily advised against reading any [i]values[/i] from [param statset] in this function,
## and reading [param prototype] from [param statset] if [param statset] is a [StatSetEffectable]
## will result in infinite recursion!
func effect_getting(working_value:Variant, prototype:StatPrototype, statset:StatSet) -> Variant:
	return working_value

## INTENDED VIRTUAL
## Returns the value from the given [StatSet] [param statset]
## when effecting the setting of that stat.[br]
## This function will only be called if [method get_effects_setting_stat] returns true for the same
## [param prototype] and [param statset].[br]
## NOTE: This method should [b]NOT[/b] set the [param statset] itself!
## This will cause infinite recursion.
## This method only returns the [param stat_value] after this effect effects it.
## NOTE: [param stat_value] is the value that the effect should modify,
## not the value currently in [param statset].[br]
## NOTE: [param statset] is here for the sake of checking what other [StatPrototype]s are inside.
## It's heavily advised against reading any [i]values[/i] from [param statset] in this function,
## and reading [param prototype] from [param statset] if [param statset] is a [StatSetEffectable]
## will result in infinite recursion!
func effect_setting(working_value:Variant, prototype:StatPrototype, statset:StatSet) -> Variant:
	return working_value


