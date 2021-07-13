/mob/living/simple_animal/hostile/darkspawn_progenitor
	name = "cosmic progenitor"
	desc = "..."
	icon = 'yogstation/icons/mob/darkspawn_progenitor.dmi'
	icon_state = "darkspawn_progenitor"
	icon_living = "darkspawn_progenitor"
	health = INFINITY
	maxHealth = INFINITY
	attacktext = "rips apart"
	attack_sound = 'yogstation/sound/creatures/progenitor_attack.ogg'
	friendly = "stares down"
	speak_emote = list("roars")
	armour_penetration = 100
	melee_damage_lower = 40
	melee_damage_upper = 40
	move_to_delay = 10
	speed = 1
	pixel_x = -48
	pixel_y = -32
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 100
	light_range = 15
	light_color = "#21007F"
	weather_immunities = list("lava", "ash")
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER
	movement_type = FLYING
	var/time_to_next_roar = 0

/mob/living/simple_animal/hostile/darkspawn_progenitor/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_HOLY, "ohgodohfuck") //sorry no magic
	alpha = 0
	animate(src, alpha = 255, time = 10)
	var/obj/item/radio/headset/silicon/ai/radio = new(src) //so the progenitor can hear people's screams over radio
	radio.wires.cut(WIRE_TX) //but not talk over it

/mob/living/simple_animal/hostile/darkspawn_progenitor/AttackingTarget()
	if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/door_assembly))
		playsound(target, 'yogstation/sound/magic/pass_smash_door.ogg', 100, FALSE)
		obj_damage = 60
	. = ..()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Login()
	..()
	var/image/I = image(icon = 'yogstation/icons/mob/mob.dmi' , icon_state = "smol_progenitor", loc = src)
	I.override = 1
	I.pixel_x -= pixel_x
	I.pixel_y -= pixel_y
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smolgenitor", I)
	time_to_next_roar = world.time + 30 SECONDS

/mob/living/simple_animal/hostile/darkspawn_progenitor/Life()
	..()
	if(time_to_next_roar + 10 SECONDS <= world.time) //gives time to roar manually if you like want to do that
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/say(message, bubble_type,var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(time_to_next_roar <= world.time)
		roar()

/mob/living/simple_animal/hostile/darkspawn_progenitor/Process_Spacemove()
	return TRUE

/mob/living/simple_animal/hostile/darkspawn_progenitor/proc/roar()
	playsound(src, 'yogstation/sound/creatures/progenitor_roar.ogg', 100, TRUE)
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M, src) > 7)
			M.playsound_local(src, 'yogstation/sound/creatures/progenitor_distant.ogg', 75, FALSE, falloff = 5)
		else if(isliving(M))
			var/mob/living/L = M
			if(L != src) //OH GOD OH FUCK I'M SCARING MYSELF
				to_chat(M, "<span class='boldannounce'>You stand paralyzed in the shadow of the cold as it descends from on high.</span>")
				L.Stun(20)
	time_to_next_roar = world.time + 30 SECONDS

/obj/effect/proc_holder/spell/targeted/progenitor_curse
	name = "Viscerate Mind"
	desc = "Unleash a powerful psionic barrage into the mind of the target."
	charge_max = 50
	clothes_req = FALSE
	action_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	action_icon_state = "veil_mind"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/aimed/update_icon()
	return

/obj/effect/proc_holder/spell/targeted/progenitor_curse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>You can't reach anyone's minds.</span>")
		return
	var/mob/living/target = targets[1]
	var/mob/living/M = target
	var/zoinks = pick(0.1, 0.5, 1)//like, this isn't even my final form!
	usr.visible_message("<span class='warning'>[usr]'s sigils flare as it glances at [M]!</span>", \
						"<span class='velvet'>You direct [zoinks]% of your psionic power into [M]'s mind!.</span>")
	M.apply_status_effect(STATUS_EFFECT_PROGENITORCURSE)

/mob/living/simple_animal/hostile/darkspawn_progenitor/narsie_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ratvar_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/singularity_act()
	return

/mob/living/simple_animal/hostile/darkspawn_progenitor/ex_act() //sorry no bombs
	return
