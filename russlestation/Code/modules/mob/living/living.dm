
/mob/living/verb/succumb()
	set hidden = 1
	if ((src.health < 0 && src.health > -95.0))
		src.adjustOxyLoss(src.health + 200)
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
		src << "\blue You have given up life and succumbed to death."


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
		//world << "DEBUG: burn_skin(), mutations=[mutations]"
		if(mShock in src.mutations) //shockproof
			return 0
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (COLD_RESISTANCE in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.species && (H.species.flags & NO_BREATHE))
			return 0
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		if(H.species && (H.species.flags & IS_SYNTHETIC))
			return 0
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)

		for(var/obj/item/clothing/suit/storage/S in src.contents)//Check for labcoats and jackets
			L += get_contents(S)

		for(var/obj/item/clothing/tie/storage/S in src.contents)//Check for holsters
			L += get_contents(S)

		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter:zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return



/mob/living/proc/revive()
	rejuvenate()
	buckled = initial(src.buckled)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD
	for(var/datum/disease/D in viruses)
		D.cure(0)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.species && (H.species.flags & IS_SYNTHETIC))
			if(H.hstyle_save)
				H.h_style = hstyle_save
				H.regenerate_icons()

/mob/living/proc/rejuvenate()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	SetParalysis(0)
	SetStunned(0)
	SetWeakened(0)
	fire_stacks = 0
	on_fire = 0

	// shut down ongoing problems
	radiation = 0
	nutrition = 450
	bodytemperature = T20C
	sdisabilities = 0
	disabilities = 0
	halloss = 0
	hallucination = 0

	// fix blindness and deafness
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	heal_overall_damage(getBruteLoss(), getFireLoss())


	// restore all of a human's blood
	if(ishuman(src))
		var/mob/living/carbon/human/human_mob = src
		human_mob.restore_blood()
		human_mob.reagents.clear_reagents()
		if(HUSK in human_mob.mutations)
			human_mob.mutations.Remove(HUSK)
			human_mob.status_flags |= DISFIGURED
			human_mob.mutations.Remove(NOCLONE)
			human_mob.update_mutantrace()
			human_mob.UpdateAppearance()
			human_mob.update_body(0)
			human_mob.dna.ready_dna(human_mob)

	// fix all of our organs
	restore_all_organs()

	if(isrobot(src))
		var/mob/living/silicon/robot/R = src
		for(var/V in R.components)
			var/datum/robot_component/C = R.components[V]
			C.installed = 1
			C.brute_damage = 0
			C.electronics_damage = 0
			if(R.cell == null)
				if(R.old_cell == null)
					R.cell = new /obj/item/weapon/cell(R)
				else
					R.cell = R.old_cell
					R.old_cell = null
			R.cell.charge = R.cell.maxcharge
			R.health = 200
	if(isAI(src))
		var/mob/living/silicon/ai/A = src
		A.icon_state = A.rejuv_i_state
		A.rejuv_i_state = null

	if(isanimal(src))
		var/mob/living/simple_animal/S = src
		S.health = S.maxHealth
		S.icon_state = S.icon_living
		S.stat = CONSCIOUS
		S.density = 1
		S.Life()


	// remove the character from the list of the dead
	if(stat == 2)
		dead_mob_list -= src
		living_mob_list += src
		tod = null

	// restore us to conciousness
	stat = CONSCIOUS
	update_fire()

	// make the icons look correct
	regenerate_icons()

	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

	return

/mob/living/proc/UpdateDamageIcon()
	return


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			usr << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			usr << "[src] does not have any stored infomation!"
	else
		usr << "OOC Metadata is not supported by this server!"

	return

