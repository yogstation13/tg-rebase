/mob/living/simple_animal/drone
	ignores_capitalism = TRUE // Yogs -- Lets drones buy a damned smoke for christ's sake
	var/pacifism = TRUE // Marks whether pacifism should be enabled for this drone type

/mob/living/simple_animal/drone/syndrone
	pacifism = FALSE
	
/mob/living/simple_animal/drone/cogscarab
	pacifism = FALSE

/mob/living/simple_animal/drone/Initialize()
	.=..()
	if(pacifism)
		add_trait(TRAIT_PACIFISM, JOB_TRAIT)
		add_trait(TRAIT_NOGUNS, JOB_TRAIT) //love drones t. Altoids <3