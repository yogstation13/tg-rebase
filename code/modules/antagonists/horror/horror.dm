/mob/living/simple_animal/horror
	name = "eldritch horror"
	real_name = "eldritch horror"
	desc = "Your eyes can barely comprehend what they're looking at."
	icon_state = "horror"
	icon_living = "horror"
	icon_dead = "horror_dead"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 10
	see_in_dark = 7
	stop_automated_movement = TRUE
	attacktext = "bites"
	speak_emote = list("gurgles")
	attack_sound = 'sound/weapons/bite.ogg'
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("neutral","silicon","hostile","creature","heretics")
	ventcrawler = VENTCRAWLER_ALWAYS
	initial_language_holder = /datum/language_holder/universal
	hud_type = /datum/hud/chemical_counter

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	var/playstyle_string = "<span class='big bold'>You are an eldritch horror,</span><B> an evermutating parasitic abomination. Seek human souls to consume. \
							Crawl into people's heads and steal their essence. Use it to mutate yourself, giving you access to more power and abilities. \
							You operate on chemicals that get built up while you spend time in someone's head. You are weak when outside, play carefully.\
							Check your notes to see which chemical reagent is your bane, and avoid from getting in contact with it. </B>"

	var/datum/reagent/weakness = /datum/reagent/consumable/sugar //default is sugar, but a random one is attributed
	var/mob/living/carbon/victim
	var/datum/mind/target
	var/mob/living/captive_brain/host_brain
	var/truename = null
	var/available_points = 4
	var/consumed_souls = 0
	var/list/horrorabilities = list() //An associative list ("id" = ability datum) containing the abilities the horror has
	var/list/horrorupgrades = list()		  //same, but for permanent upgrades
	var/docile = FALSE
	var/bonding = FALSE
	var/controlling = FALSE
	var/chemicals = 10
	var/chem_regen_rate = 2
	var/used_freeze
	var/used_target
	var/horror_chems = list(/datum/horror_chem/epinephrine,/datum/horror_chem/mannitol,/datum/horror_chem/bicaridine,/datum/horror_chem/kelotane,/datum/horror_chem/charcoal)

	var/leaving = FALSE
	var/hiding = FALSE
	var/invisible = FALSE
	var/waketimerid = null
	var/datum/action/innate/horror/talk_to_horror/talk_to_horror_action = new

/mob/living/simple_animal/horror/Initialize(mapload, gen=1)
	..()
	real_name = "Eldritch horror"
	truename = "[pick(GLOB.horror_names)]"

	//default abilities
	add_ability("mutate")
	add_ability("seek_soul")
	add_ability("consume_soul")
	add_ability("talk_to_host")
	add_ability("freeze_victim")
	add_ability("infest")
	add_ability("toggle_hide")
	add_ability("talk_to_brain")
	add_ability("take_control")
	add_ability("leave_body")
	add_ability("make_chems")
	add_ability("talk_to_brain")
	add_ability("release_control")
	RefreshAbilities()

	var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	hud.add_hud_to(src)
	update_horror_hud()


/mob/living/simple_animal/horror/Destroy()
	host_brain = null
	victim = null
	return ..()


/mob/living/simple_animal/horror/proc/has_chemicals(amt)
	return chemicals >= amt

/mob/living/simple_animal/horror/proc/use_chemicals(amt)
	if(!has_chemicals(amt))
		return FALSE
	chemicals -= amt
	update_horror_hud()
	return TRUE

/mob/living/simple_animal/horror/proc/regenerate_chemicals(amt)
	chemicals += amt
	chemicals = min(250, chemicals)
	update_horror_hud()

/mob/living/simple_animal/horror/proc/update_horror_hud()
	if(!src || !hud_used)
		return
	var/datum/hud/chemical_counter/H = hud_used
	var/obj/screen/counter = H.chemical_counter
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#7264FF'>[chemicals]</font></div>"

