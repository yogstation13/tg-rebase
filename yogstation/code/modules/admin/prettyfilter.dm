GLOBAL_LIST_EMPTY(pretty_filter_items)
GLOBAL_LIST_EMPTY(minor_filter_items)
GLOBAL_VAR(lwordregex)

// Append pretty filter items from file to a list
/proc/setup_pretty_filter(path = "config/pretty_filter.txt")
	var/list/filter_lines = world.file2list(path)

	for(var/line in filter_lines)
		add_pretty_filter_line(line)

	filter_lines = world.file2list("config/minor_filter.txt")
	for(var/line in filter_lines)
		add_pretty_filter_line(line, TRUE)

// Add a filter pair
/proc/add_pretty_filter_line(line, minor)
	if(findtextEx(line,"#",1,2) || length(line) == 0)
		return

	//Split the line at every "="
	var/list/parts = splittext(line, "=")
	if(!parts.len)
		return FALSE

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return FALSE

	//replacement follows the first "="
	var/replacement = ""
	if(parts.len >= 2)
		var/index = 2
		for(index = 2; index <= parts.len; index++)
			replacement += parts[index]
			if(index < parts.len)
				replacement += "="

	if(!replacement)
		return FALSE
	if(minor)
		GLOB.minor_filter_items.Add(line)
	else if(replacement == "lizard")
		GLOB.lwordregex = pattern
	else
		GLOB.pretty_filter_items.Add(line)
	return TRUE

// List all filters that have been loaded
/client/proc/list_pretty_filters()
	set category = "Special Verbs"
	set name = "Pretty Filters - List"

	to_chat(usr, "<font size='3'><b>Pretty filters list</b></font>")
	for(var/line in GLOB.pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		to_chat(usr, "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>")
	to_chat(usr, "<font size='3'><b>End of list</b></font>")

//Filter out and replace unwanted words, prettify sentences
/proc/pretty_filter(text, list/filter = GLOB.pretty_filter_items)
	for(var/line in filter)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		var/regex/R = new(pattern, "ig")
		text = R.Replace(text, replacement)
	var/regex/R = new(GLOB.lwordregex,"ig")
	text = R.Replace(text,"BAN ME ADMINS!")
	return text

/proc/isnotpretty(var/text) // A simpler version of pretty_filter(), where all it returns is whether it had to replace something or not.
	//Useful for the "You fumble your words..." business.
	
	for(var/line in GLOB.pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/regex/R = new(pattern, "ig")
		if(R.Find(text)) //If found
			return TRUE // Yes, it isn't pretty.
	//Now, for the L-word
	var/regex/R = new(GLOB.lwordregex,"ig")
	if(R.Find(text))
		if(!usr || !isliving(usr))
			return TRUE
		var/list/passes = usr.GetAllContents(/obj/item/card/lword_pass)
		if(!passes.len)
			return TRUE
		to_chat(usr,"<span class='notice'>You expend an L-Word Pass!</span>")
		playsound(usr.loc, "sparks", 50, 1)
		message_admins("key_name[usr] just used an L-Word Pass to say: [text]")
		qdel(pick(passes))
		return FALSE
	
	return FALSE // No, it is pretty.

//Filter out and replace unwanted but not important words, like WTF or LOL
/proc/minor_filter(text)
	text = text + " " //necessary since some words like "lol" have words like lollard, which means we need to only trigger if there's a space after it, which won't happen at the end of the sentence
	return pretty_filter(text, GLOB.minor_filter_items)

