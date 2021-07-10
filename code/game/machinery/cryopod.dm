/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */
GLOBAL_LIST_EMPTY(cryopods)
GLOBAL_LIST_EMPTY(cryopod_computers)

// These items are preserved when the process() despawn proc occurs.
GLOBAL_LIST_INIT(typecache_cryoitems, typecacheof(list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/mmi,
		/obj/item/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/defibrillator/compact,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/krav_maga,
		/obj/item/nullrod,
		/obj/item/tank/jetpack,
		/obj/item/documents,
		/obj/item/nuke_core_container)))

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "cellconsole_1"
	density = FALSE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = TRUE

/obj/machinery/computer/cryopod/Initialize()
	. = ..()
	GLOB.cryopod_computers += src

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	..()

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	add_fingerprint(user)

	var/dat

	dat += "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=[REF(src)];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='?src=[REF(src)];view=1'>View objects</a>.<br>"
	if(allowed(user))
		dat += "<a href='?src=[REF(src)];item=1'>Recover object</a>.<br>"
		dat += "<a href='?src=[REF(src)];allitems=1'>Recover all objects</a>.<br>"
	dat += "</BODY></HTML>"
	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)
	if(..())
		return TRUE

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["log"])
		var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
		dat += "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"
		dat += "</BODY></HTML>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return
		var/dat = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
		dat += "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"
		dat += "</BODY></HTML>"
		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return

		if(!allow_items)
			return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(user, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, "<span class='notice'>\The [I] is no longer in storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges \the [I].</span>")
		I.forceMove(drop_location())
		frozen_items -= I

	else if(href_list["allitems"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in frozen_items)
			I.forceMove(drop_location())
		frozen_items.Cut()

	updateUsrDialog()
	return

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE
	var/ready = FALSE

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"

	// 5 minutes-ish safe period before being despawned.
	var/time_till_despawn = 15 MINUTES // Time if a player gets forced into cryo
	var/time_till_despawn_online = 30 SECONDS // Time if a player manually enters cryo

	var/obj/machinery/computer/cryopod/control_computer
	var/cooldown = FALSE

/obj/machinery/cryopod/Initialize()
	..()
	GLOB.cryopods += src
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/Destroy()
	GLOB.cryopods -= src
	..()

/obj/machinery/cryopod/LateInitialize()
	update_icon()
	find_control_computer()

/obj/machinery/cryopod/proc/find_control_computer(urgent = 0)
	for(var/M in GLOB.cryopod_computers)
		var/obj/machinery/computer/cryopod/C = M
		if(get_area(C) == get_area(src))
			control_computer = C
			break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && !cooldown)
		cooldown = TRUE
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 5 MINUTES)

	return control_computer != null

/obj/machinery/cryopod/close_machine(mob/user)
	if(!control_computer)
		find_control_computer(TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		icon_state = "cryopod"
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "<span class='boldnotice'>You feel cool air surround you. You go numb as your senses turn inward.</span>")
		if(!occupant) //Check they still exist
			return
		if(mob_occupant.client)//if they're logged in
			var/offertimer = addtimer(VARSET_CALLBACK(src, ready, TRUE), time_till_despawn_online, TIMER_STOPPABLE)
			if(alert(mob_occupant, "Do you want to offer yourself to ghosts?", "Ghost Offer", "Yes", "No") == "Yes")
				deltimer(offertimer) //Player wants to offer, cancel the timer
				if(!offer_control(occupant))
					//Player is a jackass that noone wants the body of, restart the timer
					addtimer(VARSET_CALLBACK(src, ready, TRUE), (time_till_despawn * 0.1))
		else
			addtimer(VARSET_CALLBACK(src, ready, TRUE), time_till_despawn)

/obj/machinery/cryopod/open_machine()
	..()
	icon_state = "cryopod-open"
	density = TRUE
	name = initial(name)

