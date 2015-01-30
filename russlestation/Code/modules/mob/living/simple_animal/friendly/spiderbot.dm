/mob/living/simple_animal/spiderbot

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	minbodytemp = 0
	maxbodytemp = 500

	var/obj/item/device/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/weapon/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/device/mmi/mmi = null
	var/list/req_access = list(access_robotics) //Access needed to pop out the brain.
	var/fly = 0
	pass_flags = PASSTABLE

	name = "Spider-bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/spiderbots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	wander = 0
	universal_speak = 1
	health = 10
	maxHealth = 10
	density = 0
	var/ccolor = null

	attacktext = "shocks"
	attacktext = "shocks"
	melee_damage_lower = 1
	melee_damage_upper = 3

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.
	speed = 0                    //Spiderbots gotta go fast.
	small = 1
	speak_emote = list("beeps","clicks","chirps")
	can_hide = 1

/mob/living/simple_animal/spiderbot/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if(istype(O, /obj/item/device/mmi) || istype(O, /obj/item/device/mmi/posibrain))
		var/obj/item/device/mmi/B = O
		if(src.mmi) //There's already a brain in it.
			user << "\red There's already a brain in [src]!"
			return
		if(!B.brainmob)
			user << "\red Sticking an empty MMI into the frame would sort of defeat the purpose."
			return
		if(!B.brainmob.key)
			var/ghost_can_reenter = 0
			if(B.brainmob.mind)
				for(var/mob/dead/observer/G in player_list)
					if(G.can_reenter_corpse && G.mind == B.brainmob.mind)
						ghost_can_reenter = 1
						break
			if(!ghost_can_reenter)
				user << "<span class='notice'>[O] is completely unresponsive; there's no point.</span>"
				return

		if(B.brainmob.stat == DEAD)
			user << "\red [O] is dead. Sticking it into the frame would sort of defeat the purpose."
			return

		if(jobban_isbanned(B.brainmob, "Cyborg"))
			user << "\red [O] does not seem to fit."
			return

		user << "\blue You install [O] in [src]!"

		user.drop_item()
		src.mmi = O
		src.transfer_personality(O)

		O.loc = src
		src.update_icon()
		return 1

	if (istype(O, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = O
		if (WT.remove_fuel(0))
			if(health < maxHealth)
				health += pick(1,1,1,2,2,3)
				if(health > maxHealth)
					health = maxHealth
				add_fingerprint(user)
				for(var/mob/W in viewers(user, null))
					W.show_message(text("\red [user] has spot-welded some of the damage to [src]!"), 1)
			else
				user << "\blue [src] is undamaged!"
		else
			user << "Need more welding fuel!"
			return
	else if(istype(O, /obj/item/weapon/card/id)||istype(O, /obj/item/device/pda))
		if (!mmi)
			user << "\red There's no reason to swipe your ID - the spiderbot has no brain to remove."
			return 0

		var/obj/item/weapon/card/id/id_card

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.access)
			user << "\blue You swipe your access card and pop the brain out of [src]."
			eject_brain()

			if(held_item)
				held_item.loc = src.loc
				held_item = null

			return 1
		else
			user << "\red You swipe your card, with no effect."
			return 0
	else if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "\red [src] is already overloaded - better run."
			return 0
		else
			var/obj/item/weapon/card/emag/emag = O
			emag.uses--
			emagged = 1
			user << "\blue You short out the security protocols and overload [src]'s cell, priming it to explode in a short time."
			spawn(100)	src << "\red Your cell seems to be outputting a lot of power..."
			spawn(200)	src << "\red Internal heat sensors are spiking! Something is badly wrong with your cell!"
			spawn(300)	src.explode()

	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			usr << "\red This weapon is ineffective, it does no damage."
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red [user] gently taps [src] with the [O]. ")

/mob/living/simple_animal/spiderbot/proc/transfer_personality(var/obj/item/device/mmi/M as obj)

		src.mind = M.brainmob.mind
		src.mind.key = M.brainmob.key
		src.ckey = M.brainmob.ckey
		src.name = "Spider-bot ([M.brainmob.name])"

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message("\red [src] makes an odd warbling noise, fizzles, and explodes.")
	explosion(get_turf(loc), -1, -1, 3, 5)
	eject_brain()
	Die()

/mob/living/simple_animal/spiderbot/proc/update_icon()
	if(mmi)
		if(istype(mmi,/obj/item/device/mmi))
			if(ccolor)
				icon_state = "spiderbot-chassis-mmi"+"_[ccolor]"
				icon_living = "spiderbot-chassis-mmi"+"_[ccolor]"
				icon_dead = "spiderbot-smashed"+"_[ccolor]"
			else
				icon_state = "spiderbot-chassis-mmi"
				icon_living = "spiderbot-chassis-mmi"
				icon_dead = "spiderbot-smashed"
		if(istype(mmi, /obj/item/device/mmi/posibrain))
			if(ccolor)
				icon_state = "spiderbot-chassis-posi"+"_[ccolor]"
				icon_living = "spiderbot-chassis-posi"+"_[ccolor]"
				icon_dead = "spiderbot-smashed"+"_[ccolor]"
			else
				icon_state = "spiderbot-chassis-posi"
				icon_living = "spiderbot-chassis-posi"
				icon_dead = "spiderbot-smashed"

	else
		if(ccolor)
			icon_state = "spiderbot-chassis"+"_[ccolor]"
			icon_living = "spiderbot-chassis"+"_[ccolor]"
			icon_dead = "spiderbot-smashed"+"_[ccolor]"
		else
			icon_state = "spiderbot-chassis"
			icon_living = "spiderbot-chassis"
			icon_dead = "spiderbot-smashed"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(loc)
		if(T)
			mmi.loc = T
		if(mind)	mind.transfer_to(mmi.brainmob)
		mmi = null
		src.name = "Spider-bot"
		update_icon()

/mob/living/simple_animal/spiderbot/Del()
	eject_brain()
	..()

/mob/living/simple_animal/spiderbot/New()

	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	camera.c_tag = "Spiderbot-[real_name]"
	camera.network = list("SS13")

	..()

/mob/living/simple_animal/spiderbot/Die()

	living_mob_list -= src
	dead_mob_list += src

	if(camera)
		camera.status = 0

	held_item.loc = src.loc
	held_item = null

	robogibs(src.loc, viruses)
	src.Del()
	return

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/spiderbot/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Spiderbot"
	if(fly)
		usr << "\red Can't Crawl though vent while flying!"
		return
	handle_ventcrawl(null,1)

//Cannibalized from the parrot mob. ~Zuhayr

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(stat)
		return

	if(!held_item)
		usr << "\red You have nothing to drop!"
		return 0

	if(istype(held_item, /obj/item/weapon/grenade))
		visible_message("\red [src] launches \the [held_item]!", "\red You launch \the [held_item]!", "You hear a skittering noise and a thump!")
		var/obj/item/weapon/grenade/G = held_item
		G.loc = src.loc
		G.prime()
		held_item = null
		return 1

	visible_message("\blue [src] drops \the [held_item]!", "\blue You drop \the [held_item]!", "You hear a skittering noise and a soft thump.")

	held_item.loc = src.loc
	held_item = null
	return 1

	return

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(stat)
		return -1

	if(held_item)
		src << "\red You are already holding \the [held_item]"
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= 2)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("\blue [src] scoops up \the [held_item]!", "\blue You grab \the [held_item]!", "You hear a skittering noise and a clink.")
				return held_item
		src << "\red \The [selection] is too far away."
		return 0

	src << "\red There is nothing of interest to take."
	return 0

