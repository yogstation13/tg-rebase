SUBSYSTEM_DEF(economy)
	name = "Economy"
	wait = 5 MINUTES
	init_order = INIT_ORDER_ECONOMY
	runlevels = RUNLEVEL_GAME
	var/roundstart_paychecks = 5
	var/budget_pool = 35000
	var/list/department_accounts = list(ACCOUNT_CIV = ACCOUNT_CIV_NAME,
										ACCOUNT_ENG = ACCOUNT_ENG_NAME,
										ACCOUNT_SCI = ACCOUNT_SCI_NAME,
										ACCOUNT_MED = ACCOUNT_MED_NAME,
										ACCOUNT_SRV = ACCOUNT_SRV_NAME,
										ACCOUNT_CAR = ACCOUNT_CAR_NAME,
										ACCOUNT_SEC = ACCOUNT_SEC_NAME)
	var/list/generated_accounts = list()
	var/full_ancap = FALSE // Enables extra money charges for things that normally would be free, such as sleepers/cryo/cloning.
							//Take care when enabling, as players will NOT respond well if the economy is set up for low cash flows.
	var/datum/station_state/engineering_check = new /datum/station_state()
	var/alive_humans_bounty = 100
	var/crew_safety_bounty = 1500
	var/mood_bounty = 100
	var/techweb_bounty = 25 // yogs start - nerf insane rd budget
	var/slime_bounty = list("grey" = 10,
							// tier 1
							"orange" = 75,
							"metal" = 75,
							"blue" = 75,
							"purple" = 75,
							// tier 2
							"dark purple" = 200,
							"dark blue" = 200,
							"green" = 200,
							"silver" = 200,
							"gold" = 200,
							"yellow" = 200,
							"red" = 200,
							"pink" = 200,
							// tier 3
							"cerulean" = 350,
							"sepia" = 350,
							"bluespace" = 350,
							"pyrite" = 350,
							"light pink" = 350,
							"oil" = 350,
							"adamantine" = 350, // yogs end
							// tier 4
							"rainbow" = 1000)
	var/list/bank_accounts = list() //List of normal accounts (not department accounts)
	var/list/dep_cards = list()
	///ref to moneysink. Only one should exist on the map. Has its payout() proc called every budget cycle
	var/obj/item/energy_harvester/moneysink = null
	///The modifier multiplied to the value of bounties paid out.
	var/bounty_modifier = 1
	///The modifier multiplied to the value of cargo pack prices.
	var/pack_price_modifier = 1

/datum/controller/subsystem/economy/Initialize(timeofday)
	var/budget_to_hand_out = round(budget_pool / department_accounts.len)
	for(var/A in department_accounts)
		if(A == ACCOUNT_SEC)
			new /datum/bank_account/department(A, STARTING_SEC_BUDGET)
			continue
		new /datum/bank_account/department(A, budget_to_hand_out)
	return ..()

/datum/controller/subsystem/economy/fire(resumed = 0)
	eng_payout() // Payout based on station integrity. Also adds money from excess power sold via energy harvester.
	sci_payout() // Payout based on slimes.
	secmedsrv_payout() // Payout based on crew safety, health, and mood.
	civ_payout() // Payout based on ??? Profit
	car_payout() // Cargo's natural gain in the cash moneys.
	var/list/dictionary = list()
	for(var/datum/corporation/c in GLOB.corporations)
		dictionary[c] = list()
		for(var/datum/mind/m in c.employees)
			dictionary[c] += m.name
	for(var/A in bank_accounts)
		var/datum/bank_account/B = A
		for(var/datum/corporation/c in dictionary)
			if(B.account_holder in dictionary[c])
				B.payday(c.paymodifier, TRUE)
		B.payday(1)	

/datum/controller/subsystem/economy/proc/get_dep_account(dep_id)
	for(var/datum/bank_account/department/D in generated_accounts)
		if(D.department_id == dep_id)
			return D

/** Payout for engineering every cycle. Uses a base of 3000 then multiplies it by station integrity. Afterwards, calls the payout proc from
  * the energy harvester and adds the cash from that to the budget.
  */
/datum/controller/subsystem/economy/proc/eng_payout()
	var/engineering_cash = 3000
	engineering_check.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(engineering_check)), 100)
	station_integrity *= 0.01
	engineering_cash *= station_integrity
	if(moneysink)
		engineering_cash += moneysink.payout()
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(engineering_cash)


/datum/controller/subsystem/economy/proc/car_payout()
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(500)

/datum/controller/subsystem/economy/proc/secmedsrv_payout()
	for(var/mob/m in GLOB.mob_list)
		if(isnewplayer(m))
			continue
		if(m.mind)
			if(isbrain(m) || iscameramob(m))
				continue
			if(ishuman(m))
				var/mob/living/carbon/human/H = m
				if(H.stat != DEAD)
					var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
					var/medical_cash = (H.health / H.maxHealth) * alive_humans_bounty
					if(mood)
						var/datum/bank_account/D = get_dep_account(ACCOUNT_SRV)
						if(D)
							var/mood_dosh = (mood.mood_level / 9) * mood_bounty
							D.adjust_money(mood_dosh)
						medical_cash *= (mood.sanity / 100)

					var/datum/bank_account/D = get_dep_account(ACCOUNT_MED)
					if(D)
						D.adjust_money(medical_cash)
		CHECK_TICK

	var/service_passive_income = (rand(1, 6) * 400) //min 400, max 2400
	var/datum/bank_account/SRV = get_dep_account(ACCOUNT_SRV)
	if(SRV)
		SRV.adjust_money(service_passive_income)

/datum/controller/subsystem/economy/proc/sci_payout()
	var/science_bounty = 0
	for(var/mob/living/simple_animal/slime/S in GLOB.mob_list)
		if(S.stat == DEAD)
			continue
		if(!is_station_level(S.z))
			continue
		science_bounty += slime_bounty[S.colour]
	var/datum/bank_account/D = get_dep_account(ACCOUNT_SCI)
	if(D)
		D.adjust_money(min(science_bounty, MAX_GRANT_SCI))

/datum/controller/subsystem/economy/proc/civ_payout()
	var/civ_cash = (rand(1,5) * 500)
	var/datum/bank_account/D = get_dep_account(ACCOUNT_CIV)
	if(D)
		D.adjust_money(min(civ_cash, MAX_GRANT_CIV))
