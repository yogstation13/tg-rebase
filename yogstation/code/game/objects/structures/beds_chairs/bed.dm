#define STASIS_TOGGLE_COOLDOWN 50
/obj/structure/bed/roller/stasis
	name = "stasis roller bed"
	desc = "A rolling bed with the stabilizing effect of a stasis bed."
	icon = 'yogstation/icons/obj/rollerbed.dmi'
	icon_state = "stasis-down-off"
	foldabletype = /obj/item/roller/stasis
	upicon = "stasis-up-off"
	downicon = "stasis-down-off"
	bolts = FALSE

	var/idle_power_usage = 80
	var/active_power_usage = 680
	var/emag_power_usage = 1020
	var/stasis_enabled = FALSE
	var/last_stasis_sound = FALSE
	var/mob/living/carbon/human/patient = null
	var/stasis_can_toggle = 0
	var/use_power = 0
	var/obj/item/stock_parts/cell/cell = null
	var/up_overlay = null
	var/down_overlay = null

/obj/structure/bed/roller/stasis/get_cell()
	return cell

/obj/structure/bed/roller/stasis/proc/update_overlay()
	cut_overlays()
	if(!cell)
		up_overlay = "stasis-up-nocell"
		down_overlay = "stasis-down-nocell"
		if(patient)
			add_overlay(up_overlay)
		else
			add_overlay(down_overlay)
		return
	var/chargeleft = cell.percent()
	if(chargeleft >= 100)
		up_overlay = "stasis-up-100"
		down_overlay = "stasis-down-100"
	else if(chargeleft < 100 && chargeleft >= 75)
		up_overlay = "stasis-up-75"
		down_overlay = "stasis-down-75"
	else if(chargeleft < 75 && chargeleft >= 50)
		up_overlay = "stasis-up-50"
		down_overlay = "stasis-down-50"
	else if(chargeleft < 50 && chargeleft >= 25)
		up_overlay = "stasis-up-25"
		down_overlay = "stasis-down-25"
	else if(chargeleft < 25 && chargeleft > 0)
		up_overlay = "stasis-up-25"
		down_overlay = "stasis-down-25"
	if(patient)
		add_overlay(up_overlay)
	else
		add_overlay(down_overlay)

/obj/structure/bed/roller/stasis/post_buckle_mob(mob/living/M)
	..()
	M.pixel_y = initial(M.pixel_y)
	if(stasis_enabled)
		chill_out(M)
	patient = M
	cut_overlays()
	add_overlay(up_overlay)
	update_icon()

/obj/structure/bed/roller/stasis/post_unbuckle_mob(mob/living/M)
	..()
	thaw_them(M)
	patient = null
	cut_overlays()
	add_overlay(down_overlay)
	update_icon()

/obj/structure/bed/roller/stasis/proc/play_power_sound()
	if(last_stasis_sound != stasis_enabled)
		var/sound_freq = rand(5120, 8800)
		if(stasis_enabled)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)

		last_stasis_sound = stasis_enabled

/obj/structure/bed/roller/stasis/proc/chill_out(mob/living/target)
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(STATUS_EFFECT_STASIS, null, TRUE)
	target.ExtinguishMob()
	use_power = active_power_usage
	if(obj_flags & EMAGGED)
		use_power = emag_power_usage
		to_chat(target, "<span class='warning'>Your limbs start to feel numb...</span>")

/obj/structure/bed/roller/stasis/proc/thaw_them(mob/living/target)
	target.remove_status_effect(STATUS_EFFECT_STASIS)
	use_power = idle_power_usage

/obj/structure/bed/roller/stasis/AltClick(mob/user)
	if(!(world.time >= stasis_can_toggle && user.canUseTopic(src, !issilicon(user)) || cell.charge < active_power_usage))
		return
	if(cell.charge < active_power_usage)
		to_chat(user, "<span class='warning'>The roller stasis bed doesent have enough power to start!</span>")
		return
	switch_states()
	stasis_can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)

/obj/structure/bed/roller/stasis/proc/switch_states()
	if(stasis_enabled)
		if(patient)
			thaw_them(patient)
		upicon = "stasis-up-off"
		downicon = "stasis-down-off"
		stasis_enabled = FALSE
		use_power = 0
		update_bed_icon()
		play_power_sound()
		STOP_PROCESSING(SSobj, src)
		return
	use_power = idle_power_usage
	if(patient)
		chill_out(patient)
	upicon = "stasis-up"
	downicon = "stasis-down"
	stasis_enabled = TRUE
	update_bed_icon()
	play_power_sound()
	START_PROCESSING(SSobj, src)

/obj/structure/bed/roller/stasis/process()
	deductcharge(use_power)
	if(obj_flags & EMAGGED && patient.getStaminaLoss() <= 200)
		patient.adjustStaminaLoss(5)
		
/obj/structure/bed/roller/stasis/proc/deductcharge(chrgdeductamt)
	if(!cell)
		return
	. = cell.use(chrgdeductamt)
	update_overlay()
	if(stasis_enabled && cell.charge < use_power)
		switch_states()
		cut_overlays()

/obj/structure/bed/roller/stasis/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
			return
		if(C.maxcharge < active_power_usage)
			to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		cell = W
		to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
		update_icon()
		update_overlay()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!cell)
			return
		cell.update_icon()
		cell.forceMove(get_turf(src))
		cell = null
		W.play_tool_sound(src, 50)
		to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
		if(stasis_enabled)
			switch_states()
		update_icon()
		update_overlay()
		STOP_PROCESSING(SSobj, src)
	else
		return ..()

