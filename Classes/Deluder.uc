/*******************************************************************************
	Deluder - Based on the Deluder gametype from Rise of the Triads			<br />
	This is a tribute to the Developers of Incredible Power (you know who
	you are)																<br />
	Some parts of this game type are "borrowed" from the invasion gametype. <br />
																			<br />
	Creation date: 21/08/2004 13:33											<br />
	Copyright (c) 2004, Michiel "El Muerte" Hendriks						<br />
																			<br />
	This program is free software; you can redistribute and/or modify
	it under the terms of the Open Unreal Mod License.
	<!-- $Id: Deluder.uc,v 1.1 2004/09/02 08:33:57 elmuerte Exp $ -->
*******************************************************************************/

class Deluder extends xTeamGame;

/** triad class to use */
var class<Triad> TriadClass;

/** number of triads allowed in the game */
var() config int NumTriads;
/** delay between spawning of the triads */
var() config float newTriadDelay;

/** number of triads needed */
var protected int needNewTriad;
/** next triad spawn time */
var protected float newTriadTime;

/**
	List with all the navigation points. Used by TriadController to find a new
	destination for the Triad
*/
var array< NavigationPoint > NavPoints;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	GameReplicationInfo.bNoTeamSkins = true;
	GameReplicationInfo.bForceNoPlayerLights = true;
	GameReplicationInfo.bNoTeamChanges = true;

	CreateNavPoints();
}

/** create and sort a list with navigation points */
function CreateNavPoints()
{
	local NavigationPoint n;
	for ( N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint )
	{
		NavPoints[NavPoints.length] = n;
	}
	log(NavPoints.length@"NavigationPoints");
	//TODO: sort
}

/** award score if Other is the triad */
function ScoreKill(Controller Killer, Controller Other)
{
	if (TriadController(Other) != none)
	{
		log("Triad killed. Waiting"@newTriadDelay@"seconds to respawn", name);
		needNewTriad = clamp(needNewTriad+1, 1, NumTriads);
		// only set delay if it wasn't been set yet
		if (Level.TimeSeconds > newTriadTime) newTriadTime = Level.TimeSeconds + newTriadDelay;
	}
}

/** force everybody to be on the same team. Team #1 is for the triads*/
function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	return Teams[0];
}

/** force everybody to be on the same team. */
function byte PickTeam(byte num, Controller C)
{
	return 0;
}

//TODO: spawn Deluder bot
//function Bot SpawnBot(optional string botName)

/**
	Rate whether player/monster should choose this NavigationPoint as its start.
	Copy from the Invasion gametype
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
    local float Score, NextDist;
    local int i;
    local Controller OtherPlayer;

	if ( (Team == 0) || ((Player !=None) && Player.bIsPlayer) )
		return Super.RatePlayerStart(N,Team,Player);

    if ( N.PhysicsVolume.bWaterVolume )
        return -10000000;

    //assess candidate
    if ( (SmallNavigationPoint(N) != None) && (PlayerStart(N) == None) )
		return -1;

    score = 0;
	i = 1;
	for ( OtherPlayer=Level.ControllerList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextController)
	{
		if ( OtherPlayer.Pawn != none && OtherPlayer != self)
		{
			NextDist = VSize(OtherPlayer.Pawn.Location - N.Location);
			score += NextDist / i; // create average score
			i++;
        }
    }
    return score;
}

/** spawn a triad */
function SpawnTriad()
{
	local NavigationPoint StartSpot;
	local Pawn NewTriad;

	StartSpot = FindPlayerStart(None,1);
	if ( StartSpot == None )
		return;

	NewTriad = Spawn(TriadClass,,,StartSpot.Location+(TriadClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
	if (NewTriad != none)
	{
		NewTriad.SetPhysics(PHYS_Falling); //otherwise the AI won't kick in, maybe move this to an other location in Triad?
		needNewTriad--;
		log("New triad"@NewTriad@"@"@NewTriad.location, name);
	}
}

/** main game code, will check for triads to spawn */
State MatchInProgress
{
	function BeginState()
	{
		Super.BeginState();
		needNewTriad = NumTriads;
	}

	/** check if new triads should be spawned */
	function Timer()
	{
		global.Timer();
		if (needNewTriad > 0)
		{
			if (Level.TimeSeconds > newTriadTime)
			{
				SpawnTriad();
				newTriadTime = Level.TimeSeconds + newTriadDelay;
			}
		}
	}
}

// more..

/** remove PlayInfo properties not used by this gametype */
static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ((PropertyName == "bBalanceTeams")
		|| (PropertyName == "bPlayersBalanceTeams")
		)
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

defaultproperties
{
	// TODO:
	ScreenShotName="UT2004Thumbnails.InvasionShots"

	GameName="Deluder"
	Acronym="DEL"
	MapPrefix="DM"
	Description="Score by destroying the roving token. But make sure others don't kill it before you."

	NumTriads=1
	newTriadDelay=5

	// TODO:
 	HUDType="Skaarjpack.HudInvasion"
	ScoreboardType="Skaarjpack.ScoreboardInvasion"

	//TeamAIType(0)=class'SkaarjPack.InvasionTeamAI'
	//TeamAIType(1)=class'SkaarjPack.InvasionTeamAI'

	//MutatorClass="Skaarjpack.InvasionMutator"
	//MapListType="Skaarjpack.MapListSkaarjInvasion"
	//DeathMessageClass=class'SkaarjPack.InvasionDeathMessage'
	//GameReplicationInfoClass=class'SkaarjPack.InvasionGameReplicationInfo'

	bForceNoPlayerLights=True

	TriadClass=class'Triad'
}
