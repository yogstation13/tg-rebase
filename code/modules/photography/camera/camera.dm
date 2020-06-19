#define CAMERA_PICTURE_SIZE_HARD_LIMIT 21

/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items_and_weapons.dmi'
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "camera"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	light_color = LIGHT_COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_NECK
	materials = list(MAT_METAL = 50, MAT_GLASS = 150)
	var/obj/item/disk/holodisk/disk
	var/pictures_left = 0
	var/default_picture_name
	var/camera_mode = CAMERA_STANDARD
	var/blending = FALSE		//lets not take pictures while the previous is still processing!
	var/on = TRUE // used to toggle the state during use.
	var/state_on = "camera"
	var/state_off = "camera_off"
	var/pictures_max = 10
	var/cooldown = 64
	var/see_ghosts = CAMERA_NO_GHOSTS //for the spoop of it
	var/sound/custom_sound
	var/picture_size_x = 2 // default x
	var/picture_size_y = 2 // default y
	var/picture_size_x_min = 1
	var/picture_size_y_min = 1
	var/picture_size_x_max = 4
	var/picture_size_y_max = 4
	var/silent = FALSE
	var/can_customise = TRUE // can this camera use description mode?
	var/can_switch_modes = TRUE // are you able to change the mode of this camera or is it stuck in default mode?
	var/flash_enabled = TRUE
	var/start_full = TRUE // does the camera spawn full of film

/obj/item/camera/Initialize()
	. = ..()
	if(start_full)
		pictures_left = pictures_max // future proofed if anyone ever creates a camera with a different max

/obj/item/camera/attack_self(mob/user)
	if(!disk)
		return
	to_chat(user, "<span class='notice'>You eject [disk] out the back of [src].</span>")
	user.put_in_hands(disk)
	disk = null

/obj/item/camera/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to change its focusing, allowing you to set how big of an area it will capture.</span>"

/obj/item/camera/proc/adjust_zoom(mob/user)
	var/desired_x = input(user, "How high do you want the camera to shoot, between [picture_size_x_min] and [picture_size_x_max]?", "Zoom", picture_size_x) as num
	var/desired_y = input(user, "How wide do you want the camera to shoot, between [picture_size_y_min] and [picture_size_y_max]?", "Zoom", picture_size_y) as num
	picture_size_x = min(clamp(desired_x, picture_size_x_min, picture_size_x_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)
	picture_size_y = min(clamp(desired_y, picture_size_y_min, picture_size_y_max), CAMERA_PICTURE_SIZE_HARD_LIMIT)

/obj/item/camera/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	adjust_zoom(user)

/obj/item/camera/attack_self(mob/user)
	if(can_switch_modes)
		if(camera_mode == CAMERA_STANDARD && can_customise)
			camera_mode = CAMERA_DESCRIPTION
		else if(camera_mode == CAMERA_DESCRIPTION)
			camera_mode = CAMERA_STANDARD
		to_chat(user, "<span class='notice'>You set the [src] to [camera_mode] mode.</span>")
		return

	to_chat(user, "<span class='notice'>This [src] can only be used in the [camera_mode] mode.</span>") // just in-case somone makes a camera that can only be descriptive

/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		qdel(I)
		pictures_left = pictures_max
		return
	if(istype(I, /obj/item/disk/holodisk))
		if (!disk)
			if(!user.transferItemToLoc(I, src))
				to_chat(user, "<span class='warning'>[I] is stuck to your hand!</span>")
				return TRUE
			to_chat(user, "<span class='notice'>You slide [I] into the back of [src].</span>")
			disk = I
		else
			to_chat(user, "<span class='warning'>There's already a disk inside [src].</span>")
		return TRUE //no afterattack
	..()

/obj/item/camera/examine(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE)) // so you're telling me you're able to see how many photo's are left inside the camera from a distance?
		return
	var/iscarbon = FALSE
	var/photographer = FALSE
	if(istype(user,/mob/living/carbon))
		var/mob/living/carbon/human/H = user
		iscarbon = TRUE
		if (HAS_TRAIT(H, TRAIT_PHOTOGRAPHER))
			photographer = TRUE

	if(pictures_left == 0)
		. += "[src] is empty."
	else
		if(iscarbon)
			if (photographer)
				. += "It has [pictures_left] photos left."
			else
				. += "It has photos left."
		else
			. += "It has [pictures_left] photos left." 
	if(photographer)
		. += "[src] lens is set for a [picture_size_x] by [picture_size_y] picture."
		. += "[src] is set to the [camera_mode] mode."

//user can be atom or mob
/obj/item/camera/proc/can_target(atom/target, mob/user, prox_flag)
	if(!on || blending || !pictures_left)
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	if(istype(user))
		if(isAI(user) && !GLOB.cameranet.checkTurfVis(T))
			return FALSE
		else if(user.client && !(get_turf(target) in get_hear(user.client.view, user)))
			return FALSE
		else if(!(get_turf(target) in get_hear(world.view, user)))
			return FALSE
	else					//user is an atom
		if(!(get_turf(target) in view(world.view, user)))
			return FALSE
	return TRUE

/obj/item/camera/emp_act(severity)
	if(on) // EMP will only work on cameras that are on as it has power going through it
		icon_state = state_off
		on = FALSE
		addtimer(CALLBACK(src, .proc/emp_after), (600/severity))