/mob/living/simple_animal/horror/proc/can_use_ability()
	if(stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return FALSE
	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/horror/proc/SearchTarget()
	if(target)
		if(world.time - used_target < 3 MINUTES)
			to_chat(src, "<span class='warning'>You cannot use that ability again so soon.</span>")
			return
		if(alert("You already have a target ([target.name]). Would you like to change that target?","Swap targets?","Yes","No") != "Yes")
			return

	var/datum/objective/A = new
	A.owner = mind
	var/list/targets = list()
	for(var/i in 0 to 4)
		var/datum/mind/targeted
		if(mind.enslaved_to)
			targeted = A.find_target(null, list(mind.enslaved_to.mind, target))
		else
			targeted = A.find_target(null, list(target))
		if(!targeted || !targeted.hasSoul)
			break
		targets[targeted.current.real_name] = targeted.current

	target = targets[input(src,"Choose your next target","Target") in targets]
	qdel(A)

	if(target)
		used_target = world.time
		to_chat(src,"<span class='warning'>Your new target has been selected, go and consume [target.name]'s soul!</span>")
		apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
		for(var/datum/status_effect/agent_pinpointer/horror/status in status_effects)
			status.scan_target = target
	else
		to_chat(src,"<span class='warning'>A new target could not be found.</span>")

/mob/living/simple_animal/horror/proc/ConsumeSoul()
	if(!can_use_ability())
		return

	if(!src.victim.mind.hasSoul)
		to_chat(src, "This host doesn't have a soul!")
		return

	if(victim == mind.enslaved_to)
		to_chat(src, "<span class='userdanger'>No, not yet... We still need them...</span>")
		return

	if(victim != target)
		to_chat(src, "This soul isn't your target, you can't consume it!")
		return

	to_chat(src, "You begin consuming [src.victim.name]'s soul!")
	addtimer(CALLBACK(src, .proc/consume), 200)

/mob/living/simple_animal/horror/proc/consume()
	if(!can_use_ability() || !victim || !victim.mind.hasSoul)
		return
	consumed_souls++
	available_points++
	to_chat(src, "<span class='userdanger'>You succeed in consuming [victim.name]'s soul!</span>")
	to_chat(src.victim, "<span class='userdanger'>You suddenly feel weak and hollow inside...</span>")
	victim.health -= 20
	victim.maxHealth -= 20
	victim.mind.hasSoul = FALSE
	target = null
	remove_status_effect(/datum/status_effect/agent_pinpointer/horror)
	playsound(src, 'sound/effects/curseattack.ogg', 150)
	playsound(src, 'sound/effects/ghost.ogg', 50)

/mob/living/simple_animal/horror/proc/Communicate()
	if(!can_use_ability())
		return
	if(!src.victim)
		to_chat(src, "You do not have a host to communicate with!")
		return

	var/input = stripped_input(src, "Please enter a message to tell your host.", "Horror", null)
	if(!input)
		return

	if(src && !QDELETED(src) && !QDELETED(src.victim))
		var/say_string = (src.docile) ? "slurs" :"states"
		if(src.victim)
			to_chat(victim, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
			log_say("Horror Communication: [key_name(src)] -> [key_name(victim)] : [input]")
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					var/rendered = "<span class='changeling'><i>Horror Communication from <b>[truename]</b> : [input]</i>"
					var/link = FOLLOW_LINK(M, src)
					to_chat(M, "[link] [rendered]")
		to_chat(src, "<span class='changeling'><i>[truename] [say_string]:</i> [input]</span>")
		add_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Grant(victim)

/mob/living/proc/horror_comm()
	set name = "Converse with Horror"
	set category = "Horror"
	set desc = "Communicate mentally with the thing in your head."

	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B)
		var/input = stripped_input(src, "Please enter a message to tell the horror.", "Message", "")
		if(!input)
			return

		to_chat(B, "<span class='changeling'><i>[src.name] says:</i> [input]</span>")
		src.log_talk("Horror Communication: [key_name(src)] -> [key_name(B)] : [input]", LOG_SAY, tag="changeling")

		for(var/M in GLOB.dead_mob_list)
			if(isobserver(M))
				var/rendered = "<span class='changeling'><i>Horror Communication from <b>[B.truename]</b> : [input]</i>"
				var/link = FOLLOW_LINK(M, src)
				to_chat(M, "[link] [rendered]")
		to_chat(src, "<span class='changeling'><i>[src] says:</i> [input]</span>")

/mob/living/proc/trapped_mind_comm()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Please enter a message to tell the trapped mind.", "Message", null)
	if(!input)
		return

	to_chat(CB, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")
	log_say("Horror Communication: [key_name(B)] -> [key_name(CB)] : [input]")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			var/rendered = "<span class='changeling'><i>Horror Communication from <b>[B.truename]</b> : [input]</i>"
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	to_chat(src, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")

/mob/living/simple_animal/horror/Life()
	..()
	if(horrorupgrades["regen"])
		heal_overall_damage(5)

	if(invisible) //don't regenerate chemicals when invisible
		if(has_chemicals(5))
			use_chemicals(5)
			alpha = max(alpha - 100, 1)
		else
			to_chat(src, "<span class='warning'>You ran out of chemicals to support your invisibility.</span>")
			invisible = FALSE
			Update_Invisibility_Button()
	else
		if(horrorupgrades["nohost_regen"])
			regenerate_chemicals(chem_regen_rate)
		else if(victim)
			if(victim.stat == DEAD)
				regenerate_chemicals(1)
			else
				regenerate_chemicals(chem_regen_rate)
	alpha = min(255, alpha + 50)

	if(victim)
		if(stat != DEAD && victim.stat != DEAD)
			heal_overall_damage(1)
			if(victim.reagents.has_reagent(weakness.type))
				if(!docile || waketimerid)
					if(controlling)
						to_chat(victim, "<span class='warning'>You feel the soporific flow of [weakness.name] in your host's blood, lulling you into docility.</span>")
					else
						to_chat(src, "<span class='warning'>You feel the soporific flow of [weakness.name] in your host's blood, lulling you into docility.</span>")
					if(waketimerid)
						deltimer(waketimerid)
						waketimerid = null
					docile = TRUE
			else
				if(docile && !waketimerid)
					if(controlling)
						to_chat(victim, "<span class='warning'>You start shaking off your lethargy as the [weakness.name] leaves your host's blood. This will take about 10 seconds...</span>")
					else
						to_chat(src, "<span class='warning'>You start shaking off your lethargy as the [weakness.name] leaves your host's blood. This will take about 10 seconds...</span>")

					waketimerid = addtimer(CALLBACK(src, "wakeup"), 10, TIMER_STOPPABLE)
			if(controlling)
				if(docile)
					to_chat(victim, "<span class='warning'>You are feeling far too docile to continue controlling your host...</span>")
					victim.release_control()
					return


/mob/living/simple_animal/horror/proc/wakeup()
	if(controlling)
		to_chat(victim, "<span class='warning'>You finish shaking off your lethargy.</span>")
	else
		to_chat(src, "<span class='warning'>You finish shaking off your lethargy.</span>")
	docile = FALSE
	if(waketimerid)
		waketimerid = null

/mob/living/simple_animal/horror/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(victim)
		to_chat(src, "<span class='warning'>You cannot speak out loud while inside a host!</span>")
		return
	return ..()

/mob/living/simple_animal/horror/emote(act, m_type = null, message = null, intentional = FALSE)
	if(victim)
		to_chat(src, "<span class='warning'>You cannot emote while inside a host!</span>")
		return
	return ..()

/mob/living/simple_animal/horror/UnarmedAttack(atom/A)
	if(istype(A, /obj/machinery/door/airlock))
		visible_message("<span class='warning'>[src] slips their tentacles into the airlock and starts prying it open!</span>", "<span class='warning'>You start moving onto the airlock.</span>")
		playsound(A, 'sound/misc/splort.ogg', 50, 1)
		if(!do_after(src, 5 SECONDS, target = A))
			return
		visible_message("<span class='warning'>[src] forces themselves through the airlock!</span>", "<span class='warning'>You force yourself through the airlock.</span>")
		forceMove(get_turf(A))
		playsound(A, 'sound/machines/airlock_alien_prying.ogg', 50, 1)
		return
	if(isliving(A))
		if(victim || A == src.mind.enslaved_to)
			healthscan(usr, A)
			chemscan(usr, A)
		else
			alpha = 255
			if(hiding)
				var/datum/action/innate/horror/H = has_ability("toggle_hide")
				H.Activate()
			if(invisible)
				var/datum/action/innate/horror/H = has_ability("chameleon")
				H.Activate()
			Update_Invisibility_Button()
			..()

/mob/living/simple_animal/horror/ex_act()
	if(victim)
		return

	..()

/mob/living/simple_animal/horror/proc/infect_victim()
	if(!can_use_ability())
		return
	if(victim)
		to_chat(src, "<span class='warning'>You are already within a host.</span>")

	if(stat == DEAD)
		return

	var/list/choices = list()
	for(var/mob/living/carbon/H in view(1,src))
		if(H!=src && Adjacent(H))
			choices += H

	if(!choices.len)
		return
	var/mob/living/carbon/H = choices.len > 1 ? input(src,"Who do you wish to infest?") in null|choices : choices[1]
	if(!H || !src)
		return

	if(!Adjacent(H))
		return

	if(H.has_horror_inside())
		to_chat(src, "<span class='warning'>[H] is already infested!</span>")
		return

	to_chat(src, "<span class='warning'>You slither your tentacles up [H] and begin probing at their ear canal...</span>")
	if(!do_mob(src, H, 30))
		to_chat(src, "<span class='warning'>As [H] moves away, you are dislodged and fall to the ground.</span>")
		return

	if(!H || !src)
		return

	Infect(H)

/mob/living/simple_animal/horror/proc/Infect(mob/living/carbon/C)
	if(!C)
		return
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(!head)
		to_chat(src, "<span class='warning'>[C] doesn't have a head!</span>")
		return
	var/hasbrain = FALSE
	for(var/obj/item/organ/brain/X in C.internal_organs)
		hasbrain = TRUE
		break
	if(!hasbrain)
		to_chat(src, "<span class='warning'>[C] doesn't have a brain! </span>")
		return

	if(C.has_horror_inside())
		to_chat(src, "<span class='warning'>[C] is already infested!</span>")
		return

	if((!C.key || !C.mind) && C != target)
		to_chat(src, "<span class='warning'>[C]'s mind seems unresponsive. Try someone else!</span>")
		return

	invisible = FALSE
	Update_Invisibility_Button()
	victim = C
	forceMove(victim)
	RefreshAbilities()
	log_game("[src]/([src.ckey]) has infested [victim]/([victim.ckey]")

/mob/living/simple_animal/horror/proc/secrete_chemicals()
	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(!can_use_ability())
		return

	var content = ""
	content += "<p>Chemicals: <span id='chemicals'>[chemicals]</span></p>"

	content += "<table>"

	for(var/datum in horror_chems)
		var/datum/horror_chem/C = new datum()
		if(C.chemname)
			content += "<tr><td><a class='chem-select' href='?_src_=\ref[src];src=\ref[src];horror_use_chem=[C.chemname]'>[C.chemname] ([C.chemuse])</a><p>[C.chem_desc]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(null, "window=ViewHorror\ref[src]Chems;size=600x800")
	usr << browse(html, "window=ViewHorror\ref[src]Chems;size=600x800")

/mob/living/simple_animal/horror/proc/hide()
	if(victim)
		to_chat(src, "<span class='warning'>You cannot do this while you're inside a host.</span>")
		return

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = LATTICE_LAYER
		visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
		hiding = TRUE
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")
		hiding = FALSE

/mob/living/simple_animal/horror/proc/go_invisible()
	if(victim)
		to_chat(src, "<span class='warning'>You cannot do this while you're inside a host.</span>")
		return

	if(!can_use_ability())
		return

	if(!has_chemicals(10))
		to_chat(src, "<span class='warning'>You don't have enough chemicals to do that.</span>")
		return

	if(!invisible)
		to_chat(src, "<span class='noticealien'>You focus your chameleon skin to blend into the environment.</span>")
		invisible = TRUE
	else
		to_chat(src, "<span class='noticealien'>You stop your camouflage.</span>")
		invisible = FALSE

/mob/living/simple_animal/horror/proc/freeze_victim()
	if(world.time - used_freeze < 150)
		to_chat(src, "<span class='warning'>You cannot use that ability again so soon.</span>")
		return

	if(victim)
		to_chat(src, "<span class='warning'>You cannot do that from within a host body.</span>")
		return

	if(!can_use_ability())
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(!choices.len)
		return
	var/mob/living/carbon/M = choices.len > 1 ? input(src,"Who do you wish to stun?") in null|choices : choices[1]


	if(!M || !src || stat != CONSCIOUS || victim || (world.time - used_freeze < 150))
		return
	if(!Adjacent(M))
		return

	layer = MOB_LAYER
	if(horrorupgrades["paralysis"])
		to_chat(src, "<span class='warning'>You whip your electrocharged tentacle at [M]'s leg and knock them down!</span>")
		playsound(loc, "sound/effects/sparks4.ogg", 30, 1, -1)
		M.SetSleeping(70)
		M.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, 1, FALSE)
	else
		to_chat(src, "<span class='warning'>You whip your tentacle at [M]'s leg and knock them down!</span>")
		to_chat(M, "<span class='userdanger'>You feel something wrapping around your leg, pulling you down!</span>")
		playsound(loc, "sound/weapons/whipgrab.ogg", 30, 1, -1)
		M.Stun(50)
		M.Knockdown(70)
	used_freeze = world.time

/mob/living/simple_animal/horror/proc/release_victim()
	if(!victim)
		to_chat(src, "<span class='userdanger'>You are not inside a host body.</span>")
		return

	if(!can_use_ability())
		return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "<span class='userdanger'>You begin disconnecting from [victim]'s synapses and prodding at their internal ear canal.</span>")

	if(victim.stat != DEAD && !horrorupgrades["invisible_exit"])
		to_chat(victim, "<span class='userdanger'>An odd, uncomfortable pressure begins to build inside your skull, behind your ear...</span>")

	leaving = TRUE

	addtimer(CALLBACK(src, .proc/release_host), 100)

/mob/living/simple_animal/horror/proc/release_host()
	if(!victim || !src || QDELETED(victim) || QDELETED(src))
		return
	if(!leaving)
		return
	if(controlling)
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='userdanger'>You cannot release your host in your current state.</span>")
		return

	if(horrorupgrades["invisible_exit"])
		alpha = 60
		if(has_ability("chameleon"))
			invisible = TRUE
			Update_Invisibility_Button()
		to_chat(src, "<span class='userdanger'>You silently wiggle out of [victim]'s ear and plop to the ground before vanishing via reflective solution that covers you.</span>")
	else
		to_chat(src, "<span class='userdanger'>You wiggle out of [victim]'s ear and plop to the ground.</span>")
	if(victim.mind)
		if(!horrorupgrades["invisible_exit"])
			to_chat(victim, "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>")

	leaving = FALSE

	leave_victim()

/mob/living/simple_animal/horror/proc/leave_victim()
	if(!victim)
		return

	if(controlling)
		detatch()

	forceMove(get_turf(victim))

	reset_perspective(null)
	machine = null

	victim.reset_perspective(null)
	victim.machine = null

	var/mob/living/V = victim
	remove_verb(V, /mob/living/proc/horror_comm)
	talk_to_horror_action.Remove(victim)

	for(var/obj/item/horrortentacle/T in victim)
		victim.visible_message("<span class='warning'>[victim]'s tentacle transforms back!</span>", "<span class='notice'>Your tentacle disappears!</span>")
		playsound(victim, 'sound/effects/blobattack.ogg', 30, 1)
		qdel(T)
	victim = null

	RefreshAbilities()
	return

/mob/living/simple_animal/horror/proc/jumpstart()
	if(!victim)
		to_chat(src, "<span class='warning'>You need a host to be able to use this.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat != DEAD)
		to_chat(src, "<span class='warning'>Your host is already alive!</span>")
		return

	if(!has_chemicals(250))
		to_chat(src, "<span class='warning'>You need 250 chemicals to use this!</span>")
		return

	if(victim.stat == DEAD)
		victim.tod = null
		victim.setToxLoss(0)
		victim.setOxyLoss(0)
		victim.setCloneLoss(0)
		victim.SetUnconscious(0)
		victim.SetStun(0)
		victim.SetKnockdown(0)
		victim.radiation = 0
		victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
		victim.reagents.clear_reagents()
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			H.restore_blood()
			H.remove_all_embedded_objects()
		victim.revive()
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		to_chat(src, "<span class='notice'>You send a jolt of energy to your host, reviving them!</span>")
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		to_chat(victim, "<span class='notice'>You bolt upright, gasping for breath!</span>")

/mob/living/simple_animal/horror/proc/view_memory()
	if(!victim)
		to_chat(src, "<span class='warning'>You need a host to be able to use this.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='warning'>Your host brain is unresponsive. They are dead!</span>")
		return

	if(prob(20))
		to_chat(victim, "<span class='danger'>You suddenly feel your memory being tangled with...</span>")//chance to alert the victim

	if(victim.mind)
		var/datum/mind/suckedbrain = victim.mind
		to_chat(src, "<span class='boldnotice'>You skim through [victim]'s memories...[suckedbrain.memory]</span>")
		for(var/A in suckedbrain.antag_datums)
			var/datum/antagonist/antag_types = A
			var/list/all_objectives = antag_types.objectives.Copy()
			if(antag_types.antag_memory)
				to_chat(src, "<span class='notice'>[antag_types.antag_memory]</span>")
			if(LAZYLEN(all_objectives))
				to_chat(src, "<span class='boldnotice'>Objectives:</span>")
				var/obj_count = 1
				for(var/O in all_objectives)
					var/datum/objective/objective = O
					to_chat(src, "<span class='notice'>Objective #[obj_count++]: [objective.explanation_text]</span>")
					var/list/datum/mind/other_owners = objective.get_owners() - suckedbrain
					if(other_owners.len)
						for(var/mind in other_owners)
							var/datum/mind/M = mind
							to_chat(src, "<span class='notice'>Conspirator: [M.name]</span>")

		var/list/recent_speech = list()
		var/list/say_log = list()
		var/log_source = victim.logging
		for(var/log_type in log_source)
			var/nlog_type = text2num(log_type)
			if(nlog_type & LOG_SAY)
				var/list/reversed = log_source[log_type]
				if(islist(reversed))
					say_log = reverseRange(reversed.Copy())
					break
		if(LAZYLEN(say_log))
			for(var/spoken_memory in say_log)
				if(recent_speech.len >= 5)//up to 5 random lines of speech, favoring more recent speech
					break
				if(prob(50))
					recent_speech[spoken_memory] = say_log[spoken_memory]
		if(recent_speech.len)
			to_chat(src, "<span class='boldnotice'>You catch some drifting memories of their past conversations...</span>")
			for(var/spoken_memory in recent_speech)
				to_chat(src, "<span class='notice'>[recent_speech[spoken_memory]]</span>")
		var/mob/living/carbon/human/H = victim
		var/datum/dna/the_dna = H.has_dna()
		if(the_dna)
			to_chat(src, "<span class='boldnotice'>You uncover that [H.p_their()] true identity is [the_dna.real_name].</span>")

/mob/living/simple_animal/horror/proc/bond_brain()
	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(!can_use_ability())
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='warning'>This host lacks enough brain function to control.</span>")
		return

	if(bonding)
		bonding = FALSE
		to_chat(src, "<span class='userdanger'>You stop attempting to take control of your host.</span>")
		return

	to_chat(src, "<span class='danger'>You begin delicately adjusting your connection to the host brain...</span>")

	if(QDELETED(src) || QDELETED(victim))
		return

	bonding = TRUE

	var/delay = 200
	if(horrorupgrades["fast_control"])
		delay -= 120
	addtimer(CALLBACK(src, .proc/assume_control), delay)

/mob/living/simple_animal/horror/proc/assume_control()
	if(!victim || !src || controlling || victim.stat == DEAD)
		return
	if(!bonding)
		return
	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		bonding = FALSE
		return
	if(is_servant_of_ratvar(victim) || iscultist(victim))
		to_chat(src, "<span class='warning'>[victim]'s mind seems to be blocked by some unknown force!</span>")
		bonding = FALSE
		return
	if(HAS_TRAIT(victim, TRAIT_MINDSHIELD))
		to_chat(src, "<span class='warning'>[victim]'s mind seems to be shielded from your influence!</span>")
		bonding = FALSE
		return
	else
		RegisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE, .proc/hit_detatch)
		log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with eldritch powers.")
		to_chat(src, "<span class='warning'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>")
		to_chat(victim, "<span class='userdanger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")

		qdel(host_brain)
		host_brain = new(src)
		host_brain.H = src
		victim.mind.transfer_to(host_brain)

		to_chat(host_brain, "You are trapped in your own mind. You feel that there must be a way to resist!")

		mind.transfer_to(victim)

		bonding = FALSE
		controlling = TRUE

		remove_verb(victim, /mob/living/proc/horror_comm)
		talk_to_horror_action.Remove(victim)
		GrantControlActions()

		victim.med_hud_set_status()
		if(target)
			victim.apply_status_effect(/datum/status_effect/agent_pinpointer/horror)
			for(var/datum/status_effect/agent_pinpointer/horror/status in victim.status_effects)
				status.scan_target = target

/mob/living/carbon/proc/release_control()
	var/mob/living/simple_animal/horror/B = has_horror_inside()
	if(B && B.host_brain)
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")
		B.detatch()

//Check for brain worms in head.
/mob/proc/has_horror_inside()
	for(var/I in contents)
		if(ishorror(I))
			return I
	return FALSE

/mob/living/simple_animal/horror/proc/hit_detatch()
	if(victim.health <= 75)
		detatch()
		to_chat(src, "<span class='danger'>Upon taking damage, [victim]s brain detected danger, and hastily took over.</span>")
		to_chat(victim, "<span class='danger'>Your body is under attack, your brain immediately took over!</span>")

/mob/living/simple_animal/horror/proc/detatch()
	if(!victim || !controlling)
		return

	controlling = FALSE
	UnregisterSignal(victim, COMSIG_MOB_APPLY_DAMAGE)
	add_verb(victim, /mob/living/proc/horror_comm)
	RemoveControlActions()
	RefreshAbilities()
	talk_to_horror_action.Grant(victim)

	victim.med_hud_set_status()
	victim.remove_status_effect(/datum/status_effect/agent_pinpointer/horror)

	victim.mind.transfer_to(src)
	if(host_brain)
		host_brain.mind.transfer_to(victim)

	log_game("[src]/([src.ckey]) released control of [victim]/([victim.ckey]")
	qdel(host_brain)

/mob/living/simple_animal/horror/proc/Update_Invisibility_Button()
	var/datum/action/innate/horror/action = has_ability("chameleon")
	if(action)
		action.button_icon_state = "horror_sneak_[invisible ? "true" : "false"]"
		action.UpdateButtonIcon()

/mob/living/simple_animal/horror/proc/GrantHorrorActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("horror" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveHorrorActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("horror" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantInfestActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("infest" in ability.category)
			ability.Grant(src)

/mob/living/simple_animal/horror/proc/RemoveInfestActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("infest" in ability.category)
			ability.Remove(src)

/mob/living/simple_animal/horror/proc/GrantControlActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("control" in ability.category)
			ability.Grant(victim)

/mob/living/simple_animal/horror/proc/RemoveControlActions()
	for(var/A in horrorabilities)
		var/datum/action/innate/horror/ability = horrorabilities[A]
		if("control" in ability.category)
			ability.Remove(victim)

/mob/living/simple_animal/horror/proc/RefreshAbilities() //control abilities technically don't belong to horror
	if(victim)
		RemoveHorrorActions()
		GrantInfestActions()
	else
		RemoveInfestActions()
		GrantHorrorActions()