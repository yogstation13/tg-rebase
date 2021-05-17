//ANTAG DATUMS
/datum/antagonist/horror
	name = "Horror"
	show_in_antagpanel = TRUE
	prevent_roundtype_conversion = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	var/datum/mind/summoner

/datum/antagonist/horror/on_gain()
	. = ..()
	give_objectives()
	if(ishorror(owner) && owner.current.mind)
		var/mob/living/simple_animal/horror/H = owner.current
		H.update_horror_hud()
		H.mind.store_memory("You become docile after contact with [H.weakness.name]. Avoid it.")

/datum/antagonist/horror/proc/give_objectives()
	if(summoner)
		var/datum/objective/newobjective = new
		newobjective.explanation_text = "Serve your summoner, [summoner.name]."
		newobjective.owner = owner
		newobjective.completed = TRUE
		objectives += newobjective
	else
		var/datum/objective/horrorascend/ascend = new
		ascend.owner = owner
		ascend.target_amount = rand(6, 10)
		objectives += ascend
		ascend.update_explanation_text()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/objective/horrorascend
	name = "consume souls"

/datum/objective/horrorascend/update_explanation_text()
	. = ..()
	explanation_text = "Consume [target_amount] souls."

/datum/objective/horrorascend/check_completion()
	var/mob/living/simple_animal/horror/H = owner.current
	if(istype(H) && H.consumed_souls > target_amount)
		return TRUE
	return FALSE

//SPAWNER
/obj/item/horrorspawner
	name = "suspicious pet carrier"
	desc = "It contains some sort of creature inside. You can see tentacles sticking out of it."
	icon = 'icons/obj/pet_carrier.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "pet_carrier"
	icon_state = "pet_carrier_occupied"
	var/used = FALSE
	var/weakness
	color = rgb(130, 105, 160)

/obj/item/horrorspawner/attack_self(mob/living/user)
	if(used)
		to_chat(user, "The pet carrier appears unresponsive.")
		return
	used = TRUE
	to_chat(user, "You're attempting to wake up the creature inside the box...")
	sleep(5 SECONDS)
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the eldritch horror in service of [user.real_name]?", ROLE_HORROR, null, FALSE, 100)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/horror/H = new /mob/living/simple_animal/horror(get_turf(src))
		H.weakness = weakness
		H.key = C.key
		H.mind.enslave_mind_to_creator(user)
		H.mind.add_antag_datum(C)
		H.mind.memory += "You are <span class='purple'><b>[H.truename]</b></span>, an eldritch horror. Consume souls to evolve.<br>"
		var/datum/antagonist/horror/S = new
		S.summoner = user.mind
		S.antag_memory += "<b>[user.mind]</b> woke you from your eternal slumber. Aid them in their objectives as a token of gratitude.<br>"
		H.mind.add_antag_datum(S)
		log_game("[key_name(user)] has summoned [key_name(H)], an eldritch horror.")
		to_chat(user, "<span><b>[H.truename]</b> has awoken into your service!</span>")
		used = TRUE
		icon_state = "pet_carrier_open"
		sleep(5)
		var/obj/item/horrorsummonhorn/horn = new /obj/item/horrorsummonhorn(get_turf(src))
		horn.summoner = user.mind
		horn.horror = H
		to_chat(user, "<span class='notice'>A strange looking [horn] falls out of [src]!</span>")
	else
		to_chat(user, "The creatures looks at you with one of it's eyes before going back to slumber.")
		used = FALSE
		return

//Summoning horn
/obj/item/horrorsummonhorn
	name = "old horn"
	desc = "A very old horn. You feel an incredible urge to blow into it."
	icon = 'icons/obj/items_and_weapons.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "horn"
	icon_state = "horn"
	var/datum/mind/summoner
	var/mob/living/simple_animal/horror/horror
	var/cooldown

/obj/item/horrorsummonhorn/examine(mob/user)
	. = ..()
	if(user.mind == summoner)
		to_chat(user, "<span class='velvet'>Blowing into this horn will recall the horror back to you. Be wary, the horn is loud, and may attract <B>unwanted</B> attention.<span>")

