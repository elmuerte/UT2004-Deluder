/*******************************************************************************
	TriadController, the AI for the triad token								<br />
																			<br />
	Creation date: 21/08/2004 13:48
	Copyright (c) 2004, Michiel "El Muerte" Hendriks						<br />
																			<br />
	This program is free software; you can redistribute and/or modify
	it under the terms of the Open Unreal Mod License.
	<!-- $Id: TriadController.uc,v 1.1 2004/09/02 08:33:57 elmuerte Exp $ -->
*******************************************************************************/

class TriadController extends ScriptedController;

/** the next target destination */
var protected NavigationPoint SafeDestination;

/** last and next navigation point, used for error correction */
var protected Actor NextNavPoint, LastNavPoint;

/** rate a destination point */
function float RateDestination(NavigationPoint N)
{
	local Controller OtherPlayer;
	local float score, NextDist;
	local int i;

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

/** find a safe destination away from all players */
function NavigationPoint FindSafeDestination()
{
	local int i;
	local float lastScore, bestScore;
	local NavigationPoint NewDest;

	for (i = 0; i < Deluder(Level.Game).NavPoints.length; i++)
	{
		if (SafeDestination == Deluder(Level.Game).NavPoints[i]) continue;

		lastScore = RateDestination(Deluder(Level.Game).NavPoints[i]);
		if (lastScore > bestScore)
		{
			bestScore = lastScore;
			NewDest = Deluder(Level.Game).NavPoints[i];
		}
	}
	log("FindSafeDestination"@NewDest@"score:"@bestScore, name);
	return NewDest;
}

/** if received more than X damage, find new safe destination */
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	Log("NotifyTakeHit"@Damage, name);
	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);
}

/** check navigation point, return true if the MoveToward should be performed */
function bool CheckNavPoint(Actor N)
{
	if (N == none)
	{
		GotoState('Roaming', 'FindNewDestination');
		return false;
	}
	if (NavigationPoint(N) != none)
	{
		if (NavigationPoint(N).bSpecialMove || NavigationPoint(N).bSpecialForced)
		{
			NavigationPoint(N).SuggestMovePreparation(Pawn);
		}
		if (AIMarker(N) != none)
		{
			//TOOD: broken
			log(N, name);
			AIMarker(N).markedScript.TakeOver(Pawn);
			GotoState('Scripting');
			return false;
		}
	}
	return actorReachable(N);
}

/** normal behavior, the triad picks a safe point and tries to move towards it */
auto state Roaming
{

FindNewDestination:
	WaitForLanding();
	NextNavPoint = none;
	SafeDestination = FindSafeDestination();
	log("New destination"@SafeDestination@SafeDestination.Location, name);
	while (!Pawn.ReachedDestination(SafeDestination))
	{
		if (NextNavPoint == SafeDestination) // failed to reach the destination
		{
			Warn("Unable to reach SafeDestination"@NextNavPoint);
			goto('FindNewDestination');
		}
		LastNavPoint = NextNavPoint;
		NextNavPoint = FindPathToward(SafeDestination);
		if (LastNavPoint == NextNavPoint)
		{
			Warn("LastNavPoint == NextNavPoint:"@LastNavPoint);
			goto('FindNewDestination'); // endless loop?
		}
		if (CheckNavPoint(NextNavPoint)) MoveToward(NextNavPoint, self);
ContinueMovement:
	}
	goto('FindNewDestination');

Begin:
	goto('FindNewDestination');
}

/** AIscript */
state Scripting
{
	function LeaveScripting()
	{
		GotoState('Roaming', 'ContinueMovement');
	}
}
