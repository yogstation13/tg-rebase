/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled to the brim with medical junk."
	icon_state = "med"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical1/PopulateContents()
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/reagent_containers/dropper = 2,
		/obj/item/storage/belt/medical = 1,
		/obj/item/storage/box/syringes = 1,
		/obj/item/reagent_containers/glass/bottle/toxin = 1,
		/obj/item/reagent_containers/glass/bottle/morphine = 2,
		/obj/item/reagent_containers/glass/bottle/epinephrine= 3,
		/obj/item/reagent_containers/glass/bottle/charcoal = 3,
		/obj/item/storage/box/rxglasses = 1)
	generate_items_inside(items_inside,src)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic closet"
	desc = "Used to knock people out."
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/medical2/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/tank/internals/anesthetic(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/mask/breath/medical(src)

/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_SURGERY)
	icon_state = "med_secure"

/obj/structure/closet/secure_closet/medical3/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	return

/obj/structure/closet/secure_closet/CMO
	name = "\proper chief medical officer's locker"
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	..()
	new /obj/item/storage/backpack/duffelbag/med(src)
	new /obj/item/cartridge/cmo(src)
	new /obj/item/radio/headset/heads/cmo(src)
	new /obj/item/megaphone/command(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/healthanalyzer/advanced(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/autosurgeon/cmo(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/clothing/neck/petcollar(src)
	new /obj/item/pet_carrier(src)
	new /obj/item/wallframe/defib_mount(src)
	new /obj/item/circuitboard/machine/techfab/department/medical(src)
	new /obj/item/storage/photo_album/CMO(src)
	new /obj/item/clipboard/yog/paperwork/cmo(src)
	new /obj/item/storage/backpack/duffelbag/med/chief/clothing(src)


/obj/structure/closet/secure_closet/paramedic
	name = "paramedical closet"
	desc = "It's a secure storage unit for paramedical supplies."
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "paramed"
	req_access = list(ACCESS_PARAMEDIC)

/obj/structure/closet/secure_closet/paramedic/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel/med(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
		if ("green")
			new /obj/item/clothing/under/rank/medical/green(src)
		if ("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
	switch(pick("blue", "green", "purple"))
		if ("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
		if ("green")
			new /obj/item/clothing/under/rank/medical/green(src)
		if ("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt(src)
	new /obj/item/clothing/head/soft/emt(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt/green(src)
	new /obj/item/clothing/head/soft/emt/green (src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)

/obj/structure/closet/secure_closet/mmedical
	name = "mining medic's locker"
	req_access = list(ACCESS_MEDICAL)
	icon = 'yogstation/icons/obj/closet.dmi'
	icon_state = "medic"

/obj/structure/closet/secure_closet/mmedical/PopulateContents()
	..()
	new /obj/item/reagent_containers/hypospray/mixi(src)
	new /obj/item/reagent_containers/hypospray/derm(src)
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel/med(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/clothing/suit/toggle/labcoat/emt/explorer(src)
	new /obj/item/clothing/under/yogs/rank/miner/medic(src)
	new /obj/item/clothing/shoes/sneakers/white(src)
	new /obj/item/cartridge/medical(src)
	new /obj/item/radio/headset/headset_cargo(src)
	new /obj/item/storage/firstaid/toxin(src)
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/pickaxe(src)
	new /obj/item/twohanded/binoculars(src)
	new /obj/item/clothing/ears/earmuffs(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/sensor_device(src)
	new /obj/item/storage/box/bodybags(src)
	new /obj/item/extinguisher/mini(src)
	var/obj/item/key/K = new(src)
	K.name = "ATV key"
	K.desc = "It's a small grey key. Don't let those goddamn ashwalkers get it."

/obj/structure/closet/secure_closet/animal
	name = "animal control"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/animal/PopulateContents()
	..()
	new /obj/item/assembly/signaler(src)
	for(var/i in 1 to 3)
		new /obj/item/electropack(src)

/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	req_access = list(ACCESS_CHEMISTRY)
	icon_door = "chemical"

/obj/structure/closet/secure_closet/chemical/PopulateContents()
	..()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/medsprays(src)
	new /obj/item/storage/box/medsprays(src)
	new /obj/item/reagent_containers/glass/bottle/facid(src)
	new /obj/item/reagent_containers/glass/bottle/capsaicin(src)
	new /obj/item/reagent_containers/glass/bottle/mutagen(src)

/obj/structure/closet/secure_closet/chemical/heisenberg //contains one of each beaker, syringe etc.
	name = "advanced chemical closet"

/obj/structure/closet/secure_closet/chemical/heisenberg/PopulateContents()
	..()
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/storage/box/syringes/variety(src)
	new /obj/item/storage/box/beakers/variety(src)
	new /obj/item/clothing/glasses/science(src)
