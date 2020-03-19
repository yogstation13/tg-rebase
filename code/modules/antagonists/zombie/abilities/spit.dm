/obj/effect/proc_holder/zombie/spit
	name = "Spit Neurotoxin"
	desc = "Spits neurotoxin at someone, paralyzing them for a short time."
	action_icon_state = "alien_neurotoxin_0"
	active = FALSE
	cooldown_time = 1.5 MINUTES


/obj/effect/proc_holder/zombie/spit/fire(mob/living/carbon/user)
	var/message
	if(active)
		message = "<span class='notice'>You close your neurotoxin reserves.</span>"
		remove_ranged_ability(message)
	else
		message = "<span class='notice'>You open your neurotoxin reserves. <B>Left-click to fire at a target!</B></span>"
		add_ranged_ability(user, message, TRUE)

/obj/effect/proc_holder/zombie/spit/update_icon()
	action.button_icon_state = "alien_neurotoxin_[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/zombie/spit/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(!isinfected(ranged_ability_user) || ranged_ability_user.stat)
		remove_ranged_ability()
		return

	var/mob/living/carbon/user = ranged_ability_user

	if(!ready)
		to_chat(user, "<span class='warning'>You cannot currently spit. You can spit again in [(cooldown_ends - world.time) / 10] seconds</span>")
		remove_ranged_ability()
		return

	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE

	user.visible_message("<span class='danger'>[user] spits neurotoxin!", "<span class='alertalien'>You spit neurotoxin.</span>")
	var/obj/item/projectile/bullet/neurotoxin/spitter/A = new /obj/item/projectile/bullet/neurotoxin/spitter(user.loc)
	A.preparePixelProjectile(target, user, params)
	A.fire()
	user.newtonian_move(get_dir(U, T))
	start_cooldown()

	return TRUE

/obj/item/projectile/bullet/neurotoxin/spitter
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = TOX
	paralyze = 50

/obj/item/projectile/bullet/neurotoxin/spitter/on_hit(atom/target, blocked = FALSE)
	if(isinfected(target))
		paralyze = 0
		nodamage = TRUE
	return ..()
