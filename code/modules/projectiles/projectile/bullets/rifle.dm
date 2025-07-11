// 5.56mm (M-90gl Carbine)

/obj/projectile/bullet/a556
	name = "5.56mm bullet"
	damage = 35
	armour_penetration = 75
	wound_bonus = -40

/obj/projectile/bullet/a556/weak //centcom
	damage = 20

/obj/projectile/bullet/a556/phasic
	name = "5.56mm phasic bullet"
	icon_state = "gaussphase"
	damage = 20
	armour_penetration = 80
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

// 7.62 (Nagant Rifle)

/obj/projectile/bullet/a762
	name = "7.62 bullet"
	damage = 60
	armour_penetration = 0
	armour_ignorance = 10
	wound_bonus = -45
	wound_falloff_tile = 0

/obj/projectile/bullet/a762/surplus
	name = "7.62 surplus bullet"
	weak_against_armour = TRUE //this is specifically more important for fighting carbons than fighting noncarbons. Against a simple mob, this is still a full force bullet
	armour_ignorance = 0

/obj/projectile/bullet/a762/enchanted
	name = "enchanted 7.62 bullet"
	damage = 20
	stamina = 80

// Harpoons (Harpoon Gun)

/obj/projectile/bullet/harpoon
	name = "harpoon"
	icon_state = "gauss"
	damage = 60
	armour_penetration = 80
	wound_bonus = -20
	bare_wound_bonus = 80
	embedding = list(embed_chance=100, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)
	wound_falloff_tile = -5

// Rebar (Rebar Crossbow)
/obj/projectile/bullet/rebar
	name = "rebar"
	icon_state = "rebar"
	damage = 30
	speed = 0.4
	dismemberment = 1 //because a 1 in 100 chance to just blow someones arm off is enough to be cool but also not enough to be reliable
	armour_penetration = 20
	wound_bonus = -20
	bare_wound_bonus = 20
	embedding = list("embed_chance" = 60, "fall_chance" = 2, "jostle_chance" = 2, "ignore_throwspeed_threshold" = TRUE, "pain_stam_pct" = 0.4, "pain_mult" = 4, "jostle_pain_mult" = 2, "rip_time" = 10)
	embed_falloff_tile = -5
	wound_falloff_tile = -2
	shrapnel_type = /obj/item/ammo_casing/rebar

/obj/projectile/bullet/rebar/proc/handle_drop(datum/source, obj/item/ammo_casing/rebar/newcasing)

/obj/projectile/bullet/rebar/syndie
	name = "rebar"
	icon_state = "rebar"
	damage = 60
	dismemberment = 2 //It's a budget sniper rifle.
	armour_penetration = 30 //A bit better versus armor.
	armour_ignorance = 10 //Makes it one tap limbs against about the same level of armour as it did before the AP rework
	wound_bonus = 10
	bare_wound_bonus = 20
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/syndie

/obj/projectile/bullet/rebar/zaukerite
	name = "zaukerite shard"
	icon_state = "rebar_zaukerite"
	damage = 60
	speed = 0.6
	dismemberment = 10
	damage_type = TOX
	eyeblur = 5
	armour_penetration = 20 // not nearly as good, as its not as sharp.
	wound_bonus = 10
	bare_wound_bonus = 40
	embedding = list("embed_chance" =100, "fall_chance" = 0, "jostle_chance" = 5, "ignore_throwspeed_threshold" = TRUE, "pain_stam_pct" = 0.8, "pain_mult" = 6, "jostle_pain_mult" = 2, "rip_time" = 30)
	embed_falloff_tile = 0 // very spiky.
	shrapnel_type = /obj/item/ammo_casing/rebar/zaukerite

/obj/projectile/bullet/rebar/hydrogen
	name = "metallic hydrogen bolt"
	icon_state = "rebar_hydrogen"
	damage = 45
	speed = 0.6
	projectile_piercing = PASSMOB|PASSVEHICLE
	projectile_phasing = ~(PASSMOB|PASSVEHICLE)
	max_pierces = 3
	phasing_ignore_direct_target = TRUE
	dismemberment = 0 //goes through clean.
	damage_type = BRUTE
	armour_penetration = 75 //very pointy.
	projectile_piercing = PASSMOB //felt this might have been a nice compromise for the lower damage for the difficulty of getting it
	wound_bonus = -15
	bare_wound_bonus = 10
	shrapnel_type = /obj/item/ammo_casing/rebar/hydrogen
	embedding = list("embed_chance" = 50, "fall_chance" = 2, "jostle_chance" = 3, "ignore_throwspeed_threshold" = TRUE, "pain_stam_pct" = 0.6, "pain_mult" = 4, "jostle_pain_mult" = 2, "rip_time" =18)
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/hydrogen
	accurate_range = 205 //15 tiles before falloff starts to kick in

/obj/projectile/bullet/rebar/hydrogen/Impact(atom/A) // TODO projectile refactor
	. = ..()
	def_zone = ran_zone(def_zone, clamp(205-(7*get_dist(get_turf(A), starting)), 5, 100))

/obj/projectile/bullet/rebar/hydrogen/on_hit(atom/target, blocked, pierce_hit)
	if(isAI(target))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/projectile/bullet/rebar/healium
	name = "healium bolt"
	icon_state = "rebar_healium"
	damage = 0
	dismemberment = 0
	damage_type = BRUTE
	armour_penetration = 100
	wound_bonus = -100
	bare_wound_bonus = -100
	embedding = list(embed_chance = 0)
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/healium

/obj/projectile/bullet/rebar/healium/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return BULLET_ACT_HIT
	var/mob/living/breather = target
	breather.SetSleeping(3 SECONDS)
	breather.adjustFireLoss(-30, updating_health = TRUE, required_bodytype = BODYTYPE_ORGANIC)
	breather.adjustToxLoss(-30, updating_health = TRUE, required_biotype = BODYTYPE_ORGANIC)
	breather.adjustBruteLoss(-30, updating_health = TRUE, required_bodytype = BODYTYPE_ORGANIC)
	breather.adjustOxyLoss(-30, updating_health = TRUE, required_biotype = BODYTYPE_ORGANIC, required_respiration_type = ALL)

	return BULLET_ACT_HIT

/obj/projectile/bullet/rebar/supermatter
	name = "supermatter bolt"
	icon_state = "rebar_supermatter"
	damage = 0
	dismemberment = 0
	damage_type = TOX
	armour_penetration = 100
	shrapnel_type = /obj/item/ammo_casing/rebar/supermatter

/obj/projectile/bullet/rebar/supermatter/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		dust_feedback(target)
		victim.dust()

	else if(!isturf(target)&& !isliving(target))
		dust_feedback(target)
		qdel(target)

	return BULLET_ACT_HIT

/obj/projectile/bullet/rebar/supermatter/proc/dust_feedback(atom/target)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 10, TRUE)
	visible_message(span_danger("[target] is hit by [src], turning [target.p_them()] to dust in a brilliant flash of light!"))

/obj/projectile/bullet/paperball
	desc = "Doink!"
	damage = 1 // It's a damn toy.
	range = 10
	shrapnel_type = null
	name = "paper ball"
	desc = "doink!"
	damage_type = BRUTE
	icon_state = "paperball"

/obj/projectile/bullet/a223
	name = ".223 bullet"
	damage = 35
	armour_penetration = 40
	wound_bonus = -40

/obj/projectile/bullet/a223/weak //centcom
	damage = 20

/obj/projectile/bullet/a223/phasic
	name = ".223 phasic bullet"
	icon_state = "gaussphase"
	damage = 30
	armour_penetration = 100
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS
