///Has no special properties.
/datum/material/iron
	name = "iron"
	id = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#878687"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/metal
	coin_type = /obj/item/coin/iron

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	id = "glass"
	desc = "Glass forged by melting sand."
	color = "#dae6f0"
	alpha = 210
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	integrity_modifier = 0.1
	sheet_type = /obj/item/stack/sheet/glass


///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	id = "silver"
	desc = "Silver"
	color = "#bdbebf"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	coin_type = /obj/item/coin/silver

///Slight force increase
/datum/material/gold
	name = "gold"
	id = "gold"
	desc = "Gold"
	color = "#f0972b"
	strength_modifier = 1.2
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	coin_type = /obj/item/coin/gold

///Has no special properties
/datum/material/diamond
	name = "diamond"
	id = "diamond"
	desc = "Highly pressurized carbon"
	color = "#22c2d4"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	coin_type = /obj/item/coin/diamond

///Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	id = "uranium"
	desc = "Uranium"
	color = "#1fb83b"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	coin_type = /obj/item/coin/uranium

/datum/material/uranium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/radioactive, amount / 10, source, 0) //half-life of 0 because we keep on going.

/datum/material/uranium/on_removed(atom/source, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/radioactive))


///Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	id = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	color = "#c716b8"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	coin_type = /obj/item/coin/plasma

/datum/material/plasma/on_applied(atom/source, amount, material_flags)
	. = ..()
	if(ismovable(source))
		source.AddComponent(/datum/component/explodable, 0, 0, amount / 1000, amount / 500)

/datum/material/plasma/on_removed(atom/source, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/explodable))

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	id = "bluespace_crystal"
	desc = "Crystals with bluespace properties"
	color = "#506bc7"
	categories = list(MAT_CATEGORY_ORE = TRUE)
	sheet_type = /obj/item/stack/sheet/bluespace_crystal

///Honks and slips
/datum/material/bananium
	name = "bananium"
	id = "bananium"
	desc = "Material with hilarious properties"
	color = "#fff263"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	coin_type = /obj/item/coin/bananium

/datum/material/bananium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
	source.AddComponent(/datum/component/slippery, min(amount / 10, 80))

/datum/material/bananium/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/slippery))
	qdel(source.GetComponent(/datum/component/squeak))


///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	id = "titanium"
	desc = "Titanium"
	color = "#b3c0c7"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/titanium

///Force decrease
/datum/material/plastic
	name = "plastic"
	id = "plastic"
	desc = "plastic"
	color = "#caccd9"
	strength_modifier = 0.85
	sheet_type = /obj/item/stack/sheet/plastic

///Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	id = "biomass"
	desc = "Organic matter"
	color = "#735b4d"
	strength_modifier = 0.8

//formed when freon react with o2, emits a lot of plasma when heated
/datum/material/hot_ice
	name = "hot ice"
	desc = "A weird kind of ice, feels warm to the touch"
	color = "#88cdf1"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/hot_ice

/datum/material/hot_ice/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.AddComponent(/datum/component/hot_ice, "plasma", amount*150, amount*20+300)

/datum/material/hot_ice/on_removed(atom/source, amount, material_flags)
	qdel(source.GetComponent(/datum/component/hot_ice, "plasma", amount*150, amount*20+300))
	return ..()

/datum/material/hot_ice/on_accidental_mat_consumption(mob/living/carbon/M, obj/item/S)
	M.reagents.add_reagent(/datum/reagent/toxin/plasma, rand(5, 6))
	S?.reagents?.add_reagent(/datum/reagent/toxin/plasma, S.reagents.total_volume*(3/5))
	var/obj/item/reagent_containers/food/snacks/food_S = S
	if(istype(food_S) && food_S?.tastes?.len)
		food_S.tastes += "salt"
		food_S.tastes["salt"] = 3
	return TRUE

/datum/material/metalhydrogen
	name = "Metal Hydrogen"
	desc = "Solid metallic hydrogen. Some say it should be impossible"
	color = "#f2d5d7"
	alpha = 240
	categories = list(MAT_CATEGORY_RIGID = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/metal_hydrogen
	strength_modifier = 1.2

/datum/material/zaukerite
	name = "zaukerite"
	desc = "A light absorbing crystal"
	color = COLOR_ALMOST_BLACK
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_ITEM_MATERIAL=TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/zaukerite

/datum/material/zaukerite/on_accidental_mat_consumption(mob/living/carbon/victim, obj/item/source_item)
	victim.apply_damage(30, BURN, BODY_ZONE_HEAD)
	source_item?.reagents?.add_reagent(/datum/reagent/toxin/plasma, source_item.reagents.total_volume*5)
	return TRUE

///Yogs///

///Used for some batteries and in atmospherics to lower the required temperature for fusion
/datum/material/dilithium
	name = "dilithium crystal"
	id = "dilithium_crystal"
	desc = "Crystals with dilithium properties"
	color = "#506bc7"
	categories = list(MAT_CATEGORY_ORE = TRUE)
	sheet_type = /obj/item/stack/sheet/dilithium_crystal
