/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_status_effects.dm with the name "/datum/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/slimecross/stabilized
	name = "stabilized extract"
	desc = "It seems inert, but anything it touches glows softly..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/status_effect/linked_effect

/obj/item/slimecross/stabilized/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/slimecross/stabilized/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(linked_effect)
	return ..()

/// Returns the mob that is currently holding us if we are either in their inventory or a backpack analogue.
/// Returns null if it's in an invalid location, so that we can check explicitly for null later.
/obj/item/slimecross/stabilized/proc/get_held_mob()
	if(isnull(loc))
		return null
	if(isliving(loc))
		return loc
	// Snowflake check for modsuit backpacks, which should be valid but are 3 rather than 2 steps from the owner
	if(istype(loc, /obj/item/mod/module/storage))
		var/obj/item/mod/module/storage/mod_backpack = loc
		var/mob/living/modsuit_wearer = mod_backpack.mod?.wearer
		return modsuit_wearer ? modsuit_wearer : null
	var/nested_loc = loc.loc
	if (isliving(nested_loc))
		return nested_loc
	return null

/obj/item/slimecross/stabilized/process()
	if(!QDELETED(linked_effect))
		return
	var/mob/living/holder = get_held_mob()
	if(isnull(holder))
		return
	var/effectpath = /datum/status_effect/stabilized
	var/static/list/effects = subtypesof(/datum/status_effect/stabilized)
	for(var/datum/status_effect/stabilized/effect as anything in effects)
		if(initial(effect.colour) != colour)
			continue
		effectpath = effect
		break
	if(!holder.has_status_effect(effectpath))
		holder.apply_status_effect(effectpath, src)

//Colors and subtypes:
/obj/item/slimecross/stabilized/grey
	colour = "grey"
	effect_desc = "Makes slimes friendly to the owner"

/obj/item/slimecross/stabilized/orange
	colour = "orange"
	effect_desc = "Passively tries to increase or decrease the owner's body temperature to normal"

/obj/item/slimecross/stabilized/purple
	colour = "purple"
	effect_desc = "Provides a regeneration effect"

/obj/item/slimecross/stabilized/blue
	colour = "blue"
	effect_desc = "Makes the owner immune to slipping on water, soap or foam. Space lube and ice are still too slippery."

/obj/item/slimecross/stabilized/metal
	colour = "metal"
	effect_desc = "Every 30 seconds, adds a sheet of material to a random stack in the owner's backpack."

/obj/item/slimecross/stabilized/yellow
	colour = "yellow"
	effect_desc = "Every ten seconds it recharges a device on the owner by 10%."

/obj/item/slimecross/stabilized/darkpurple
	colour = "dark purple"
	effect_desc = "Gives you burning fingertips, automatically cooking any microwavable food you hold."

/obj/item/slimecross/stabilized/darkblue
	colour = "dark blue"
	effect_desc = "Slowly extinguishes the owner if they are on fire, also wets items like monkey cubes, creating a monkey."

/obj/item/slimecross/stabilized/silver
	colour = "silver"
	effect_desc = "Slows the rate at which the owner loses nutrition"

/obj/item/slimecross/stabilized/bluespace
	colour = "bluespace"
	effect_desc = "On a two minute cooldown, when the owner has taken enough damage, they are teleported to a safe place."

/obj/item/slimecross/stabilized/sepia
	colour = "sepia"
	effect_desc = "Randomly adjusts the owner's speed."

/obj/item/slimecross/stabilized/cerulean
	colour = "cerulean"
	effect_desc = "Creates a duplicate of the owner. If the owner dies they will take control of the duplicate, unless the death was from beheading or gibbing."

/obj/item/slimecross/stabilized/pyrite
	colour = "pyrite"
	effect_desc = "Randomly colors the owner every few seconds."

/obj/item/slimecross/stabilized/red
	colour = "red"
	effect_desc = "Nullifies all equipment based slowdowns."

