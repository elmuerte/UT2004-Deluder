/*******************************************************************************
    TriadController, the AI for the triad token                             <br />
                                                                            <br />
    Creation date: 21/08/2004 13:48
    Copyright (c) 2004, Michiel "El Muerte" Hendriks                        <br />
                                                                            <br />
    This program is free software; you can redistribute and/or modify
    it under the terms of the Open Unreal Mod License.
    <!-- $Id: TriadController.uc,v 1.3 2004/10/20 14:05:29 elmuerte Exp $ -->
*******************************************************************************/

class TriadController extends ScriptedController;

/** the next target destination */
var protected NavigationPoint SafeDestination;

/** last and next navigation point, used for error correction */
var protected Actor NextNavPoint, LastNavPoint;

/** last destination selection */
var protected float LastDestUpdate;

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
    if (score > 2000) score *= -1; // too far away
    score += score*(0.33*frand()-0.16);
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
    if (NavigationPoint(N) != none)
    {
        if (NavigationPoint(N).bSpecialMove || NavigationPoint(N).bSpecialForced)
        {
            NavigationPoint(N).SuggestMovePreparation(Pawn);
        }
    }
    return actorReachable(N);
}

/** normal behavior, the triad picks a safe point and tries to move towards it */
auto state Roaming
{
    /** if got hit, find next path node, to correct a possible mistake */
    function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
    {
        global.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);
        if ((Damage > 10) && (LastDestUpdate < Level.TimeSeconds-2 )) GotoState('Roaming', 'FindNewDestination');
        else GotoState('Roaming', 'ContinueMovement');
    }

FindNewDestination:
    WaitForLanding();
    NextNavPoint = none;
    LastDestUpdate = Level.TimeSeconds;
    if (LastDestUpdate < Level.TimeSeconds-2 ) sleep(1);
    SafeDestination = FindSafeDestination();
    log("New destination"@SafeDestination@SafeDestination.Location, name);

    while (!Pawn.ReachedDestination(SafeDestination) && (LastDestUpdate > Level.TimeSeconds-10 ))
    {
        if (NextNavPoint == SafeDestination) // failed to reach the destination
        {
            Warn("Unable to reach SafeDestination"@NextNavPoint);
            break;
        }
        LastNavPoint = NextNavPoint;
        NextNavPoint = FindPathToward(SafeDestination);
        if (NextNavPoint == none)
        {
            Warn("NextNavPoint == none");
            break;
        }
        if (LastNavPoint == NextNavPoint)
        {
            Warn("LastNavPoint == NextNavPoint:"@LastNavPoint);
            break;
        }
        if (CheckNavPoint(NextNavPoint)) MoveToward(NextNavPoint, self);
ContinueMovement:
    }
    goto('FindNewDestination');

Begin:
    goto('FindNewDestination');
}
