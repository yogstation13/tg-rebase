//ABILITIES

/datum/action/innate/horror
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_horror.dmi'
	var/id //The ability's ID, for giving, taking and such
	var/blacklisted = FALSE //If the ability can't be mutated
	var/soul_price = 0 //How much souls the ability costs to buy; if this is 0, it isn't listed on the catalog
	var/chemical_cost = 0 //How much chemicals the ability costs to use
	var/mob/living/simple_animal/horror/B //Horror holding the ability
	var/category  //category for when the ability is active, "horror" is for creature, "infest" is during infestation, "controlling" is when a horror is controlling a body

/datum/action/innate/horror/New(Target, horror)
	B = horror
	..()

/datum/action/innate/horror/IsAvailable()
	if(!B)
		return
	if(!B.has_chemicals(chemical_cost))
		return
	. = ..()

/datum/action/innate/horror/mutate
	name = "Mutate"
	id = "mutate"
	desc = "Use consumed souls to mutate your abilities."
	button_icon_state = "mutate"
	blacklisted = TRUE
	category = list("horror","infest")

/datum/action/innate/horror/mutate/Activate()
	to_chat(usr, "<span class='velvet bold'>You focus on mutating your body...</span>")
	B.ui_interact(usr)
	return TRUE

/datum/action/innate/horror/seek_soul
	name = "Seek target soul"
	id = "seek_soul"
	desc = "Search for a soul weak enough for you to consume."
	button_icon_state = "seek_soul"
	blacklisted = TRUE
	category = list("horror","infest")

/datum/action/innate/horror/seek_soul/Activate()
	B.SearchTarget()

/datum/action/innate/horror/consume_soul
	name = "Consume soul"
	id = "consume_soul"
	desc = "Consume your target's soul."
	button_icon_state = "consume_soul"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/consume_soul/Activate()
	B.ConsumeSoul()

/datum/action/innate/horror/talk_to_host
	name = "Converse with Host"
	id = "talk_to_host"
	desc = "Send a silent message to your host."
	button_icon_state = "talk_to_host"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/talk_to_host/Activate()
	B.Communicate()

/datum/action/innate/horror/infest_host
	name = "Infest"
	id = "infest"
	desc = "Infest a suitable humanoid host."
	button_icon_state = "infest"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/infest_host/Activate()
	B.infect_victim()

/datum/action/innate/horror/toggle_hide
	name = "Toggle Hide"
	id = "toggle_hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "horror_hiding_false"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/toggle_hide/Activate()
	B.hide()
	button_icon_state = "horror_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/horror/talk_to_horror
	name = "Converse with Horror"
	id = "talk_to_horror"
	desc = "Communicate mentally with your horror."
	button_icon_state = "talk_to_horror"
	blacklisted = TRUE

/datum/action/innate/horror/talk_to_horror/Activate()
	var/mob/living/O = owner
	O.horror_comm()

/datum/action/innate/horror/talk_to_brain
	name = "Converse with Trapped Mind"
	id = "talk_to_brain"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "talk_to_trapped_mind"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/talk_to_brain/Activate()
	B.victim.trapped_mind_comm()

/datum/action/innate/horror/take_control
	name = "Assume Control"
	id = "take_control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "horror_brain"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/take_control/Activate()
	B.bond_brain()

/datum/action/innate/horror/give_back_control
	name = "Release Control"
	id = "release_control"
	desc = "Release control of your host's body."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("control")

/datum/action/innate/horror/give_back_control/Activate()
	B.victim.release_control()

/datum/action/innate/horror/leave_body
	name = "Release Host"
	id = "leave_body"
	desc = "Slither out of your host."
	button_icon_state = "horror_leave"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/leave_body/Activate()
	B.release_victim()

/datum/action/innate/horror/make_chems
	name = "Secrete chemicals"
	id = "make_chems"
	desc = "Push some chemicals into your host's bloodstream."
	icon_icon = 'icons/obj/chemical.dmi'
	button_icon_state = "minidispenser"
	blacklisted = TRUE
	category = list("infest")

/datum/action/innate/horror/make_chems/Activate()
	B.secrete_chemicals()

/datum/action/innate/horror/freeze_victim
	name = "Knockdown victim"
	id = "freeze_victim"
	desc = "Use your tentacle to trip a victim, stunning for a short duration."
	button_icon_state = "trip"
	blacklisted = TRUE
	category = list("horror")

/datum/action/innate/horror/freeze_victim/Activate()
	B.freeze_victim()
	UpdateButtonIcon()
	addtimer(CALLBACK(src, .proc/UpdateButtonIcon), 150)

/datum/action/innate/horror/freeze_victim/IsAvailable()
	if(world.time - B.used_freeze < 150)
		return FALSE
	else
		return ..()

//non-default abilities, can be mutated

