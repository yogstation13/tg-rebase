/obj/item/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	var/copied = 0
	var/iscopy = 0


/obj/item/paper/carbon/update_icon()
	if(iscopy)
		if(text)
			icon_state = "cpaper_words"
			return
		icon_state = "cpaper"
	else if (copied)
		if(text)
			icon_state = "paper_words"
			return
		icon_state = "paper"
	else
		if(text)
			icon_state = "paper_stack_words"
			return
		icon_state = "paper_stack"

/obj/item/paper/carbon/verb/removecopy()
	set name = "Remove carbon-copy"
	set category = "Object"
	set src in usr

	if (copied == 0)
		var/obj/item/paper/carbon/copy = src
		var/obj/item/paper/carbon/c = new /obj/item/paper/carbon (loc)
		var/copyinfo = copy.info
		copyinfo = clearcolor(copyinfo)
		c.info += copyinfo + "</font>"
		//Now for copying the new $written var
		for(var/L in copy.written)
			if(istype(L,/datum/langtext))
				var/datum/langtext/oldL = L
				var/datum/langtext/newL = new(clearcolor(oldL.text),oldL.lang)
				c.written += newL
			else
				c.written += L
		c.name = copy.name
		c.fields = copy.fields
		c.update_icon()
		c.stamps = copy.stamps
		if(copy.stamped)
			c.stamped = copy.stamped.Copy()
		c.copy_overlays(copy, TRUE)
	else
		usr << "There are no more carbon copies attached to this paper!"

/obj/item/paper/carbon/proc/clearcolor(text) // Breaks all font color spans in the HTML text.
	return replacetext(replacetext(text, "<font face=\"[CRAYON_FONT]\" color=", "<font face=\"[CRAYON_FONT]\" nocolor="), "<font face=\"[PEN_FONT]\" color=", "<font face=\"[PEN_FONT]\" nocolor=") //This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