/obj/item/horrorsummonhorn/attack_self(mob/living/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='notice'>Take a breath before you blow [src] again.</span>")
		return
	to_chat(user, "<span class='notice'>You take a deep breath and prepare to blow into [src]...</span>")
	if(do_mob(user, src, 10 SECONDS))
		if(cooldown > world.time)
			return
		cooldown = world.time + 10 SECONDS
		to_chat(src, "<span class='notice'>You blow the horn...</span>")
		playsound(loc, "sound/items/airhorn.ogg", 100, 1, 30)
		var/turf/summonplace = get_turf(src)
		sleep(5 SECONDS)
		if(prob(20)) //yeah you're summoning an eldritch horror allright
			new /obj/effect/temp_visual/summon(summonplace)
			sleep(10)
			var/type = pick(typesof(/mob/living/simple_animal/hostile/abomination))
			var/mob/R = new type(summonplace)
			playsound(summonplace, "sound/effects/phasein.ogg", 30)
			summonplace.visible_message("<span class='danger'>[R] emerges!</span>")
		else
			if(!horror || horror.stat == DEAD)
				summonplace.visible_message("<span class='danger'>But nothing responds to the call!</span>")
			else
				new /obj/effect/temp_visual/summon(summonplace)
				sleep(10)
				horror.leave_victim()
				horror.forceMove(summonplace)
				playsound(summonplace, "sound/effects/phasein.ogg", 30)
				summonplace.visible_message("<span class='notice'>[horror] appears out of nowhere!</span>")
				if(user.mind != summoner)
					sleep(2 SECONDS)
					playsound(summonplace, "sound/effects/glassbr2.ogg", 30, 1)
					to_chat(user, "<span class='danger'>[src] breaks!</span>")
					qdel(src)

/obj/item/horrorsummonhorn/suicide_act(mob/living/user)  //"I am the prettiest unicorn that ever was!" ~Spy 2013
	user.visible_message("<span class='suicide'>[user] stabs [user.p_their()] forehead with [src]!  It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/paper/crumpled/horrorweakness
	name = "scruffed note"
	infolang = /datum/language/aphasia //his previous owner got brought to madness, luckily curator can translate

//Tentacle arm
/obj/item/horrortentacle
	name = "tentacle"
	desc = "A long, slimy, arm-like appendage."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "horrortentacle"
	item_state = "tentacle"
	lefthand_file = 'icons/mob/inhands/antag/horror_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/horror_righthand.dmi'
	resistance_flags = ACID_PROOF
	force = 17
	item_flags = ABSTRACT | DROPDEL
	reach = 2
	hitsound = 'sound/weapons/whip.ogg'

/obj/item/horrortentacle/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/horrortentacle/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='velvet bold'>Functions:<span>")
	to_chat(user, "<span class='velvet'><b>All attacks work up to 2 tiles away.</b></span>")
	to_chat(user, "<span class='velvet'><b>Help intent:</b> Usual help function of an arm.</span>")
	to_chat(user, "<span class='velvet'><b>Disarm intent:</b> Whips the tentacle, disarming your opponent.</span>")
	to_chat(user, "<span class='velvet'><b>Grab intent:</b> Instant aggressive grab on an opponent. Can also throw them!</span>")
	to_chat(user, "<span class='velvet'><b>Harm intent:</b> Whips the tentacle, damaging your opponent.</span>")
	to_chat(user, "<span class='velvet'>Also functions to pry open unbolted airlocks.</span>")

/obj/item/horrortentacle/attack(atom/target, mob/living/user)
	if(isliving(target))
		user.Beam(target,"purpletentacle",time=5)
		var/mob/living/L = target
		switch(user.a_intent)
			if(INTENT_HELP)
				L.attack_hand(user)
				return
			if(INTENT_GRAB)
				if(L != user)
					L.grabbedby(user)
					L.grippedby(user, instant = TRUE)
					L.Knockdown(30)
				return
			if(INTENT_DISARM)
				if(iscarbon(L))
					var/mob/living/carbon/C = L
					var/obj/item/I = C.get_active_held_item()
					if(I)
						if(C.dropItemToGround(I))
							playsound(loc, "sound/weapons/whipgrab.ogg", 30)
							target.visible_message("<span class='danger'>[I] is whipped out of [C]'s hand by [user]!</span>","<span class='userdanger'>A tentacle whips [I] out of your hand!</span>")
							return
						else
							to_chat(user, "<span class='danger'>You can't seem to pry [I] off [C]'s hands!</span>")
							return
					else
						C.attack_hand(user)
						return
	. = ..()

/obj/item/horrortentacle/afterattack(atom/target, mob/user, proximity)
	if(isliving(user.pulling) && user.pulling != target)
		var/mob/living/H = user.pulling
		user.visible_message("<span class='warning'>[user] throws [H] with [user.p_their()] [src]!</span>", "<span class='warning'>You throw [H] with [src].</span>")
		H.throw_at(target, 8, 2)
		H.Knockdown(30)
		return
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if((!A.requiresID() || A.allowed(user)) && A.hasPower())
			return
		if(A.locked)
			to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
			return

		if(A.hasPower())
			user.visible_message("<span class='warning'>[user] jams [src] into the airlock and starts prying it open!</span>", "<span class='warning'>You start forcing the airlock open.</span>",
			"<span class='italics'>You hear a metal screeching sound.</span>")
			playsound(A, 'sound/machines/airlock_alien_prying.ogg', 150, 1)
			if(!do_after(user, 10 SECONDS, target = A))
				return
		user.visible_message("<span class='warning'>[user] forces the airlock to open with [user.p_their()] [src]!</span>", "<span class='warning'>You force the airlock to open.</span>",
		"<span class='italics'>You hear a metal screeching sound.</span>")
		A.open(2)
		return
	. = ..()

/obj/item/horrortentacle/suicide_act(mob/user) //funnily enough, this will never be called, since horror stops suicide
	user.visible_message("<span class='suicide'>[src] coils itself around [user] tightly gripping [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (OXYLOSS)

//Pinpointer
/obj/screen/alert/status_effect/agent_pinpointer/horror
	name = "Soul locator"
	desc = "Find your target soul."

/datum/status_effect/agent_pinpointer/horror
	id = "horror_pinpointer"
	minimum_range = 0
	range_fuzz_factor = 0
	tick_interval = 20
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/horror

/datum/status_effect/agent_pinpointer/horror/scan_for_target()
	return

//TRAPPED MIND - when horror takes control over your body, you become a mute trapped mind
/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"
	var/datum/action/innate/resist_control/R
	var/mob/living/simple_animal/horror/H

/mob/living/captive_brain/Initialize(mapload, gen=1)
	..()
	R = new
	R.Grant(src)

/mob/living/captive_brain/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='danger'>You cannot speak in IC (muted).</span>")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(ishorror(loc))
		message = sanitize(message)
		if(!message)
			return
		log_say("[key_name(src)] : [message]")
		if(stat == 2)
			return say_dead(message)

		to_chat(src, "<i><span class='alien'>You whisper silently, \"[message]\"</span></i>")
		to_chat(H.victim, "<i><span class='alien'>The captive mind of [src] whispers, \"[message]\"</span></i>")

		for (var/mob/M in GLOB.player_list)
			if(isnewplayer(M))
				continue
			else if(M.stat == 2 &&  M.client.prefs.toggles & CHAT_GHOSTEARS)
				to_chat(M, "<i>Thought-speech, <b>[src]</b> -> <b>[H.truename]:</b> [message]</i>")

/mob/living/captive_brain/emote(act, m_type = null, message = null, intentional = FALSE)
	return

/datum/action/innate/resist_control
	name = "Resist control"
	desc = "Try to take back control over your brain. A strong nerve impulse should do it."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_horror.dmi'
	button_icon_state = "resist_control"

/datum/action/innate/resist_control/Activate()
	var/mob/living/captive_brain/B = owner
	if(B)
		B.try_resist()

/mob/living/captive_brain/resist()
	try_resist()

/mob/living/captive_brain/proc/try_resist()
	var/delay = rand(20 SECONDS,30 SECONDS)
	if(H.horrorupgrades["deep_control"])
		delay += rand(20 SECONDS,30 SECONDS)
	to_chat(src, "<span class='danger'>You begin doggedly resisting the parasite's control.</span>")
	to_chat(H.victim, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")
	addtimer(CALLBACK(src, .proc/return_control), delay)

/mob/living/captive_brain/proc/return_control()
    if(!H || !H.controlling)
        return
    to_chat(src, "<span class='userdanger'>With an immense exertion of will, you regain control of your body!</span>")
    to_chat(H.victim, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")
    H.detatch()