/obj/item/slimecross/stabilized/green
	colour = "green"
	effect_desc = "Changes the owner's name and appearance while holding this extract."

/obj/item/slimecross/stabilized/pink
	colour = "pink"
	effect_desc = "As long as no creatures are harmed in the owner's presense, they will not attack you. If the peace is broken it takes two minutes to restore."

/obj/item/slimecross/stabilized/gold
	colour = "gold"
	effect_desc = "Creates a pet when held."
	var/mob_type
	var/datum/mind/saved_mind
	var/mob_name = "Familiar"

/obj/item/slimecross/stabilized/gold/proc/generate_mobtype()
	var/static/list/mob_spawn_pets = list()
	if(!length(mob_spawn_pets))
		for(var/mob/living/simple_animal/animal as anything in subtypesof(/mob/living/simple_animal))
			if(initial(animal.gold_core_spawnable) == FRIENDLY_SPAWN)
				mob_spawn_pets += animal
		for(var/mob/living/basic/basicanimal as anything in subtypesof(/mob/living/basic))
			if(initial(basicanimal.gold_core_spawnable) == FRIENDLY_SPAWN)
				mob_spawn_pets += basicanimal
	mob_type = pick(mob_spawn_pets)

/obj/item/slimecross/stabilized/gold/Initialize(mapload)
	. = ..()
	generate_mobtype()

/obj/item/slimecross/stabilized/gold/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Which do you want to reset?", "Familiar Adjustment", sort_list(list("Familiar Location", "Familiar Species", "Familiar Sentience", "Familiar Name")))
	if(isnull(choice))
		return
	if(!user.can_perform_action(src))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_status_effect(/datum/status_effect/stabilized/gold))
			L.remove_status_effect(/datum/status_effect/stabilized/gold)
	if(choice == "Familiar Location")
		to_chat(user, span_notice("You prod [src], and it shudders slightly."))
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Species")
		to_chat(user, span_notice("You squeeze [src], and a shape seems to shift around inside."))
		generate_mobtype()
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Sentience")
		to_chat(user, span_notice("You poke [src], and it lets out a glowing pulse."))
		saved_mind = null
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Name")
		var/newname = sanitize_name(tgui_input_text(user, "Would you like to change the name of [mob_name]", "Name change", mob_name, MAX_NAME_LEN))
		if(newname)
			mob_name = newname
		to_chat(user, span_notice("You speak softly into [src], and it shakes slightly in response."))
		START_PROCESSING(SSobj, src)

/obj/item/slimecross/stabilized/oil
	colour = "oil"
	effect_desc = "The owner will violently explode when they die while holding this extract."

/obj/item/slimecross/stabilized/black
	colour = "black"
	effect_desc = "While strangling someone, the owner's hands melt around their neck, draining their life in exchange for food and healing."

/obj/item/slimecross/stabilized/lightpink
	colour = "light pink"
	effect_desc = "The owner moves at high speeds while holding this extract, also stabilizes anyone in critical condition around you using Epinephrine."

/obj/item/slimecross/stabilized/adamantine
	colour = "adamantine"
	effect_desc = "Owner gains a slight boost in damage resistance to all types."

/obj/item/slimecross/stabilized/rainbow
	colour = "rainbow"
	effect_desc = "Accepts a regenerative extract and automatically uses it if the owner enters a critical condition."
	var/obj/item/slimecross/regenerative/regencore

/obj/item/slimecross/stabilized/rainbow/Destroy()
	if(!QDELETED(regencore))
		regencore.forceMove(drop_location())
	regencore = null
	return ..()

/obj/item/slimecross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/slimecross/regenerative/regen = O
	if(istype(regen) && !regencore)
		to_chat(user, span_notice("You place [O] in [src], prepping the extract for automatic application!"))
		regencore = regen
		regen.forceMove(src)
		return
	return ..()
