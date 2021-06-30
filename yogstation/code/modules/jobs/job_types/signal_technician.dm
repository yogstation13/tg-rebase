/datum/job/signal_tech
	title = "Signal Technician"
	flag = SIGNALTECH
	department_head = list("Chief Engineer")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"

	outfit = /datum/outfit/job/signal_tech

	access = list(ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN, ACCESS_TECH_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_CONSTRUCTION, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP,
					ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE)
	minimal_access = list(ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN, ACCESS_TECH_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	display_order = JOB_DISPLAY_ORDER_SIGNAL_TECHNICIAN

	changed_maps = list("OmegaStation")

/datum/job/signal_tech/proc/OmegaStationChanges()
	access = list(ACCESS_ENGINE, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN)
	minimal_access = list(ACCESS_ENGINE, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN)
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/signal_tech
	name = "Signal Technician"
	jobtype = /datum/job/signal_tech

	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/pda/signaltech
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/yogs/rank/signal_tech
	suit = /obj/item/clothing/suit/hooded/wintercoat/engineering/tcomms
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots

	plasmaman_head = /obj/item/clothing/head/helmet/space/plasmaman/engineering
	plasmaman_uniform = /obj/item/clothing/under/plasmaman/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer
	pda_slot = SLOT_L_STORE
