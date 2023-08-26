#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

#include maps\mp\gametypes\_gamelogic;

/*
	Plutonium IW6 Mapvote
	Developed by DoktorSAS
	Version: v1.0.0

	1.0.0:
	- 3 maps support
	- Credits, sentence and social on bottom left
*/

init()
{
	preCacheShader("gradient_fadein");
	preCacheShader("gradient");
	preCacheShader("white");
	preCacheShader("line_vertical");

	level thread onPlayerConnected();
	level thread mv_Config();

	level.startmapvote = ::startMapvote;
}

startMapvote()
{
	if (wasLastRound())
	{
		mv_Begin();
	}
}

mv_Config()
{
	SetDvarIfNotInizialized("mv_enable", 1);
	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return; // End if the mapvote its not enable

	level.__mapvote = [];
	SetDvarIfNotInizialized("mv_time", 20);
	level.__mapvote["time"] = getDvarInt("mv_time");
	SetDvarIfNotInizialized("mv_maps", "mp_convoy mp_backlot mp_bog mp_crash mp_crossfire mp_citystreets mp_farm mp_overgrown mp_shipment mp_vacant mp_broadcast mp_carentan mp_countdown mp_bloc mp_creek mp_killhouse mp_pipeline mp_strike mp_showdown mp_cargoship mp_crash_snow mp_farm_spring mp_bog_summer");

	SetDvarIfNotInizialized("mv_credits", 1);
	SetDvarIfNotInizialized("mv_socials", 1);
	SetDvarIfNotInizialized("mv_socialname", "Website");
	SetDvarIfNotInizialized("mv_sociallink", "^3h1.gg^7");
	SetDvarIfNotInizialized("mv_sentence", "Thanks for Playing by @DoktorSAS");
	SetDvarIfNotInizialized("mv_votecolor", "5");
	SetDvarIfNotInizialized("mv_blur", "3");
	SetDvarIfNotInizialized("mv_scrollcolor", "cyan");
	SetDvarIfNotInizialized("mv_selectcolor", "lightgreen");
	SetDvarIfNotInizialized("mv_backgroundcolor", "grey");
	SetDvarIfNotInizialized("mv_gametypes", "dm;dm.cfg war;war.cfg sd;sd.cfg");
	setDvarIfNotInizialized("mv_excludedmaps", "");
}

// Mapvote Logic
mv_Begin()
{
	level endon("mv_ended");

	if (getDvarInt("mv_enable") != 1) // Check if mapvote is enable
		return;						  // End if the mapvote its not enable

	if (!isDefined(level.mapvote_started))
	{
		level.mapvote_started = 1;

		mapsIDs = [];
		mapsIDs = strTok(getDvar("mv_maps"), " ");
		mapschoosed = mv_GetRandomMaps(mapsIDs);

		level.__mapvote["map1"] = spawnStruct();
		level.__mapvote["map2"] = spawnStruct();
		level.__mapvote["map3"] = spawnStruct();

		level.__mapvote["map1"].mapname = maptoname(mapschoosed[0]);
		level.__mapvote["map1"].mapid = mapschoosed[0];
		level.__mapvote["map2"].mapname = maptoname(mapschoosed[1]);
		level.__mapvote["map2"].mapid = mapschoosed[1];
		level.__mapvote["map3"].mapname = maptoname(mapschoosed[2]);
		level.__mapvote["map3"].mapid = mapschoosed[2];

		gametypes = strTok(getDvar("mv_gametypes"), " ");
		g1 = gametypes[randomIntRange(0, gametypes.size)];
		g2 = gametypes[randomIntRange(0, gametypes.size)];
		g3 = gametypes[randomIntRange(0, gametypes.size)];

		level.__mapvote["map1"].gametype = g1;
		level.__mapvote["map2"].gametype = g2;
		level.__mapvote["map3"].gametype = g3;

		foreach (player in level.players)
		{
			if (!is_bot(player))
				player thread mv_PlayerUI();
		}
		wait 0.2;
		level thread mv_ServerUI();

		mv_VoteManager();
	}
}

ArrayRemoveIndex(array, index)
{
	new_array = [];
	for (i = 0; i < array.size; i++)
	{
		if (i != index)
			new_array[new_array.size] = array[i];
	}
	array = new_array;
	return new_array;
}

mv_GetRandomMaps(mapsIDs) // Select random map from the list
{
	mapschoosed = [];
	for (i = 0; i < 3; i++)
	{
		index = randomIntRange(0, mapsIDs.size);
		map = mapsIDs[index];
		mapsIDs = ArrayRemoveIndex(mapsIDs, map);
		mapschoosed[i] = map;
	}

	return mapschoosed;
}

is_bot(entity) // Check if a players is a bot
{
	return isDefined(entity.pers["isBot"]) && entity.pers["isBot"];
}