/datum/action/innate/horror/tentacle
	name = "Grow Tentacle"
	id = "tentacle"
	desc = "Makes your host grow a tentacle in their arm. Costs 50 chemicals to activate."
	button_icon_state = "tentacle"
	chemical_cost = 50
	category = list("infest", "control")
	soul_price = 2

/datum/action/innate/horror/tentacle/IsAvailable()
	if(!active && !B.has_chemicals(chemical_cost))
		return FALSE
	return ..()

/datum/action/innate/horror/tentacle/New()
	..()
	START_PROCESSING(SSfastprocess, src)

/datum/action/innate/horror/tentacle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/action/innate/horror/tentacle/process()
	..()
	active = locate(/obj/item/horrortentacle) in B.victim
	UpdateButtonIcon()


/datum/action/innate/horror/tentacle/Activate()
	B.use_chemicals(50)
	B.victim.visible_message("<span class='warning'>[B.victim]'s arm contorts into tentacles!</span>", "<span class='notice'>Your arm transforms into a giant tentacle. Examine it to see possible uses.</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>You transform [B.victim]'s arm into a tentacle!</span>")
	var/obj/item/horrortentacle/T = new
	B.victim.put_in_hands(T)
	return TRUE

/datum/action/innate/horror/tentacle/Deactivate()
	B.victim.visible_message("<span class='warning'>[B.victim]'s tentacle transforms back!</span>", "<span class='notice'>Your tentacle disappears!</span>")
	playsound(B.victim, 'sound/effects/blobattack.ogg', 30, 1)
	to_chat(B, "<span class='warning'>You transform [B.victim]'s arm back.</span>")
	for(var/obj/item/horrortentacle/T in B.victim)
		qdel(T)
	return TRUE

/datum/action/innate/horror/transfer_host
	name = "Transfer to another Host"
	id = "transfer_host"
	desc = "Move into another host directly. Grabbing makes the process faster."
	button_icon_state = "transfer_host"
	category = list("infest", "control")
	soul_price = 1

/datum/action/innate/horror/transfer_host/Activate()
	var/list/choices = list()
	for(var/mob/living/carbon/C in range(1,B.victim))
		if(C!=B.victim && C.Adjacent(B.victim))
			choices += C

	if(!choices.len)
		return
	var/mob/living/carbon/C = choices.len > 1 ? input(owner,"Who do you wish to infest?") in null|choices : choices[1]
	if(!C || !B)
		return
	if(!C.Adjacent(B.victim))
		return
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		to_chat(owner, "<span class='warning'>[C] doesn't have a head!</span>")
		return
	var/hasbrain = FALSE
	for(var/obj/item/organ/brain/X in C.internal_organs)
		hasbrain = TRUE
		break
	if(!hasbrain)
		to_chat(owner, "<span class='warning'>[C] doesn't have a brain! </span>")
		return
	if((!C.key || !C.mind) && C != B.target)
		to_chat(owner, "<span class='warning'>[C]'s mind seems unresponsive. Try someone else!</span>")
		return
	if(C.has_horror_inside())
		to_chat(owner, "<span class='warning'>[C] is already infested!</span>")
		return

	to_chat(owner, "<span class='warning'>You move your tentacles away from [B.victim] and begin to transfer to [C]...</span>")
	var/delay = 20 SECONDS
	var/silent
	if(B.victim.pulling != C)
		silent = TRUE
	else
		switch(B.victim.grab_state)
			if(GRAB_PASSIVE)
				delay = 10 SECONDS
			if(GRAB_AGGRESSIVE)
				delay = 5 SECONDS
			if(GRAB_NECK)
				delay = 3 SECONDS
			else
				delay = 1 SECONDS

	if(!do_mob(B, C, delay))
		to_chat(owner, "<span class='warning'>As [C] moves away, your transfer gets interrupted!</span>")
		return

	if(!C || !B)
		return
	B.leave_victim()
	B.Infect(C)
	if(!silent)
		to_chat(C, "<span class='warning'>Something slimy wiggles into your ear!</span>")
		playsound(B, 'sound/effects/blobattack.ogg', 30, 1)

/datum/action/innate/horror/jumpstart_host
	name = "Revive Host"
	id = "jumpstart_host"
	desc = "Bring your host back to life."
	button_icon_state = "revive"
	category = list("infest")
	soul_price = 2

/datum/action/innate/horror/jumpstart_host/Activate()
	B.jumpstart()

/datum/action/innate/horror/view_memory
	name = "View Memory"
	id = "view_memory"
	desc = "Read recent memory of the host you're inside of."
	button_icon_state = "view_memory"
	category = list("infest")
	soul_price = 1

/datum/action/innate/horror/view_memory/Activate()
	B.view_memory()

/datum/action/innate/horror/chameleon
	name = "Chameleon Skin"
	id = "chameleon"
	desc = "Adjust your skin color to blend into environment. Costs 5 chemicals per tick, also stopping chemical regeneration while active. Attacking stops the invisibility completely."
	button_icon_state = "horror_sneak_false"
	category = list("horror")
	soul_price = 1

