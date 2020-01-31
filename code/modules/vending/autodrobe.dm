/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access = list(ACCESS_THEATRE)
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use AutoDrobe!"
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1,
					/obj/item/clothing/head/chicken = 1,
					/obj/item/clothing/under/rank/blueclown = 1,
					/obj/item/clothing/under/rank/greenclown = 1,
					/obj/item/clothing/under/rank/yellowclown = 1,
					/obj/item/clothing/under/rank/orangeclown = 1,
					/obj/item/clothing/under/rank/purpleclown = 1,
					/obj/item/clothing/under/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1,
					/obj/item/clothing/under/gimmick/rank/captain/suit = 1,
					/obj/item/clothing/under/gimmick/rank/captain/suit/skirt = 1,
					/obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/toggle/labcoat/mad = 1,
					/obj/item/clothing/shoes/jackboots = 10, //yogs added more jack boots
					/obj/item/clothing/under/schoolgirl = 1,
					/obj/item/clothing/under/schoolgirl/red = 1,
					/obj/item/clothing/under/schoolgirl/green = 1,
					/obj/item/clothing/under/schoolgirl/orange = 1,
					/obj/item/clothing/head/kitty = 1,
					/obj/item/clothing/under/skirt/black = 1,
					/obj/item/clothing/head/beret = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/suit_jacket = 1,
					/obj/item/clothing/head/that = 1,
					/obj/item/clothing/under/kilt = 1,
					/obj/item/clothing/head/beret/vintage = 1,
					/obj/item/clothing/head/beret/archaic = 1,
					/obj/item/clothing/glasses/monocle = 1, //yogs added a single space the horrors!
					/obj/item/clothing/head/bowler = 1,
					/obj/item/cane = 1,
					/obj/item/clothing/under/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
					/obj/item/clothing/head/plaguedoctorhat = 1,
					/obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/toggle/owlwings = 1,
					/obj/item/clothing/under/owl = 1,
					/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/suit/toggle/owlwings/griffinwings = 1,
					/obj/item/clothing/under/griffin = 1,
					/obj/item/clothing/shoes/griffin = 1,
					/obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/suit/apron = 1,
					/obj/item/clothing/under/waiter = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/under/pirate = 1,
					/obj/item/clothing/suit/pirate = 1,
					/obj/item/clothing/head/pirate = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/under/soviet = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,
					/obj/item/clothing/suit/chaplainsuit/holidaypriest = 1,
					/obj/item/clothing/suit/chaplainsuit/whiterobe = 1,
					/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
					/obj/item/clothing/under/sundress = 1,
					/obj/item/clothing/head/witchwig = 1,
					/obj/item/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,
					/obj/item/clothing/head/wizard/fake = 1,
					/obj/item/staff = 3,
					/obj/item/clothing/mask/gas/sexyclown = 1,
					/obj/item/clothing/under/rank/clown/sexy = 1,
					/obj/item/clothing/mask/gas/sexymime = 1,
					/obj/item/clothing/under/sexymime = 1,
					/obj/item/clothing/under/rank/mime/skirt = 1,
					/obj/item/clothing/mask/rat/bat = 1,
					/obj/item/clothing/mask/rat/bee = 1,
					/obj/item/clothing/mask/rat/bear = 1,
					/obj/item/clothing/mask/rat/raven = 1,
					/obj/item/clothing/mask/rat/jackal = 1,
					/obj/item/clothing/mask/rat/fox = 1,
					/obj/item/clothing/mask/frog = 1,
					/obj/item/clothing/mask/rat/tribal = 1,
					/obj/item/clothing/mask/rat = 1,
					/obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/head/sombrero/green = 1,
					/obj/item/clothing/suit/poncho = 1,
					/obj/item/clothing/suit/poncho/green = 1,
					/obj/item/clothing/suit/poncho/red = 1,
					/obj/item/clothing/under/maid = 1,
					/obj/item/clothing/under/janimaid = 1,
					/obj/item/clothing/glasses/cold=1,
					/obj/item/clothing/glasses/heat=1,
					/obj/item/clothing/suit/whitedress = 1,
					/obj/item/clothing/under/jester = 1,
					/obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/villain = 1,
					/obj/item/clothing/shoes/singery = 1,
					/obj/item/clothing/under/singery = 1,
					/obj/item/clothing/shoes/singerb = 1,
					/obj/item/clothing/under/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,
					/obj/item/clothing/suit/hooded/ian_costume = 1,
					/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,
					/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/mask/joy = 1,
					/obj/item/clothing/head/cueball = 1,
					/obj/item/clothing/under/scratch = 1,
					/obj/item/clothing/under/sailor = 1,
        			/obj/item/clothing/ears/headphones = 2,
        			/obj/item/clothing/head/wig/random = 3, // yogs added a ,
        			/obj/item/clothing/under/yogs/ronaldmcdonald = 1, // yogs clothes for autodrobe start here
					/obj/item/clothing/mask/yogs/ronald = 1,
					/obj/item/clothing/mask/yogs/cluwne/happy_cluwne = 1,
					/obj/item/clothing/mask/yogs/bananamask = 1,
					/obj/item/storage/backpack/banana = 1,
					/obj/item/clothing/mask/yogs/gigglesmask = 1,
					/obj/item/storage/backpack/clownface = 1,
					/obj/item/clothing/mask/yogs/scaryclown = 1,
					/obj/item/clothing/under/yogs/scaryclown = 1,
					/obj/item/clothing/shoes/clown_shoes/scaryclown = 1,
					/obj/item/clothing/under/yogs/barber = 4,
					/obj/item/clothing/head/yogs/boater = 4,
					/obj/item/clothing/under/yogs/bluecoatuniform = 5,
					/obj/item/clothing/suit/yogs/bluecoatcoat = 5,
					/obj/item/clothing/head/yogs/tricornhat = 5,
					/obj/item/clothing/head/yogs/microwave = 1,
					/obj/item/clothing/head/yogs/drinking_hat = 1,
					/obj/item/clothing/suit/yogs/beaker = 1,
					/obj/item/clothing/suit/yogs/facebook = 1,
					/obj/item/clothing/suit/yogs/gothic = 1,
					/obj/item/clothing/under/yogs/zootsuit = 1,
					/obj/item/clothing/head/yogs/zoothat = 1,
					/obj/item/clothing/under/yogs/hamiltonuniform = 1,
					/obj/item/clothing/suit/yogs/hamiltoncoat = 1,
					/obj/item/clothing/suit/hooded/sandsuit = 1,
					/obj/item/clothing/under/yogs/thejester = 1,
					/obj/item/clothing/suit/yogs/thejestercoat = 1,
					/obj/item/clothing/under/yogs/trickster = 1,
					/obj/item/clothing/suit/yogs/trickstercoat = 1,
					/obj/item/clothing/head/yogs/trickster = 1,
					/obj/item/clothing/under/yogs/harveyflint = 1,
					/obj/item/clothing/under/yogs/penguinsuit = 1,
					/obj/item/clothing/head/yogs/penguin = 1,
					/obj/item/clothing/under/yogs/dresdenunder = 1,
					/obj/item/clothing/head/yogs/dresden = 1,
					/obj/item/clothing/under/yogs/doomsday = 1,
					/obj/item/clothing/under/yogs/lederhosen = 1,
					/obj/item/clothing/head/yogs/folkhat = 1,
					/obj/item/clothing/glasses/yogs/hypno = 1,
					/obj/item/clothing/under/yogs/soldieruniform = 4,
					/obj/item/clothing/suit/yogs/soldierwebbing = 4,
					/obj/item/clothing/head/yogs/soldierhelmet = 4,
					/obj/item/clothing/head/yogs/headpiece = 1,
					/obj/item/clothing/head/yogs/indianfether = 3,
					/obj/item/clothing/glasses/yogs/eyepatch = 2,
					/obj/item/clothing/under/yogs/infmob = 4,
					/obj/item/clothing/suit/yogs/infsuit = 4,
					/obj/item/clothing/head/yogs/infhat = 4,
					/obj/item/clothing/head/yogs/bike = 1,
					/obj/item/clothing/mask/yogs/freddy = 1,
					/obj/item/clothing/mask/yogs/bonnie = 1,
					/obj/item/clothing/mask/yogs/chica = 1,
					/obj/item/clothing/mask/yogs/foxy = 1,
					/obj/item/clothing/mask/yogs/fawkes = 1,
					/obj/item/clothing/mask/yogs/thejester = 1,
					/obj/item/clothing/mask/yogs/dallas = 1,
					/obj/item/clothing/mask/yogs/hoxton = 1,
					/obj/item/clothing/mask/yogs/robwolf = 1,
					/obj/item/clothing/mask/yogs/chains = 1,
					/obj/item/clothing/head/yogs/turban = 1,
					/obj/item/clothing/under/yogs/cowboy2 = 1,
					/obj/item/clothing/under/yogs/cowboy = 1,
					/obj/item/clothing/head/yogs/truecowboy = 1,
					/obj/item/clothing/head/yogs/truecowboy2 = 1,
					/obj/item/clothing/head/yogs/cowboy = 1,
					/obj/item/clothing/head/yogs/cowboy_sheriff = 1,
					/obj/item/clothing/under/yogs/familiartunic = 1,
					/obj/item/clothing/head/yogs/sith_hood = 1,
					/obj/item/clothing/neck/yogs/sith_cloak = 1,
					/obj/item/clothing/suit/yogs/armor/sith_suit = 1,
					/obj/item/clothing/shoes/clown_shoes/beeshoes = 1) //yogs clothes for autodrobe end here
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,
					  /obj/item/clothing/head/powdered_wig = 1,
					  /obj/item/toy/toyritualdagger = 1,
					  /obj/item/gun/magic/wand = 2,
					  /obj/item/clothing/glasses/sunglasses/garb = 2,
					  /obj/item/clothing/glasses/blindfold = 1,
					  /obj/item/clothing/mask/muzzle = 2)
	premium = list(/obj/item/clothing/suit/pirate/captain = 2,
				   /obj/item/clothing/head/pirate/captain = 2,
				   /obj/item/clothing/under/rank/rainbowclown = 1,
				   /obj/item/clothing/head/helmet/roman/fake = 1,
				   /obj/item/clothing/head/helmet/roman/legionnaire/fake = 1,
				   /obj/item/clothing/under/roman = 1,
				   /obj/item/clothing/shoes/roman = 1,
				   /obj/item/shield/riot/roman/fake = 1,
				   /obj/item/clothing/suit/chaplainsuit/clownpriest = 1,
				   /obj/item/clothing/head/clownmitre = 1,
		           /obj/item/skub = 1,
		           /obj/item/clothing/under/lampskirt = 1,
		           /obj/item/clothing/under/yogs/soviet_dress_uniform = 1, //yogs start
		           /obj/item/clothing/under/yogs/enclaveo = 1,
		           /obj/item/clothing/under/yogs/rycliesuni = 1,
		           /obj/item/clothing/head/yogs/toad = 1,
		           /obj/item/clothing/head/helmet/justice = 1,
		           /obj/item/clothing/mask/yogs/richard = 1) //yogs end
	refill_canister = /obj/item/vending_refill/autodrobe

