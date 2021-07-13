/datum/religion_rites
	var/name = "religious rite" // name of the religious rite
	var/desc = "immm gonna rooon" // Description of the religious rite
	var/ritual_length = (10 SECONDS) // length it takes to complete the ritual
	var/list/ritual_invocations // list of invocations said (strings) throughout the rite
	var/invoke_msg // message when you invoke
	var/favor_cost = 0

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()


///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, "<span class='warning'>This rite requires more favor!</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You begin to perform the rite of [name]...</span>")
	if(!ritual_invocations)
		if(do_after(user, target = user, delay = ritual_length))
			if(invoke_msg)
				user.say(invoke_msg, forced = "ritual")
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len))
			return FALSE
		user.say(i, forced = "ritual")
	if(!do_after(user, target = user, delay = ritual_length/ritual_invocations.len)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg, forced = "ritual")
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 1 MINUTES
	ritual_invocations = list(
	"By the inner workings of our god...",
	"... We call upon you, in the face of adversity...",
	"... to complete us, removing that which is undesirable..."
	)
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 350

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2borg = i
			break
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	return TRUE

/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"...Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 2000	

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/cyberimp/arm/surgery,
					/obj/item/organ/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/cyberimp/eyes/hud/medical,
					/obj/item/organ/cyberimp/mouth/breathing_tube,
					/obj/item/organ/cyberimp/chest/thrusters,
					/obj/item/organ/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE
	

/*********Capitalists**********/

/*
* this rites makes you into a non converting capitalist golem for 10000 favor
*/
/datum/religion_rites/toppercent
	name = "Reaching the Top Percent"
	desc = "Help a moneybag to get even richer."
	ritual_length = 1 MINUTES
	ritual_invocations = list("%Money, money, money...",
						"%... Must be funny...",
						"%... In the rich man's world...")
	invoke_msg = "... Wait, it worked?"
	favor_cost = 10000

/*
* this rites gives you some snazzy looking clothes for 100 favor
*/
/datum/religion_rites/looks
	name = "Gonna look like it"
	desc = "From rags to riches? Better get rid of the rags then!"
	ritual_length = 0.5 MINUTES
	invoke_msg = "Please, all i want are some nice clothes..."
	favor_cost = 100

/datum/religion_rites/looks/invoke_effect(atom/religious_tool, mob/user)
	var/location = get_turf(user)
	new /obj/item/clothing/head/that(location)
	new /obj/item/clothing/glasses/monocle(location)
	new /obj/item/clothing/under/yogs/victorianvest(location)
	return TRUE

/datum/religion_rites/toppercent/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return
	return ..()

/datum/religion_rites/toppercent/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/mantomoney
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			mantomoney = i
			break
	if(!mantomoney)
		return FALSE
	mantomoney.set_species(/datum/species/golem/church_capitalist)
	mantomoney.visible_message("<span class='notice'>[mantomoney] has ascended to the top of society!</span>")
	return TRUE

/*********Ever-Burning Candle**********/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Wax"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded) || istype(chosen_clothing,/obj/item/clothing/suit/space/hardsuit ))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, "<span class='warning'>The clothing that was chosen for the rite is no longer on the altar!</span>")
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Candle Fuel"
	desc = "Sacrifice a buckled burning corpse for favor; the more burn damage the corpse has, the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("To feed the fire of the one true flame ...",
	"... to make it burn brighter ...",
	"... so that it may consume all in its path ...",
	"... I offer you this pitiful being ...")
	invoke_msg = "... may it join you in the amalgamation of wax and fire, and become one in the black and white scene. "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, "<span class='warning'>Nothing is buckled to the altar!</span>")
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, "<span class='warning'>Only carbon lifeforms can be properly burned for the sacrifice!</span>")
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, "<span class='warning'>You can only sacrifice dead bodies, this one is still alive!</span>")
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user, "<span class='warning'>This corpse needs to be on fire to be sacrificed!</span>")
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, "<span class='warning'>The right sacrifice is no longer on the altar!</span>")
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user, "<span class='warning'>The sacrifice is no longer on fire, it needs to burn until the end of the rite!</span>")
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, "<span class='warning'>The sacrifice has to stay dead for the rite to work!</span>")
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	to_chat(user, "<span class='notice'>[GLOB.deity] absorb the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor.</span>")
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE



/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "please lend us five of your candles so we may bask in your burning glory."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

/*********Plant people**********/

/datum/religion_rites/plantconversion
	name = "Ent Conversion"
	desc = "Convert a human-esque individual into a treelike golem."
	ritual_length = 1 MINUTES
	ritual_invocations = list(
	"Let us call upon the vines that protect...",
	"... Allow them to strip away that which is undesirable...",
	"... Allow them to protect our souls with a new shell..."
	)
	invoke_msg = "... Arise, one from the earth! Become one with the true vines, and spread its holy roots!!"
	favor_cost = 400 //on average, 20-40 crops

/datum/religion_rites/plantconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, "<span class='warning'>This rite requires a religious device that individuals can be buckled to.</span>")
			return
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [movable_reltool].</span>")
		return
	return ..()

/datum/religion_rites/plantconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2plant
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2plant = i
			break
	if(!human2plant)
		return FALSE
	human2plant.set_species(/datum/species/golem/wood/holy)
	human2plant.visible_message("<span class='notice'>[human2plant] has been converted by the rite of [name]!</span>")
	return TRUE