/mob/living/simple_animal/spiderbot/examine()
	..()
	if(src.held_item)
		usr << "It is carrying \a [src.held_item] \icon[src.held_item]."


/mob/living/simple_animal/spiderbot/verb/choose_color()
	set name = "Choose Color"
	set category = "Spiderbot"
	set desc = "Allows you to change your chassis color."
	if(stat)
		return
	var/accepted = 0
	var/outofchances = 0
	var/newcolor
	var/chassis_colors = list("Standard", "Blue", "Red", "Green", "Pink", "Orange")
	while(!accepted)
		if(outofchances >= 7)
			accepted = 1
			verbs.Remove(/mob/living/simple_animal/spiderbot/verb/choose_color)
			return
		newcolor = input(usr,"Which color style would you like?") in chassis_colors
		switch(newcolor)
			if("Standard")
				ccolor = null
			if("Blue")
				ccolor = "blue"
			if("Red")
				ccolor = "red"
			if("Green")
				ccolor = "green"
			if("Pink")
				ccolor = "pink"
			if("Orange")
				ccolor = "orange"
			else
				ccolor = null
			outofchances++

		update_icon()

		switch(input(usr,"Look at your color - is this what you want?") in list("Yes","No"))
			if("Yes")
				accepted = 1
				verbs.Remove(/mob/living/simple_animal/spiderbot/verb/choose_color)
			if("No")
				if(outofchances >=7)
					usr << "Welp, out of time, buddy. You're stuck. Next time choose faster."
					accepted = 1
					verbs.Remove(/mob/living/simple_animal/spiderbot/verb/choose_color)
	return


/mob/living/simple_animal/spiderbot/verb/fly()
	set name = "Fly/land"
	set category = "Spiderbot"
	set desc = "Allows you to Fly over objects."
	if(layer == TURF_LAYER+0.2)
		hide()
	if(!fly)
		fly = 1
		floatiness = 1
		speed = -2
		make_floaty()
	else
		fly = 0
		speed = 0
		floatiness = 0

/mob/living/simple_animal/spiderbot/hide()
	set category = "Spiderbot"
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."

	if(stat != CONSCIOUS)
		return
	if(fly)
		usr << "\red Can't hide while flying!"
		return
	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		src << text("\green You are now hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("<B>[] scurries to the ground!</B>", src)
	else
		layer = MOB_LAYER
		src << text("\green You have stopped hiding.")
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("[] slowly peaks up from the ground...", src)