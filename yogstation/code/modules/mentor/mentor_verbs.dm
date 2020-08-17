GLOBAL_LIST_INIT(mentor_verbs, list(
	/client/proc/cmd_mentor_say,
	/client/proc/show_mentor_memo,
	/client/proc/show_mentor_tickets,
	/client/proc/cmd_mentor_pm_context
	))
GLOBAL_PROTECT(mentor_verbs)

/client/proc/add_mentor_verbs()
	if(mentor_datum)
		verbs += GLOB.mentor_verbs

/client/proc/remove_mentor_verbs()
	verbs -= GLOB.mentor_verbs

/client/proc/show_mentors()
	set name = "Show Mentors"
	set category = "Mentor"

	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(src, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return

	var/msg = "<b>Current Mentors:</b>\n"
	var/datum/DBQuery/query_load_mentors = SSdbcore.NewQuery("SELECT `ckey` FROM `[format_table_name("mentor")]`")
	if(!query_load_mentors.Execute())
		qdel(query_load_mentors)
		return

	while(query_load_mentors.NextRow())
		var/ckey = query_load_mentors.item[1]
		msg += "\t[ckey]"
	qdel(query_load_mentors)

	to_chat(src, msg, confidential=TRUE)

/client/verb/mentorwho()
	set name = "Mentorwho"
	set category = "Mentor"

	var/msg = "<b>Current Mentors:</b>\n"
	if(holder)
		for(var/client/C in GLOB.mentors)
			msg += "\t[C] is a mentor"

			if(C.holder && C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(isnewplayer(C.mob))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"
	else
		for(var/client/C in GLOB.mentors)
			if(C.holder && C.holder.fakekey)
				msg += "\t[C.holder.fakekey] is a mentor"
			else
				msg += "\t[C] is a mentor"
			msg += "\n"
		msg += "<span class='info'>Mentorhelps are also seen by admins. If no mentors are available in game adminhelp instead and an admin will see it and respond.</span>"
	to_chat(src, msg, confidential=TRUE)

/client/proc/show_tip()
	set category = "Mentor"
	set name = "Show Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!is_mentor())
		return

	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()


	message_admins("[key_name(usr)] sent a tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Tip")