/datum/action/innate/horror/chameleon/Activate()
	B.go_invisible()
	button_icon_state = "horror_sneak_[B.invisible ? "true" : "false"]"
	UpdateButtonIcon()

//UPGRADES
/datum/horror_upgrade
	var/name = "horror upgrade"
	var/desc = "This is an upgrade."
	var/id
	var/soul_price = 0 //How much souls an upgrade costs to buy
	var/mob/living/simple_animal/horror/B //Horror holding the upgrades

/datum/horror_upgrade/proc/unlock()
	if(!B)
		return
	apply_effects()
	qdel(src)
	return TRUE

/datum/horror_upgrade/New(owner)
	..()
	B = owner

/datum/horror_upgrade/proc/apply_effects()
	return

//Upgrades the stun ability
/datum/horror_upgrade/paralysis
	name = "Electrocharged tentacle"
	id = "paralysis"
	desc = "Empowers your tentacle knockdown ability by giving it extra charge, knocking your victim down unconcious."
	soul_price = 3

/datum/horror_upgrade/paralysis/apply_effects()
	var/datum/action/innate/horror/A = B.has_ability("freeze_victim")
	if(A)
		A.name = "Paralyze Victim"
		A.desc = "Shock a victim with an electrically charged tentacle."
		A.button_icon_state = "paralyze"
		B.update_action_buttons()

//Increases chemical regeneration rate by 2
/datum/horror_upgrade/chemical_regen
	name = "Efficient chemical glands"
	id = "chem_regen"
	desc = "Your chemical glands work more efficiently. Unlocking this increases your chemical regeneration."
	soul_price = 2

/datum/horror_upgrade/chemical_regen/apply_effects()
	B.chem_regen_rate += 2

//Lets horror regenerate chemicals outside of a host
/datum/horror_upgrade/nohost_regen
	name = "Independent chemical glands"
	id = "nohost_regen"
	desc = "Your chemical glands become less parasitic and let you regenerate chemicals on their own without need for a host."
	soul_price = 2

//Lets horror regenerate health
/datum/horror_upgrade/regen
	name = "Regenerative skin"
	id = "regen"
	desc = "Your skin adapts to sustained damage and slowly regenerates itself, healing your wounds over time."
	soul_price = 1

//Triples horror's health pool
/datum/horror_upgrade/hp_up
	name = "Rhino skin"  //Horror can....roll?
	id = "hp_up"
	desc = "Your skin becomes hard as rock, greatly increasing your maximum health - and odds of survival outside of host."
	soul_price = 2

/datum/horror_upgrade/hp_up/apply_effects()
	B.health = round(min(B.maxHealth,B.health * 3))
	B.maxHealth = round(B.maxHealth * 3)

//Makes horror almost invisible for a short time after leaving a host
/datum/horror_upgrade/invisibility
	name = "Reflective fluids"
	id = "invisible_exit"
	desc = "You build up reflective solution inside host's brain. Upon exiting a host, you're briefly covered in it, rendering you near invisible for a few seconds. This mutation also makes the host unable to notice you exiting it directly."
	soul_price = 2

//Increases melee damage to 20
/datum/horror_upgrade/dmg_up
	name = "Sharpened teeth"
	id = "dmg_up"
	desc = "Your teeth become sharp blades, this mutation increases your melee damage."
	soul_price = 2

/datum/horror_upgrade/dmg_up/apply_effects()
	B.attacktext = "crushes"
	B.attack_sound = 'sound/weapons/pierce_slow.ogg' //chunky
	B.melee_damage_lower += 10
	B.melee_damage_upper += 10

//Expands the reagent selection horror can make
/datum/horror_upgrade/upgraded_chems
	name = "Advanced reagent synthesis"
	id = "upgraded_chems"
	desc = "Lets you synthetize adrenaline, salicyclic acid, oxandrolone, pentetic acid and rezadone into your host."
	soul_price = 2

/datum/horror_upgrade/upgraded_chems/apply_effects()
	B.horror_chems += list(/datum/horror_chem/adrenaline,/datum/horror_chem/sal_acid,/datum/horror_chem/oxandrolone,/datum/horror_chem/pen_acid,/datum/horror_chem/rezadone)

//faster mind control
/datum/horror_upgrade/fast_control
	name = "Precise probosci"
	id = "fast_control"
	desc = "Your probosci become more precise, allowing you to take control over your host's brain noticably faster."
	soul_price = 2

//makes it longer for host to snap out of mind control
/datum/horror_upgrade/deep_control
	name = "Insulated probosci"
	id = "deep_control"
	desc = "Your probosci become insulated, protecting them from neural shocks. This makes it harder for the host to regain control over their body."
	soul_price = 2