mv_PlayerUI()
{
	// self endon("disconnect");
	level endon("game_ended");

	self SetBlurForPlayer(getDvarFloat("mv_blur"), 1.5);

	scroll_color = getColor(getDvar("mv_scrollcolor"));
	bg_color = getColor(getDvar("mv_backgroundcolor"));
	self freezeControlsWrapper(1);
	boxes = [];
	boxes[0] = self createRectangle("center", "center", -220, -452, 205, 133, scroll_color, "white", 1, .7);
	boxes[1] = self createRectangle("center", "center", 0, -452, 205, 133, bg_color, "white", 1, .7);
	boxes[2] = self createRectangle("center", "center", 220, -452, 205, 133, bg_color, "white", 1, .7);

	self thread mv_PlayerFixAngle();

	level waittill("mv_start_animation");

	boxes[0] affectElement("y", 1.2, -50);
	boxes[1] affectElement("y", 1.2, -50);
	boxes[2] affectElement("y", 1.2, -50);
	self thread destroyBoxes(boxes);

	self notifyonplayercommand("left", "+attack");
	self notifyonplayercommand("right", "+speed_throw");
	self notifyonplayercommand("left", "+moveright");
	self notifyonplayercommand("right", "+moveleft");
	self notifyonplayercommand("select", "+usereload");
	self notifyonplayercommand("select", "+activate");
	self notifyonplayercommand("select", "+gostand");

	self.statusicon = "veh_hud_target_chopperfly"; // Red dot
	level waittill("mv_start_vote");

	index = 0;
	isVoting = 1;
	while (level.__mapvote["time"] > 0 && isVoting)
	{
		command = self waittill_any_return("left", "right", "select", "done");
		if (command == "right")
		{
			index++;
			if (index == boxes.size)
				index = 0;
		}
		else if (command == "left")
		{
			index--;
			if (index < 0)
				index = boxes.size - 1;
		}

		if (command == "select")
		{
			self.statusicon = "compass_icon_vf_active"; // Green dot
			vote = "vote" + (index + 1);
			level notify(vote);
			select_color = getColor(getDvar("mv_selectcolor"));
			boxes[index] affectElement("color", 0.2, select_color);
			isVoting = 0;
		}
		else
		{
			for (i = 0; i < boxes.size; i++)
			{
				if (i != index)
					boxes[i] affectElement("color", 0.2, bg_color);
				else
					boxes[i] affectElement("color", 0.2, scroll_color);
			}
		}
	}
}

destroyBoxes(boxes)
{
	level endon("game_ended");
	level waittill("mv_destroy_hud");
	foreach (box in boxes)
	{
		box affectElement("alpha", 0.5, 0);
	}
}

mv_PlayerFixAngle()
{
	self endon("disconnect");
	level endon("game_ended");
	level waittill("mv_start_vote");
	angles = self getPlayerAngles();

	self waittill_any("left", "right");
	if (self getPlayerAngles() != angles)
		self setPlayerAngles(angles);
}

mv_VoteManager()
{
	level endon("game_ended");
	votes = [];
	votes[0] = spawnStruct();
	votes[0].votes = level createServerFontString("objective", 2);
	votes[0].votes setPoint("center", "center", -220 + 70, -325);
	votes[0].votes.label = &"^" + getDvar("mv_votecolor");
	votes[0].votes.sort = 4;
	votes[0].value = 0;
	votes[0].map = level.__mapvote["map1"];

	votes[1] = spawnStruct();
	votes[1].votes = level createServerFontString("objective", 2);
	votes[1].votes setPoint("center", "center", 0 + 70, -325);
	votes[1].votes.label = &"^" + getDvar("mv_votecolor");
	votes[1].votes.sort = 4;
	votes[1].value = 0;
	votes[1].map = level.__mapvote["map2"];

	votes[2] = spawnStruct();
	votes[2].votes = level createServerFontString("objective", 2);
	votes[2].votes setPoint("center", "center", 220 + 70, -325);
	votes[2].votes.label = &"^" + getDvar("mv_votecolor");
	votes[2].votes.sort = 4;
	votes[2].value = 0;
	votes[2].map = level.__mapvote["map3"];

	votes[0].votes setValue(0);
	votes[1].votes setValue(0);
	votes[2].votes setValue(0);

	votes[0].votes affectElement("y", 1, 0);
	votes[1].votes affectElement("y", 1, 0);
	votes[2].votes affectElement("y", 1, 0);

	votes[0].hideWhenInMenu = 1;
	votes[1].hideWhenInMenu = 1;
	votes[2].hideWhenInMenu = 1;

	isInVote = 1;
	index = 0;
	while (isInVote)
	{
		notify_value = level waittill_any_return("vote1", "vote2", "vote3", "mv_destroy_hud");

		if (notify_value == "mv_destroy_hud")
		{
			isInVote = 0;

			votes[0].votes affectElement("alpha", 0.5, 0);
			votes[1].votes affectElement("alpha", 0.5, 0);
			votes[2].votes affectElement("alpha", 0.5, 0);

			break;
		}
		else
		{
			switch (notify_value)
			{
			case "vote1":
				index = 0;
				break;
			case "vote2":
				index = 1;
				break;
			case "vote3":
				index = 2;
				break;
			}
			votes[index].value++;
			votes[index].votes setValue(votes[index].value);
		}
	}

	winner = mv_GetMostVotedMap(votes);
	map = winner.map;
	mv_SetRotation(map.mapid, map.gametype);

	wait 1.2;
}