/obj/machinery/vending/autodrobe/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SRV
/obj/machinery/vending/autodrobe/all_access
	desc = "A vending machine for costumes. This model appears to have no access restrictions."
	req_access = null

/obj/item/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"

/obj/machinery/vending/autodrobe/capdrobe
	name = "\improper CapDrobe"
	desc = "A vending machine for captain outfits."
	icon_state = "capdrobe"
	icon_deny = "capdrobe-deny"
	req_access = list(ACCESS_CAPTAIN)
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use the Captain's Autodrobe!"
	vend_reply = "Thank you for using the Captain's Autodrobe!"
	products = list(/obj/item/clothing/suit/hooded/wintercoat/captain = 1,
					/obj/item/storage/backpack/captain = 1,
					/obj/item/storage/backpack/satchel/cap = 1,
					/obj/item/storage/backpack/duffelbag/captain = 1,
					/obj/item/clothing/neck/cloak/cap = 1,
					/obj/item/clothing/shoes/sneakers/brown = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/rank/captain/skirt = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace = 1,
					/obj/item/clothing/head/caphat = 1,
					/obj/item/clothing/under/captainparade = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
					/obj/item/clothing/head/caphat/parade = 1,
					/obj/item/clothing/suit/captunic = 1,
					/obj/item/clothing/glasses/sunglasses/gar/supergar = 1,
					/obj/item/clothing/gloves/color/captain = 1,
					/obj/item/clothing/under/yogs/captainartillery = 1,
					/obj/item/clothing/under/yogs/casualcaptain = 1,
					/obj/item/clothing/under/yogs/whitecaptainsuit = 1,
					/obj/item/clothing/head/yogs/whitecaptaincap = 1,
					/obj/item/clothing/under/yogs/victoriouscaptainuniform = 1,
					/obj/item/clothing/head/beret/captain = 1)
	premium = list(/obj/item/clothing/head/crown/fancy = 1)

	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SRV
