/// How many jobs have bounties, minus the random civ bounties. PLEASE INCREASE THIS NUMBER AS MORE DEPTS ARE ADDED TO BOUNTIES.
#define MAXIMUM_BOUNTY_JOBS 13

/datum/bounty
	var/name
	var/description
	var/reward = 1000 // In credits.
	var/claimed = FALSE
	var/high_priority = FALSE

/datum/bounty/proc/can_claim()
	return !claimed

/// Called when the claim button is clicked. Override to provide fancy rewards.
/datum/bounty/proc/claim()
	if(can_claim())
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			D.adjust_money(reward * SSeconomy.bounty_modifier)
		claimed = TRUE

/// If an item sent in the cargo shuttle can satisfy the bounty.
/datum/bounty/proc/applies_to(obj/O)
	return FALSE

/// Called when an object is shipped on the cargo shuttle.
/datum/bounty/proc/ship(obj/O)
	return

/** Returns a new bounty of random type, but does not add it to GLOB.bounties_list.
 *
 * *Guided determines what specific catagory of bounty should be chosen.
 */
/proc/random_bounty(guided = 0)
	var/bounty_num
	var/chosen_type
	var/bounty_succeeded = FALSE
	var/datum/bounty/item/bounty_ref
	while(!bounty_succeeded)
		if(guided && (guided != CIV_JOB_RANDOM))
			bounty_num = guided
		else
			bounty_num = rand(1, MAXIMUM_BOUNTY_JOBS)
		switch(bounty_num)
			if(CIV_JOB_BASIC)
				chosen_type = pick(subtypesof(/datum/bounty/item/assistant))
			if(CIV_JOB_ROBO) //monkestation edit: bot bounties
				if(prob(50))
					chosen_type = pick(subtypesof(/datum/bounty/item/mech))
				else
					chosen_type = pick(subtypesof(/datum/bounty/item/bot))
			if(CIV_JOB_CHEF)
				chosen_type = pick(subtypesof(/datum/bounty/item/chef) + subtypesof(/datum/bounty/reagent/chef))
			if(CIV_JOB_SEC)
				chosen_type = pick(subtypesof(/datum/bounty/item/security))
			if(CIV_JOB_DRINK)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/simple_drink
				else
					chosen_type = /datum/bounty/reagent/complex_drink
			if(CIV_JOB_CHEM)
				if(prob(50))
					chosen_type = /datum/bounty/reagent/chemical_simple
				else
					chosen_type = /datum/bounty/reagent/chemical_complex
			if(CIV_JOB_VIRO)
				chosen_type = /datum/bounty/item/virus // Monkestation Edit: Pathology Bounties
			if(CIV_JOB_SCI)
				chosen_type = pick(subtypesof(/datum/bounty/item/science))
			if(CIV_JOB_XENO)
				chosen_type = pick(subtypesof(/datum/bounty/item/slime))
			if(CIV_JOB_SCI_HEAD) //monkestation addition : RD bounties. 50% for science bounty, 50% for robo bounty.
				if(prob(50))
					if(prob(50))
						chosen_type = pick(subtypesof(/datum/bounty/item/science))
					else
						chosen_type = pick(subtypesof(/datum/bounty/item/slime))
				else
					if(prob(50))
						chosen_type = pick(subtypesof(/datum/bounty/item/mech))
					else
						chosen_type = pick(subtypesof(/datum/bounty/item/bot))
			if(CIV_JOB_ENG)
				chosen_type = pick(subtypesof(/datum/bounty/item/engineering))
			if(CIV_JOB_MINE)
				chosen_type = pick(subtypesof(/datum/bounty/item/mining))
			if(CIV_JOB_MED)
				chosen_type = pick(subtypesof(/datum/bounty/item/medical))
			if(CIV_JOB_GROW)
				chosen_type = pick(subtypesof(/datum/bounty/item/botany))
			if(CIV_JOB_ATMOS)
				chosen_type = pick(subtypesof(/datum/bounty/item/atmospherics))
		bounty_ref = new chosen_type
		if(bounty_ref.can_get())
			bounty_succeeded = TRUE
		else
			qdel(bounty_ref)
	return bounty_ref

#undef MAXIMUM_BOUNTY_JOBS
