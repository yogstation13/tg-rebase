//here is the chopping block.
//it can be created from 2 wooden planks
//place this on a table or else you will build it in your hands, which places at your feet!
/obj/item/chopping_block
	name = "chopping block"
	desc = "A primitive version that cavemen used to use for processing food. Yuck!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "choppingblock"

/obj/item/chopping_block/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/kitchen/rollingpin))
		return
	var/turf/T = get_turf(src)
	if(!T)
		return
	new /obj/structure/chopping_block(T)
	qdel(W)
	qdel(src)

/obj/structure/chopping_block
	name = "chopping block"
	desc = "A primitive version that cavemen used to use for processing food. Yuck!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "choppingpin"

	var/build_stage = 1
	var/obj/item/reagent_containers/glass/bowl
	var/completed = FALSE

/obj/structure/chopping_block/update_icon()
	. = ..()
	if(build_stage == 1)
		icon_state = "choppinbowl"

/obj/structure/chopping_block/Destroy()
	if(!completed)
		var/turf/T = get_turf(src)
		if(!T)
			return
		new /obj/item/chopping_block(T)
		new /obj/item/kitchen/rollingpin(T)
		if(bowl)
			new /obj/item/reagent_containers/glass/bowl(T)
	. = ..()


/obj/structure/chopping_block/attackby(obj/item/I, mob/living/user, params)
	if(build_stage == 1)
		if(!istype(I, /obj/item/reagent_containers/glass/bowl))
			to_chat(user, "<span class='warning'>You require a bowl!</span>")
			return
		bowl = I
		qdel(I)
		update_icon()
		build_stage++
		return
	if(build_stage == 2)
		if(!istype(I, /obj/item/kitchen/knife/butcher))
			to_chat(user, "<span class='warning'>You require a butcher's knife!</span>")
			return
		var/turf/T = get_turf(src)
		if(!T)
			return
		new /obj/machinery/processor/chopping_block(T)
		completed = TRUE
		qdel(I)
		qdel(src)
	if(istype(I, /obj/item/wrench))
		src.Destroy()
	if(istype(I, /obj/item/screwdriver))
		src.Destroy()

/obj/machinery/processor/chopping_block
	name = "chopping block"
	desc = "A primitive version that cavemen used to use for processing food. Yuck!"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "chopibobut"
	density = FALSE
	circuit = null

/obj/machinery/processor/chopping_block/Initialize()
	. = ..()

/obj/machinery/processor/chopping_block/Destroy()
	var/turf/T = get_turf(src)
	if(!T)
		return
	new /obj/item/chopping_block(T)
	new /obj/item/kitchen/rollingpin(T)
	new /obj/item/reagent_containers/glass/bowl(T)
	new /obj/item/kitchen/knife/butcher(T)
	. = ..()

/obj/machinery/processor/chopping_block/attackby(obj/item/O, mob/user, params)
	if(processing)
		to_chat(user, "<span class='warning'>[src] is in the process of processing!</span>")
		return TRUE
	if(istype(O, /obj/item/wrench))
		src.Destroy()
	if(istype(O, /obj/item/screwdriver))
		src.Destroy()
	if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/item/reagent_containers/food/snacks/S in T.contents)
			var/datum/food_processor_process/P = select_recipe(S)
			if(P)
				if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
					loaded++

		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] items into [src].</span>")
		return

	var/datum/food_processor_process/P = select_recipe(O)
	if(P)
		user.visible_message("[user] put [O] into [src].", \
			"You put [O] into [src].")
		user.transferItemToLoc(O, src, TRUE)
		return 1
	else
		if(user.a_intent != INTENT_HARM)
			to_chat(user, "<span class='warning'>That probably won't blend!</span>")
			return 1
		else
			return ..()

/obj/machinery/processor/chopping_block/interact(mob/user)
	if(processing)
		to_chat(user, "<span class='warning'>[src] is in the process of processing!</span>")
		return TRUE
	if(contents.len == 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return TRUE
	processing = TRUE
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How did it get in there? Please report it immediately!!!")
			continue
		total_time += P.time
	sleep(total_time / rating_speed)
	for(var/atom/movable/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How do you put it in?")
			continue
		process_food(P, O)
	pixel_x = initial(pixel_x) //return to its spot after shaking
	processing = FALSE
	visible_message("\The [src] finishes processing.")
