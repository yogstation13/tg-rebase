/datum/job/paramedic
	title = "Paramedic"
	flag = PARAMEDIC
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/paramedic
	
	minimal_character_age = 24 // "According to age statistics published by the Association of American Medical Colleges, the average age among medical students who matriculated at U.S. medical schools in the 2017-2018 school year was 24"

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_PARAMEDIC, ACCESS_CLONING, ACCESS_MECH_MEDICAL)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_PARAMEDIC, ACCESS_MECH_MEDICAL)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_PARAMEDIC

	changed_maps = list("OmegaStation", "EclipseStation")

/datum/job/paramedic/proc/OmegaStationChanges()
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain and the head of personnel"

/datum/job/paramedic/proc/EclipseStationChanges()
	total_positions = 4
	spawn_positions = 2

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic

	backpack_contents = list(/obj/item/storage/firstaid/regular)
	belt = /obj/item/pda/para
	ears = /obj/item/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/medical
	suit = /obj/item/clothing/suit/toggle/labcoat/emt
	shoes = /obj/item/clothing/shoes/sneakers/white
	l_hand = /obj/item/roller
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/gps

	plasmaman_head = /obj/item/clothing/head/helmet/space/plasmaman/blue
	plasmaman_uniform = /obj/item/clothing/under/plasmaman/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