/obj/structure/bed/roller/stasis/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] does not have a power source installed.</span>"
	
/obj/structure/bed/roller/stasis/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The roller stasis bed's safeties are already overriden!</span>")
		return
	to_chat(user, "<span class='notice'>You override the roller stasis bed's safeties!</span>")
	obj_flags |= EMAGGED

/obj/structure/bed/roller/stasis/MouseDrop(over_object, src_location, over_location)
	if(!over_object == usr && Adjacent(usr))
		return
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return 0
	if(has_buckled_mobs())
		return 0
	usr.visible_message("[usr] collapses \the [src.name].", "<span class='notice'>You collapse \the [src.name].</span>")
	var/obj/structure/bed/roller/stasis/B = new foldabletype(get_turf(src))
	usr.put_in_hands(B)
	B.cell = cell
	B.stasis_enabled = stasis_enabled
	B.last_stasis_sound = last_stasis_sound
	B.stasis_can_toggle = stasis_can_toggle
	if(cell)
		B.icon_state = "stasis-folded-off"
	if(stasis_enabled)
		B.icon_state = "stasis-folded-on"
		B.use_power = B.idle_power_usage
	if(obj_flags & EMAGGED)
		B.obj_flags |= EMAGGED
	if(obj_flags & EMAGGED && stasis_enabled)
		B.icon_state = "stasis-folded-emaged"
	qdel(src)

/obj/item/roller/stasis
	name = "stasis roller bed"
	desc = "A folded rolling bed with the stabilizing effect of a stasis bed."
	icon = 'yogstation/icons/obj/rollerbed.dmi'
	icon_state = "stasis-folded-nocell"
	unfoldabletype = /obj/structure/bed/roller/stasis

	var/idle_power_usage = 80
	var/active_power_usage = 680
	var/emag_power_usage = 1020
	var/stasis_enabled = FALSE
	var/last_stasis_sound = FALSE
	var/stasis_can_toggle = 0
	var/use_power = 0
	var/obj/item/stock_parts/cell/cell = null

/obj/item/roller/stasis/get_cell()
	return cell

/obj/item/roller/stasis/proc/play_power_sound()
	if(last_stasis_sound != stasis_enabled)
		var/sound_freq = rand(5120, 8800)
		if(stasis_enabled)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)

		last_stasis_sound = stasis_enabled

		

/obj/item/roller/stasis/AltClick(mob/user)
	if(!(world.time >= stasis_can_toggle && user.canUseTopic(src, !issilicon(user)) || cell.charge < active_power_usage))
		return
	if(cell.charge < active_power_usage)
		to_chat(user, "<span class='warning'>The roller stasis bed doesent have enough power to start!</span>")
		return
	switch_states()
	stasis_can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)

/obj/item/roller/stasis/proc/switch_states()
	if(stasis_enabled)
		icon_state = "stasis-folded-off"
		stasis_enabled = FALSE
		use_power = 0
		play_power_sound()
		STOP_PROCESSING(SSobj, src)
		return
	use_power = idle_power_usage
	icon_state = "stasis-folded-on"
	if(obj_flags & EMAGGED)
		icon_state = "stasis-folded-emaged"
	stasis_enabled = TRUE
	play_power_sound()
	START_PROCESSING(SSobj, src)

/obj/item/roller/stasis/process()
	deductcharge(use_power)
		
/obj/item/roller/stasis/proc/deductcharge(chrgdeductamt)
	if(!cell)
		return
	. = cell.use(chrgdeductamt)
	if(stasis_enabled && cell.charge < use_power)
		switch_states()

/obj/item/roller/stasis/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
			return
		if(C.maxcharge < active_power_usage)
			to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		cell = W
		to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
		icon_state = "stasis-folded-off"

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!cell)
			return
		cell.update_icon()
		cell.forceMove(get_turf(src))
		cell = null
		W.play_tool_sound(src, 50)
		to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
		if(stasis_enabled)
			switch_states()
		icon_state = "stasis-folded-nocell"
		STOP_PROCESSING(SSobj, src)
	else
		return ..()

/obj/item/roller/stasis/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] does not have a power source installed.</span>"
	
/obj/item/roller/stasis/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The roller stasis bed's safeties are already overriden!</span>")
		return
	to_chat(user, "<span class='notice'>You override the roller stasis bed's safeties!</span>")
	obj_flags |= EMAGGED
	if(stasis_enabled)
		icon_state = "stasis-folded-emaged"

/obj/item/roller/stasis/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/stasis/R = new unfoldabletype(location)
	R.add_fingerprint(user)
	R.cell = cell
	R.last_stasis_sound = last_stasis_sound
	R.stasis_can_toggle = stasis_can_toggle
	if(stasis_enabled)
		R.switch_states()
	R.update_overlay()
	if(obj_flags & EMAGGED)
		R.obj_flags |= EMAGGED
	qdel(src)

/obj/structure/bed/roller/stasis/prototype
	name = "stasis roller bed"
	desc = "An unfolded prototype of a design that combines the mobilitiy of a rolling bed with the stabilizing effect of a stasis bed, given to the station by Nanotrasen for field testing."
	foldabletype = /obj/item/roller/stasis/prototype

/obj/item/roller/stasis/prototype
	name = "stasis roller bed"
	desc = "A folded prototype of a design that combines the mobilitiy of a rolling bed with the stabilizing effect of a stasis bed, given to the station by Nanotrasen for field testing."
	unfoldabletype = /obj/structure/bed/roller/stasis/prototype
