/*******************************************************************************
	Triad. This is the roving token players have to kill in the Deluder\Eluder
	gametypes.                                                              <br />
																			<br />
	Creation date: 21/08/2004 13:48
	Copyright (c) 2004, Michiel "El Muerte" Hendriks                        <br />
																			<br />
	This program is free software; you can redistribute and/or modify
	it under the terms of the Open Unreal Mod License.
	<!-- $Id: Triad.uc,v 1.3 2004/12/13 08:07:34 elmuerte Exp $ -->
*******************************************************************************/

class Triad extends Monster;

#EXEC OBJ LOAD FILE=Triad_M.ukx
#EXEC OBJ LOAD FILE=Traid_T.utx

/** rotation speed of the triad */
var() float RotSpeed;
/** current rotation */
var protected float TriadRot;

var protected bool bDead;

/** rotate our triad */
event Tick(float delta)
{
	local rotator r;
	super.Tick(delta);

	if (bDead) return;

	TriadRot += RotSpeed * delta;
	if (TriadRot > 65536) TriadRot = TriadRot-65536;
	r.Pitch = int(TriadRot);
	SetBoneRotation('Triad', r, 0);
}

simulated function PlayDirectionalHit(Vector HitLoc);

simulated function PlayDirectionalDeath(Vector HitLoc);

simulated function FootStepping(int Side);

state Dying
{
    function BeginState()
	{
	   bDead = true;
	   super.BeginState();
    }
}

defaultproperties
{
	ControllerClass=class'Deluder.TriadController'

	Mesh=Mesh'Triad_M.Triad_M'

	Skins(0)=texture'Traid_T.TriadTexture'
	Skins(1)=none

	DrawScale=0.6
	DrawScale3D=(X=0.33,Y=0.5,Z=0.33)

	CollisionHeight=30.0
	CollisionRadius=25.0
	PrePivot=(X=0,Y=0,Z=-30)

	RotSpeed=50000.f

	//TODO: tweak
	Health=1000
	HealthMax=1000

	//TODO: tweak
	JumpZ=450
	bCanDodge=true
	bCanDodgeDoubleJump=true
	bCanTeleport=true
	bCanWalkOffLedges=true
	bCanWallDodge=true

	//TODO: tweak
	/*
	GroundSpeed=660
	AirSpeed=440
	WaterSpeed=330
	*/

	MaxFallSpeed=2400.0

	GibGroupClass=class'xBotGibGroup'
    SoundGroupClass=class'xBotSoundGroup'
	AmbientSound=sound'machinery36'

	MovementAnims(0)=Spinny
	MovementAnims(1)=Spinny
	MovementAnims(2)=Spinny
	MovementAnims(3)=Spinny
	SwimAnims(0)=Spinny
	SwimAnims(1)=Spinny
	SwimAnims(2)=Spinny
	SwimAnims(3)=Spinny
	WalkAnims(0)=Spinny
	WalkAnims(1)=Spinny
	WalkAnims(2)=Spinny
	WalkAnims(3)=Spinny
	WallDodgeAnims(0)=Spinny
	WallDodgeAnims(1)=Spinny
	WallDodgeAnims(2)=Spinny
	WallDodgeAnims(3)=Spinny
	IdleWeaponAnim=Spinny
	IdleHeavyAnim=Spinny
	IdleRifleAnim=Spinny
	TurnRightAnim=Spinny
	TurnLeftAnim=Spinny
	CrouchAnims(0)=Spinny
	CrouchAnims(1)=Spinny
	CrouchAnims(2)=Spinny
	CrouchAnims(3)=Spinny
	CrouchTurnRightAnim=Spinny
	CrouchTurnLeftAnim=Spinny
	AirStillAnim=Spinny
	AirAnims(0)=Spinny
	AirAnims(1)=Spinny
	AirAnims(2)=Spinny
	AirAnims(3)=Spinny
	TakeoffStillAnim=Spinny
	TakeoffAnims(0)=Spinny
	TakeoffAnims(1)=Spinny
	TakeoffAnims(2)=Spinny
	TakeoffAnims(3)=Spinny
	LandAnims(0)=Spinny
	LandAnims(1)=Spinny
	LandAnims(2)=Spinny
	LandAnims(3)=Spinny
	DodgeAnims(0)=Spinny
	DodgeAnims(1)=Spinny
	DodgeAnims(2)=Spinny
	DodgeAnims(3)=Spinny
	DoubleJumpAnims(0)=Spinny
	DoubleJumpAnims(1)=Spinny
	DoubleJumpAnims(2)=Spinny
	DoubleJumpAnims(3)=Spinny
	IdleRestAnim=Spinny
	IdleCrouchAnim=Spinny
	IdleSwimAnim=Spinny
	IdleChatAnim=Spinny
	FireHeavyRapidAnim=Spinny
	FireHeavyBurstAnim=Spinny
	FireRifleRapidAnim=Spinny
	FireRifleBurstAnim=Spinny
}
