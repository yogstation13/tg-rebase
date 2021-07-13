/obj/item/clothing/under/yogs/rank/signal_tech
	desc = "It's a green high jumpsuit worn by signal technicians. It is slightly warmer than most jumpsuits."
	name = "signal technician's jumpsuit"
	icon_state = "signaltech"
	item_state = "ro_suit"
	cold_protection = CHEST
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	mutantrace_variation = MUTANTRACE_VARIATION //Yogs Start: Digilegs alt stuff
	digiversion = TRUE //Yogs End

/obj/item/clothing/under/yogs/rank/signal_tech/skirt
	desc = "It's a green high jumpskirt worn by signal technicians. It is slightly warmer than most jumpskirts."
	name = "signal technician's jumpskirt"
	icon_state = "signaltech_skirt"
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	digiversion = FALSE //Yogs: Digilegs alt stuff
