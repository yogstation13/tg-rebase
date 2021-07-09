/obj/machinery/papershredder
	name = "Paper Shredder"
	desc = "For those documents you don't want seen."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papershredder0"
	density = 1
	anchored = 1
	var/max_paper = 10
	var/paperamount = 0


/obj/machinery/papershredder/attackby(obj/item/W as obj, mob/user as mob)
	if(default_unfasten_wrench(user, W))
		return
	if (istype(W, /obj/item/paper))
		if(paperamount == max_paper)
			if(prob(5))
				var/i
				var/curpaper = paperamount
				for(i=1; i<=curpaper; i++)
					var/obj/item/shreddedp/SP = new /obj/item/shreddedp(usr.loc)
					SP.pixel_x = rand(-5,5)
					SP.pixel_y = rand(-5,5)
					var/ran = rand(1,3)
					if(ran == 1)
						SP.color = "#BABABA"
					if(ran == 2)
						SP.color = "#7F7F7F"
					if(ran == 3)
						SP.color = null
					paperamount -=1
				update_icon()
				user <<"\red The [src] was too full and shredded paper goes everywhere"
				return
			else
				user << "\red The [src] is full please empty it before you continue"
				return
		if(paperamount < max_paper)
			del(W)
			paperamount += 1
			update_icon()
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			return
	else if(istype(W, /obj/item/photo))
		if(paperamount < max_paper)
			del(W)
			paperamount += 1
			update_icon()
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			return
	else if(istype(W, /obj/item/newspaper))
		if(paperamount < max_paper-3)
			del(W)
			paperamount += 3
			update_icon()
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			return
	else if(istype(W, /obj/item/card/id))
		if(paperamount < max_paper-3)
			del(W)
			paperamount += 3
			update_icon()
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			return
	else if(istype(W, /obj/item/paper_bundle))
		if(paperamount < max_paper-3)
			del(W)
			paperamount += 3
			update_icon()
			playsound(src.loc, 'sound/items/pshred.ogg', 75, 1)
			return
	else if(istype(W, /obj/item/storage/bag/trash))
		var/datum/component/storage/STR = W.GetComponent(/datum/component/storage)
		var/curpaper = paperamount
		var/i
		for(i=1; i<=curpaper; i++)
			if(W.contents.len < 21)
				var/obj/item/shreddedp/SP = new /obj/item/shreddedp
				var/ran = rand(1,3)
				if(ran == 1)
					SP.color = "#BABABA"
				if(ran == 2)
					SP.color = "#7F7F7F"
				if(ran == 3)
					SP.color = null
				STR.handle_item_insertion(SP)
				paperamount -=1
				update_icon()
			else
				user << "\red The [W] is full"
				return
	else if(istype(W, /obj/item/shreddedp))
		if(paperamount == max_paper)
			user << "\red The [src] is full please empty it before you continue"
			return
		if(paperamount < max_paper)
			del(W)
			paperamount += 1
			update_icon()
			return
	else
		return



/obj/machinery/papershredder/verb/emtpy()
	set name = "Empty bin"
	set category = "Object"
	set src in oview(1)
	if(paperamount != 0)
		var/i
		var/curpaper = paperamount
		for(i=1; i<=curpaper; i++)
			var/obj/item/shreddedp/SP = new /obj/item/shreddedp(usr.loc)
			SP.pixel_x = rand(-5,5)
			SP.pixel_y = rand(-5,5)
			var/ran = rand(1,3)
			if(ran == 1)
				SP.color = "#BABABA"
			if(ran == 2)
				SP.color = "#7F7F7F"
			if(ran == 3)
				SP.color = null
			paperamount -=1
		update_icon()

/obj/machinery/papershredder/update_icon()
	if(paperamount == 0)
		icon_state = "papershredder0"
	if(paperamount == 1||paperamount == 2)
		icon_state = "papershredder1"
	if(paperamount == 3||paperamount == 4)
		icon_state = "papershredder2"
	if(paperamount == 5||paperamount == 6)
		icon_state = "papershredder3"
	if(paperamount == 7||paperamount == 8)
		icon_state = "papershredder4"
	if(paperamount == 9||paperamount == 10)
		icon_state = "papershredder5"
	return

/obj/item/shreddedp
	name = "shredded paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredp"
	throwforce = 0
	w_class = 1.0
	throw_range = 3
	throw_speed = 1
	layer = 4
	pressure_resistance = 1

/obj/item/shreddedp/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/lighter))
		burnpaper(W, user)
	else
		..()


/obj/item/shreddedp/proc/burnpaper(obj/item/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/lighter))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.")

				if(user.get_inactive_hand_index() == src)
					user.dropItemToGround(src)

				new /obj/effect/decal/cleanable/ash(src.loc)
				del(src)

			else
				user << "\red You must hold \the [P] steady to burn \the [src]."

/obj/item/shreddedp/proc/FireBurn()
	new /obj/effect/decal/cleanable/ash(src.loc)
	del(src)
