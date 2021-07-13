/obj/item/clothing/under/yogs/tourist
	name = "Hawaiian shirt"
	desc = "I explored the galaxy and all I got was this lousy T-shirt!"
	icon_state = "tourist"
	item_state = "gy_suit"
	item_color = "tourist"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION //Yogs Start: Digilegs alt stuff
	digiversion = TRUE //Yogs End

/obj/item/clothing/under/yogs/rank/clerk
	desc = "Oh, look it comes with its own vest."
	name = "clerk's uniform"
	icon_state = "clerk"
	item_state = "clerk"
	item_color = "clerk"
	can_adjust = FALSE
	mutantrace_variation = MUTANTRACE_VARIATION //Yogs Start: Digilegs alt stuff
	digiversion = TRUE //Yogs End

/obj/item/clothing/under/yogs/rank/clerk/skirt
	desc = "Oh, look it comes with its own vest."
	name = "clerk's skirt"
	icon_state = "clerk_skirt"
	item_state = "clerk_skirt"
	item_color = "clerk_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	digiversion = FALSE //Yogs: Digilegs alt stuff

/obj/item/clothing/under/yogs/rank/miner/medic
	desc = "A verstile blue and white uniform honored to hard working recovery medics in hazardous environments. It has minor protection against biohazards."
	name = "recovery medic's jumpsuit"
	icon_state = "recovery"
	item_state = "recovery"
	item_color = "recovery"
	can_adjust = 0
	sensor_mode = 3
	random_sensor = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 15, rad = 0)
	mutantrace_variation = MUTANTRACE_VARIATION //Yogs Start: Digilegs alt stuff
	digiversion = TRUE //Yogs End
