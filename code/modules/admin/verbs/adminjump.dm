/client/proc/jumptoarea(area/A in get_sorted_areas())
	set name = "Jump to Area"
	set desc = "Area to jump to"
	set category = "Admin.Game"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	if(!A)
		return

	var/list/turfs = list()
	for (var/list/zlevel_turfs as anything in A.get_zlevel_turf_lists())
		for (var/turf/area_turf as anything in zlevel_turfs)
			if(!area_turf.density)
				turfs.Add(area_turf)

	if(length(turfs))
		var/turf/T = pick(turfs)
		usr.forceMove(T)
		log_admin("[key_name(usr)] jumped to [AREACOORD(T)]")
		message_admins("[key_name_admin(usr)] jumped to [AREACOORD(T)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Area") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	else
		to_chat(src, "Nowhere to jump to!", confidential = TRUE)
		return


/client/proc/jumptoturf(turf/T in world)
	set name = "Jump to Turf"
	set category = "Admin.Game"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	log_admin("[key_name(usr)] jumped to [AREACOORD(T)]")
	message_admins("[key_name_admin(usr)] jumped to [AREACOORD(T)]")
	usr.forceMove(T)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Turf") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/client/proc/jumptomob(mob/M in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Jump to Mob"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [ADMIN_LOOKUPFLW(M)] at [AREACOORD(M)]")
	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = get_turf(M)
		if(T && isturf(T))
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			A.forceMove(M.loc)
		else
			to_chat(A, "This mob is not located in the game world.", confidential = TRUE)

/client/proc/jumptocoord(tx as num, ty as num, tz as num)
	set category = "Admin.Game"
	set name = "Jump to Coordinate"

	if (!holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	if(src.mob)
		var/mob/A = src.mob
		var/turf/T = locate(tx,ty,tz)
		A.forceMove(T)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Coordiate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("[key_name_admin(usr)] jumped to coordinates [tx], [ty], [tz]")

/client/proc/jumptokey()
	set category = "Admin.Game"
	set name = "Jump to Key"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sort_key(keys)
	if(!selection)
		to_chat(src, "No keys found.", confidential = TRUE)
		return
	var/mob/M = selection.mob
	log_admin("[key_name(usr)] jumped to [key_name(M)]")
	message_admins("[key_name_admin(usr)] jumped to [ADMIN_LOOKUPFLW(M)]")

	usr.forceMove(M.loc)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Jump To Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/Getmob(mob/M in GLOB.mob_list - GLOB.dummy_mob_list)
	set category = "Admin.Game"
	set name = "Get Mob"
	set desc = "Mob to teleport"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	var/atom/loc = get_turf(usr)
	M.admin_teleport(loc)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/// Proc to hook user-enacted teleporting behavior and keep logging of the event.
/atom/movable/proc/admin_teleport(atom/new_location)
	if(isnull(new_location))
		log_admin("[key_name(usr)] teleported [key_name(src)] to nullspace")
		moveToNullspace()
	else
		var/turf/location = get_turf(new_location)
		log_admin("[key_name(usr)] teleported [key_name(src)] to [AREACOORD(location)]")
		forceMove(new_location)

/mob/admin_teleport(atom/new_location)
	var/turf/location = get_turf(new_location)
	var/msg = "[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(src)] to [isnull(new_location) ? "nullspace" : ADMIN_VERBOSEJMP(location)]"
	message_admins(msg)
	admin_ticket_log(src,  "[key_name(usr)] teleported [src] to [isnull(new_location) ? "nullspace" : location]") // MONKESTATION EDIT - tgui tickets
	return ..()


/client/proc/Getkey()
	set category = "Admin.Game"
	set name = "Get Key"
	set desc = "Key to teleport"

	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return

	var/list/keys = list()
	for(var/mob/M in GLOB.player_list)
		keys += M.client
	var/client/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in sort_key(keys)
	if(!selection)
		return
	var/mob/M = selection.mob

	if(!M)
		return
	// MONKESTATION EDIT START - tgui tickets
	var/log_msg = "[key_name(usr)] teleported [key_name(M)]"
	log_admin(log_msg)
	var/msg = "[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(M)]"
	message_admins(msg)
	admin_ticket_log(M, log_msg)
	// MONKESTATION EDIT END
	if(M)
		M.forceMove(get_turf(usr))
		usr.forceMove(M.loc)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Get Key") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sendmob(mob/jumper in sort_mobs())
	set category = "Admin.Game"
	set name = "Send Mob"
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	var/list/sorted_areas = get_sorted_areas()
	if(!length(sorted_areas))
		to_chat(src, "No areas found.", confidential = TRUE)
		return
	var/area/target_area = tgui_input_list(src, "Pick an area", "Send Mob", sorted_areas)
	if(isnull(target_area))
		return
	if(!istype(target_area))
		return
	var/list/turfs = get_area_turfs(target_area)
	if(length(turfs) && jumper.forceMove(pick(turfs)))
		// MONKESTATION EDIT START - tgui tickets
		var/log_msg = "[key_name(usr)] teleported [key_name(jumper)] to [AREACOORD(jumper)]"
		log_admin(log_msg)
		var/msg = "[key_name_admin(usr)] teleported [ADMIN_LOOKUPFLW(jumper)] to [AREACOORD(jumper)]"
		message_admins(msg)
		admin_ticket_log(jumper, log_msg)
		// MONKESTATION EDIT END
	else
		to_chat(src, "Failed to move mob to a valid location.", confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Send Mob") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
