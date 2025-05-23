#define FILE_RECENT_MAPS "data/RecentMaps.json"
#define KEEP_ROUNDS_MAP 3

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE

	///instantiated wall engraving components
	var/list/wall_engravings = list()
	///all saved persistent engravings loaded from JSON
	var/list/saved_engravings = list()
	///tattoo stories that we're saving.
	var/list/prison_tattoos_to_save = list()
	///tattoo stories that have been selected for this round.
	var/list/prison_tattoos_to_use = list()
	var/list/saved_messages = list()
	var/list/saved_modes = list(1,2,3)
	var/list/saved_maps = list()
	var/list/blocked_maps = list()
	var/list/saved_trophies = list()
	var/list/picture_logging_information = list()
	var/list/obj/structure/sign/picture_frame/photo_frames
	var/list/obj/item/storage/photo_album/photo_albums
	var/rounds_since_engine_exploded = 0
	var/delam_highscore = 0
	var/tram_hits_this_round = 0
	var/tram_hits_last_round = 0

/datum/controller/subsystem/persistence/Initialize()
	load_poly()
	load_wall_engravings()
	load_prisoner_tattoos()
	load_trophies()
	load_recent_maps()
	load_photo_persistence()
	load_randomized_recipes()
	load_custom_outfits()
	load_delamination_counter()
	load_tram_counter()
	load_adventures()
	return SS_INIT_SUCCESS

///Collects all data to persist.
/datum/controller/subsystem/persistence/proc/collect_data()
	save_wall_engravings()
	save_prisoner_tattoos()
	collect_trophies()
	collect_maps()
	save_photo_persistence() //THIS IS PERSISTENCE, NOT THE LOGGING PORTION.
	save_randomized_recipes()
	save_scars()
	save_custom_outfits()
	save_modular_persistence()
	save_delamination_counter()
	if(SStramprocess.can_fire)
		save_tram_counter()
	if(GLOB.interviews)
		save_keys(GLOB.interviews.approved_ckeys)

///Loads up Poly's speech buffer.
/datum/controller/subsystem/persistence/proc/load_poly()
	for(var/mob/living/basic/parrot/poly/bird in GLOB.alive_mob_list)
		var/list/list_to_read = bird.get_static_list_of_phrases()
		twitterize(list_to_read, "polytalk")
		break //Who's been duping the bird?!

/// Loads up the amount of times maps appeared to alter their appearance in voting and rotation.
/datum/controller/subsystem/persistence/proc/load_recent_maps()
	var/map_sav = FILE_RECENT_MAPS
	if(!fexists(FILE_RECENT_MAPS))
		return
	var/list/json = json_decode(file2text(map_sav))
	if(!json)
		return
	saved_maps = json["data"]

	//Convert the mapping data to a shared blocking list, saves us doing this in several places later.
	for(var/map in config.maplist)
		var/datum/map_config/VM = config.maplist[map]
		var/run = 0
		if(VM.map_name == SSmapping.current_map.map_name)
			run++
		for(var/name in SSpersistence.saved_maps)
			if(VM.map_name == name)
				run++
		if(run >= 2) //If run twice in the last KEEP_ROUNDS_MAP + 1 (including current) rounds, disable map for voting and rotation.
			blocked_maps += VM.map_name

///Updates the list of the most recent maps.
/datum/controller/subsystem/persistence/proc/collect_maps()
	if(length(saved_maps) > KEEP_ROUNDS_MAP) //Get rid of extras from old configs.
		saved_maps.Cut(KEEP_ROUNDS_MAP+1)
	var/mapstosave = min(length(saved_maps)+1, KEEP_ROUNDS_MAP)
	if(length(saved_maps) < mapstosave) //Add extras if too short, one per round.
		saved_maps += mapstosave
	for(var/i = mapstosave; i > 1; i--)
		saved_maps[i] = saved_maps[i-1]
	saved_maps[1] = SSmapping.current_map.map_name
	var/json_file = file(FILE_RECENT_MAPS)
	var/list/file_data = list()
	file_data["data"] = saved_maps
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/save_keys(list/approved_ckeys)
	var/json_file = file("data/approved_keys.json")
	var/list/keys = list()
	if(fexists(json_file))
		fdel(json_file)
	keys = json_encode(approved_ckeys)
	WRITE_FILE(json_file, keys)

#undef FILE_RECENT_MAPS
#undef KEEP_ROUNDS_MAP
