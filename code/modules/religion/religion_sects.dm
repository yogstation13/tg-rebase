  /*
  Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.

  Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  */
/datum/religion_sect
	var/name = "Religious Sect Base Type" // Name of the religious sect
	var/desc = "Oh My! What Do We Have Here?!!?!?!?" // Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/convert_opener // Opening message when someone gets converted
	var/alignment = ALIGNMENT_GOOD // holder for alignments.
	var/starter = TRUE // Does this require something before being available as an option?
	var/favor = 0 // The Sect's 'Mana'
	var/max_favor = 1000 // The max amount of favor the sect can have
	var/default_item_favor = 5 // The default value for an item that can be sacrificed
	var/list/desired_items // Turns into 'desired_items_typecache', lists the types that can be sacrificed barring optional features in can_sacrifice()
	var/list/desired_items_typecache // Autopopulated by `desired_items`
	var/list/rites_list // Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/altar_icon // Changes the Altar of Gods icon
	var/altar_icon_state // Changes the Altar of Gods icon_state
	var/list/active_rites // Currently Active (non-deleted) rites

/datum/religion_sect/New()
	. = ..()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	if(rites_list)
		var/listylist = generate_rites_list()
		rites_list = listylist
	on_select()

///Generates a list of rites with 'name' = 'type'
/datum/religion_sect/proc/generate_rites_list()
	. = list()
	for(var/i in rites_list)
		if(!ispath(i))
			continue
		var/datum/religion_rites/RI = i
		var/name_entry = "[initial(RI.name)]"
		if(initial(RI.desc))
			name_entry += " - [initial(RI.desc)]"
		if(initial(RI.favor_cost))
			name_entry += " ([initial(RI.favor_cost)] favor)"

		. += list("[name_entry]" = i)

/// Activates once selected
/datum/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	if(convert_opener)
		to_chat(L, "<span class='notice'>[convert_opener]</span")

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering. Returning TRUE will stop the attackby sequence and proceed to on_sacrifice.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/L)
	. = TRUE
	if(!is_type_in_typecache(I,desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. This proc has NO bearing on the attackby sequence of other objects when used in conjunction with the religious_tool component.
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor,L)

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	var/old_favor = favor //store the current favor
	favor = clamp(favor+amount, 0, max_favor) //ensure we arent going overboard
	return favor - old_favor //return the difference 

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = clamp(amount, 0, max_favor)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, atom/religious_tool)

/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
			return TRUE

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [GLOB.deity]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return FALSE

/datum/religion_sect/puritanism
	name = "Puritanism (Default)"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"

/datum/religion_sect/technophile
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte.<br>Bibles now recharge cyborgs and heal robotic limbs if targeted, but they do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell)
	rites_list = list(/datum/religion_rites/synthconversion, /datum/religion_rites/machine_blessing)
	altar_icon_state = "convertaltar-blue"