mv_GetMostVotedMap(votes)
{
	winner = votes[0];
	for (i = 1; i < votes.size; i++)
	{
		if (isDefined(votes[i]) && votes[i].value > winner.value)
		{
			winner = votes[i];
		}
	}

	return winner;
}
mv_SetRotation(mapid, gametype)
{
	array = strTok(gametype, ";");
	str = "";
	if (array.size > 1)
	{
		str = "gametype " + array[0];
	}
	logPrint("mapvote//gametype//" + array[0] + "//executing//" + str + "\n");
	setdvar("g_gametype", array[0]);
	setdvar("sv_currentmaprotation", str + " map " + mapid);
	setdvar("sv_maprotationcurrent", str + " map " + mapid);
	setdvar("sv_maprotation", str + " map " + mapid);
	level notify("mv_ended");
}

mv_ServerUI()
{
	level endon("game_ended");

	buttons = level createServerFontString("objective", 1.6);
	buttons setText("^3[{+speed_throw}]              ^7Press ^3[{+gostand}] ^7or ^3[{+activate}] ^7to select              ^3[{+attack}]");
	buttons setPoint("center", "center", 0, 80);
	buttons.hideWhenInMenu = 0;

	mv_votecolor = getDvar("mv_votecolor");

	mapUI1 = level createString("^7" + level.__mapvote["map1"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map1"].gametype, ";")[0]), "objective", 1.1, "center", "center", -220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
	mapUI2 = level createString("^7" + level.__mapvote["map2"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map2"].gametype, ";")[0]), "objective", 1.1, "center", "center", 0, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);
	mapUI3 = level createString("^7" + level.__mapvote["map3"].mapname + "\n" + gametypeToName(strTok(level.__mapvote["map3"].gametype, ";")[0]), "objective", 1.1, "center", "center", 220, -325, (1, 1, 1), 1, (0, 0, 0), 0.5, 5, 1);

	mapUIBTXT1 = level createRectangle("center", "center", -220, 0, 205, 32, (1, 1, 1), "black", 3, 0, 1);
	mapUIBTXT2 = level createRectangle("center", "center", 0, 0, 205, 32, (1, 1, 1), "black", 3, 0, 1);
	mapUIBTXT3 = level createRectangle("center", "center", 220, 0, 205, 32, (1, 1, 1), "black", 3, 0, 1);

	level notify("mv_start_animation");
	mapUI1 affectElement("y", 1.2, -6);
	mapUI2 affectElement("y", 1.2, -6);
	mapUI3 affectElement("y", 1.2, -6);
	mapUIBTXT1 affectElement("alpha", 1.5, 0.8);
	mapUIBTXT2 affectElement("alpha", 1.5, 0.8);
	mapUIBTXT3 affectElement("alpha", 1.5, 0.8);

	/*mv_arrowcolor = GetColor(getDvar("mv_arrowcolor"));

	arrow_right = drawshader("arrow_left", 200, 290, 25, 25, mv_arrowcolor, 100, 2, "center", "center", 1);
	arrow_left = drawshader("arrow_right", -200, 290, 25, 25, mv_arrowcolor, 100, 2, "center", "center", 1);*/

	wait 1;
	level notify("mv_start_vote");

	mv_sentence = getDvar("mv_sentence");
	mv_socialname = getDvar("mv_socialname");
	mv_sociallink = getDvar("mv_sociallink");
	credits = level createServerFontString("objective", 1.2);
	credits setPoint("center", "center", -200, 180);
	credits setText(mv_sentence + "\nDeveloped by @^5DoktorSAS ^7\n" + mv_socialname + ": " + mv_sociallink);

	timer = level createServerFontString("objective", 2);
	timer setPoint("center", "center", 0, -140);
	timer setTimer(level.__mapvote["time"]);
	wait level.__mapvote["time"];
	level notify("mv_destroy_hud");

	credits affectElement("alpha", 0.5, 0);
	buttons affectElement("alpha", 0.5, 0);
	mapUI1 affectElement("alpha", 0.5, 0);
	mapUI2 affectElement("alpha", 0.5, 0);
	mapUI3 affectElement("alpha", 0.5, 0);
	mapUIBTXT1 affectElement("alpha", 0.5, 0);
	mapUIBTXT2 affectElement("alpha", 0.5, 0);
	mapUIBTXT3 affectElement("alpha", 0.5, 0);
	// arrow_right affectElement("alpha", 0.5, 0);
	// arrow_left affectElement("alpha", 0.5, 0);
	timer affectElement("alpha", 0.5, 0);

	foreach (player in level.players)
	{
		player notify("done");
		player SetBlurForPlayer(0, 0);
	}
}

onPlayerConnected()
{
	level endon("game_ended");
	for (;;)
	{
		level waittill("connected", player);
		player thread FixBlur();
	}
}
FixBlur() // Patch blur effect
{
	self endon("disconnect");
	level endon("game_ended");
	self waittill("spawned_player");
	self SetBlurForPlayer(0, 0);
}

main()
{
	// replacefunc do not work as intended once patched remove // in front of one of the next 2 lines

	replacefunc( maps\mp\gametypes\_gamelogic::waittillfinalkillcamdone, ::waittillfinalkillcamdone);
}
waittillfinalkillcamdone()
{
    if ( !isdefined( level.finalkillcam_winner ) )
        return 0;

    level waittill( "final_killcam_done" );
    if (waslastround())
    {
        [[level.startmapvote]]();
    }

    return 1;
}
// Utils
maptoname(mapid)
{
	mapid = tolower(mapid);
	if (mapid == "mp_convoy") return "Ambush";
    if (mapid == "mp_backlot") return "Backlot";
    if (mapid == "mp_bog") return "Bog";
    if (mapid == "mp_crash") return "Crash";
    if (mapid == "mp_crossfire") return "Crossfire";
    if (mapid == "mp_citystreets") return "District";
    if (mapid == "mp_farm") return "Downpour";
    if (mapid == "mp_overgrown") return "Overgrown";
    if (mapid == "mp_shipment") return "Shipment";
    if (mapid == "mp_vacant") return "Vacant";
    if (mapid == "mp_vlobby_room") return "Lobby Map";
    if (mapid == "mp_broadcast") return "Broadcast";
    if (mapid == "mp_carentan") return "Chinatown";
    if (mapid == "mp_countdown") return "Countdown";
    if (mapid == "mp_bloc") return "Bloc";
    if (mapid == "mp_creek") return "Creek";
    if (mapid == "mp_killhouse") return "Killhouse";
    if (mapid == "mp_pipeline") return "Pipeline";
    if (mapid == "mp_strike") return "Strike";
    if (mapid == "mp_showdown") return "Showdown";
    if (mapid == "mp_cargoship") return "Wet Work";
    if (mapid == "mp_crash_snow") return "Winter Crash";
    if (mapid == "mp_farm_spring") return "Day Break";
    if (mapid == "mp_bog_summer") return "Beach Bog";
    return mapid;
}
SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}
IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
}

gametypeToName(gametype)
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

	case "hq":
		return "Headquaters";

	case "koth":
		return "Hardpoint";

	case "oic":
		return "One in the chamber";

	case "oneflag":
		return "One-Flag CTF";

	case "sas":
		return "Sticks & Stones";

	case "shrp":
		return "Sharpshooter";
	}
	return "invalid";
}

