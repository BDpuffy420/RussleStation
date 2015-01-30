/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(var/message)

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		src << "You whisper silently, \"[message]\""
		B.host << "<font color = #cc8400>The captive mind of [src] whispers, \"[message]\"</font>"

		for(var/mob/M in mob_list)
			if(M.mind && (istype(M, /mob/dead/observer)))
				var/mob/dead/observer/obs = M
				if(obs.client.holder || obs.has_enabled_antagHUD)
					obs << "<font color = #cc8400><i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i></font>"

/mob/living/captive_brain/emote(var/message)
	return
/mob/living/captive_brain/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1
	if (istype(other, /mob/living/silicon))
		return 1
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/captive_brain))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/simple_animal/borer))
		return 1
	if (istype(other, /mob/living/carbon/slime))
		return 1
	if (istype(other, /mob/living/simple_animal))
		if(other.universal_speak || src.universal_speak || src.universal_understand)
			return 1
		return 0
	return ..()
/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes the"
	response_disarm = "prods the"
	response_harm   = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "nips"
	friendly = "prods"
	wander = 0
	small = 1
	density = 0
	pass_flags = PASSTABLE
	can_hide = 1
	var/mind_check = 0

	var/used_dominate
	var/chemicals = 10                      // Chemicals used for reproduction and spitting neurotoxin.
	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/truename                            // Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain // Used for swapping control of the body back and forth.
	var/controlling                         // Used in human death check.
	var/docile = 0                          // Sugar can stop borers from acting.

/mob/living/simple_animal/borer/Life()

	..()


	if(host)

		if(!stat && !host.stat)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						host << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					else
						src << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					docile = 1
			else
				if(docile)
					if(controlling)
						host << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					else
						src << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					docile = 0

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					host << "\blue You are feeling far too docile to continue controlling your host..."
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(rand(1,2))

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")
	if(mind)
		if(!stat)
			if(!mind_check)
				if(ticker.mode.borers.len >0)
					for(var/datum/mind/borer in ticker.mode.borers)
						if(borer == mind) return

				ticker.mode.borers += mind
				ticker.mode.modePlayer += mind
				ticker.mode.forge_borer_objectives(mind)
				mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
				mind.special_role = "Borer"
				mind_check = 1

/mob/living/simple_animal/borer/New()
	if(istype(src,/mob/living/simple_animal/borer/GM))return ..()
	..()
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	host_brain = new/mob/living/captive_brain(src)
	request_player()
	verbs -= /mob/living/carbon/human/emote
	verbs += /mob/living/simple_animal/borer/emote


/mob/living/simple_animal/borer/GM

/mob/living/simple_animal/borer/GM/New()
	..()
	truename = "[pick("Primary","Secondary","Tertiary","Quaternary")] [rand(1000,9999)]"
	host_brain = new/mob/living/captive_brain(src)

/mob/living/simple_animal/borer/GM/Life()
	..()

/mob/living/simple_animal/borer/emote(var/message)
	return


/mob/living/simple_animal/borer/say(var/message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	message = capitalize(message)

	if(!message)
		return

	if (stat == 2)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

	if (copytext(message, 1, 2) == ";") //Brain borer hivemind.
		return borer_speak(message)

	if(!host)
		src << "You have no host to speak to."
		return //No host, no audible speech.

	src << "You drop words into [host]'s mind: \"[message]\""
	host << "<font color =#cc8400>Your own thoughts speak: \"[message]\"</font>"

	for(var/mob/M in mob_list)
		if(M.mind && (istype(M, /mob/dead/observer)))
			var/mob/dead/observer/obs = M
			if(obs.client.holder || obs.has_enabled_antagHUD)
				obs << "<font color =#cc8400><i>Thought-speech, <b>[truename]</b> -> <b>[host]:</b> [copytext(message, 2)]</i></font>"

/mob/living/simple_animal/borer/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1
	if (istype(other, /mob/living/silicon))
		return 1
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/captive_brain))
		return 1
	if (istype(other, /mob/living/carbon/brain))
		return 1
	if (istype(other, /mob/living/simple_animal/borer))
		return 1
	if (istype(other, /mob/living/carbon/slime))
		return 1
	if (istype(other, /mob/living/simple_animal))
		if(other.universal_speak || src.universal_speak || src.universal_understand)
			return 1
		return 0
	return ..()
/mob/living/simple_animal/borer/Stat()
	..()
	statpanel("Status")

	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		if(!host)
			if(world.time - used_dominate < 300)
				stat(null,"Dominate Not Ready")
			else
				stat(null,"Dominate Ready")
		stat("Chemicals", chemicals)

// VERBS!

/mob/living/simple_animal/borer/proc/borer_speak(var/message)
	if(!message)
		return

	for(var/mob/M in player_list)
		if(M.mind && (istype(M, /mob/living/simple_animal/borer)))
			M << "<font color =#00b273><i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i></font>"
		else if(M.mind && istype(M,/mob/living/carbon))
			var/mob/living/carbon/C = M
			var/mob/living/simple_animal/borer/borer = M.has_brain_worms()

			if(borer)
				if(borer.controlling)
					C << "<font color =#00b273><i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i></font>"
		else if(M.mind && istype(M, /mob/dead/observer))
			var/mob/dead/observer/obs = M
			if(obs.client.holder || obs.has_enabled_antagHUD)
				obs << "<font color =#00b273><i>Cortical link, <b>[truename]:</b> [copytext(message, 2)]</i></font>"
