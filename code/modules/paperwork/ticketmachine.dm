//Bureaucracy machine!
//Simply set this up in the hopline and you can serve people based on ticket numbers

/obj/machinery/ticket_machine
	name = "ticket machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "A marvel of bureaucratic engineering encased in an efficient plastic shell. Click to take a number!"
	density = TRUE
	var/screenNum = 0 //this is the the number of the person who is up
	var/currentNum= 0 //this is the the number someone who takes a ticket gets
	var/ticketNumMax = 999 //No more!
	var/cooldown = 10
	var/ready = TRUE
	var/linked = FALSE

/obj/machinery/ticket_machine/Initialize()
	. = ..()
	update_icon()

/obj/machinery/ticket_machine/proc/Debugg()
	update_icon()

/obj/machinery/ticket_machine/update_icon()
	var/Temp=screenNum //This whole thing breaks down a 3 digit number into 3 seperate digits, aka "69" becomes "0","6" and "9"
	var/Digit1 = round(Temp%10)//The remainder of any number/10 is always that number's rightmost digit
	var/Digit2 = round(((Temp-Digit1)*0.1)%10) //Same idea, but divided by ten, to find the middle digit
	var/Digit3 = round(((Temp-Digit1-Digit2*10)*0.01)%10)//Same as above. Despite the weird notation these will only ever output integers, don't worry.
	overlays=list()//this clears the overlays, so they don't start stacking on each other
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_first_[Digit1]")
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_second_[Digit2]")
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_third_[Digit3]")
	switch(currentNum) //Gives you an idea of how many tickets are left
		if(0 to 200)
			icon_state = "ticketmachine_100"
		if(201 to 800)
			icon_state = "ticketmachine_50"
		if(801 to 999)
			icon_state = "ticketmachine_0"

/obj/machinery/ticket_machine/proc/increment()
	playsound(src, 'sound/misc/announce_dig.ogg', 50, 0)
	say("Next customer, please!")
	screenNum ++ //Increment the one we're serving.
	if(currentNum > ticketNumMax)
		currentNum=0
		say("Error: Stack Overflow!")
	if(screenNum > ticketNumMax)
		screenNum=0
		say("Error: Stack Overflow!")
	if(currentNum < screenNum)
		currentNum = screenNum //this should only happen if the queue is all caught up and more numbers keep getting called
		screenNum -- //so the number wont go onto infinity. Numbers that haven't been taken yet won't show up on the screen yet either.
	update_icon() //Update our icon here rather than when they take a ticket to show the current ticket number being served

/obj/machinery/ticket_machine/proc/reset_cooldown()
	ready = TRUE

/obj/machinery/ticket_machine/attack_hand(mob/living/carbon/user)
	. = ..()
	if(!ready)
		return
	ready = FALSE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
	addtimer(CALLBACK(src, .proc/reset_cooldown), cooldown)//Small cooldown to prevent the clown from ripping out every ticket
	currentNum ++
	to_chat(user, "<span class='notice'>You take a ticket from [src], looks like you're customer #[currentNum]...</span>")
	var/obj/item/ticket_machine_ticket/theirticket = new /obj/item/ticket_machine_ticket(get_turf(src))
	theirticket.name = "Ticket #[currentNum]"
	theirticket.source=src
	theirticket.ticket_number=currentNum
	theirticket.update_icon()
	user.put_in_hands(theirticket)


/obj/machinery/ticket_machine/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(default_deconstruction_screwdriver(user, "ticketmachine_panel", "ticketmachine", O))
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(stat)
		return TRUE

	if(istype(O, /obj/item/ticket_machine_remote))
		if (!linked)
			var/obj/item/ticket_machine_remote/Z=O //typecasting!!
			Z.connection=src
			to_chat(user,"<span class='info'>You link the remote to the machine.</span>")
			linked = TRUE
			return TRUE
		else
			to_chat(user,"<span class='warning'>It's already linked to a remote!.</span>")

/obj/item/ticket_machine_ticket
	name = "Ticket"
	desc = "A ticket which shows your place in the queue."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticket"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/obj/machinery/ticket_machine/source
	var/ticket_number

/obj/item/ticket_machine_ticket/update_icon()
	var/Temp=ticket_number //this stuff is a repeat from the other update_icon
	var/Digit1 = round(Temp%10)
	var/Digit2 = round(((Temp-Digit1)*0.1)%10)
	var/Digit3 = round(((Temp-Digit1-Digit2*10)*0.01)%10)
	overlays=list()
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_first_[Digit1]")
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_second_[Digit2]")
	overlays+=image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_third_[Digit3]")

/obj/item/ticket_machine_remote
	name = "Ticket Machine Remote"
	desc = "A remote used to operate a ticket machine."
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small_simple"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 100
	var/obj/machinery/ticket_machine/connection=null
	var/cooldown = 20
	var/ready = TRUE

/obj/item/ticket_machine_remote/proc/reset_cooldown()
	ready = TRUE

/obj/item/ticket_machine_remote/attack_self(mob/user)
	if(!connection || !ready)
		return
	ready = FALSE
	addtimer(CALLBACK(src, .proc/reset_cooldown), cooldown)
	connection.increment()