/mob/living/Move(a, b, flag)
	if (buckled)
		return

	if (restrained())
		stop_pulling()


	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				stop_pulling()
				return
			else
				if(Debug)
					log_debug("pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]")
					log_debug("REPORT THIS")

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (isliving(pulling))
					var/mob/living/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/atom/movable/t = M.pulling
						M.stop_pulling()

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.getBruteLoss() / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood(M)
						//pull damage with injured people
							if(prob(25))
								M.adjustBruteLoss(1)
								visible_message("\red \The [M]'s wounds open more from being dragged!")
						if(M.pull_damage())
							if(prob(25))
								M.adjustBruteLoss(2)
								visible_message("\red \The [M]'s wounds worsen terribly from being dragged!")
								var/turf/location = M.loc
								if (istype(location, /turf/simulated))
									location.add_blood(M)
									if(ishuman(M))
										var/mob/living/carbon/H = M
										var/blood_volume = round(H:vessel.get_reagent_amount("blood"))
										if(blood_volume > 0)
											H:vessel.remove_reagent("blood",1)


						step(pulling, get_dir(pulling.loc, T))
						M.start_pulling(t)
				else
					if (pulling)
						if (istype(pulling, /obj/structure/window))
							if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
								for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									stop_pulling()
						if(istype(pulling, /obj/structure/stool/bed/chair/wheelchair))
							var/obj/structure/stool/bed/chair/wheelchair/WC = pulling
							if(WC.buckled_mob)
								WC.buckled_mob.dir = src.dir
								WC.handle_rotation()
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		stop_pulling()
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.next_move > world.time)
		return
	usr.next_move = world.time + 20

	var/mob/living/L = usr



	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc //Get our item holder.
		var/mob/M = H.loc                      //Get our mob holder (if any).

		if(istype(M))
			M.drop_from_inventory(H)
			M << "[H] wriggles out of your grip!"
			src << "You wriggle out of [M]'s grip!"
		else if(istype(H.loc,/obj/item))
			src << "You struggle free of [H.loc]."
			H.loc = get_turf(H)

		if(istype(M))
			for(var/atom/A in M.contents)
				if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
					return

			M.status_flags &= ~PASSEMOTES
		return


	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H << "\red <B>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</B>"
		B.host << "\red <B>You feel the captive mind of [src] begin to resist your control.</B>"

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H << "\red <B>With an immense exertion of will, you regain control of your body!</B>"
			B.host << "\red <B>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</b>"
			B.controlling = 0

			B.ckey = B.host.ckey
			B.host.ckey = H.ckey

			H.ckey = null
			H.name = "host brain"
			H.real_name = "host brain"

			verbs -= /mob/living/carbon/proc/release_control
			verbs -= /mob/living/carbon/proc/punish_host
			verbs -= /mob/living/carbon/proc/spawn_larvae
			verbs -= /mob/living/carbon/proc/borer_speak


			return

	//resisting grabs (as if it helps anyone...)
	if ((!( L.stat ) && L.canmove && !( L.restrained() )))
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			del(O)
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == 1)
				del(G)
			else
				if (G.state == 2)
					if (prob(25))
						for(var/mob/O in viewers(L, null))
							O.show_message(text("\red [] has broken free of []'s grip!", L, G.assailant), 1)
						del(G)
				else
					if (G.state == 3)
						if (prob(5))
							for(var/mob/O in viewers(usr, null))
								O.show_message(text("\red [] has broken free of []'s headlock!", L, G.assailant), 1)
							del(G)
		if(resisting)
			for(var/mob/O in viewers(usr, null))
				O.show_message(text("\red <B>[] resists!</B>", L), 1)


	//unbuckling yourself
	if(L.buckled && (L.last_special <= world.time) )
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if( C.handcuffed )
				C.next_move = world.time + 100
				C.last_special = world.time + 100
				C << "\red You attempt to unbuckle yourself. (This will take around 2 minutes and you need to stand still)"
				for(var/mob/O in viewers(L))
					O.show_message("\red <B>[usr] attempts to unbuckle themself!</B>", 1)
				spawn(0)
					if(do_after(usr, 1200))
						if(!C.buckled)
							return
						for(var/mob/O in viewers(C))
							O.show_message("\red <B>[usr] manages to unbuckle themself!</B>", 1)
						C << "\blue You successfully unbuckle yourself."
						C.buckled.manual_unbuckle(C)
		else
			L.buckled.manual_unbuckle(L)

	//Breaking out of a locker?
	else if( src.loc && (istype(src.loc, /obj/structure/closet)) )
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		usr.next_move = world.time + 100
		L.last_special = world.time + 100
		L << "\red You lean on the back of \the [C] and start pushing the door open. (this will take about [breakout_time] minutes)"
		for(var/mob/O in viewers(usr.loc))
			O.show_message("\red <B>The [L.loc] begins to shake violently!</B>", 1)


		spawn(0)
			if(do_after(usr,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
				if(istype(L.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					if(!SC.locked && !SC.welded)
						return
				else
					if(!C.welded)
						return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = 1
					SC.locked = 0
					SC.update_icon()
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [SC]!</B>", 1)
					if(istype(SC.loc, /obj/structure/bigDelivery)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/structure/bigDelivery/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					C.update_icon()
					usr << "\red You successfully break out!"
					for(var/mob/O in viewers(L.loc))
						O.show_message("\red <B>\the [usr] successfully broke out of \the [C]!</B>", 1)
					if(istype(C.loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
						var/obj/structure/bigDelivery/BD = C.loc
						BD.attack_hand(usr)
					C.open()

	//Stop drop and roll & Handcuffs
	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
		if(CM.on_fire && CM.canmove)
			CM.fire_stacks -= 5
			CM.weakened = 5
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>", \
				"<span class='notice'>You stop, drop, and roll!</span>")
			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>", \
				"<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return
		if(CM.handcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "\red You attempt to break your handcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the handcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.handcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the handcuffs!</B>", CM), 1)
						CM << "\red You successfully break your handcuffs."
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
			else
				var/obj/item/weapon/handcuffs/HC = CM.handcuffed
				var/breakouttime = 1200 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/handcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.handcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the handcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.handcuffed]."
						CM.drop_from_inventory(CM.handcuffed)

		else if(CM.legcuffed && CM.canmove && (CM.last_special <= world.time))
			CM.next_move = world.time + 100
			CM.last_special = world.time + 100
			if(isalienadult(CM) || (HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				usr << "\red You attempt to break your legcuffs. (This will take around 5 seconds and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message(text("\red <B>[] is trying to break the legcuffs!</B>", CM), 1)
				spawn(0)
					if(do_after(CM, 50))
						if(!CM.legcuffed || CM.buckled)
							return
						for(var/mob/O in viewers(CM))
							O.show_message(text("\red <B>[] manages to break the legcuffs!</B>", CM), 1)
						CM << "\red You successfully break your legcuffs."
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						del(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = 1200 //A default in case you are somehow legcuffed with something that isn't an obj/item/weapon/legcuffs type
				var/displaytime = 2 //Minutes to display in the "this will take X minutes."
				if(istype(HC)) //If you are legcuffed with actual legcuffs... Well what do I know, maybe someone will want to legcuff you with toilet paper in the future...
					breakouttime = HC.breakouttime
					displaytime = breakouttime / 600 //Minutes
				CM << "\red You attempt to remove \the [HC]. (This will take around [displaytime] minutes and you need to stand still)"
				for(var/mob/O in viewers(CM))
					O.show_message( "\red <B>[usr] attempts to remove \the [HC]!</B>", 1)
				spawn(0)
					if(do_after(CM, breakouttime))
						if(!CM.legcuffed || CM.buckled)
							return // time leniency for lag which also might make this whole thing pointless but the server
						for(var/mob/O in viewers(CM))//                                         lags so hard that 40s isn't lenient enough - Quarxink
							O.show_message("\red <B>[CM] manages to remove the legcuffs!</B>", 1)
						CM << "\blue You successfully remove \the [CM.legcuffed]."
						CM.drop_from_inventory(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
		else if(istype(CM, /mob/living/carbon/human))
			var/mob/living/carbon/human/D = CM
			if(D.restrained())
				if (istype(D.wear_suit, /obj/item/clothing/suit/straight_jacket)&& D.canmove && (D.last_special <= world.time))
					D.next_move = world.time + 100
					D.last_special = world.time + 100
					if(HULK in usr.mutations)//Don't want to do a lot of logic gating here.
						usr << "\red You attempt to breakout of your Straight Jacket. (This will take around 5 seconds and you need to stand still)"
						for(var/mob/O in viewers(D))
							O.show_message(text("\red <B>[] is trying to breakout of the Straight Jacket!</B>", D), 1)
						spawn(0)
							if(do_after(D, 50))
								if(!istype(D.wear_suit, /obj/item/clothing/suit/straight_jacket))
									return // time leniency for lag which also might make this whole thing pointless but the server
								for(var/mob/O in viewers(D))
									O.show_message(text("\red <B>[] manages to breakout of the Straight Jacket!</B>", D), 1)
								D << "\red You successfully break your handcuffs."
								D.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
								del(D.wear_suit)
								D.wear_suit = null
								D.update_inv_wear_suit(1)
					else
						var/obj/item/clothing/suit/straight_jacket/SJ = D.wear_suit
						var/breakouttime = 2400 //A default in case you are somehow handcuffed with something that isn't an obj/item/weapon/handcuffs type
						var/displaytime = 4 //Minutes to display in the "this will take X minutes."
						if(istype(SJ)) //If you are handcuffed with actual handcuffs... Well what do I know, maybe someone will want to handcuff you with toilet paper in the future...
							breakouttime = SJ.breakouttime
							displaytime = breakouttime / 600 //Minutes
						D << "\red You attempt to remove \the [SJ]. (This will take around [displaytime] minutes and you need to stand still)"
						for(var/mob/O in viewers(D))
							O.show_message( "\red <B>[usr] attempts to remove \the [SJ]!</B>", 1)
						spawn(0)
							if(do_after(D, breakouttime))
								if(!istype(D.wear_suit, /obj/item/clothing/suit/straight_jacket))
									return // time leniency for lag which also might make this whole thing pointless but the server
								for(var/mob/O in viewers(D))//                                         lags so hard that 40s isn't lenient enough - Quarxink
									O.show_message("\red <B>[D] manages to remove their Straight Jacket!</B>", 1)
								D << "\blue You successfully remove \the [D.wear_suit]."
								D.drop_from_inventory(D.wear_suit)


/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"
	if(istype(src,/mob/living/carbon/human))
		if(stat)
			src << "You must be conscious to do this!"
			return
	resting = !resting
	src << "\blue You are now [resting ? "resting" : "getting up"]"

/mob/living/proc/handle_ventcrawl(var/obj/machinery/atmospherics/unary/vent_pump/vent_found = null, var/ignore_items = 0)
	if(stat)
		src << "You must be conscious to do this!"
		return
	if(lying)
		src << "You can't vent crawl while you're stunned!"
		return

	if(vent_found) // one was passed in, probably from vent/AltClick()
		if(vent_found.welded)
			src << "That vent is welded shut."
			return
		if(!vent_found.Adjacent(src))
			return // don't even acknowledge that
	else
		for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
			if(!v.welded)
				if(v.Adjacent(src))
					vent_found = v
	if(!vent_found)
		src << "You'll need a non-welded vent to crawl into!"
		return

	if(!vent_found.network || !vent_found.network.normal_members.len)
		src << "This vent is not connected to anything."
		return

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
		if(temp_vent.welded)
			continue
		if(temp_vent in loc)
			continue
		var/turf/T = get_turf(temp_vent)

		if(!T || T.z != loc.z)
			continue

		var/i = 1
		var/index = "[T.loc.name]\[[i]\]"
		while(index in vents)
			i++
			index = "[T.loc.name]\[[i]\]"
		vents[index] = temp_vent
	if(!vents.len)
		src << "\red There are no available vents to travel to, they could be welded."
		return

	var/obj/selection = input("Select a destination.", "Duct System") as null|anything in sortAssoc(vents)
	if(!selection)	return

	if(!vent_found.Adjacent(src))
		src << "Never mind, you left."
		return

	if(!ignore_items)
		for(var/obj/item/carried_item in contents)//If the monkey got on objects.
			if( !istype(carried_item, /obj/item/weapon/implant) && !istype(carried_item, /obj/item/clothing/mask/facehugger) )//If it's not an implant or a facehugger
				src << "\red You can't be carrying items or have items equipped when vent crawling!"
				return

	if(isslime(src))
		var/mob/living/carbon/slime/S = src
		if(S.Victim)
			src << "\red You'll have to let [S.Victim] go or finish eating \him first."
			return

	var/obj/machinery/atmospherics/unary/vent_pump/target_vent = vents[selection]
	if(!target_vent)
		return

	for(var/mob/O in viewers(src, null))
		O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
	loc = target_vent

	var/travel_time = round(get_dist(loc, target_vent.loc) / 2)

	spawn(travel_time)

		if(!target_vent)	return
		for(var/mob/O in hearers(target_vent,null))
			O.show_message("You hear something squeezing through the ventilation ducts.",2)

		sleep(travel_time)

		if(!target_vent)	return
		if(target_vent.welded)			//the vent can be welded while alien scrolled through the list or travelled.
			target_vent = vent_found 	//travel back. No additional time required.
			src << "\red The vent you were heading to appears to be welded."
		loc = target_vent.loc
		var/area/new_area = get_area(loc)
		if(new_area)
			new_area.Entered(src)