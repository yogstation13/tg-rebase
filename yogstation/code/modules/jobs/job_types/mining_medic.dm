/datum/job/miningmedic
	title = "Mining Medic"
	flag = MMEDIC
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and the quartermaster"
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/miningmedic

	minimal_character_age = 24 // "According to age statistics published by the Association of American Medical Colleges, the average age among medical students who matriculated at U.S. medical schools in the 2017-2018 school year was 24"

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CARGO, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_MINING_MEDIC

	changed_maps = list("EclipseStation")

/datum/job/miningmedic/proc/EclipseStationChanges()
	total_positions = 2
	spawn_positions = 1

/datum/outfit/job/miningmedic
	name = "Mining Medic"
	jobtype = /datum/job/miningmedic

	backpack_contents = list(/obj/item/roller = 1,\
		/obj/item/kitchen/knife/combat/survival = 1,\
		/obj/item/gps/mining = 1)
	belt = /obj/item/storage/belt/mining/medical
	ears = /obj/item/radio/headset/headset_medcargo
	glasses = /obj/item/clothing/glasses/hud/health/meson
	shoes = /obj/item/clothing/shoes/workboots/mining
	uniform = /obj/item/clothing/under/yogs/rank/miner/medic
	l_hand = /obj/item/storage/firstaid/regular
	l_pocket =  /obj/item/pda/medical
	gloves = /obj/item/clothing/gloves/color/latex

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
 	box = /obj/item/storage/box/survival_mining

	plasmaman_uniform = /obj/item/clothing/under/plasmaman/mining
	plasmaman_head = /obj/item/clothing/head/helmet/space/plasmaman/blue