/obj/item/camera/proc/emp_after()
	on = TRUE
	icon_state = state_on

/obj/item/camera/afterattack(atom/target, mob/user, flag)
	if (disk)
		if(ismob(target))
			if (disk.record)
				QDEL_NULL(disk.record)

			disk.record = new
			var/mob/M = target
			disk.record.caller_name = M.name
			disk.record.set_caller_image(M)
		else
			to_chat(user, "<span class='warning'>Invalid holodisk target.</span>")
			return

	if(!can_target(target, user, flag))
		return

	on = FALSE

	var/realcooldown = cooldown
	var/mob/living/carbon/human/H = user
	if (HAS_TRAIT(H, TRAIT_PHOTOGRAPHER))
		realcooldown *= 0.5
	addtimer(CALLBACK(src, .proc/cooldown), realcooldown)

	icon_state = state_off

	INVOKE_ASYNC(src, .proc/captureimage, target, user, flag, picture_size_x - 1, picture_size_y - 1)


/obj/item/camera/proc/cooldown()
	UNTIL(!blending)
	icon_state = state_on
	on = TRUE

/obj/item/camera/proc/show_picture(mob/user, datum/picture/selection)
	var/obj/item/photo/P = new(src, selection)
	P.show(user)
	to_chat(user, P.desc)
	qdel(P)

/obj/item/camera/proc/captureimage(atom/target, mob/user, flag, size_x = 1, size_y = 1)
	if(flash_enabled)
		flash_lighting_fx(8, light_power, light_color)
	blending = TRUE
	var/turf/target_turf = get_turf(target)
	if(!isturf(target_turf))
		blending = FALSE
		return FALSE
	size_x = clamp(size_x, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	size_y = clamp(size_y, 0, CAMERA_PICTURE_SIZE_HARD_LIMIT)
	var/list/desc = list("This is a photo of an area of [size_x+1] meters by [size_y+1] meters.")
	var/list/mobs_spotted = list()
	var/list/dead_spotted = list()
	var/ai_user = isAI(user)
	var/list/seen
	var/list/viewlist = (user && user.client)? getviewsize(user.client.view) : getviewsize(world.view)
	var/viewr = max(viewlist[1], viewlist[2]) + max(size_x, size_y)
	var/viewc = user.client? user.client.eye : target
	seen = get_hear(viewr, viewc)
	var/list/turfs = list()
	var/list/mobs = list()
	var/blueprints = FALSE
	var/clone_area = SSmapping.RequestBlockReservation(size_x * 2 + 1, size_y * 2 + 1)
	for(var/turf/T in block(locate(target_turf.x - size_x, target_turf.y - size_y, target_turf.z), locate(target_turf.x + size_x, target_turf.y + size_y, target_turf.z)))
		if((ai_user && GLOB.cameranet.checkTurfVis(T)) || (T in seen))
			turfs += T
			for(var/mob/M in T)
				mobs += M
			if(locate(/obj/item/areaeditor/blueprints) in T)
				blueprints = TRUE
	for(var/i in mobs)
		var/mob/M = i
		mobs_spotted += M
		if(M.stat == DEAD)
			dead_spotted += M
		desc += M.get_photo_description(src)

	var/psize_x = (size_x * 2 + 1) * world.icon_size
	var/psize_y = (size_y * 2 + 1) * world.icon_size
	var/get_icon = camera_get_icon(turfs, target_turf, psize_x, psize_y, clone_area, size_x, size_y, (size_x * 2 + 1), (size_y * 2 + 1))
	qdel(clone_area)
	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	temp.Blend("#000", ICON_OVERLAY)
	temp.Scale(psize_x, psize_y)
	temp.Blend(get_icon, ICON_OVERLAY)

	var/datum/picture/P = new("picture", desc.Join(" "), mobs_spotted, dead_spotted, temp, null, psize_x, psize_y, blueprints)
	after_picture(user, P, flag)
	blending = FALSE

/obj/item/camera/proc/after_picture(mob/user, datum/picture/picture, proximity_flag)
	printpicture(user, picture)

/obj/item/camera/proc/printpicture(mob/user, datum/picture/picture) //Normal camera proc for creating photos
	var/obj/item/photo/p = new(get_turf(src), picture)
	if(in_range(src, user)) //needed because of TK
		user.put_in_hands(p)
		pictures_left--
		to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
		if(can_customise && camera_mode == CAMERA_DESCRIPTION)
			var/customise = "No"
			customise = alert(user, "Do you want to customize the photo?", "Customization", "Yes", "No")
			if(customise == "Yes")
				var/name1 = stripped_input(user, "Set a name for this photo, or leave blank. 32 characters max.", "Name", max_length = 32)
				var/desc1 = stripped_input(user, "Set a description to add to photo, or leave blank. 128 characters max.", "Caption", max_length = 128)
				var/caption = stripped_input(user, "Set a caption for this photo, or leave blank. 256 characters max.", "Caption", max_length = 256)
				if(name1)
					picture.picture_name = name1
				if(desc1)
					picture.picture_desc = "[desc1] - [picture.picture_desc]"
				if(caption)
					picture.caption = caption
			else
				if(default_picture_name)
					picture.picture_name = default_picture_name

		p.set_picture(picture, TRUE, TRUE)
		if(CONFIG_GET(flag/picture_logging_camera))
			picture.log_to_file()