/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Dominate Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	if(host)
		src << "You cannot do that from within a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(3,src))
		if(C.stat != 2)
			choices += C

	if(world.time - used_dominate < 300)
		src << "You cannot use that ability again so soon."
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices

	if(!M || !src) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return

	src << "\red You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread."
	M << "\red You feel a creeping, horrible sense of dread come over you, freezing your limbs,setting your heart racing and causes you to go mute from fear."
	M.Weaken(3)
	M.silent += 30

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(src.stat)
		src << "You cannot do that in your current state."
		return

	if(!host.internal_organs_by_name["brain"]) //this should only run in admin-weirdness situations, but it's here non the less - RR
		src << "<span class='warning'>There is no brain here for us to command!</span>"
		return

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	src << "You begin delicately adjusting your connection to the host brain..."

	spawn(300+(host.brainloss*5))

		if(!host || !src || controlling)
			return
		else
			src << "\red <B>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</B>"
			host << "\red <B>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</B>"

			var/mob/borer = src
			host_brain.ckey = host.ckey
			host.ckey = src.ckey
			if(borer && !borer.ckey)
				borer.ckey = "@[host.ckey]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
			controlling = 1

			host.verbs += /mob/living/carbon/proc/release_control
			host.verbs += /mob/living/carbon/proc/punish_host
			host.verbs += /mob/living/carbon/proc/spawn_larvae
			host.verbs += /mob/living/carbon/proc/borer_speak

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot secrete chemicals in your current state."

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	if(chemicals < 50)
		src << "You don't have enough chemicals!"

	var/chem = input("Select a chemical to secrete.", "Chemicals") in list("bicaridine","tramadol","hyperzine","alkysine")

	if(chemicals < 50 || !host || controlling || !src || stat) //Sanity check.
		return

	src << "\red <B>You squirt a measure of [chem] from your reservoirs into [host]'s bloodstream.</B>"
	host.reagents.add_reagent(chem, 15)
	chemicals -= 50

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!host)
		src << "You are not inside a host body."
		return

	if(stat)
		src << "You cannot leave your host in your current state."

	if(docile)
		src << "\blue You are feeling far too docile to do that."
		return

	if(!host || !src) return

	src << "You begin disconnecting from [host]'s synapses and prodding at their internal ear canal."

	spawn(200)

		if(!host || !src) return

		if(src.stat)
			src << "You cannot infest a target in your current state."
			return

		src << "You wiggle out of [host]'s ear and plop to the ground."

		detatch()

mob/living/simple_animal/borer/proc/detatch()

	if(!host) return

	if(istype(host,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = host
		var/datum/organ/external/head = H.get_organ("head")
		head.implants -= src
	if(controlling)
		if(host.ckey)
			ckey = host.ckey
			controlling = 0
			host.ckey = host_brain.ckey
			host_brain.ckey = null
	host_brain.name = "host brain"
	host_brain.real_name = "host brain"

	src.loc = get_turf(host)
	controlling = 0

	reset_view(null)
	machine = null

	host.reset_view(null)
	host.machine = null

	host.verbs -= /mob/living/carbon/proc/release_control
	host.verbs -= /mob/living/carbon/proc/punish_host
	host.verbs -= /mob/living/carbon/proc/spawn_larvae
	host.verbs -= /mob/living/carbon/proc/borer_speak

	var/mob/living/H = host
	host = null
	for(var/atom/A in H.contents)
		if(istype(A,/mob/living/simple_animal/borer) || istype(A,/obj/item/weapon/holder))
			return
	H.status_flags &= ~PASSEMOTES

/mob/living/simple_animal/borer/verb/infest()
	set category = "Borer"
	set name = "Infest"
	set desc = "Infest a suitable humanoid host."

	if(host)
		src << "You are already within a host."
		return

	if(stat)
		src << "You cannot infest a target in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat != 2 && src.Adjacent(C))
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	if(M.has_brain_worms())
		src << "You cannot infest someone who is already infested!"
		return


	src << "You slither up [M] and begin probing at their ear canal..."

	if(!do_after(src,50))
		src << "As [M] moves away, you are dislodged and fall to the ground."
		return

	if(!M || !src) return

	if(src.stat)
		src << "You cannot infest a target in your current state."
		return

	if(M.stat == 2)
		src << "That is not an appropriate target."
		return

	if(M in view(1, src))
		src << "You wiggle into [M]'s ear."
		src.perform_infestation(M)
		return
	else
		src << "They are no longer in range!"
		return

/mob/living/simple_animal/borer/proc/perform_infestation(var/mob/living/carbon/M)
	src.host = M
	src.loc = M

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/head = H.get_organ("head")
		head.implants += src

	host_brain.name = M.name
	host_brain.real_name = M.real_name
	M.status_flags |= PASSEMOTES

/mob/living/simple_animal/borer/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Borer"
	handle_ventcrawl()

//Procs for grabbing players.
mob/living/simple_animal/borer/proc/request_player()
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Syndicate"))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_ALIEN)
				question(O.client)

mob/living/simple_animal/borer/proc/question(var/client/C)
	spawn(0)
		if(!C)	return
		var/response = alert(C, "A cortical borer needs a player. Are you interested?", "Cortical borer request", "Yes", "No", "Never for this round")
		if(!C || ckey)
			return
		if(response == "Yes")
			transfer_personality(C)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_ALIEN

mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate)
		return

	src.mind = candidate.mob.mind
	src.ckey = candidate.ckey
	if(src.mind)
		src.mind.assigned_role = "Cortical Borer"

/mob/living/simple_animal/borer/hide()
	set category = "Borer"
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."

	if(stat != CONSCIOUS)
		return
	if(host)
		src << "You canot hide within a host."
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