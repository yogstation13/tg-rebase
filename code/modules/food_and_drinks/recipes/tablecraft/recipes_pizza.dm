
// see code/module/crafting/table.dm

////////////////////////////////////////////////PIZZA!!!////////////////////////////////////////////////

/datum/crafting_recipe/food/arnold
	name = "Arnold Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 3,
		/obj/item/ammo_casing/c9mm = 8,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/arnold
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/dankpizza
	name = "Dank Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/dank
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/donkpocketpizza
	name = "Donkpocket Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/donkpocket/warm = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/donkpocket
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/nopizza
	name = "Hawaiian Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/noslice = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/no
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/margheritapizza
	name = "Margherita Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 4,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/margherita
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/meatpizza
	name = "Meat Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 4,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/meat
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/mushroompizza
	name = "Mushroom Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/grown/mushroom = 5
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/mushroom
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/sassysagepizza
	name = "Sassysage Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 3,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/sassysage
	subcategory = CAT_PIZZA

/datum/crafting_recipe/food/vegetablepizza
	name = "Vegetable Pizza"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/pizzabread = 1,
		/obj/item/reagent_containers/food/snacks/grown/eggplant = 1,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pizza/vegetable
	subcategory = CAT_PIZZA