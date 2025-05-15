#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include maps\mp\gametypes\_gamelogic;

/*
	Plutonium H1 & H2 Mapvote
	Developed by DoktorSAS
	Version: v1.1.1

	1.0.0:
	- 3 maps support
	- Credits, sentence and social on bottom left

	1.1.0:
	- Implemented mv_randomoption dvar that will not display which map and which gametype the last option will be (Random)
	- Implemented mv_minplayerstovote dvar to set the minimum number of players required to start the mapvote
	- Implemented mv_gametypes_norepeat that will enable or disable gametypes duplicate
	- Implemented mv_maps_norepeat that will enable or disable maps duplicate

	1.1.1:
	- Implemented mv_extended dvar that will allow to choose in between 6 maps
	- Solved issue https://github.com/DoktorSAS/H1Mapvote/issues/6
	- Improved design
	- Solved controller not working
*/

init()
{
	preCacheShader("gradient_fadein");
	preCacheShader("gradient");
	preCacheShader("white");
	preCacheShader("line_vertical");

	level thread onPlayerConnected();
	MapvoteConfig();
	waittillframeend;

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;
		times = 3;
		if(GetDvarInt("mv_extended") == 1)
		{
			times = 6;
		}
		gametypesIDsList = strTok(getDvar("mv_gametypes"), " ");
		gametypes = MapvoteChooseRandomGametypesSelection(gametypesIDsList, times);

		mapsIDsList = [];
		mapsIDsList = strTok(getDvar("mv_maps"), " ");
		mapschoosed = [];
		mapschoosed = MapvoteChooseRandomMapsSelection(mapsIDsList, times);

		level.mapvotedata["firstmap"] = spawnStruct();
		level.mapvotedata["secondmap"] = spawnStruct();
		level.mapvotedata["thirdmap"] = spawnStruct();
		level.mapvotedata["fourthmap"] = spawnStruct();
		level.mapvotedata["fifthmap"] = spawnStruct();
		level.mapvotedata["sixthmap"] = spawnStruct();

		level.mapvotedata["firstmap"].mapname = mapToDisplayName(mapschoosed[0]);
		level.mapvotedata["firstmap"].mapid = mapschoosed[0];
		level.mapvotedata["firstmap"].gametype = gametypes[0];
		level.mapvotedata["firstmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["firstmap"].gametype, ";")[0]);
		// level.mapvotedata["thirdmap"].loadscreen = mapidToLoadscreen(mapschoosed[0]);
		level.mapvotedata["secondmap"].mapname = mapToDisplayName(mapschoosed[1]);
		level.mapvotedata["secondmap"].mapid = mapschoosed[1];
		level.mapvotedata["secondmap"].gametype = gametypes[1];
		level.mapvotedata["secondmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["secondmap"].gametype, ";")[0]);
		// level.mapvotedata["thirdmap"].loadscreen = mapidToLoadscreen(mapschoosed[1]);
		level.mapvotedata["thirdmap"].mapname = mapToDisplayName(mapschoosed[2]);
		level.mapvotedata["thirdmap"].mapid = mapschoosed[2];
		level.mapvotedata["thirdmap"].gametype = gametypes[2];
		level.mapvotedata["thirdmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["thirdmap"].gametype, ";")[0]);
		// level.mapvotedata["thirdmap"].loadscreen = mapidToLoadscreen(mapschoosed[2]);

		// preCacheShader(level.mapvotedata["firstmap"].loadscreen);
		// preCacheShader(level.mapvotedata["secondmap"].loadscreen);
		// preCacheShader(level.mapvotedata["thirdmap"].loadscreen);

		if(GetDvarInt("mv_extended"))
		{
			level.mapvotedata["fourthmap"].mapname = mapToDisplayName(mapschoosed[3]);
			level.mapvotedata["fourthmap"].mapid = mapschoosed[3];
			level.mapvotedata["fourthmap"].gametype = gametypes[3];
			level.mapvotedata["fourthmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["fourthmap"].gametype, ";")[0]);
			// level.mapvotedata["fourthmap"].loadscreen = mapidToLoadscreen(mapschoosed[3]);
			level.mapvotedata["fifthmap"].mapname = mapToDisplayName(mapschoosed[4]);
			level.mapvotedata["fifthmap"].mapid = mapschoosed[4];
			level.mapvotedata["fifthmap"].gametype = gametypes[4];
			level.mapvotedata["fifthmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["fifthmap"].gametype, ";")[0]);
			// level.mapvotedata["fifthmap"].loadscreen = mapidToLoadscreen(mapschoosed[1]);
			level.mapvotedata["sixthmap"].mapname = mapToDisplayName(mapschoosed[5]);
			level.mapvotedata["sixthmap"].mapid = mapschoosed[5];
			level.mapvotedata["sixthmap"].gametype = gametypes[5];
			level.mapvotedata["sixthmap"].gametypename = gametypeToDisplayName(strTok(level.mapvotedata["sixthmap"].gametype, ";")[0]);
			// level.mapvotedata["sixthmap"].loadscreen = mapidToLoadscreen(mapschoosed[5]);
		}

		if (GetDvarInt("mv_randomoption") == 1)
		{
			if (GetDvarInt("mv_extended") == 1)
			{
				level.mapvotedata["sixthmap"].mapname = "Random";
				level.mapvotedata["sixthmap"].gametypename = "Random";
				level.mapvotedata["sixthmap"].loadscreen = "gradient";
			}
			else
			{
				level.mapvotedata["thirdmap"].mapname = "Random";
				level.mapvotedata["thirdmap"].gametypename = "Random";
				level.mapvotedata["thirdmap"].loadscreen = "gradient";
			}
		}

		level.CallMapvote = ::CallMapvote;
	}
}

main()
{
	replacefunc(maps\mp\gametypes\_gamelogic::waittillfinalkillcamdone, ::waittillfinalkillcamdone);
	if (getDvar("g_gametype") == "sd" || getDvar("g_gametype") == "sr")
	{
		replacefunc(maps\mp\gametypes\_damage::erasefinalkillcam, ::erasefinalkillcam);
	}
	// replacefunc(maps\mp\h2_killstreaks\_nuke::nukeDeath, ::nukeDeath); // uncomment this line if you play H2M and the nuke is a valid killstreaks
}

/*
nukeDeath() // uncomment this functiom if you play H2M and the nuke is a valid killstreaks
{
    level endon ( "nuke_cancelled" );

    level notify( "nuke_death" );

    maps\mp\gametypes\_hostmigration::waitTillHostMigrationDone();

    AmbientStop(1);

    foreach( player in level.players )
    {
        if ( isAlive( player ) )
            player thread maps\mp\gametypes\_damage::finishPlayerDamageWrapper( level.nukeInfo.player, level.nukeInfo.player, 999999, 0, "MOD_EXPLOSIVE", "nuke_mp", player.origin, player.origin, "none", 0, 0 );
    }

    level.postRoundTime = 10;

    nukeEndsGame = true;
        [[level.CallMapvote]]();
    if ( level.teamBased )
        thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.team, game["strings"]["nuclear_strike"], true );
    else
    {
        if ( isDefined( level.nukeInfo.player ) )
            thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo.player, game["strings"]["nuclear_strike"], true );
        else
            thread maps\mp\gametypes\_gamelogic::endGame( level.nukeInfo, game["strings"]["nuclear_strike"], true );
    }
}
*/

erasefinalkillcam()
{
	if (level.multiteambased)
	{
		for (var_0 = 0; var_0 < level.teamnamelist.size; var_0++)
		{
			level.finalkillcam_delay[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_victim[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_attacker[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_attackernum[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_killcamentityindex[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_killcamentitystarttime[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_sweapon[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_weaponindex[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_customindex[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_isalternate[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_deathtimeoffset[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_psoffsettime[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_timerecorded[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_timegameended[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_smeansofdeath[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_type[level.teamnamelist[var_0]] = undefined;
			level.finalkillcam_usestarttime[level.teamnamelist[var_0]] = undefined;
		}
	}
	else
	{
		level.finalkillcam_delay["axis"] = undefined;
		level.finalkillcam_victim["axis"] = undefined;
		level.finalkillcam_attacker["axis"] = undefined;
		level.finalkillcam_attackernum["axis"] = undefined;
		level.finalkillcam_killcamentityindex["axis"] = undefined;
		level.finalkillcam_killcamentitystarttime["axis"] = undefined;
		level.finalkillcam_sweapon["axis"] = undefined;
		level.finalkillcam_weaponindex["axis"] = undefined;
		level.finalkillcam_customindex["axis"] = undefined;
		level.finalkillcam_isalternate["axis"] = undefined;
		level.finalkillcam_deathtimeoffset["axis"] = undefined;
		level.finalkillcam_psoffsettime["axis"] = undefined;
		level.finalkillcam_timerecorded["axis"] = undefined;
		level.finalkillcam_timegameended["axis"] = undefined;
		level.finalkillcam_smeansofdeath["axis"] = undefined;
		level.finalkillcam_type["axis"] = undefined;
		level.finalkillcam_usestarttime["axis"] = undefined;
		level.finalkillcam_delay["allies"] = undefined;
		level.finalkillcam_victim["allies"] = undefined;
		level.finalkillcam_attacker["allies"] = undefined;
		level.finalkillcam_attackernum["allies"] = undefined;
		level.finalkillcam_killcamentityindex["allies"] = undefined;
		level.finalkillcam_killcamentitystarttime["allies"] = undefined;
		level.finalkillcam_sweapon["allies"] = undefined;
		level.finalkillcam_weaponindex["allies"] = undefined;
		level.finalkillcam_customindex["allies"] = undefined;
		level.finalkillcam_isalternate["allies"] = undefined;
		level.finalkillcam_deathtimeoffset["allies"] = undefined;
		level.finalkillcam_psoffsettime["allies"] = undefined;
		level.finalkillcam_timerecorded["allies"] = undefined;
		level.finalkillcam_timegameended["allies"] = undefined;
		level.finalkillcam_smeansofdeath["allies"] = undefined;
		level.finalkillcam_type["allies"] = undefined;
		level.finalkillcam_usestarttime["allies"] = undefined;
	}

	level.finalkillcam_delay["none"] = undefined;
	level.finalkillcam_victim["none"] = undefined;
	level.finalkillcam_attacker["none"] = undefined;
	level.finalkillcam_attackernum["none"] = undefined;
	level.finalkillcam_killcamentityindex["none"] = undefined;
	level.finalkillcam_killcamentitystarttime["none"] = undefined;
	level.finalkillcam_sweapon["none"] = undefined;
	level.finalkillcam_weaponindex["none"] = undefined;
	level.finalkillcam_customindex["none"] = undefined;
	level.finalkillcam_isalternate["none"] = undefined;
	level.finalkillcam_deathtimeoffset["none"] = undefined;
	level.finalkillcam_psoffsettime["none"] = undefined;
	level.finalkillcam_timerecorded["none"] = undefined;
	level.finalkillcam_timegameended["none"] = undefined;
	level.finalkillcam_smeansofdeath["none"] = undefined;
	level.finalkillcam_type["none"] = undefined;
	level.finalkillcam_usestarttime["none"] = undefined;
	level.finalkillcam_winner = undefined;
	//if (waslastround())
	//{
	//	[[level.CallMapvote]] ();
	//}
	if (waslastround())
	{
		ExecuteMapvote();
	}
}

waittillfinalkillcamdone()
{
	if (!isdefined(level.finalkillcam_winner))
	{
		if (waslastround())
		{
			ExecuteMapvote();
		}
		return 0;
	}
		

	level waittill("final_killcam_done");
	//if (waslastround())
	//{
	//	[[level.CallMapvote]] ();
	//}
	if (waslastround())
	{
		ExecuteMapvote();
	}
	

	return 1;
}

/**
 * This script handles the blur effect fix for players when they connect to the game.
 * It includes an event handler for player connection and a function to patch the blur effect.
 */

onPlayerConnected()
{
	level endon("game_ended");
	for (;;)
	{
		level waittill("connected", player);
		player thread FixBlur();
	}
}

/**
 * This function patches the blur effect for the player.
 * It waits for the player to spawn and then sets the blur values to 0.
 */
FixBlur()
{
	self endon("disconnect");
	level endon("game_ended");
	self waittill("spawned_player");
	//ExecuteMapvote(); // Its for tests!
	self SetBlurForPlayer(0, 0);
}

/*
 * Functions related to the mapvote funcitonality
 * Functions:
 *  - CallMapvote()
 *  - MapvoteConfig()
 *  - ExecuteMapvote()
 *  - MapvoteChooseRandomMapsSelection(mapsIDsList)
 *  - MapvotePlayerUI()
 *  - destroyBoxes(boxes)
 *  - MapvoteForceFixedAngle()
 *  - CreateVoteDisplay(x, y)
 *  - CreateVoteDisplayObject(x, y, map)
 *  - MapvoteHandler()
 *  - MapvoteGetMostVotedMap(votes)
 *  - MapvoteSetRotation(mapid, gametype)
 *  - MapvoteServerUI()
 *  - FixBlur()
 *  - mapToDisplayName(mapid)
 *  - mapidToLoadscreen(mapid)
 *  - gametypeToDisplayName(gametype)
 */

/**
 * Calls the map vote function if it is the last round.
 */
CallMapvote()
{
	if (wasLastRound())
	{
		ExecuteMapvote();
	}
}

/**
 * Configures the map vote settings.
 */
MapvoteConfig()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	level.mapvotedata = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.mapvotedata["time"] = getDvarInt("mv_time");

	SetDvarIfNotInizialized("mv_maps", "mp_convoy mp_backlot mp_bog mp_crash mp_crossfire mp_citystreets mp_farm mp_overgrown mp_shipment mp_vacant mp_broadcast mp_carentan mp_countdown mp_bloc mp_creek mp_killhouse mp_pipeline mp_strike mp_showdown mp_cargoship mp_crash_snow mp_farm_spring mp_bog_summer");
	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socialname", "Website");
	SetDvarIfNotInizialized("mv_sociallink", "^3h1.gg^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg war;war.cfg sd;sd.cfg dm;dm.cfg war;war.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_allowchangevote", 1);
	setDvarIfNotInizialized("mv_minplayerstovote", 1);
	setDvarIfNotInizialized("mv_maps_norepeat", 0);
	setDvarIfNotInizialized("mv_gametypes_norepeat", 0);
	setDvarIfNotInizialized("mv_randomoption", 1);
	setDvarIfNotInizialized("mv_extended", 1);
}

/**
 * Executes the map vote process.
 * This function checks if map voting is enabled and then displays the map vote UI to all players.
 * It also starts the map vote handler to handle player votes.
 */
ExecuteMapvote()
{
	level endon("mv_ended");

	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (_countPlayers() >= getDvarInt("mv_minplayerstovote"))
	{
		foreach (player in level.players)
		{
			if (!is_bot(player))
				player thread MapvotePlayerUI();
		}

		waittillframeend;

		level thread MapvoteServerUI();
		MapvoteHandler();
	}
}

/**
 * Removes a specified element from an array and returns a new array without the element.
 *
 * @param array The array from which to remove the element.
 * @param todelete The element to be removed from the array.
 * @return The new array without the specified element.
 */
ArrayRemoveElement(array, todelete)
{
	newarray = [];
	once = 0;
	for (i = 0; i < array.size; i++)
	{
		element = array[i];
		if (element == todelete && !once)
		{
			once = 1;
		}
		else
		{
			newarray[newarray.size] = element;
		}
	}
	return newarray;
}
/**
 * Selects random maps from the given list.
 *
 * @param mapsIDsList - The list of map IDs to choose from.
 * @param times - The number of maps to select.
 * @return An array containing the randomly selected maps.
 */
MapvoteChooseRandomMapsSelection(mapsIDsList, times) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, mapsIDsList.size);
		map = mapsIDsList[index];
		mapschoosed[i] = map;
		logprint("map;" + map + ";index;" + index + "\n");
		if (GetDvarInt("mv_maps_norepeat"))
		{
			mapsIDsList = ArrayRemoveElement(mapsIDsList, map);
		}
		// arrayremovevalue(mapsIDsList , map);
	}

	return mapschoosed;
}

/**
 * Selects random gametypes from the given list.
 *
 * @param gametypesIDsList - The list of gametypes IDs to choose from.
 * @param times - The number of maps to select.
 * @return An array containing the randomly selected maps.
 */
MapvoteChooseRandomGametypesSelection(gametypesIDsList, times) // Select random map from the list
{
	gametypeschoosed = [];
	_gametypesIDsList = gametypesIDsList;
	for (i = 0; i < times; i++)
	{
		index = randomIntRange(0, gametypesIDsList.size);
		gametype = gametypesIDsList[index];
		gametypeschoosed[i] = gametype;
		if (GetDvarInt("mv_gametypes_norepeat"))
		{
			gametypesIDsList = ArrayRemoveElement(gametypesIDsList, gametype);
			if(gametypesIDsList.size == 0)
			{
				gametypesIDsList = _gametypesIDsList;
			}
		}
		
		// arrayremovevalue(mapsIDsList , map);
	}

	return gametypeschoosed;
}

/**
 * Displays the map voting UI for players.
 *
 * This function creates three rectangles representing the map voting options.
 * It handles player input for navigating and selecting map options.
 * The selected map option is highlighted with a different color.
 * The function continues until the map voting time expires or the voting is disabled.
 */
MapvotePlayerUI()
{
	self endon("disconnect");
	level endon("game_ended");

	/**
	 * Sets the scroll color and background color based on the values of the "mv_scrollcolor" and "mv_backgroundcolor" dvars.
	 *
	 * @param scrollcolor The color for the scroll.
	 * @param bgcolor The background color.
	 */
	scrollcolor = getColor(getDvar("mv_scrollcolor"));
	bgcolor = getColor(getDvar("mv_backgroundcolor"));

	self SetBlurForPlayer(getDvarFloat("mv_blur"), 1.5);

	self notifyonplayercommand("left", "+attack");
	self notifyonplayercommand("left", "+rt");
	self notifyonplayercommand("left", "+r1");
	

	self notifyonplayercommand("right", "+speed_throw");
	self notifyonplayercommand("right", "+toggleads_throw");
	self notifyonplayercommand("right", "+lt");
	self notifyonplayercommand("right", "+l1");
	self notifyonplayercommand("right", "+ads");
	
	self notifyonplayercommand("select", "+usereload");
	self notifyonplayercommand("select", "+activate");
	self notifyonplayercommand("select", "+gostand");
	self notifyonplayercommand("select", "+use");
    self notifyonplayercommand("select", "+x");
    self notifyonplayercommand("select", "+reload");
	// self freezeControlsWrapper(1); // Could be the reason why controller stop working

	boxes = [];
	if(GetDvarInt("mv_extended"))
	{
		self notifyonplayercommand("left", "+actionslot 1");
    	self notifyonplayercommand("right", "+actionslot 2");
		self notifyonplayercommand("left", "+forward");
		self notifyonplayercommand("right", "+back");
		
		self.statusicon = "veh_hud_target_chopperfly"; // Red dot
		level waittill("mapvote_animate");
		level waittill("mapvote_start");

		index = 0;
		previuesindex = -1;
		voting = 1;

		box = self CreateRectangle("center", "center", level.mapvotedata["options"][index].x, level.mapvotedata["options"][index].y, 208, 34, scrollcolor, "white", 0, 1);
		box_selected = self CreateRectangle("center", "center", 0, -120, 208, 34, scrollcolor, "white", 0, 0);
		while (level.mapvotedata["time"] > 0 && voting)
		{
			command = self waittill_any_return("left", "right", "select", "mapvote_end");
			if (command == "mapvote_end")
			{
				box destroy();
				box_selected destroy();
				break;
			}
			else if (command == "right")
			{
				index++;
				if (index == level.mapvotedata["options"].size)
					index = 0;
				self playsound( "missile_locking" );
			}
			else if (command == "left")
			{
				index--;
				if (index < 0)
					index = level.mapvotedata["options"].size - 1;
				self playsound( "missile_locking" );
			}
			else if (command == "select")
			{
				self playsound( "player_refill_all_ammo" );
				box_selected setpoint("center", "center", level.mapvotedata["options"][index].x,  level.mapvotedata["options"][index].y);
				box_selected.alpha = 1;
				self.statusicon = "compass_icon_vf_active"; // Green dot
				if (previuesindex >= 0)
				{
					level notify("vote", previuesindex, -1);
				}
				waittillframeend; // DO NOT REMOVE THIS LINE: IF REMOVED IT WILL CAUSE THE SECOND NOTIFY TO FAIL
				level notify("vote", index, 1);
				previuesindex = index;

				select_color = getColor(getDvar("mv_selectcolor"));
				box_selected affectElement("color", 0.2, select_color);
				if (GetDvarInt("mv_allowchangevote", 1) == 0)
				{
					voting = 0;
				}
			}
			//setPoint("center", "center", 0, 120);
			//box affectElement("y", 0.2, level.mapvotedata["options"][index].y);
			box affectElement("alpha", 0.1, 0);
			wait 0.12;
			box setPoint("center", "center", 0, level.mapvotedata["options"][index].y);
			box affectElement("alpha", 0.1, 1);
			wait 0.12;
		}

		
	} 
	else {
		self notifyonplayercommand("left", "+moveleft");
		self notifyonplayercommand("right", "+moveright");
		self notifyonplayercommand("left", "+actionslot 3");
    	self notifyonplayercommand("right", "+actionslot 4");
		//boxes[0] = self CreateRectangle("center", "center", -220, -452, 206, 133, scrollcolor, "white", 1, 1);
		//boxes[1] = self CreateRectangle("center", "center", 0, -452, 206, 133, bgcolor, "white", 1, 1);
		//boxes[2] = self CreateRectangle("center", "center", 220, -452, 206, 133, bgcolor, "white", 1, 1);

		self thread MapvoteForceFixedAngle();

		level waittill("mapvote_animate");

		//boxes[0] affectElement("y", 1.2, -50);
		//boxes[1] affectElement("y", 1.2, -50);
		//boxes[2] affectElement("y", 1.2, -50);

		//self thread destroyBoxes(boxes);
		self.statusicon = "veh_hud_target_chopperfly"; // Red dot
		level waittill("mapvote_start");

		index = 0;
		previuesindex = -1;
		voting = 1;

		box = self CreateRectangle("center", "center", level.mapvotedata["options"][index].x, level.mapvotedata["options"][index].y, 208, 34, scrollcolor, "white", 0, 1);
		box_selected = self CreateRectangle("center", "center", 0, -120, 208, 34, scrollcolor, "white", 0, 0);
		while (level.mapvotedata["time"] > 0 && voting)
		{
			command = self waittill_any_return("left", "right", "select", "mapvote_end");
			if (command == "mapvote_end")
			{
				box destroy();
				box_selected destroy();
				break;
			}
			else if (command == "right")
			{
				index++;
				if (index == level.mapvotedata["options"].size)
					index = 0;
				self playsound( "missile_locking" );
			}
			else if (command == "left")
			{
				index--;
				if (index < 0)
					index = level.mapvotedata["options"].size - 1;
				self playsound( "missile_locking" );
			}
			if (command == "select")
			{
				self.statusicon = "compass_icon_vf_active"; // Green dot
				self playsound( "player_refill_all_ammo" );
				box_selected setpoint("center", "center", level.mapvotedata["options"][index].x,  level.mapvotedata["options"][index].y);
				box_selected.alpha = 1;
				if (previuesindex >= 0)
				{
					//select_color = getColor(getDvar("mv_selectcolor"));
					//boxes[previuesindex] affectElement("color", 0.2, bgcolor);
					level notify("vote", previuesindex, -1);
				}
				waittillframeend; // DO NOT REMOVE THIS LINE: IF REMOVED IT WILL CAUSE THE SECOND NOTIFY TO FAIL
				level notify("vote", index, 1);
				previuesindex = index;

				select_color = getColor(getDvar("mv_selectcolor"));
				//boxes[index] affectElement("color", 0.2, select_color);
				box_selected affectElement("color", 0.2, select_color);
				if (GetDvarInt("mv_allowchangevote", 1) == 0)
				{
					voting = 0;
				}
			}
			/*else
			{
				for (i = 0; i < boxes.size; i++)
				{
					if (i != index)
					{
						boxes[i] affectElement("color", 0.2, bgcolor);
					}
					else
					{
						boxes[i] affectElement("color", 0.2, scrollcolor);
					}
				}
			}*/

			box affectElement("alpha", 0.1, 0);
			wait 0.12;
			box setPoint("center", "center", level.mapvotedata["options"][index].x, level.mapvotedata["options"][index].y);
			box affectElement("alpha", 0.1, 1);
			wait 0.12;
		}
	}
	
}

/**
 * Function to destroy boxes.
 * @param boxes - An array of boxes to be destroyed.
 */
destroyBoxes(boxes)
{
	level endon("game_ended");
	level waittill("mapvote_end");
	for (i = 0; i < boxes.size; i++)
	{
		boxes[i] affectElement("alpha", 0.5, 0);
	}
	wait 0.5;
	for (i = 0; i < boxes.size; i++)
	{
		boxes[i] destroy();
	}
}

/**
 * Function to force fixed angle for players during map voting.
 * Players' angles are stored before the vote starts and restored if they try to change it during the vote.
 */
MapvoteForceFixedAngle()
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mapvote_start");

	// Store the initial angles of the player
	angles = self getPlayerAngles();

	self waittill_any("left", "right");

	// Check if the player's angles have changed
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

/**
 * Creates a vote display area at the specified coordinates.
 *
 * @param x The x-coordinate of the display area.
 * @param y The y-coordinate of the display area.
 * @return The created display area.
 */
CreateVoteDisplay(x, y)
{
	displayarea = createServerFontString("objective", 2);
	displayarea setPoint("center", "center", x, y);
	displayarea.label = &"^" + getDvar("mv_votecolor");
	displayarea.sort = 999;
	displayarea.alpha = 1;
	displayarea.hideWhenInMenu = 0;
	displayarea setValue(0);
	return displayarea;
}
/**
 * Creates a vote display object with the specified coordinates and map.
 *
 * @param x The x-coordinate of the display object.
 * @param y The y-coordinate of the display object.
 * @param map The map associated with the display object.
 * @return The created vote display object.
 */
CreateVoteDisplayObject(x, y, map)
{
	displayobject = spawnStruct();
	displayobject.displayarea = CreateVoteDisplay(x, y);
	displayobject.value = 0;
	displayobject.map = map;
	return displayobject;
}

/**
 * Handles the map voting process.
 */
MapvoteHandler()
{
	level endon("game_ended");
	votes = [];

	if(GetDvarInt("mv_extended"))
	{
		votes[0] = level CreateVoteDisplayObject(70, -120, level.mapvotedata["firstmap"]);
		votes[1] = level CreateVoteDisplayObject(70, -120 + 40, level.mapvotedata["secondmap"]);
		votes[2] = level CreateVoteDisplayObject(70, -120 + 80, level.mapvotedata["thirdmap"]);
		votes[3] = level CreateVoteDisplayObject(70, -120 + 120, level.mapvotedata["fourthmap"]);
		votes[4] = level CreateVoteDisplayObject(70, -120 + 160, level.mapvotedata["fifthmap"]);
		votes[5] = level CreateVoteDisplayObject(70, -120 + 200, level.mapvotedata["sixthmap"]);
		votes[0].alpha = 0;
		votes[1].alpha = 0;
		votes[2].alpha = 0;
		votes[3].alpha = 0;
		votes[4].alpha = 0;
		votes[5].alpha = 0;
		votes[0].displayarea affectElement("alpha", 1, 1);
		votes[1].displayarea affectElement("alpha", 1, 1);
		votes[2].displayarea affectElement("alpha", 1, 1);
		votes[3].displayarea affectElement("alpha", 1, 1);
		votes[4].displayarea affectElement("alpha", 1, 1);
		votes[5].displayarea affectElement("alpha", 1, 1);
	} 
	else 
	{
		votes[0] = level CreateVoteDisplayObject(-220 + 70, 0, level.mapvotedata["firstmap"]);
		votes[1] = level CreateVoteDisplayObject(0 + 70, 0, level.mapvotedata["secondmap"]);
		votes[2] = level CreateVoteDisplayObject(220 + 70, 0, level.mapvotedata["thirdmap"]);
		votes[0].alpha = 0;
		votes[1].alpha = 0;
		votes[2].alpha = 0;
		votes[0].displayarea affectElement("alpha", 1, 1);
		votes[1].displayarea affectElement("alpha", 1, 1);
		votes[2].displayarea affectElement("alpha", 1, 1);
	}

	voting = true;
	index = 0;
	while (voting)
	{
		/*
			The index represents the map ID voted while the value will be valued as 1 if it's a vote to add and
			will be set to 0 if it's a vote to remove.
		*/
		level waittill("vote", index, value);

		if (index == -1)
		{
			voting = false;

			for(i = 0; i < votes.size; i++)
			{
				votes[i].displayarea affectElement("alpha", 0.5, 0);
			}
			break;
		}
		else
		{
			votes[index].value += value;
			votes[index].displayarea setValue(votes[index].value);
		}
	}

	winner = MapvoteGetMostVotedMap(votes);
	map = winner.map;
	MapvoteSetRotation(map.mapid, map.gametype);

	for(i = 0; i < votes.size; i++)
	{
		votes[i].displayarea destroy();
	}
	wait 5;
}

/**
 * Returns the map with the highest number of votes.
 *
 * @param votes An array of vote objects.
 * @return The map object with the highest number of votes.
 */
MapvoteGetMostVotedMap(votes)
{
	winner = votes[0];
	for (i = 1; i < votes.size; i++)
	{
		if (isDefined(votes[i]) && votes[i].value > winner.value)
		{
			winner = votes[i];
		}
		else if(isDefined(votes[i]) && votes[i].value == winner.value) 
		{
			chance = RandomIntRange(0, 100);
			if(chance < 50) 
			{
				winner = votes[i];
			}
		}
	}

	return winner;
}

/**
 * Sets the map rotation for the map vote.
 *
 * @param mapid The ID of the map to be added to the rotation.
 * @param gametype The game type associated with the map.
 */
MapvoteSetRotation(mapid, gametype)
{
	str = "map " + mapid;
	if (isDefined(gametype))
	{
		array = strTok(gametype, ";");
		if (array.size > 1)
		{
			setdvar("g_gametype", array[0]);
			str = "gametype " + array[0] + " map " + mapid;
			// Debug logprint
			logprint("mapvote//gametype//" + array[0] + "//executing//" + str + "\n");
		}
		else
		{
			setdvar("g_gametype", gametype);
			// Debug logprint
			logprint("mapvote//gametype//" + gametype + "//executing//" + str + "\n");
		}
	}
	// Set the Dvars for map rotation

	setdvar("sv_currentmaprotation", str);
	setdvar("sv_maprotationcurrent", str);
	setdvar("sv_maprotation", str);

	// Notify that the map rotation has been set
	level notify("mv_ended");
}

/**
 * This function displays the map voting UI on the server.
 * It creates font strings and rectangles to display the map options and their corresponding game types.
 * It also sets up a timer for the map voting duration.
 * The function ends when the game ends or when the map voting time is up.
 * @remarks Make sure to set the necessary dvars for the map voting UI to work properly.
 */
MapvoteServerUI()
{
	// level endon("game_ended");

	buttons = level createServerFontString("objective", 1.6);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	
	
	buttons.hideWhenInMenu = 0;

	mv_votecolor = getDvar("mv_votecolor");
	mv_backgroundcolor = GetColor(getDvar("mv_backgroundcolor"));
	
	options = [];
	options_bg = [];
	if(GetDvarInt("mv_extended"))
	{
		buttons setText("^3[{+speed_throw}]^7   /   ^3[{+actionslot 1}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]^7   /   ^3[{+actionslot 2}]");
		buttons setPoint("center", "center", 0, 120);
		
		options_bg[0] = level CreateRectangle("center", "center", 0, -120, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);
		options_bg[1] = level CreateRectangle("center", "center", 0, -120 + 40, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);
		options_bg[2] = level CreateRectangle("center", "center", 0, -120 + 80, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);
		options_bg[3] = level CreateRectangle("center", "center", 0, -120 + 120, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);
		options_bg[4] = level CreateRectangle("center", "center", 0, -120 + 160, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);
		options_bg[5] = level CreateRectangle("center", "center", 0, -120 + 200, 206, 32, mv_backgroundcolor, "black", 998, 0, 1);

		options[0] = level CreateString("^7" + level.mapvotedata["firstmap"].mapname + "\n" + level.mapvotedata["firstmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[0].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		options[1] = level CreateString("^7" + level.mapvotedata["secondmap"].mapname + "\n" + level.mapvotedata["secondmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[1].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		options[2] = level CreateString("^7" + level.mapvotedata["thirdmap"].mapname + "\n" + level.mapvotedata["thirdmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[2].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		options[3] = level CreateString("^7" + level.mapvotedata["fourthmap"].mapname + "\n" + level.mapvotedata["fourthmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[3].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		options[4] = level CreateString("^7" + level.mapvotedata["fifthmap"].mapname + "\n" + level.mapvotedata["fifthmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[4].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		options[5] = level CreateString("^7" + level.mapvotedata["sixthmap"].mapname + "\n" + level.mapvotedata["sixthmap"].gametypename, "objective", 1.1, "LEFT", "CENTER", -90, options_bg[5].y - 7, (1, 1, 1), 1, (0, 0, 0), 0.5, 999, 1);
		level.mapvotedata["options"] = options_bg; // Used to move client HUD for selection
	}
	else 
	{
		buttons setText("^3[{+speed_throw}]^7   /   ^3[{+actionslot 3}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]^7   /   ^3[{+actionslot 4}]");
		buttons setPoint("center", "center", 0, 80);
		options[0] = level CreateString("^7" + level.mapvotedata["firstmap"].mapname + "\n" + level.mapvotedata["firstmap"].gametypename, "objective", 1.1, "center", "center", -220, -6, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
		options[1] = level CreateString("^7" + level.mapvotedata["secondmap"].mapname + "\n" + level.mapvotedata["secondmap"].gametypename, "objective", 1.1, "center", "center", 0, -6, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
		options[2] = level CreateString("^7" + level.mapvotedata["thirdmap"].mapname + "\n" + level.mapvotedata["thirdmap"].gametypename, "objective", 1.1, "center", "center", 220, -6, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);

		options_bg[0] = level CreateRectangle("center", "center", -220, 0, 206, 32, (1, 1, 1), "black", 3, 0, 1);
		options_bg[1] = level CreateRectangle("center", "center", 0, 0, 206, 32, (1, 1, 1), "black", 3, 0, 1);
		options_bg[2] = level CreateRectangle("center", "center", 220, 0, 206, 32, (1, 1, 1), "black", 3, 0, 1);
		level.mapvotedata["options"] = options_bg; // Used to move client HUD for selection
	}
	
	level notify("mapvote_animate");

	mv_sentence = getDvar("mv_sentence");
	mv_socialname = getDvar("mv_socialname");
	mv_sociallink = getDvar("mv_sociallink");
	credits = level createServerFontString("objective", 1.2);
	credits setPoint("center", "center", -200, 180);
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);

	for(i = 0; i < options.size; i++)
	{
		//if(!GetDvarInt("mv_extended"))
		//	options[i] affectElement("y", 1.2, -6);
		options_bg[i] affectElement("alpha", 1.5, 0.9);
	}

	wait 1;
	level notify("mapvote_start");

	timer = level createServerFontString("objective", 2);
	if(GetDvarInt("mv_extended"))
	{
		timer setPoint("center", "center", 0, -180);
	} 
	else 
	{
		timer setPoint("center", "center", 0, -140);
	}
	
	timer setTimer(level.mapvotedata["time"]);
	wait level.mapvotedata["time"];

	for(i = 0; i < options.size; i++)
	{
		options[i] affectElement("alpha", 0.5, 0);
		options_bg[i] affectElement("alpha", 0.5, 0);
	}

	timer affectElement("alpha", 0.5, 0);
	buttons affectElement("alpha", 0.5, 0);
	credits affectElement("alpha", 0.5, 0);

	foreach (player in level.players)
	{
		player notify("mapvote_end");
		player SetBlurForPlayer(0, 0);
	}

	wait 0.5;

	level notify("mapvote_end");
	level notify("vote", -1);

	timer destroy();
	buttons destroy();
	credits destroy();
	for(i = 0; i < options.size; i++)
	{
		options[i] destroy();
		options_bg[i] destroy();
	}

}

// Utils

_countPlayers()
{
	count = 0;
	foreach (player in level.players)
	{
		if (!is_bot(player))
		{
			count++;
		}
	}
	return count;
}

/**
 * Removes an element from an array by its index.
 *
 * @param array The array from which to remove the element.
 * @param index The index of the element to be removed.
 * @return The modified array with the element removed.
 */
ArrayRemoveByIndex(array, index)
{
	size = array.size;

	for (i = index; i < array.size - 1; i++)
	{
		array[i] = array[i + 1];
	}
	array[size] = undefined;
	return array;
}

/**
 * Converts a map ID to its corresponding display name.
 *
 * @param {string} mapid - The map ID to convert.
 * @returns {string} - The display name of the map.
 */
mapToDisplayName(mapid)
{
	mapid = tolower(mapid);
	switch (mapid)
	{
	case "mp_convoy":
		return "Ambush";
	case "mp_backlot":
		return "Backlot";
	case "mp_bog":
		return "Bog";
	case "mp_crash":
		return "Crash";
	case "mp_crossfire":
		return "Crossfire";
	case "mp_citystreets":
		return "District";
	case "mp_farm":
		return "Downpour";
	case "mp_overgrown":
		return "Overgrown";
	case "mp_shipment":
		return "Shipment";
	case "mp_vacant":
		return "Vacant";
	case "mp_vlobby_room":
		return "Lobby Map";
	case "mp_broadcast":
		return "Broadcast";
	case "mp_carentan":
		return "Chinatown";
	case "mp_countdown":
		return "Countdown";
	case "mp_bloc":
		return "Bloc";
	case "mp_creek":
		return "Creek";
	case "mp_killhouse":
		return "Killhouse";
	case "mp_pipeline":
		return "Pipeline";
	case "mp_strike":
		return "Strike";
	case "mp_showdown":
		return "Showdown";
	case "mp_cargoship":
		return "Wet Work";
	case "mp_crash_snow":
		return "Winter Crash";
	case "mp_farm_spring":
		return "Day Break";
	case "mp_bog_summer":
		return "Beach Bog";
	case "mp_rundown":
		return "Rundown";
	// H2M
	case "airport":
		return "Airport";
	case "cliffhanger":
		return "Blizzard";
	case "contingency":
		return "Contingency";
	case "dcburning":
		return "DC Burning";
	case "boneyard":
		return "Dumpsite";
	case "gulag":
		return "Gulag";
	case "oilrig":
		return "Oilrig";
	case "estate":
		return "Safehouse";
	case "dc_whitehouse":
		return "Whiskey Hotel";
	case "mp_afghan":
		return "Afghan";
	case "mp_derail":
		return "Derail";
	case "mp_estate":
		return "Estate";
	case "mp_favela":
		return "Favela";
	case "mp_highrise":
		return "Highrise";
	case "mp_invasion":
		return "Invasion";
	case "mp_checkpoint":
		return "Karachi";
	case "mp_quarry":
		return "Quarry";
	case "mp_rust":
		return "Rust";
	case "mp_boneyard":
		return "Scrapyard";
	case "mp_nightshift":
		return "Skidrow";
	case "mp_subbase":
		return "Sub Base";
	case "mp_terminal":
		return "Terminal";
	case "mp_underpass":
		return "Underpass";
	case "mp_brecourt":
		return "Wasteland";
	case "mp_complex":
		return "Bailout";
	case "mp_compact":
		return "Salvage";
	case "mp_storm":
		return "Storm";
	case "mp_abandon":
		return "Carnival";
	case "mp_fuel2":
		return "Fuel";
	case "mp_trailerpark":
		return "Trailer Park";
	case "mp_bootleg":
		return "Bootleg";
	case "mp_dome":
		return "Dome";
	case "mp_lambeth":
		return "Fallen";
	case "mp_hardhat":
		return "Hardhat";
	case "mp_alpha":
		return "Lockdown";
	case "mp_bravo":
		return "Mission";
	case "mp_paris":
		return "Resistance ";
	case "mp_underground":
		return "Underground";
	case "mp_courtyard_ss":
		return "Erosion";
	default:
		return mapid;
	}
}

/**
 * Returns the loadscreen name for a given map ID.
 * @param {string} mapid - The map ID.
 * @returns {string} - The loadscreen name for the map.
 */
mapidToLoadscreen(mapid)
{
	mapid = tolower(mapid);
	return "loadscreen_" + mapid;

	/*
		If there are maps that have unconventional file names, use an if case and change the return value to the appropriate one.

		if (mapid == "mp_convoy") return "loadscreen_mp_convoy";
		if (mapid == "mp_backlot") return "loadscreen_mp_backlot";
		if (mapid == "mp_bog") return "loadscreen_mp_bog";
		if (mapid == "mp_crash") return "loadscreen_mp_crash";
		if (mapid == "mp_crossfire") return "loadscreen_mp_crossfire";
		if (mapid == "mp_citystreets") return "loadscreen_mp_citystreets";
		if (mapid == "mp_farm") return "loadscreen_mp_farm";
		if (mapid == "mp_overgrown") return "loadscreen_mp_overgrown";
		if (mapid == "mp_shipment") return "loadscreen_mp_shipment";
		if (mapid == "mp_vacant") return "loadscreen_mp_vacant";
		if (mapid == "mp_vlobby_room") return "loadscreen_mp_vlobby_room";
		if (mapid == "mp_broadcast") return "loadscreen_mp_broadcast";
		if (mapid == "mp_carentan") return "loadscreen_mp_carentan";
		if (mapid == "mp_countdown") return "loadscreen_mp_countdown";
		if (mapid == "mp_bloc") return "loadscreen_mp_bloc";
		if (mapid == "mp_creek") return "loadscreen_mp_creek";
		if (mapid == "mp_killhouse") return "loadscreen_mp_killhouse";
		if (mapid == "mp_pipeline") return "loadscreen_mp_pipeline";
		if (mapid == "mp_strike") return "loadscreen_mp_strike";
		if (mapid == "mp_showdown") return "loadscreen_mp_showdown";
		if (mapid == "mp_cargoship") return "loadscreen_mp_cargoship";
		if (mapid == "mp_crash_snow") return "loadscreen_mp_crash_snow";
		if (mapid == "mp_farm_spring") return "loadscreen_mp_farm_spring";
		if (mapid == "mp_bog_summer") return "loadscreen_mp_bog_summer";
	*/
	return mapid;
}
/**
 * Sets the value of a dvar if it is not already initialized.
 *
 * @param dvar The name of the dvar.
 * @param value The value to set the dvar to.
 */
SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}

/**
 * Checks if a dvar is initialized.
 *
 * @param dvar The name of the dvar.
 * @returns True if the dvar is initialized, false otherwise.
 */
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

/**
 * Converts a game type abbreviation to its corresponding display name.
 *
 * @param {string} gametype - The game type abbreviation.
 * @returns {string} - The display name of the game type.
 */
gametypeToDisplayName(gametype)
{
	switch (tolower(gametype))
	{
	case "dm":
		return "Free for all";
	case "war":
		return "Team Deathmatch";
	case "sd":
		return "Search & Destroy";
	case "conf":
		return "Kill Confirmed";
	case "ctf":
		return "Capture the Flag";
	case "dom":
		return "Domination";
	case "dem":
		return "Demolition";
	case "gun":
		return "Gun Game";
	case "koth":
		return "Headquarters";
	case "hp":
		return "Hardpoint";
	case "oic":
		return "One in the chamber";
	case "oneflag":
		return "One-Flag CTF";
	case "sas":
		return "Sticks & Stones";
	case "shrp":
		return "Sharpshooter";
	case "infect":
        return "Infected";
	}
	return "invalid";
}

/**
 * Checks if a player is a bot.
 *
 * @param entity The player entity to check.
 * @returns True if the player is a bot, false otherwise.
 */
is_bot(entity)
{
	return isDefined(entity.pers["isBot"]) && entity.pers["isBot"];
}

/*
 *	Functions to create/manage HUD and UI elements/objects/structures/components
 *	Functions:
 *		- CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel)
 *		- CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, islevel)
 *		- CreateImage(align, relative, x, y, width, height, image, sort, alpha, islevel)
 *		- ValidateColor(value)
 *		- GetColor(color)

*/

/**
 * Validates a color value.
 *
 * @param value - The color value to validate.
 * @returns True if the value is a valid color (0-7), false otherwise.
 */
ValidateColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}

/**
 * GetColor function returns the RGB values of a given color name.
 *
 * @param {string} color - The name of the color.
 * @returns {array} - An array containing the RGB values of the color.
 */
GetColor(color)
{
	switch (tolower(color))
	{
	case "red":
		return (0.960, 0.180, 0.180);

	case "black":
		return (0, 0, 0);

	case "grey":
		return (0.035, 0.059, 0.063);

	case "purple":
		return (1, 0.282, 1);

	case "pink":
		return (1, 0.623, 0.811);

	case "green":
		return (0, 0.69, 0.15);

	case "blue":
		return (0, 0, 1);

	case "lightblue":
	case "light blue":
		return (0.152, 0329, 0.929);

	case "lightgreen":
	case "light green":
		return (0.09, 1, 0.09);

	case "orange":
		return (1, 0662, 0.035);

	case "yellow":
		return (0.968, 0.992, 0.043);

	case "brown":
		return (0.501, 0.250, 0);

	case "cyan":
		return (0, 1, 1);

	case "white":
		return (1, 1, 1);
	}
}

/**
 * Creates a font string with the specified properties.
 *
 * @param {string} input - The text to be displayed.
 * @param {string} font - The font to be used.
 * @param {float} fontScale - The scale of the font.
 * @param {int} align - The alignment of the text.
 * @param {int} relative - The relative position of the text.
 * @param {float} x - The x-coordinate of the text.
 * @param {float} y - The y-coordinate of the text.
 * @param {vector} color - The color of the text.
 * @param {float} alpha - The transparency of the text.
 * @param {vector} glowColor - The color of the text glow.
 * @param {float} glowAlpha - The transparency of the text glow.
 * @param {int} sort - The sorting order of the text.
 * @param {bool} isLevel - Indicates if the font string is created at the level or entity scope.
 * @returns {hud} The created font string.
 */
CreateString(input, font, fontScale, align, relative, x, y, color, alpha, glowColor, glowAlpha, sort, isLevel)
{
	if (!isDefined(isLevel))
		hud = self createFontString(font, fontScale);
	else
		hud = level createServerFontString(font, fontScale);

	hud setText(input);

	hud.x = x;
	hud.y = y;
	hud.align = align;
	hud.horzalign = align;
	hud.vertalign = relative;
	hud setPoint(align, relative, x, y);
	hud.color = color;
	hud.alpha = alpha;
	hud.glowColor = glowColor;
	hud.glowAlpha = glowAlpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.archived = 0;
	hud.hideWhenInMenu = 0;
	return hud;
}

/**
 * Creates a rectangle HUD element.
 *
 * @param {string} align - The alignment of the rectangle.
 * @param {bool} relative - Whether the position is relative to the parent element.
 * @param {float} x - The x-coordinate of the rectangle.
 * @param {float} y - The y-coordinate of the rectangle.
 * @param {float} width - The width of the rectangle.
 * @param {float} height - The height of the rectangle.
 * @param {vector} color - The color of the rectangle.
 * @param {string} shader - The shader applied to the rectangle.
 * @param {int} sort - The sorting order of the rectangle.
 * @param {float} alpha - The transparency of the rectangle.
 * @param {bool} isLevel - Whether the rectangle is a level element.
 * @returns {hudelem} The created rectangle HUD element.
 */
CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, islevel)
{
	if (isDefined(isLevel))
		boxElem = newhudelem();
	else
		boxElem = newclienthudelem(self);
	boxElem.elemType = "bar_shader";
	boxElem.width = width;
	boxElem.height = height;
	boxElem.align = align;
	boxElem.relative = relative;
	boxElem.horzalign = align;
	boxElem.vertalign = relative;
	boxElem.xOffset = 0;
	boxElem.yOffset = 0;
	boxElem.children = [];
	boxElem.sort = sort;
	boxElem.color = color;
	boxElem.alpha = alpha;
	boxElem setParent(level.uiParent);
	boxElem setShader(shader, width, height);
	boxElem.hidden = 0;
	boxElem setPoint(align, relative, x, y);
	boxElem.hideWhenInMenu = 0;
	boxElem.archived = 0;
	return boxElem;
}

/**
 * A function that applies an effect to an element over a specified time.
 * @param {string} type - The type of effect to apply ("x", "y", "alpha", "color").
 * @param {number} time - The duration of the effect in milliseconds.
 * @param {number} value - The value to set for the effect.
 */
affectElement(type, time, value)
{
	if (type == "x" || type == "y")
		self moveOverTime(time);
	else
		self fadeOverTime(time);
	if (type == "x")
		self.x = value;
	if (type == "y")
		self.y = value;
	if (type == "alpha")
		self.alpha = value;
	if (type == "color")
		self.color = value;
}
