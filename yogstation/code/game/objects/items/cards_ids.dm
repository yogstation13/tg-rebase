/obj/item/card
	icon = 'yogstation/icons/obj/card.dmi'
	var/has_fluff

/obj/item/card/id/update_label(newname, newjob)
	..()
	ID_fluff()

/obj/item/card/id/proc/ID_fluff()
	var/job = assignment
	var/list/idfluff = list(
	"Assistant" = list("civillian","green"),
	"Captain" = list("captain","gold"),
	"Head of Personnel" = list("civillian","silver"),
	"Head of Security" = list("security","silver"),
	"Chief Engineer" = list("engineering","silver"),
	"Research Director" = list("science","silver"),
	"Chief Medical Officer" = list("medical","silver"),
	"Station Engineer" = list("engineering","yellow"),
	"Atmospheric Technician" = list("engineering","white"),
	"Signal Technician" = list("engineering","green"),
	"Medical Doctor" = list("medical","blue"),
	"Geneticist" = list("medical","purple"),
	"Virologist" = list("medical","green"),
	"Chemist" = list("medical","orange"),
	"Paramedic" = list("medical","white"),
	"Psychiatrist" = list("medical","brown"),
	"Scientist" = list("science","purple"),
	"Roboticist" = list("science","black"),
	"Quartermaster" = list("cargo","silver"),
	"Cargo Technician" = list("cargo","brown"),
	"Shaft Miner" = list("cargo","black"),
	"Mining Medic" = list("cargo","blue"),
	"Bartender" = list("civillian","black"),
	"Botanist" = list("civillian","blue"),
	"Cook" = list("civillian","white"),
	"Janitor" = list("civillian","purple"),
	"Curator" = list("civillian","purple"),
	"Chaplain" = list("civillian","black"),
	"Clown" = list("clown","rainbow"),
	"Mime" = list("mime","white"),
	"Clerk" = list("civillian","blue"),
	"Tourist" = list("civillian","yellow"),
	"Warden" = list("security","black"),
	"Security Officer" = list("security","red"),
	"Detective" = list("security","brown"),
	"Lawyer" = list("security","purple")
	)
	if(job in idfluff)
		has_fluff = TRUE
	else
		if(has_fluff)
			return
		else
			job = "Assistant" //Loads up the basic green ID
	overlays.Cut()
	overlays += idfluff[job][1]
	overlays += idfluff[job][2]

/obj/item/card/id/silver
	icon_state = "id_silver"

/obj/item/card/id/gold
	icon_state = "id_gold"

/obj/item/card/id/captains_spare
	icon_state = "id_gold"

/obj/item/card/emag/limited
	name = "flimsy cryptographic sequencer"
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks pretty fragile."
	var/uses = 2

/obj/item/card/emag/limited/afterattack(atom/target, mob/user, proximity)
	if(!uses)
		to_chat(user, "<span class='warning'>The card is broken.</span>")
		log_combat(user, target, "failed to emag (no more uses)")
		return

	uses--
	if(!uses) // If this is our final use
		playsound(src.loc, "sparks", 50, 1)
		to_chat(user, "<span class='warning'>The card breaks!</span>")
		desc = "It's a card with a magnetic strip attached to some circuitry. It's broken."
	else if(uses == 1) // If we got a spare use left after this one
		to_chat(user, "<span class='notice'>The card starts to fall apart.</span>")
		desc = "It's a card with a magnetic strip attached to some circuitry. It's barely held together."
	return ..()

/obj/item/card/emag/emag_act(mob/user)
	var/otherEmag = user.get_active_held_item()
	if(!otherEmag)
		return
	to_chat(user, "<span class='notice'>The cyptographic sequencers attempt to override each other before destroying themselves.</span>")
	playsound(src.loc, "sparks", 50, 1)
	qdel(otherEmag)
	qdel(src)

/obj/item/card/id/gasclerk
	name = "Clerk"
	desc = "A employee ID used to access areas around the gastation."
	access = list(ACCESS_MANUFACTURING)

/obj/item/card/id/gasclerk/New()
	..()
	registered_account = new("Clerk", FALSE)