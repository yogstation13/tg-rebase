/datum/techweb_node/mmi // so we don't have nodes floating in the middle of nowhere.
	prereq_ids = list("base")

/datum/techweb_node/cyborg
	prereq_ids = list("base")

/datum/techweb_node/mech
	prereq_ids = list("base")

/datum/techweb_node/mech_tools
	prereq_ids = list("base")

/datum/techweb_node/basic_tools
	prereq_ids = list("base")

/datum/techweb_node/spacepod_basic
	id = "spacepod_basic"
	display_name = "Spacepod Construction"
	description = "Basic stuff to construct Spacepods. Don't crash your first spacepod into the station, especially while going more than 10 m/s."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	export_price = 2500
	prereq_ids = list("base")
	design_ids = list("podcore", "podarmor_civ", "podarmor_dark", "spacepod_main")

/datum/techweb_node/spacepod_lock
	id = "spacepod_lock"
	display_name = "Spacepod Security"
	description = "Keeps greytiders out of your spacepods."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2750)
	export_price = 2750
	prereq_ids = list("spacepod_basic", "engineering")
	design_ids = list("podlock_keyed", "podkey", "podmisc_tracker")

/datum/techweb_node/spacepod_disabler
	id = "spacepod_disabler"
	display_name = "Spacepod Weaponry"
	description = "For a bit of pew pew space battles"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	export_price = 3500
	prereq_ids = list("spacepod_basic", "weaponry")
	design_ids = list("podgun_disabler")

/datum/techweb_node/spacepod_lasers
	id = "spacepod_lasers"
	display_name = "Advanced Spacepod Weaponry"
	description = "For a lot of pew pew space battles. PEW PEW PEW!! Shit, I missed. I need better aim. Whatever."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5250)
	export_price = 5250
	prereq_ids = list("spacepod_disabler", "electronic_weapons")
	design_ids = list("podgun_laser", "podgun_bdisabler")

/datum/techweb_node/spacepod_ka
	id = "spacepod_ka"
	display_name = "Spacepod Mining Tech"
	description = "Cutting up asteroids using your spacepods"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	export_price = 500
	prereq_ids = list("spacepod_disabler")
	design_ids = list("pod_ka_basic")

/datum/techweb_node/spacepod_advmining
	id = "spacepod_aka"
	display_name = "Advanced Spacepod Mining Tech"
	description = "Cutting up asteroids using your spacepods.... faster!"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3500)
	export_price = 3500
	prereq_ids = list("spacepod_ka")
	design_ids = list("pod_ka", "pod_plasma_cutter")

/datum/techweb_node/spacepod_advplasmacutter
	id = "spacepod_apc"
	display_name = "Advanced Spacepod Plasma Cutter"
	description = "Cutting up asteroids using your spacepods........... FASTERRRRRR!!!!!! Oh shit, that was gibtonite."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4500)
	export_price = 4500
	prereq_ids = list("spacepod_aka", "adv_plasma")
	design_ids = list("pod_adv_plasma_cutter")

/datum/techweb_node/spacepod_pseat
	id = "spacepod_pseat"
	display_name = "Spacepod Passenger Seat"
	description = "For bringing along victims as you fly off into the far reaches of space"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3750)
	export_price = 3750
	prereq_ids = list("spacepod_basic", "adv_engi")
	design_ids = list("podcargo_seat")

/datum/techweb_node/spacepod_storage
	id = "spacepod_storage"
	display_name = "Spacepod Storage"
	description = "For storing the stuff you find in the far reaches of space"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 4500)
	export_price = 4500
	prereq_ids = list("spacepod_pseat", "high_efficiency")
	design_ids = list("podcargo_crate", "podcargo_ore")

/datum/techweb_node/spacepod_lockbuster
	id = "spacepod_lockbuster"
	display_name = "Spacepod Lock Buster"
	description = "For when someone's being really naughty with a spacepod"
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 8500)
	export_price = 8500
	prereq_ids = list("spacepod_lasers", "high_efficiency", "adv_mining")
	design_ids = list("pod_lockbuster")

/datum/techweb_node/spacepod_iarmor
	id = "spacepod_iarmor"
	display_name = "Advanced Spacepod Armor"
	description = "Better protection for your precious ride. You'll need it if you plan on engaging in spacepod battles."
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2750)
	export_price = 2750
	prereq_ids = list("spacepod_storage", "high_efficiency")
	design_ids = list("podarmor_industiral", "podarmor_sec", "podarmor_gold")

/datum/techweb_node/syndicate_surgery
	id = "syndicate_surgery"
	display_name = "Syndicate Surgery"
	description = "The Syndicate did nothing wrong."
	prereq_ids = list("exp_surgery", "syndicate_basic")
	design_ids = list("surgery_brainwashing")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7000)
	export_price = 7000

/datum/techweb_node/nanite_harmonic
	design_ids = list("fakedeath_nanites","aggressive_nanites","defib_nanites","regenerative_plus_nanites","brainheal_plus_nanites","purging_plus_nanites","nanite_heart")
