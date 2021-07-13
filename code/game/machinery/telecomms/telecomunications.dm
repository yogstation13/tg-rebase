
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

GLOBAL_LIST_EMPTY(telecomms_list)

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	critical_machine = TRUE
	var/list/links = list() // list of machines this machine is linked to
	var/traffic = 0 // value increases as traffic increases
	var/netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
	var/net_efective = 100 //yogs percentage of netspeed aplied
	var/list/autolinkers = list() // list of text/number values to link with
	var/id = "NULL" // identification string
	var/network = "NULL" // the network of the machinery

	var/list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

	var/on = TRUE
	var/toggled = TRUE 	// Is it toggled on
	var/long_range_link = FALSE  // Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/hide = FALSE  // Is it a hidden machine?

	var/generates_heat = TRUE 	//yogs turn off tcomms generating heat
	var/heatoutput = 2500		//yogs modify power output per trafic removed(usual heat capacity of the air in server room is 1600J/K)

	var/on_icon = "" // used for special cases broadcaster/reciever


/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending

	if(!on)
		return

	if(filter && !ispath(filter)) // Yogs -- for debugging telecomms later when I soop up NTSL some more
		CRASH("relay_information() was given a path filter that wasn't actually a path!")
	var/send_count = 0

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	// Loop through all linked machines and send the signal or copy.
	for(var/m_typeless in links) // Yogs -- God bless typeless for-loops
		var/obj/machinery/telecomms/machine = m_typeless
		if(filter && !istype(machine, filter) )
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(z != machine.loc.z && !long_range_link && !machine.long_range_link)
			continue

		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig)
			machine.receive_information(signal.copy(), src)
		else
			machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// receive information from linked machinery

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return TRUE if found, FALSE if not found
	return signal && (!freq_listening.len || (signal.frequency in freq_listening))

/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	GLOB.telecomms_list += src
	if(mapload && autolinkers.len)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/LateInitialize()
	..()
	for(var/obj/machinery/telecomms/T in (long_range_link ? GLOB.telecomms_list : urange(20, src, 1)))
		add_link(T)

/obj/machinery/telecomms/Destroy()
	GLOB.telecomms_list -= src
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		comm.links -= src
	links = list()
	return ..()

// Used in auto linking
/obj/machinery/telecomms/proc/add_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z == T_position.z) || (long_range_link && T.long_range_link))
		if(src != T)
			for(var/x in autolinkers)
				if(x in T.autolinkers)
					links |= T
					T.links |= src


/obj/machinery/telecomms/update_icon()
	cut_overlays()
	if(on)
		var/mutable_appearance/on_overlay
		if(on_icon)
			on_overlay = mutable_appearance(icon, on_icon)
		else
			on_overlay = mutable_appearance(icon, "[initial(icon_state)]_on")
		add_overlay(on_overlay)
	if(panel_open)
		icon_state = "[initial(icon_state)]_o"
	else
		icon_state = initial(icon_state)

/obj/machinery/telecomms/proc/update_power()

	if(toggled)
		if(stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE


/obj/machinery/telecomms/proc/update_speed()
	if(!on)
		return
	var/turf/T = get_turf(src) //yogs
	var/speedloss = 0
	var/datum/gas_mixture/env = T.return_air()
	var/temperature = env.return_temperature()
	if(temperature <= 150)				// 150K optimal operating parameters
		net_efective = 100
	else
		if(temperature >= 1150)		// at 1000K above 150K the efectivity becomes 0
			net_efective = 0
			speedloss = netspeed
		else
			var/ratio = 1000/netspeed			// temp per one unit of speedloss
			speedloss = round((temperature - 150)/ratio)	// exact speedloss
			net_efective = 100 - speedloss/netspeed		// percantage speedloss ui use only

	if(traffic > 0)
		var/deltaT = netspeed - speedloss  //yogs start
		if (traffic < deltaT)
			deltaT = traffic
			traffic = 0
		else
			traffic -= deltaT
		if(generates_heat && env.heat_capacity())
			env.set_temperature(env.return_temperature() + deltaT * heatoutput / env.heat_capacity())   //yogs end

/obj/machinery/telecomms/process()
	update_power()

	// Update the icon
	update_icon()
	update_speed()



/obj/machinery/telecomms/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(100/severity) && !(stat & EMPED))
		stat |= EMPED
		var/duration = (300 * 10)/severity
		addtimer(CALLBACK(src, .proc/de_emp), rand(duration - 20, duration + 20))

/obj/machinery/telecomms/proc/de_emp()
	stat &= ~EMPED

/obj/machinery/telecomms/emag_act()
	obj_flags |= EMAGGED
	visible_message("<span class='notice'>Sparks fly out of the [src]!</span>")
	traffic += 50
