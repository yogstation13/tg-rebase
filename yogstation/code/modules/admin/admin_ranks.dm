// Kn0ss0s: This proc allows your to use a database for admin ranks, whilst immediately providing a functioning actual fallback in the case of failure
/proc/refresh_admin_files()
	// Generate the Admins and Admins Ranks config files
	if(SSdbcore.IsConnected())
		var/datum/DBQuery/query_ranks = SSdbcore.NewQuery("SELECT `name`, `byond`, `rank_group` FROM `web_groups` ORDER BY `web_groups`.`rank_group` ASC, `web_groups`.`name` DESC")
		if(query_ranks.Execute())
			fdel("config/admin_ranks.txt")
			var/ranksFile = file("config/admin_ranks.txt")
			WRITE_FILE(ranksFile, "##############################################################################################################\n# ADMIN RANK DEFINES                                                                                         #\n# The format of this is very simple. Rank name goes first.                                                   #\n# Rank is CASE-SENSITIVE, all punctuation save for '-', '_' and '@' will be stripped so spaces don't matter. #\n# You can then define permissions for each rank by adding a '=' followed by keywords                         #\n# These keywords represent groups of verbs and abilities.                                                    #\n# keywords are preceded by either a '+' or a '-', + adds permissions, - takes them away.                     #\n# +@ (or +prev) is a special shorthand which adds all the rights of the rank above it.                       #\n# You can also specify verbs like so +/client/proc/some_added_verb or -/client/proc/some_restricted_verb     #\n# Ranks with no keywords will just be given the most basic verbs and abilities                ~Carn          #\n##############################################################################################################\n# PLEASE NOTE: depending on config options, some abilities will be unavailable regardless if you have permission to use them!\n\n# KEYWORDS:\n# +ADMIN = general admin tools, verbs etc\n# +FUN = events, other event-orientated actions. Access to the fun secrets in the secrets panel.\n# +BAN = the ability to ban, jobban and fullban\n# +STEALTH = the ability to stealthmin (make yourself appear with a fake name to everyone but other admins\n# +POSSESS = the ability to possess objects\n# +REJUV (or +REJUVINATE) = the ability to heal, respawn, modify damage and use godmode\n# +BUILD (or +BUILDMODE) = the ability to use buildmode\n# +SERVER = higher-risk admin verbs and abilities, such as those which affect the server configuration.\n# +DEBUG = debug tools used for diagnosing and fixing problems. It's useful to give this to coders so they can investigate problems on a live server.\n# +VAREDIT = everyone may view viewvars/debugvars/whatever you call it. This keyword allows you to actually EDIT those variables.\n# +RIGHTS (or +PERMISSIONS) = allows you to promote and/or demote people.\n# +SOUND (or +SOUNDS) = allows you to upload and play sounds\n# +SPAWN (or +CREATE) = mob transformations, spawning of most atoms including mobs (high-risk atoms, e.g. blackholes, will require the +FUN flag too)\n# +EVERYTHING (or +HOST or +ALL) = Simply gives you everything without having to type every flag\n\n# DO NOT EDIT THIS FILE DIRECTLY\n# IT IS AUTOMATICALLY GENERATED FROM THE SERVER DATABASE\n")

			var/lastGroup = 1
			// Write out each rank to the rank file
			while(query_ranks.NextRow())
				var/rank_name = query_ranks.item[1]
				var/rank_byond = query_ranks.item[2]
				var/rank_group = text2num(query_ranks.item[3])
				if(lastGroup != rank_group)
					lastGroup = rank_group
					WRITE_FILE(ranksFile, " ")
				WRITE_FILE(ranksFile, "[rank_name]\t=\t[rank_byond]")

		qdel(query_ranks)

		var/datum/DBQuery/query_admin = SSdbcore.NewQuery("SELECT `web_admins`.`username` AS admin, `web_groups`.`name` AS rank, `web_groups`.`rank_group` AS rank_group FROM `web_admins`, `web_groups` WHERE `web_admins`.`rank` = `web_groups`.`rankid` ORDER BY `web_groups`.`rank_group` ASC, rank DESC")
		if(query_admin.Execute())
			fdel("config/admins.txt")
			var/adminsFile = file("config/admins.txt")
			WRITE_FILE(adminsFile, "###############################################################################################\n# Basically, ckey goes first. Rank goes after the '='                                         #\n# Case is not important for ckey.                                                             #\n# Case IS important for the rank.                                                             #\n# All punctuation (spaces etc) EXCEPT '-', '_' and '@' will be stripped from rank names.      #\n# Ranks can be anything defined in admin_ranks.txt                                            #\n# NOTE: if the rank-name cannot be found in admin_ranks.txt, they will not be adminned! ~Carn #\n# NOTE: syntax was changed to allow hyphenation of ranknames, since spaces are stripped.      #\n###############################################################################################\n\n# DO NOT EDIT THIS FILE DIRECTLY\n# IT IS AUTOMATICALLY GENERATED FROM THE SERVER DATABASE\n")

			var/lastGroup = 1
			// Write out each admin to the admins file
			while(query_admin.NextRow())
				var/name = query_admin.item[1]
				var/rank = query_admin.item[2]
				var/rank_group = text2num(query_admin.item[3])
				if(lastGroup != rank_group)
					lastGroup = rank_group
					WRITE_FILE(adminsFile, " ")
				WRITE_FILE(adminsFile, "[name]\t=\t[rank]")

		qdel(query_admin)