/obj/machinery/cryopod/container_resist(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/cryopod/process()
	if(!occupant)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		// Eject dead people
		if(mob_occupant.stat == DEAD)
			open_machine()
		if(ready && !mob_occupant.client && mob_occupant.stat < 2) //Occupant is living and has no client.
			if(!control_computer)
				find_control_computer(urgent = TRUE)//better hope you found it this time
			despawn_occupant()

/obj/machinery/cryopod/proc/handle_objectives()
	var/mob/living/mob_occupant = occupant
	//Update any existing objectives involving this mob.
	for(var/thing in GLOB.objectives)
		var/datum/objective/O = thing
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(istype(O,/datum/objective/mutiny) && O.target == mob_occupant.mind)
			O.team.objectives -= O
			qdel(O)
			for(var/datum/mind/M in O.team.members)
				to_chat(M.current, "<BR><span class='userdanger'>Your target is no longer within reach. Objective removed!</span>")
				M.announce_objectives()
		else if(O.target == mob_occupant.mind)
			O.target = null
			O.find_target()
			O.update_explanation_text()

			var/list/owners = O.get_owners()

			if(!O.target && O.owner)
				qdel(O)

			for(var/M in owners)
				var/datum/mind/own = M
				to_chat(own.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
				O.owner.announce_objectives()

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant.mind && mob_occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role
		SSjob.FreeRole(job)
		if(LAZYLEN(mob_occupant.mind.objectives))
			mob_occupant.mind.objectives.Cut()
			mob_occupant.mind.special_role = null

	// Delete them from datacore.

	var/announce_rank = null
	for(var/medrecord in GLOB.data_core.medical)
		var/datum/data/record/R = medrecord
		if((R.fields["name"] == mob_occupant.real_name))
			qdel(R)
	for(var/secrecord in GLOB.data_core.security)
		var/datum/data/record/T = secrecord
		if((T.fields["name"] == mob_occupant.real_name))
			qdel(T)
	for(var/genrecord in GLOB.data_core.general)
		var/datum/data/record/G = genrecord
		if((G.fields["name"] == mob_occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)

	//Make an announcement and log the person entering storage.
	if(control_computer)
		control_computer.frozen_crew += mob_occupant.real_name

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())
		visible_message("<span class='notice'>\The [src] hums and hisses as it moves [mob_occupant.real_name] into storage.</span>")

	for(var/obj/item/W in mob_occupant.GetAllContents())
		if(QDELETED(W))
			continue
		if(W.loc.loc && (( W.loc.loc == loc ) || (W.loc.loc == control_computer)))
			continue//means we already moved whatever this thing was in
			//I'm a professional, okay
		if(is_type_in_typecache(W, GLOB.typecache_cryoitems))
			if(control_computer && control_computer.allow_items)
				control_computer.frozen_items += W
				mob_occupant.transferItemToLoc(W, control_computer, TRUE)
			else
				mob_occupant.transferItemToLoc(W, loc, TRUE)
			continue
		qdel()

	if(iscyborg(mob_occupant))
		var/mob/living/silicon/robot/R = occupant
		if(!istype(R))
			return
		R.contents -= R.mmi
		qdel(R.mmi)

	mob_occupant.ghostize(FALSE)
	handle_objectives()
	QDEL_NULL(occupant)
	for(var/obj/item/I in get_turf(src))
		if(is_type_in_typecache(I, GLOB.typecache_cryoitems))
			continue //Double safety check
		qdel(I) //Cleanup anything left
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return

	if(occupant)
		to_chat(user, "<span class='boldnotice'>The cryo pod is already occupied!</span>")
		return

	if(target.stat == DEAD)
		to_chat(user, "<span class='notice'>Dead people can not be put into cryo.</span>")
		return

	if(findtext(target.ckey, "@") || !target.mind)
		to_chat(user, "<span class='notice'>This person cannot be put in cryogenic storage!</span>")
		return

	if(user != target)
		to_chat(user, "<span class='danger'>You are unable to cryo others.</span>")
		return
	else if(target.client)
		if(alert(target,"Would you like to enter cryosleep?",,"Yes","No") == "No")
			return

	var/generic_plsnoleave_message = " Please adminhelp before leaving the round, even if there are no administrators online!"

	if(target == user && world.time - target.client.cryo_warned > 5 MINUTES)//if we haven't warned them in the last 5 minutes
		var/caught = FALSE
		var/datum/antagonist/A = target.mind.has_antag_datum(/datum/antagonist)
		if(target.mind.assigned_role in GLOB.command_positions)
			alert("You're a Head of Staff![generic_plsnoleave_message]")
			caught = TRUE
		if(A)
			alert("You're a [A.name]![generic_plsnoleave_message]")
			caught = TRUE
		if(caught)
			target.client.cryo_warned = world.time
			return

	if(!target || user.incapacitated() || !target.Adjacent(user) || !Adjacent(user) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return
		//rerun the checks in case of shenanigans

	if(occupant)
		to_chat(user, "<span class='boldnotice'>\The [src] is in use.</span>")
		return

	if(target == user)
		visible_message("[user] starts climbing into the cryo pod.")
	
	close_machine(target)
	to_chat(target, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
	name = "[name] ([occupant.name])"
	log_admin("<span class='notice'>[key_name(target)] entered a stasis pod.</span>")
	message_admins("[key_name_admin(target)] entered a stasis pod. (<A HREF='?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	add_fingerprint(target)
