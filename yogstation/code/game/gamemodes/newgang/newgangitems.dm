/*
	Gang stashbox
	Money can be inserted into it for gang to use
	but money cannot be taken out directly
	To widthdraw money, one has to use the gangtool
	Destroying the stashbox will drop a significant
	portion of the money inside, but not all of it
*/
/obj/item/stashbox
	name = "stashbox"
	desc = "a secure stash box criminals use to hide their money"
	icon = 'icons/obj/module.dmi'
	icon_state = "depositbox"
	w_class = WEIGHT_CLASS_NORMAL
	level = 1 // Makes the item hide under floor tiles
	var/datum/bank_account/registered_account

/obj/item/stashbox/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holochip))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/stack/spacecash))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/coin))
		insert_money(W, user, TRUE)
		return
	else
		return ..()

/obj/item/stashbox/proc/insert_money(obj/item/I, mob/user, physical_currency)
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		return

	if(!registered_account) // Shouldn't happen but lets leave it in just in case
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit [I] into!</span>")
		return

	registered_account.adjust_money(cash_money)
	if(physical_currency)
		to_chat(user, "<span class='notice'>You stuff [I] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account.</span>")
	else
		to_chat(user, "<span class='notice'>You insert [I] into [src], adding [cash_money] credits to the linked account.</span>")

	to_chat(user, "<span class='notice'>The linked account now reports a balance of $[registered_account.account_balance].</span>")
	qdel(I)

/obj/item/stashbox/Destroy()
	var/cached_funds = registered_account.account_balance // Funds before we reduce
	var/refund_penalty = pick(1.1,1.2,1.3,1.4,1.5)// Ammount to reduce by
	var/refund = (cached_funds / (refund_penalty))// Ammount to refund after it has been reduced
	registered_account.adjust_money(-cached_funds)
// Find someone who can actually do basic math to write a function that will randomize then reduce the amount by. something like 10-20%
	var/obj/item/holochip/holochip = new (src.drop_location(), refund)
	to_chat(loc, "a credit chip falls out of [src]")

/*
	Smugglers Beacon
	Floor teleport structure
	When alt-clicked, will sell off the items ontop of it
	Reusing piratepad code
*/
/obj/machinery/smugglerbeacon
	name = "smugglers beacon"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	var/idle_state = "lpad-idle-o"
	var/warmup_state = "lpad-idle"
	var/sending_state = "lpad-beam"
	var/warmup_time = 100
	var/sending = FALSE
	var/points = 0
	var/sending_timer
	var/datum/bank_account/registered_account

/obj/machinery/smugglerbeacon/AltClick(mob/user)
	start_sending()
	
/obj/machinery/smugglerbeacon/proc/start_sending()
	if(sending)
		return
	sending = TRUE

	src.visible_message("<span class='notice'>[src] starts charging up.</span>")
	src.icon_state = src.warmup_state
	sending_timer = addtimer(CALLBACK(src,.proc/send),warmup_time, TIMER_STOPPABLE)

/obj/machinery/smugglerbeacon/proc/stop_sending()
	if(!sending)
		return
	sending = FALSE
	src.icon_state = src.idle_state
	deltimer(sending_timer)
	registered_account.adjust_money(points)
	reset_points()

/obj/machinery/smugglerbeacon/proc/reset_points()
	points = 0

/obj/machinery/smugglerbeacon/proc/send()
	if(!sending)
		return

	var/datum/export_report/ex = new

	for(var/atom/movable/AM in get_turf(src))
		if(AM == src)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)

	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		value += ex.total_value[E]

	points += value

	src.visible_message("<span class='notice'>[src] activates!</span>")
	flick(src.sending_state,src)
	src.icon_state = src.idle_state
	stop_sending()