// UI Utils
isValidColor(value)
{
	return value == "0" || value == "1" || value == "2" || value == "3" || value == "4" || value == "5" || value == "6" || value == "7";
}
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
CreateRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, islevel)
{
	if (isDefined(isLevel))
		boxElem = newhudelem();
	else
		boxElem = newclienthudelem(self);
	boxElem.elemType = "bar";
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

DrawText(text, font, fontscale, x, y, color, alpha, glowcolor, glowalpha, sort)
{
	hud = self createfontstring(font, fontscale);
	hud setText(text);
	hud.x = x;
	hud.y = y;
	hud.color = color;
	hud.alpha = alpha;
	hud.glowcolor = glowcolor;
	hud.glowalpha = glowalpha;
	hud.sort = sort;
	hud.alpha = alpha;
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
DrawShader(shader, x, y, width, height, color, alpha, sort, align, relative, isLevel)
{
	if (isDefined(isLevel))
		hud = newhudelem();
	else
		hud = newclienthudelem(self);
	hud.elemtype = "icon";
	hud.color = color;
	hud.alpha = alpha;
	hud.sort = sort;
	hud.children = [];
	if (isDefined(align))
		hud.align = align;
	if (isDefined(relative))
		hud.relative = relative;
	hud setparent(level.uiparent);
	hud.x = x;
	hud.y = y;
	hud setshader(shader, width, height);
	hud.hideWhenInMenu = 0;
	hud.archived = 0;
	return hud;
}
// UI Animations
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
