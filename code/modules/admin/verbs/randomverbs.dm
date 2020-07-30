/client/proc/cmd_admin_drop_everything(mob/M as mob in mob_list)
	set category = null
	set name = "Drop Everything"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		M.drop_from_inventory(W)

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	message_admins("[key_name_admin(usr)] made [key_name_admin(M)] drop everything!")
	feedback_add_details("admin_verb","DEVR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_prison(mob/M as mob in mob_list)
	set category = "Admin"
	set name = "Prison"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if (ismob(M))
		if(istype(M, /mob/living/silicon/ai))
			alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
			return
		//strip their stuff before they teleport into a cell :downs:
		for(var/obj/item/W in M)
			M.drop_from_inventory(W)
		//teleport person to cell
		M.Paralyse(5)
		sleep(5)	//so they black out before warping
		M.loc = pick(prisonwarp)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), SLOT_W_UNIFORM)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), SLOT_SHOES)
		spawn(50)
			to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>")
		feedback_add_details("admin_verb","PRISON") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = sanitize(input("Message:", text("Subtle PM to [M.key]")) as text)

	if (!msg)
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, "<b>You hear a voice in your head... <i>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	message_admins("<span class='notice'><b>SubtleMessage</b>: [key_name_admin(usr)] -> [key_name_admin(M)] : [msg]</span>")
	feedback_add_details("admin_verb","SMS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mentor_check_new_players()	//Allows mentors / admins to determine who the newer players are.
	set category = "Admin"
	set name = "Check new Players"
	if(!holder)
		to_chat(src, "Only staff members may use this command.")

	var/age = alert(src, "Age check", "Show accounts yonger then _____ days","7", "30" , "All")

	if(age == "All")
		age = 9999999
	else
		age = text2num(age)

	var/missing_ages = 0
	var/msg = ""

	for(var/client/C in clients)
		if(C.player_age == "Requires database")
			missing_ages = 1
			continue
		if(C.player_age < age)
			msg += {"
				[key_name(C, 1)] [ADMIN_PP(C.mob)]:<br>
				<b>Days on server:</b> [C.player_age]<br>
				<b>In-game minutes:</b> [isnum(C.player_ingame_age) ? C.player_ingame_age : 0]
				<hr>
			"}

	if(missing_ages)
		to_chat(src, "Some accounts did not have proper ages set in their clients.  This function requires database to be present")

	if(msg != "")
		src << browse(msg, "window=Player_age_check")
	else
		to_chat(src, "No matches for that age range found.")


/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set category = "Special Verbs"
	set name = "Global Narrate"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = sanitize(input("Message:", text("Enter the text you wish to appear to everyone:")) as text)

	if (!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins("<span class='notice'><b>GlobalNarrate</b>: [key_name_admin(usr)] : [msg]<BR></span>")
	feedback_add_details("admin_verb","GLN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)	// Targetted narrate -- TLE
	set category = "Special Verbs"
	set name = "Direct Narrate"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if(!M)
		M = input("Direct narrate to who?", "Active Players") as null|anything in get_mob_with_client_list()

	if(!M)
		return

	var/msg = sanitize(input("Message:", text("Enter the text you wish to appear to your target:")) as text)

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to [key_name(M)]: [msg]")
	message_admins("<span class='notice'><b>DirectNarrate</b>: [key_name(usr)] to [key_name(M)]: [msg]<BR></span>")
	feedback_add_details("admin_verb","DIRN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Godmode"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	M.status_flags ^= GODMODE
	to_chat(usr, "<span class='notice'>Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]</span>")

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	message_admins("[key_name_admin(usr)] has toggled [key_name_admin(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	feedback_add_details("admin_verb","GOD") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(mob/M as mob, mute_type, automute = 0)
	if(automute)
		if(!config.automute_on)
			return
	else
		if(!usr || !usr.client)
			return
		if(!usr.client.holder)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You don't have permission to do this.</font>")
			return
		if(!M.client)
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: This mob doesn't have a client tied to it.</font>")
		if(M.client.holder && (M.client.holder.rights & R_ADMIN) && !check_rights(R_PERMISSIONS))
			return
		if(M.client.holder && (M.client.holder.rights & R_PERMISSIONS))
			to_chat(usr, "<font color='red'>Error: cmd_admin_mute: You cannot mute an admin with permissions rights.</font>")
			return
	if(!M.client)
		return


	var/muteunmute
	var/mute_string

	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
		if(MUTE_OOC)
			mute_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
		if(MUTE_MENTORHELP)
			mute_string = "mentorhelp and mentor PM"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
		if(MUTE_ALL)
			mute_string = "everything"
		else
			return

	if(automute)
		muteunmute = "auto-muted"
		M.client.prefs.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(M)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(M)] from [mute_string].")
		to_chat(M, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.")
		feedback_add_details("admin_verb","AUTOMUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(M.client.prefs.muted & mute_type)
		muteunmute = "unmuted"
		M.client.prefs.muted &= ~mute_type
		if(M.client.prefs.permamuted & mute_type)
			M.client.prefs.permamuted &= ~mute_type
			M.client.prefs.save_preferences()
			to_chat(M, "<span class='notice'>You have been [mute_string] unmuted from [usr.key].</span>")
	else
		if(alert("Would you like to make it permament?","Permamute?","Yes","No, round only") == "Yes")
			var/permmutreason = input("Permamute Reason") as text|null
			if(permmutreason)
				muteunmute = "permamuted"
				M.client.prefs.permamuted |= mute_type
				M.client.prefs.save_preferences()
				M.client.prefs.muted |= mute_type
				notes_add(M.ckey, "Permamute from [mute_string]: [permmutreason]", usr.client)
				permmutreason = sanitize(permmutreason)
				to_chat(M, "<span class='alert big bold'>You have been permamuted from [mute_string] by [usr.key].<br>Reason: [permmutreason]</span>")
			else
				to_chat(usr, "<span class='alert'>Could not apply permamute: Reason is empty</span>")
				return

		else if (alert("Add a notice for round mute?", "Mute Notice?", "Yes","No") == "Yes")
			var/mutereason = input("Mute Reason") as text|null
			if(mutereason)
				notes_add(M.ckey, "Muted from [mute_string]: [mutereason]", usr.client)
				mutereason = sanitize(mutereason)
				to_chat(M, "<span class='alert big bold'>You have been muted from [mute_string] by [usr.key].<br>Reason: [mutereason]</span>")
			else
				return
		else
			to_chat(M, "<span class='alert big bold'>You have been muted from [mute_string] by [usr.key].</span>")

		muteunmute = "muted"
		M.client.prefs.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(M)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(M)] from [mute_string].")
	feedback_add_details("admin_verb","MUTE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_admin_add_random_ai_law()
	set category = "Fun"
	set name = "Add Random AI Law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	log_admin("[key_name(src)] has added a random AI law.")
	message_admins("[key_name_admin(src)] has added a random AI law.")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", "istorm")

	IonStorm(0)
	feedback_add_details("admin_verb","ION") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in player_list)
			if(M.stat != DEAD)		continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_role))	continue	//we don't want to be an alium
			if(M.client.is_afk())	continue	//we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)	continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(usr, "<font color='red'>Error: create_xeno(): no suitable candidates.</font>")
	if(!istext(ckey))	return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = xeno_spawn.len ? pick(xeno_spawn) : pick(latejoin)
	var/mob/living/carbon/xenomorph/new_xeno
	switch(alien_caste)
		if("Queen")		new_xeno = new /mob/living/carbon/xenomorph/humanoid/queen(spawn_here)
		if("Hunter")	new_xeno = new /mob/living/carbon/xenomorph/humanoid/hunter(spawn_here)
		if("Sentinel")	new_xeno = new /mob/living/carbon/xenomorph/humanoid/sentinel(spawn_here)
		if("Drone")		new_xeno = new /mob/living/carbon/xenomorph/humanoid/drone(spawn_here)
		if("Larva")		new_xeno = new /mob/living/carbon/xenomorph/larva(spawn_here)
		else			return 0

	new_xeno.ckey = ckey
	message_admins("<span class='notice'>[key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].</span>")
	return 1

/*
Allow admins to set players to be able to respawn/bypass 30 min wait, without the admin having to edit variables directly
Ccomp's first proc.
*/

/client/proc/get_ghosts(notify = 0,what = 2)
	// what = 1, return ghosts ass list.
	// what = 2, return mob list

	var/list/mobs = list()
	var/list/ghosts = list()
	var/list/sortmob = sortAtom(observer_list)                           // get the mob list.
	var/any = 0
	for(var/mob/dead/observer/M in sortmob)
		mobs.Add(M)                                             //filter it where it's only ghosts
		any = 1                                                 //if no ghosts show up, any will just be 0
	if(!any)
		if(notify)
			to_chat(src, "There doesn't appear to be any ghosts for you to select.")
		return

	for(var/mob/M in mobs)
		var/name = M.name
		ghosts[name] = M                                        //get the name of the mob for the popup list
	if(what==1)
		return ghosts
	else
		return mobs


/client/proc/allow_character_respawn()
	set category = "Special Verbs"
	set name = "Allow player to respawn"
	set desc = "Let's the player bypass the 30 minute wait to respawn or allow them to re-enter their corpse."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/list/ghosts= get_ghosts(1,1)

	var/target = input("Please, select a ghost!", "COME BACK TO LIFE!", null, null) as null|anything in ghosts
	if(!target)
		to_chat(src, "Hrm, appears you didn't select a ghost")// Sanity check, if no ghosts in the list we don't want to edit a null variable and cause a runtime error.
		return

	var/mob/dead/observer/G = ghosts[target]
	if(G.has_enabled_antagHUD && config.antag_hud_restricted)
		var/response = alert(src, "Are you sure you wish to allow this individual to play?","Ghost has used AntagHUD","Yes","No")
		if(response == "No") return
	G.timeofdeath=-19999						/* time of death is checked in /mob/verb/abandon_mob() which is the Respawn verb.
									   timeofdeath is used for bodies on autopsy but since we're messing with a ghost I'm pretty sure
									   there won't be an autopsy.
									*/
	G.has_enabled_antagHUD = 2
	G.can_reenter_corpse = 1

	to_chat(G, "<span class='notice'><B>You may now respawn. You should roleplay as if you learned nothing about the round during your time with the dead.</B></span>")
	log_admin("[key_name(usr)] allowed [key_name(G)] to bypass the 30 minute respawn limit")
	message_admins("Admin [key_name_admin(usr)] allowed [key_name_admin(G)] to bypass the 30 minute respawn limit")


/client/proc/toggle_antagHUD_use()
	set category = "Server"
	set name = "Toggle antagHUD usage"
	set desc = "Toggles antagHUD usage for observers."

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_allowed)
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						//Remove the verb from non-admin ghosts
				g.verbs -= /mob/dead/observer/verb/toggle_antagHUD
			if(g.antagHUD)
				g.antagHUD = 0						// Disable it on those that have it enabled
				g.has_enabled_antagHUD = 2				// We'll allow them to respawn
				to_chat(g, "<span class='warning'><B>The Administrator has disabled AntagHUD </B></span>")
		config.antag_hud_allowed = 0
		to_chat(src, "<span class='warning'><B>AntagHUD usage has been disabled</B></span>")
		action = "disabled"
	else
		for(var/mob/dead/observer/g in get_ghosts())
			if(!g.client.holder)						// Add the verb back for all non-admin ghosts
				g.verbs += /mob/dead/observer/verb/toggle_antagHUD
			to_chat(g, "<span class='notice'><B>The Administrator has enabled AntagHUD </B></span>")// Notify all observers they can now use AntagHUD
		config.antag_hud_allowed = 1
		action = "enabled"
		to_chat(src, "<span class='notice'><B>AntagHUD usage has been enabled</B></span>")


	log_admin("[key_name(usr)] has [action] antagHUD usage for observers")
	message_admins("Admin [key_name_admin(usr)] has [action] antagHUD usage for observers")



/client/proc/toggle_antagHUD_restrictions()
	set category = "Server"
	set name = "Toggle antagHUD Restrictions"
	set desc = "Restricts players that have used antagHUD from being able to join this round."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
	var/action=""
	if(config.antag_hud_restricted)
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='notice'><B>The administrator has lifted restrictions on joining the round if you use AntagHUD</B></span>")
		action = "lifted restrictions"
		config.antag_hud_restricted = 0
		to_chat(src, "<span class='notice'><B>AntagHUD restrictions have been lifted</B></span>")
	else
		for(var/mob/dead/observer/g in get_ghosts())
			to_chat(g, "<span class='warning'><B>The administrator has placed restrictions on joining the round if you use AntagHUD</B></span>")
			to_chat(g, "<span class='warning'><B>Your AntagHUD has been disabled, you may choose to re-enabled it but will be under restrictions </B></span>")
			g.antagHUD = 0
			g.has_enabled_antagHUD = 0
		action = "placed restrictions"
		config.antag_hud_restricted = 1
		to_chat(src, "<span class='warning'><B>AntagHUD restrictions have been enabled</B></span>")

	log_admin("[key_name(usr)] has [action] on joining the round if they use AntagHUD")
	message_admins("Admin [key_name_admin(usr)] has [action] on joining the round if they use AntagHUD")




/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Special Verbs"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(src, "Please specify which key will be respawned.", "Key", "") as null|anything in clients
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role=="Alien")
			if(alert("This character appears to have been an alien. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/turf/T
				if(xeno_spawn.len)	T = pick(xeno_spawn)
				else				T = pick(latejoin)

				var/mob/living/carbon/xenomorph/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")	new_xeno = new /mob/living/carbon/xenomorph/humanoid/hunter(T)
					if("Sentinel")	new_xeno = new /mob/living/carbon/xenomorph/humanoid/sentinel(T)
					if("Drone")		new_xeno = new /mob/living/carbon/xenomorph/humanoid/drone(T)
					if("Queen")		new_xeno = new /mob/living/carbon/xenomorph/humanoid/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_xeno.key = G_found.key
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [key_name_admin(new_xeno)] as a filthy xeno.</span>")
				return	//all done. The ghost is auto-deleted

		//check if they were a monkey
		else if(findtext(G_found.real_name,"monkey"))
			if(alert("This character appears to have been a monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new(pick(latejoin))
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				new_monkey.key = G_found.key
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				message_admins("<span class='notice'>[key_name_admin(usr)] has respawned [key_name_admin(new_monkey)] as a filthy xeno.</span>")
				return	//all done. The ghost is auto-deleted


	//Ok, it's not a xeno or a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")
		for(var/datum/data/record/t in data_core.locked)
			if(t.fields["id"]==id)
				record_found = t//We shall now reference the record.
				break

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["sex"]
		new_character.age = record_found.fields["age"]
		new_character.b_type = record_found.fields["b_type"]
	else
		new_character.gender = pick(MALE,FEMALE)
		var/datum/preferences/A = new()
		A.randomize_appearance_for(new_character)
		new_character.real_name = G_found.real_name

	if(!new_character.real_name)
		if(new_character.gender == MALE)
			new_character.real_name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
		else
			new_character.real_name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
		new_character.mind.special_verbs = list()
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = "Test Subject"//If they somehow got a null assigned role.

	//DNA
	if(record_found)//Pull up their name from database records if they did have a mind.
		new_character.dna = new()//Let's first give them a new DNA.
		new_character.dna.unique_enzymes = record_found.fields["b_dna"]//Enzymes are based on real name but we'll use the record for conformity.

		// I HATE BYOND.  HATE.  HATE. - N3X
		var/list/newSE= record_found.fields["enzymes"]
		var/list/newUI = record_found.fields["identity"]
		new_character.dna.SE = newSE.Copy() //This is the default of enzymes so I think it's safe to go with.
		new_character.dna.UpdateSE()
		new_character.UpdateAppearance(newUI.Copy())//Now we configure their appearance based on their unique identity, same as with a DNA machine or somesuch.
	else//If they have no records, we just do a random DNA for them, based on their random appearance/savefile.
		new_character.dna.ready_dna(new_character)

	new_character.key = G_found.key

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	switch(new_character.mind.special_role)
		if("traitor")
			SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)
			ticker.mode.equip_traitor(new_character)
		if("Wizard")
			new_character.loc = pick(wizardstart)
			//ticker.mode.learn_basic_spells(new_character)
			ticker.mode.equip_wizard(new_character)
		if("Syndicate")
			var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
			if(synd_spawn)
				new_character.loc = get_turf(synd_spawn)
			call(/datum/game_mode/proc/equip_syndicate)(new_character)
		if("Ninja")
			new_character.equip_space_ninja()
			new_character.internal = new_character.s_store
			new_character.internals.icon_state = "internal1"
			if(ninjastart.len == 0)
				to_chat(new_character, "<B><span class='warning'>A proper starting location for you could not be found, please report this bug!</span></B>")
				to_chat(new_character, "<B><span class='warning'>Attempting to place at a carpspawn.</span></B>")
				for(var/obj/effect/landmark/L in landmarks_list)
					if(L.name == "carpspawn")
						ninjastart.Add(L)
				if(ninjastart.len == 0 && latejoin.len > 0)
					to_chat(new_character, "<B><span class='warning'>Still no spawneable locations could be found. Defaulting to latejoin.</span></B>")
					new_character.loc = pick(latejoin)
				else if (ninjastart.len == 0)
					to_chat(new_character, "<B><span class='warning'>Still no spawneable locations could be found. Aborting.</span></B>")

		if("Death Commando")//Leaves them at late-join spawn.
			new_character.equip_death_commando()
			new_character.internal = new_character.s_store
			new_character.internals.icon_state = "internal1"
		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				if("AI")
					new_character = new_character.AIize()
					if(new_character.mind.special_role=="traitor")
						call(/datum/game_mode/proc/add_law_zero)(new_character)
				//Add aliens.
				else
					SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!="MODE")//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				call(/mob/dead/new_player/proc/AnnounceArrival)(new_character, new_character.mind.assigned_role)

	message_admins("<span class='notice'>[admin] has respawned [player_key] as [new_character.real_name].</span>")

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	feedback_add_details("admin_verb","RSPCH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Fun"
	set name = "Add Custom AI law"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = sanitize(input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null)
	if(!input)
		return
	for(var/mob/living/silicon/ai/M in ai_list)
		if (M.stat == DEAD)
			to_chat(usr, "Upload failed. No signal is being detected from the AI.")
		else if (M.see_in_dark == 0)
			to_chat(usr, "Upload failed. Only a faint signal is being detected from the AI, and it is not responding to our requests. It may be low on power.")
		else
			M.add_ion_law(input)
			for(var/mob/living/silicon/ai/O in ai_list)
				to_chat(O, "<span class='warning'></span>" + input + "<span class='warning'>...LAWS UPDATED</span>")

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	if(show_log == "Yes")
		command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", "istorm")
	feedback_add_details("admin_verb","IONC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Rejuvenate"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!check_rights(R_REJUVINATE)) return
	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	if(config.allow_admin_rev)
		M.revive()

		log_admin("[key_name(usr)] healed / revived [key_name(M)]")
		message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!</span>")
	else
		alert("Admin revive disabled")
	feedback_add_details("admin_verb","REJU") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Special Verbs"
	set name = "Create Command Report"
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = sanitize(input(usr, "Please enter anything you want. Anything. Serious.", "What?", "") as message|null, MAX_PAPER_MESSAGE_LEN, extra = FALSE)
	var/customname = sanitize_safe(input(usr, "Pick a title for the report.", "Title") as text|null)
	if(!input)
		return
	if(!customname)
		customname = "NanoTrasen Update"

	switch(alert("Should this be announced to the general population?",,"Yes","No","Cancel"))
		if("Yes")
			command_alert(input, customname)
		if("No")
			to_chat(world, "<span class='warning'>New NanoTrasen Update available at all communication consoles.</span>")
			station_announce(sound = "commandreport")
		if("Cancel")
			return

	for (var/obj/machinery/computer/communications/C in communications_list)
		if(! (C.stat & (BROKEN|NOPOWER) ) )
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper( C.loc )
			P.name = "'[command_name()] Update.'"
			P.info = replacetext(input, "\n", "<br/>")
			P.update_icon()
			C.messagetitle.Add("[command_name()] Update")
			C.messagetext.Add(P.info)

	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report")
	feedback_add_details("admin_verb","CCR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_delete(atom/O as obj|mob|turf in view())
	set category = "Admin"
	set name = "Delete"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	if (alert(src, "Are you sure you want to delete:\n[O]\nat ([O.x], [O.y], [O.z])?", "Confirmation", "Yes", "No") == "Yes")
		log_admin("[key_name(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] deleted [O] at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","DEL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(isturf(O))
			var/turf/T = O
			T.ChangeTurf(T.basetype)
		else
			qdel(O)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin"
	set name = "List free slots"

	if (!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(SSjob)
		for(var/datum/job/job in SSjob.occupations)
			to_chat(src, "[job.title]: [job.total_positions]")
	feedback_add_details("admin_verb","LFS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "Explosion"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flash]) at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","EXPL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Special Verbs"
	set name = "EM Pulse"

	if(!check_rights(R_DEBUG|R_FUN))	return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null) return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null) return

	if (heavy || light)

		empulse(O, heavy, light)
		log_admin("[key_name(usr)] created an EM Pulse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
		feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

		return
	else
		return

/client/proc/cmd_admin_gib(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Gib"

	if(!check_rights(R_ADMIN|R_FUN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]")

	if(istype(M, /mob/dead/observer))
		gibs(M.loc, M.viruses)
		return

	M.gib()
	feedback_add_details("admin_verb","GIB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		if (istype(mob, /mob/dead/observer)) // so they don't spam gibs everywhere
			return
		else
			mob.gib()

		log_admin("[key_name(usr)] used gibself.")
		message_admins("<span class='notice'>[key_name_admin(usr)] used gibself.</span>")
		feedback_add_details("admin_verb","GIBS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_dust(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Turn to dust"

	if(!check_rights(R_ADMIN|R_FUN))
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes") return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)	return

	log_admin("[key_name(usr)] has annihilate [key_name(M)]")
	message_admins("[key_name_admin(usr)] has annihilate [key_name_admin(M)]")

	if(istype(M, /mob/dead/observer))
		return

	M.dust()
	feedback_add_details("admin_verb","DUST") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
/*
/client/proc/cmd_manual_ban()
	set name = "Manual Ban"
	set category = "Special Verbs"
	if(!authenticated || !holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/mob/M = null
	switch(alert("How would you like to ban someone today?", "Manual Ban", "Key List", "Enter Manually", "Cancel"))
		if("Key List")
			var/list/keys = list()
			for(var/mob/M in world)
				keys += M.client
			var/selection = input("Please, select a player!", "Admin Jumping", null, null) as null|anything in keys
			if(!selection)
				return
			M = selection:mob
			if ((M.client && M.client.holder && (M.client.holder.level >= holder.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

	switch(alert("Temporary Ban?",,"Yes","No"))
	if("Yes")
		var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
		if(!mins)
			return
		if(mins >= 525600) mins = 525599
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		if(M)
			AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
			to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
			to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
			to_chat(M, "<span class='warning'>To try to resolve this matter head to http://ss13.donglabs.com/forum/</span>")
			log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
			message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")
			world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=[mins]&server=[replacetext(config.server_name, "#", "")]")
			del(M.client)
			qdel(M)
		else

	if("No")
		var/reason = input(usr,"Reason?","reason","Griefer") as text
		if(!reason)
			return
		AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
		to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
		to_chat(M, "<span class='warning'>This is a permanent ban.</span>")
		to_chat(M, "<span class='warning'>To try to resolve this matter head to http://ss13.donglabs.com/forum/</span>")
		log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("<span class='notice'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.</span>")
		world.Export("http://216.38.134.132/adminlog.php?type=ban&key=[usr.client.key]&key2=[M.key]&msg=[html_decode(reason)]&time=perma&server=[replacetext(config.server_name, "#", "")]")
		del(M.client)
		qdel(M)
*/

/client/proc/update_world()
	// If I see anyone granting powers to specific keys like the code that was here,
	// I will both remove their SVN access and permanently ban them from my servers.
	return

/client/proc/cmd_admin_check_contents(mob/living/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	feedback_add_details("admin_verb","CC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/* This proc is DEFERRED. Does not do anything.
/client/proc/cmd_admin_remove_phoron()
	set category = "Debug"
	set name = "Stabilize Atmos."
	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	feedback_add_details("admin_verb","STATM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
// DEFERRED
	spawn(0)
		for(var/turf/T in view())
			T.poison = 0
			T.oldpoison = 0
			T.tmppoison = 0
			T.oxygen = 755985
			T.oldoxy = 755985
			T.tmpoxy = 755985
			T.co2 = 14.8176
			T.oldco2 = 14.8176
			T.tmpco2 = 14.8176
			T.n2 = 2.844e+006
			T.on2 = 2.844e+006
			T.tn2 = 2.844e+006
			T.tsl_gas = 0
			T.osl_gas = 0
			T.sl_gas = 0
			T.temp = 293.15
			T.otemp = 293.15
			T.ttemp = 293.15
*/

/client/proc/toggle_view_range()
	set category = "Special Verbs"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views."

	if(view == world.view)
		view = input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128)
	else
		view = world.view

	log_admin("[key_name(usr)] changed their view range to [view].")
	//message_admins("<span class='notice'>[key_name_admin(usr)] changed their view range to [view].</span>", 1)	//why? removed by order of XSI

	feedback_add_details("admin_verb","CVRA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()

	set category = "Admin"
	set name = "Call Shuttle"

	if(!ticker || SSshuttle.location)
		return

	if(!check_rights(R_ADMIN))
		return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	if(SSshuttle.always_fake_recall)
		var/choice = input("The shuttle will just return if you call it. What you want to do?") in list(
					"Cancel shuttle call",
					"Call it anyway",
					"Call and allow it to fly to station")
		switch(choice)
			if("Cancel shuttle call")
				return
			if("Call and allow it to fly to station")
				SSshuttle.always_fake_recall = FALSE
				SSshuttle.fake_recall = 0
				log_admin("[key_name(usr)] disabled shuttle fake recall.")
				message_admins("<span class='info'>[key_name_admin(usr)] disabled shuttle fake recall.</span>")

	var/type = alert(src, "It's emergency shuttle or crew transfer?", "Confirm", "Emergency", "Crew transfer")

	if(type == "Crew transfer")
		SSshuttle.shuttlealert(1)
		SSshuttle.incall()
		captain_announce("A crew transfer has been initiated. The shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "crew_shut_called")
	else
		var/eaccess = alert(src, "Grant acces to maints for everyone?", "Confirm", "Yes", "No")
		SSshuttle.incall()
		captain_announce("The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes.", sound = "emer_shut_called")

		if(eaccess == "Yes")
			make_maint_all_access(FALSE)

	feedback_add_details("admin_verb","CSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the emergency shuttle.")
	message_admins("<span class='notice'>[key_name_admin(usr)] admin-called the emergency shuttle.</span>")
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin"
	set name = "Cancel Shuttle"

	if(!check_rights(R_ADMIN))
		return

	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes") return

	if(!ticker || SSshuttle.location || SSshuttle.direction == 0)
		return

	SSshuttle.recall()
	feedback_add_details("admin_verb","CCSHUT") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the emergency shuttle.")
	message_admins("<span class='notice'>[key_name_admin(usr)] admin-recalled the emergency shuttle.</span>")

	if(timer_maint_revoke_id)
		deltimer(timer_maint_revoke_id)
		timer_maint_revoke_id = 0
	timer_maint_revoke_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/revoke_maint_all_access, FALSE), 600, TIMER_UNIQUE|TIMER_STOPPABLE)

	return

/client/proc/admin_deny_shuttle()
	set category = "Admin"
	set name = "Toggle Deny Shuttle"

	if (!ticker)
		return

	if(!check_rights(R_ADMIN))
		return

	SSshuttle.deny_shuttle = !SSshuttle.deny_shuttle

	log_admin("[key_name(src)] has [SSshuttle.deny_shuttle ? "denied" : "allowed"] the shuttle to be called.")
	message_admins("[key_name_admin(usr)] has [SSshuttle.deny_shuttle ? "denied" : "allowed"] the shuttle to be called.")

/client/proc/cmd_admin_attack_log(mob/M as mob in mob_list)
	set category = "Special Verbs"
	set name = "Attack Log"

	to_chat(usr, text("<span class='warning'><b>Attack Log for []</b></span>", mob))
	for(var/t in M.attack_log)
		to_chat(usr, t)
	feedback_add_details("admin_verb","ATTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/everyone_random()
	set category = "Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(!check_rights(R_FUN))	return

	if (ticker && ticker.mode)
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	if(ticker.random_players)
		ticker.random_players = 0
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, "<span class='notice'><b>Admin [usr.key] has forced the players to have completely random identities!</b></span>")

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	ticker.random_players = 1
	feedback_add_details("admin_verb","MER") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"

	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off."
	if(!check_rights(R_SERVER))	return

	if(!config.allow_random_events)
		config.allow_random_events = 1
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.")
	else
		config.allow_random_events = 0
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.")
	feedback_add_details("admin_verb","TRE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/send_fax_message()
	set name = "Send Fax Message"
	set category = "Special Verbs"

	if(!check_rights(R_ADMIN))
		return

	var/sent_text = sanitize(input(usr, "Please, enter the text you want to send.", "What?", "") as message|null, MAX_PAPER_MESSAGE_LEN, extra = FALSE)
	if(!sent_text)
		return

	var/sent_name = sanitize_safe(input(usr, "Pick a title for the message.", "Title") as text)
	if(!sent_name)
		sent_name = "NanoTrasen Update"
	if(sent_name == "Cancel")
		return

	var/list/departments = alldepartments.Copy()
	departments += "All"
	var/department = input(usr, "Please, choose the destination department.") as null|anything in departments
	if(!department)
		return

	var/list/stamp_list = list("CentComm", "Syndicate", "Clown", "FakeCentComm", "None")
	var/stamp_name = input(usr, "Please, choose the stamp you want to send with.") as null|anything in stamp_list
	if(!stamp_name)
		return

	var/stamp_type = null
	if(stamp_name != "None")
		stamp_type = text2path("/obj/item/weapon/stamp/[lowertext(stamp_name)]")

	var/stamp_text = null
	if(stamp_type)
		stamp_text = sanitize(input(usr, "Pick a message for stamp text (e.g. This paper has been stamped by the Central Compound Quantum Relay). In case of empty field there will be default stamp text.") as text)

	var/obj/item/weapon/paper/P = new
	P.name = sent_name
	var/parsed_text = parsebbcode(sent_text)
	parsed_text = replacetext(parsed_text, "\[nt\]", "<img src = bluentlogo.png />")
	P.info = parsed_text
	P.update_icon()

	if(stamp_type)
		var/obj/item/weapon/stamp/S = new stamp_type

		if(stamp_text)
			S.stamp_paper(P, stamp_text)
		else
			S.stamp_paper(P)

	send_fax(usr, P, department)

	add_communication_log(type = "fax-centcomm", title = sent_name, author = "Centcomm Officer", content = P.info + "\n" + P.stamp_text)

	feedback_add_details("admin_verb","FAXMESS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	message_admins("Fax message was created by [key_name_admin(usr)] and sent to [department]")
	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = ":fax: Fax message was created by **[key_name(usr)]** and sent to ***[department]***",
		attachment_msg = sent_text,
		attachment_color = BRIDGE_COLOR_ADMINCOM,
	)

/client/proc/add_player_age()
	set category = "Server"
	set name = "Increase player age"
	set desc = "Allow a new player to skip the job time restrictions."

	if(!check_rights(R_VAREDIT))
		return

	if(!config.use_ingame_minutes_restriction_for_jobs)
		return

	var/client/target = input("Select player to increase his in-game age to [config.add_player_age_value] minutes") as null|anything in clients

	if(!target)
		return

	if(!isnum(target.player_ingame_age))
		to_chat(src, "Player age not loaded yet.")
		return

	var/value = config.add_player_age_value
	if(check_rights(R_PERMISSIONS,0) && alert("As +PERMISSIONS user you can set custom value. Set custom?", "Custom age?", "Yes", "No") == "Yes")
		value = input("Enter custom in-game age value") as num|null

	if(!value)
		return

	if(target.player_ingame_age < value)
		notes_add(target.ckey, "PLAYERAGE: increased in-game age from [target.player_ingame_age] to [value]", src, secret = 0)

		log_admin("[key_name(usr)] increased [key_name(target)] in-game age from [target.player_ingame_age] to [value]")
		message_admins("[key_name_admin(usr)] increased [key_name_admin(target)] in-game age from [target.player_ingame_age] to [value]")

		target.player_ingame_age = value
	else
		to_chat(src, "This player already has more minutes than [value]!")

/client/proc/grand_guard_pass()
	set name = "Guard pass"
	set desc = "Allow a new player to skip the guard checks"

	if(!check_rights(R_VAREDIT))
		return

	if(!dbcon.IsConnected())
		return

	var/ckey = ckey(input("Enter player ckey") as null|text)

	if(!ckey)
		return

	var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET ingameage = '[GUARD_CHECK_AGE]' WHERE ckey = '[sanitize_sql(ckey)]' AND cast(ingameage as unsigned integer) < [GUARD_CHECK_AGE]")
	query_update.Execute()

	to_chat(src, "Guard pass granted (probably)")
	log_admin("GUARD: [key_name(usr)] granted to [ckey] guard pass ([GUARD_CHECK_AGE] minutes)")
	message_admins("GUARD: [key_name_admin(usr)] [key_name(usr)] granted to [ckey] guard pass ([GUARD_CHECK_AGE] minutes)")