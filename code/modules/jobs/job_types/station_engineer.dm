/datum/job/engineer
	title = "Station Engineer"
	flag = ENGINEER
	department_head = list("Chief Engineer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/engineer

	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
									ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
									ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG

	display_order = JOB_DISPLAY_ORDER_STATION_ENGINEER

	changed_maps = list("EclipseStation", "OmegaStation")

/datum/job/engineer/proc/EclipseStationChanges()
	total_positions = 6
	spawn_positions = 5

/datum/job/engineer/proc/OmegaStationChanges()
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS )
	minimal_access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS )
	supervisors = "the captain and the head of personnel"

GLOBAL_LIST_INIT(available_depts_eng, list(ENG_DEPT_MEDICAL, ENG_DEPT_SCIENCE, ENG_DEPT_SUPPLY, ENG_DEPT_SERVICE))

/datum/job/engineer/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign department engineering
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.prefered_engineering_department
		if(!LAZYLEN(GLOB.available_depts_eng) || department == "None")
			return
		else if(department in GLOB.available_depts_eng)
			LAZYREMOVE(GLOB.available_depts_eng, department)
		else
			department = pick_n_take(GLOB.available_depts_eng)
	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	switch(department)
		if(ENG_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_eng/department/supply
			dep_access = list(ACCESS_MAILSORTING, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_CARGO)
			accessory = /obj/item/clothing/accessory/armband/cargo
		if(ENG_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_eng/department/med
			dep_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_GENETICS)
			accessory =  /obj/item/clothing/accessory/armband/medblue
		if(ENG_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_eng/department/sci
			dep_access = list(ACCESS_RESEARCH, ACCESS_TOX, ACCESS_XENOBIOLOGY, ACCESS_TOX_STORAGE)
			accessory = /obj/item/clothing/accessory/armband/science
		if(ENG_DEPT_SERVICE)
			ears = /obj/item/radio/headset/headset_eng/department/service
			dep_access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_JANITOR, ACCESS_CHAPEL_OFFICE)
			accessory =  /obj/item/clothing/accessory/armband/service

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		U.attach_accessory(new accessory)
	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),SLOT_EARS)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access

	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	belt = /obj/item/storage/belt/utility/full/engi
	l_pocket = /obj/item/pda/engineering
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/workboots
	head = /obj/item/clothing/head/hardhat
	r_pocket = /obj/item/t_scanner

	plasmaman_head = /obj/item/clothing/head/helmet/space/plasmaman/engineering
	plasmaman_uniform = /obj/item/clothing/under/plasmaman/engineering
	
	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer
	pda_slot = SLOT_L_STORE
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced=1)

/datum/outfit/job/engineer/gloved
	name = "Station Engineer (Gloves)"
	gloves = /obj/item/clothing/gloves/color/yellow

/datum/outfit/job/engineer/gloved/rig
	name = "Station Engineer (Hardsuit)"
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/engine
	suit_store = /obj/item/tank/internals/oxygen
	head = null
	internals_slot = SLOT_S_STORE

/obj/item/radio/headset/headset_eng/department/Initialize()
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
	recalculateChannels()

/obj/item/radio/headset/headset_eng/department/supply
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_eng/department/med
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_eng/department/sci
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_eng/department/service
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_service
