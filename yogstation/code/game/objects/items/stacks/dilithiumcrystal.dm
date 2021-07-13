//Dilithium crystals, used in atmospherics to lower the required temperature for fusion, by grinding into a matter and reacting to form a gas.
/obj/item/stack/ore/dilithium_crystal
	name = "dilithium crystal"
	desc = "A glowing dilithium crystal. It looks very delicate."
	icon = 'yogstation/icons/obj/telescience.dmi'
	icon_state = "dilithium_crystal"
	singular_name = "dilithium crystal"
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/dilithium=MINERAL_MATERIAL_AMOUNT)
	points = 50
	refined_type = /obj/item/stack/sheet/dilithium_crystal
	grind_results = list(/datum/reagent/dilithium = 20)

/obj/item/stack/ore/dilithium_crystal/refined
	name = "refined dilithium crystal"
	points = 0

/obj/item/stack/ore/dilithium_crystal/Initialize()
	. = ..()
	pixel_x = rand(-5, 5) // Cloned over from bluespace crystals. I guess to make their spawning a bit more scattered?
	pixel_y = rand(-5, 5)

/obj/item/stack/ore/dilithium_crystal/attack_self(mob/user) // Currently has no effect, besides crushing one of the crystals into dust.
	user.visible_message("<span class='warning'>[user] crushes [src]!</span>", "<span class='danger'>You crush [src]!</span>")
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, "sparks", 50, 1)
	use(1)

/obj/item/stack/sheet/dilithium_crystal
	name = "dilithium polycrystal"
	icon = 'yogstation/icons/obj/telescience.dmi'
	icon_state = "dilithium_polycrystal"
	singular_name = "dilithium polycrystal"
	desc = "A stable polycrystal, made of fused-together dilithium crystals. You could probably break one off."
	materials = list(/datum/material/dilithium=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("dilithium polybashed", "dilithium polybattered", "bluespace polybludgeoned", "bluespace polythrashed", "bluespace polysmashed")
	novariants = TRUE
	grind_results = list(/datum/reagent/dilithium = 20)
	point_value = 30
	var/crystal_type = /obj/item/stack/ore/dilithium_crystal/refined

/obj/item/stack/sheet/dilithium_crystal/attack_self(mob/user)// to prevent the construction menu from ever happening
	to_chat(user, "<span class='warning'>You cannot crush the polycrystal in-hand, try breaking one off.</span>")

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/stack/sheet/dilithium_crystal/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		var/BC = new crystal_type(src)
		user.put_in_hands(BC)
		use(1)
		if(!amount)
			to_chat(user, "<span class='notice'>You break the final crystal off.</span>")
		else
			to_chat(user, "<span class='notice'>You break off a crystal.</span>")
	else
		..()