/datum/religion_sect/technophile/sect_bless(mob/living/L, mob/living/user)
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		var/charge_amt = 50
		if(L.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amt *= 2
		R.cell?.charge += charge_amt
		R.visible_message("<span class='notice'>[user] charges [R] with the power of [GLOB.deity]!</span>")
		to_chat(R, "<span class='boldnotice'>You are charged by the power of [GLOB.deity]!</span>")
		SEND_SIGNAL(R, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/ethereal/eth_stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(3)
		did_we_charge = TRUE
	if(ispreternis(H))
		var/datum/species/preternis/preternis = H.dna.species
		preternis.charge = clamp(preternis.charge + 3, PRETERNIS_LEVEL_NONE, PRETERNIS_LEVEL_FULL)
		did_we_charge = TRUE
	
	//if we're not targetting a robot part we stop early
	var/obj/item/bodypart/BP = H.get_bodypart(user.zone_selected)
	if(BP.status != BODYPART_ROBOTIC)
		if(!did_we_charge)
			to_chat(user, "<span class='warning'>[GLOB.deity] scoffs at the idea of healing such fleshy matter!</span>")
		else
			H.visible_message("<span class='notice'>[user] charges [H] with the power of [GLOB.deity]!</span>")
			to_chat(H, "<span class='boldnotice'>You feel charged by the power of [GLOB.deity]!</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
			playsound(user, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(BP.heal_damage(5,5,null,BODYPART_ROBOTIC))
		H.update_damage_overlays()

	H.visible_message("<span class='notice'>[user] [did_we_charge ? "repairs" : "repairs and charges"] [H] with the power of [GLOB.deity]!</span>")
	to_chat(H, "<span class='boldnotice'>The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!</span>")
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/technophile/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/stock_parts/cell/the_cell = I
	if(!istype(the_cell)) //how...
		return
	if(the_cell.charge < 3000)
		to_chat(L,"<span class='notice'>[GLOB.deity] does not accept pity amounts of power.</span>")
		return
	adjust_favor(round(the_cell.charge/1500), L)
	to_chat(L, "<span class='notice'>You offer [the_cell]'s power to [GLOB.deity], pleasing them.</span>")
	qdel(I)
	return TRUE
/*
 * A religious sect based around giving money for favor which can be used to get a cool suit and become a golem. 
 */
/datum/religion_sect/capitalists
	name = "The Cult of St. Credit"
	desc = "A cult oriented around money."
	convert_opener = "If you always donate your money and dont violate the NAP, you too might one day achieve the top 0.0000001%!<br>(Only Holochips accepted, for more questions reach out to our legal team!)"
	alignment = ALIGNMENT_EVIL
	desired_items = list(/obj/item/holochip)
	max_favor = 100000
	rites_list = list(/datum/religion_rites/toppercent,
					  /datum/religion_rites/looks)

/datum/religion_sect/capitalists/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	var/obj/item/card/id/id_card = H.get_idcard()
	var/obj/item/card/id/id_cardu = user.get_idcard()
	var/money_check = 500

	if(!id_card.registered_account.account_balance > money_check)
		user.visible_message("<span class='notice'>[H] is too poor to recieve [GLOB.deity]'s blessing!</span>")
	else
		var/heal_amt = 10
		var/list/hurt_limbs = H.get_damaged_bodyparts(TRUE, TRUE, null, BODYPART_ORGANIC)

		if(hurt_limbs.len)
			for(var/X in hurt_limbs)
				var/obj/item/bodypart/affecting = X
				if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
					H.update_damage_overlays()
		id_card.registered_account.adjust_money(-10)
		id_cardu.registered_account.adjust_money(10)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/misc/capitialism.ogg', 25, TRUE, -1)
		H.visible_message("<span class='notice'>[user] blesses [H] with the power of capitalism!</span>")
		to_chat(H, "<span class='boldnotice'>You feel spiritually enriched, and donate to the cause of [GLOB.deity]!</span>")
		H.visible_message("<span class='notice'>[H] donated 10 credits!</span>")

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [GLOB.deity]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/capitalists/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/holochip/money = I
	if(!istype(money))
		return
	adjust_favor(round(money.credits), L)
	to_chat(L, "<span class='notice'>As you insert the chip into the small slit in the altar, you feel [GLOB.deity] looking at you with gratitude. Seems being a God isnt that easy on your wallet.</span>")
	qdel(I)
	return TRUE

/**** Ever-Burning Candle sect ****/

/datum/religion_sect/candle_sect
	name = "Ever-Burning Candle"
	desc = "A sect dedicated to candles."
	convert_opener = "May you be the wax to keep the Ever-Burning Candle burning, acolyte.<br>Sacrificing burning corpses with a lot of burn damage and candles grants you favor."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/candle)
	rites_list = list(/datum/religion_rites/fireproof, /datum/religion_rites/burning_sacrifice, /datum/religion_rites/infinite_candle)
	altar_icon_state = "convertaltar-red"

//candle sect bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/candle_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/candle_sect/on_sacrifice(obj/item/candle/offering, mob/living/user)
	if(!istype(offering))
		return
	if(!offering.lit)
		to_chat(user, "<span class='notice'>The candle needs to be lit to be offered!</span>")
		return
	to_chat(user, "<span class='notice'>Another candle for [GLOB.deity]'s collection</span>")
	adjust_favor(20, user) //it's not a lot but hey there's a pacifist favor option at least
	qdel(offering)
	return TRUE

/**** Children of the Kudzu sect, will allow you to sacrifice plants to become a special wood golem. ****/

/datum/religion_sect/plant
	name = "Children of the Kudzu"
	desc = "A sect dedicated to plants."
	convert_opener = "The kudzu welcomes you with open arms, acolyte.<br>Sacrificing plants will give you favor based on their potency and allow you to ascend."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/reagent_containers/food/snacks/grown)
	rites_list = list(/datum/religion_rites/plantconversion)
	altar_icon_state = "convertaltar-green"

//plant sect bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/plant/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/plant/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/reagent_containers/food/snacks/grown/offering = I
	var/favortogive = 1
	if(!istype(offering))
		return
	favortogive += I.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 2
	adjust_favor(round(favortogive), L) //amount of favor depends on how much nutriment the plant carries
	to_chat(L, "<span class='notice'>[GLOB.deity] happily accepts your offering, and brings the crop to a new home.</span>")
	qdel(I)
	return TRUE
