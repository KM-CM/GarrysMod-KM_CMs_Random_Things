/*If Defined, will Prevent Execution of All Other Behaviour Functions. Made for People Who Know What They're Doing.
But Not `FoundEnemy` and Not The Base's Internal Functions, as They are Not Behaviour Functions.*/
//function ENT:Behaviour() end

//Purely Informational!
ENT.flTopSpeed = 0
ENT.flTopSpeedCrouch = 0

/*A_ction Functions. These are Used by The Base to Translate an Action.
In Simple Words, if You have a Custom Movement Function, for Example
Helicopter Motion, Then You can Put It Here, and The Base will Use It!

You should Override These for Your Custom Actors.

T H E  N A M E  I S  N O T  A  D O O M  R E F E R E N C E

I Mean, Actually, It Kinda is*/

//ENT.dLastMotion = nil

/*flHeight is Basically a Crouch Multiplier. 1 = Standing ( vHullMaxs.z ), 0 = Crouching ( vHullDuckMaxs.z )
Dont Forget That if You cant Move While Crouching, You can Just Ignore That Parameter.
flSpeed is Self-Describing - a Speed Multiplier. 1 = Top ( Running ), 0 = Standing ( Const 0 )

Always Override This and A_CombatMovePath!*/
function ENT:A_CombatMove( dir, flSpeed, flHeight, bAim, tFilter )
	if !self.bNoPhysics then return end
	local odir = dir
	dir, flHeight = self:AddMovementMixins( dir, flHeight, tFilter )
	if !dir || !flHeight then return end
	self.dLastMotion = dir
	self.loco:Approach( self:GetPos() + dir, 1 )
end
function ENT:A_CombatMovePath( Path, flSpeed, flHeight, bAim, tFilter, flTargetSequence )
	if istable( Path ) then
		flSpeed = Path.flSpeed
		flHeight = Path.flHeight
		bAim = Path.bAim
		tFilter = Path.tFilter
		flTargetSequence = Path.flTargetSequence
		Path = Path.Path
	end
	local goal = Path:GetCurrentGoal()
	if !goal then Path:Update( self ) return end
	self.dLastMotion = ( goal.pos - self:GetPos() ):GetNormalized()
	if goal.ladder != nil && goal.type == 2 && self.bCanClimbUp then
		self:ClimbUp( goal )
		return
	elseif goal.ladder != nil && goal.type != 2 && self.bCanClimbDown then
		self:ClimbDown( goal )
		return
	else
		if goal.type == 2 || goal.type == 3 then self:Jump( goal ) end
	end
	if self.MoveBlendMotor then
		if flTargetSequence then self.MoveBlendMotor:SetSecondarySequence( flTargetSequence ) end
		self.MoveBlendMotor:SetRatioTarget( 1 - clamp( #GetVelocity( self ) / ( self.flTopSpeed * flSpeed ), 0, 1 ) )
		//self.MoveBlendMotor:SetRatioTarget( 1 - clamp( abs( Path:GetLength() - Path:GetCursorPosition() ) / self.flTopSpeed, 0, 1 ) )
	end
	self:A_CombatMove( ( goal.pos - self:GetPos() ):GetNormalized(), flSpeed, flHeight, bAim, tFilter )
	Path:Update( self )
end
//See A_CombatMoveStraight for Quirks of flSpeed
function ENT:A_CombatMovePathSlow( Path, flSpeed, flHeight, bAim, tFilter, flTargetSequence )
	if istable( Path ) then
		flSpeed = Path.flSpeed
		flHeight = Path.flHeight
		bAim = Path.bAim
		tFilter = Path.tFilter
		flTargetSequence = Path.flTargetSequence
		Path = Path.Path
	end
	local goal = Path:GetCurrentGoal()
	if !goal then Path:Update( self ) return end
	self.dLastMotion = ( goal.pos - self:GetPos() ):GetNormalized()
	if goal.ladder != nil && goal.type == 2 && self.bCanClimbUp then
		self:ClimbUp( goal )
		return
	elseif goal.ladder != nil && goal.type != 2 && self.bCanClimbDown then
		self:ClimbDown( goal )
		return
	else
		if goal.type == 2 || goal.type == 3 then self:Jump( goal ) end
	end
	if self.MoveBlendMotor then
		if flTargetSequence then self.MoveBlendMotor:SetSecondarySequence( flTargetSequence ) end
		self.MoveBlendMotor:SetRatioTarget( 1 - clamp( #GetVelocity( self ) / ( self.flTopSpeed * flSpeed ), 0, 1 ) )
		//self.MoveBlendMotor:SetRatioTarget( 1 - clamp( abs( Path:GetLength() - Path:GetCursorPosition() ) / self.flTopSpeed, 0, 1 ) )
	end
	self:A_CombatMove( ( goal.pos - self:GetPos() ):GetNormalized(), clamp( abs( Path:GetLength() - Path:GetCursorPosition() ) / self.flTopSpeed, 0, 1 ) * flSpeed, flHeight, bAim, tFilter )
	Path:Update( self )
end
/*flSpeed isnt Absolute! What This Means is That It is a Multiplier to The TOP Speed, Not The DESIRED One.
In Simpler Words, Setting It to .1 wouldnt Mean We Always Go Ten Times Slower.
We can Go Up to Const 0 Slow, Depending on The Distance to vec!
Also, vec isnt Absolute Either! What This Means Here is That You should NOT PathFind Towards It,
and Instead, You should Move Towards It in a Straight Line!*/
function ENT:A_CombatMoveStraight( vec, flSpeed, flHeight, bAim, tFilter )
	local flTop = math.Remap( flHeight, 1, 0, self.flTopSpeed, self.flTopSpeedCrouch ) * flSpeed
	self:A_CombatMove( ( vec - self:GetPos() ):GetNormalized(), clamp( vec:Distance( self ) / flTop, 0, 1 ) * flSpeed, flHeight, bAim, tFilter )
end
function ENT:A_FaceMotion()
	local v = GetVelocity( self )
	local b = #v < 10
	if b || !self.dLastMotion then
		if b then v = self:GetForward() end
		v = v:Angle()
		v.p = 0
		self:SetLookAngle( self:GetForward() )
	else
		local v = self.dLastMotion:Angle()
		v.p = 0
		self:SetLookAngle( v )
	end
end
function ENT:A_RangeAttack( vec ) //vec is Actually VecOrEnt
	if isentity( vec ) then if IsValid( vec ) then
		local beh = vec.GAME_Behaviour || vec.BEHAVIOUR
		if beh && !beh:AllowAttacking( self, vec ) then self:SetLookAngle( ( vec:GetCenter() - self:GetShootPos() ):GetNormalized() ) return end
		vec = vec:GetCenter()
	else return end end
	if IsInCone( vec, self:GetShootPos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
	self:SetLookAngle( ( vec - self:GetShootPos() ):GetNormalized() )
end
//Reminder - DO NOT Do That when Making Bases! It Does Not Call The SubClass' Overriden Function if It Exists!
//ENT.A_CombatMoveRangeAttack = ENT.A_RangeAttack
function ENT:A_CombatMoveRangeAttack( ... ) self:A_RangeAttack( ... ) end
function ENT:A_CombatAim( dir, aim ) self:SetLookAngle( dir, aim ) end
function ENT:A_MaintainVelocity()
	self.loco:SetDesiredSpeed( 0 )
	self.loco:SetAcceleration( 0 )
	self.loco:SetDeceleration( 0 )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( 0 )
	self.loco:Approach( Vector( 0, 0, 0 ), 1 )
end
function ENT:A_CalcCombatStandSequence( flHeight, bAim ) return -1 end
function ENT:A_CalcCombatStandActivity( ... ) return self:GetSequenceActivity( self:A_CalcCombatStandSequence( ... ) ) end
function ENT:A_CombatStand( flHeight, bAim ) self:A_MaintainVelocity() end

function ENT:FoundEnemy( enemy ) end

function ENT:CombatBehaviour( enemy ) end
function ENT:StealthBehaviour( enemy ) self:CombatBehaviour( enemy ) end
function ENT:HuntBehaviour( enemy ) self:CombatBehaviour( enemy ) end
function ENT:AlertBehaviour( vLastAlertPos/*, vLastAlertFacing, vLastAlertDir*/ ) end
function ENT:PatrolBehaviour( vLastAlertPos/*, vLastAlertFacing, vLastAlertDir*/ ) self:AlertBehaviour( vLastAlertPos ) end
function ENT:IdleBehaviour() end

function ENT:CallPhysicsInit( iSolid ) self:PhysicsInit( tonumber( iSolid ) || self:GetSolid() ) end

//ENT.bNoThreat = nil
//ENT.bAltHate = nil
ENT.flAltHateDist = 0
function ENT:GetAltHateDistLength() return 0 end
ENT.tThreat = {}
ENT.tAltHateDistIgnore = {}

ALT_HATE_DIST_PERSONAL_SPACE = 500

CREATURE_HOSTILE_LENGTH_MIN, CREATURE_HOSTILE_LENGTH_MAX = 60, 240

CREATURE_STALK_DISTANCE = 2000

ENT.CATEGORIZE = {}

ENT.Organized = true

//Multiplier of Our Current Health
ENT.flSuppressionWeakenRate = 1.5
//Also a Multiplier of Our Current Health
ENT.flSuppressionMaxAmount = 3

function ENT:CalcEnemyDamageDecrease() return self:Health() * .02 end

function ENT:CustomOnRemove() end

function ENT:OnDeath( d )
	self:DeathMessage( d )
	self:BecomeRagdoll( d )
end

function ENT:HandleKeyValue() end

function ENT:ModifyPatrolPos( vPatrolPos ) return vPatrolPos end

ENT.tSpawnResetVars = {/*
	Number = 100,
	String = "\"abc\""
*/}

ENT.tCapabilities = {}

function ENT:OnKillEntity( ent, dmginfo ) end

function ENT:AllowPhysicsDamage(data) return yes end

function ENT:ForceTick() end //Called every tick in ENT:Think(). Use PlaySequenceAndWait here!
function ENT:Tick() end //Called every tick in ENT:RunBehaviour(). Use PlaySequenceAndWaitC here!

function ENT:PreInit() end //Ran before the entity sets up its properties. Not recommended.
function ENT:Init() end //Same as ENT:Initialize(), called from it.
function ENT:PostInit() end //After entity sets up its properties.

//ENT.bCanClimbUp = false
//ENT.bCanClimbDown = false
function ENT:ClimbUp( cg ) self:Jump( cg ) end
function ENT:ClimbDown( cg ) self:A_MaintainVelocity() end
function ENT:Jump( cg )
	if isvector( cg ) then cg = { pos = cg } end
	//Prevent Them from OverJumping
	local old = self.loco:GetJumpHeight()
	self.loco:SetJumpHeight( lmin( cg.pos:Distance( self:GetPos() ), old ) )
	if cg.type == 3 then self.loco:JumpAcrossGap( cg.pos, self:GetForward() ) else self.loco:Jump() end
	self.loco:SetJumpHeight( old )
end
function ENT:InAir( cg ) self:A_MaintainVelocity() self:NewActivity( ACT_GLIDE ) end

//If an Enemy Aims at The Target, `CanExpose` Considers His Health into Account.
//If The Sum of All The Enemies That Aim's Healths is More Than Our Health Multiplied by This, //Then `CanExpose` will Return `false`.
ENT.flExposedHideHealth = .1
//Same, But for Getting Shot at
ENT.flSuppressionHideHealth = .04

//Used by ENT.FireVolley, for firing weapons in (obviously) bursts/volleys
ENT.VolleyBreakTimes = { .4, .8 }
ENT.VolleyTimes = { 1, 3 }

ENT.flMaxFlank = 45 //Max flank in degrees, the multiplier of this value being flHordeMovementAdd

//If Our Health is Smaller Than Our Max Health Multiplied by This, //`ENT:IsScared` will Return True.
ENT.flHealthPercentScared = .75

//See radio.lua
ENT.RadioAnswerQuery = {}

//Dist to search for allies
ENT.flAllySearchDist = 3000

//ENT.iCatAndMouseHealth = 0 :: Enemy must have less than this health to toy with him. Not setting this means the value is OurHealth*0.33

ENT.CatAndMouseMinDur = 20
ENT.CatAndMouseMaxDur = 40

ENT.CatAndMouseMinDelay = 40
ENT.CatAndMouseMaxDelay = 80

ENT.flGravityMul = 1 //Gravity Multiplier for sv_gravity

ENT.flPathTol = 25

//ENT.bFlying = No :: If this is a helicopter or smth like one, set this to yes. This allows for 3D patrol alertposes&&more. This also prevents NPCM from being called.
ENT.bAllowAirYields = Yes //If set to no, will NEVER normally call InAir, even when bFlying is false.
ENT.bIgnoreProps = Yes //For relationships. Self-describing.
//CUT! Replaced with a better ENT.FindLookAng system!
//ENT.bForceLookAtTarget = Yes //If yes, we ALWAYS turn at enemy no matter what.
//Locks Pitch and Roll. Prevents us from doing damage with our physics object.
//Made for NPCs like Combine Soldiers. Remove if You're making something like a Manhack.
ENT.bNoPhysics = Yes

ENT.bScaredOfVehicles = yes //Are we scared of enemies in vehicles? (Realistically for humans)
ENT.bScaredOfFire = yes //Are we scared of being on fire? (Realistically for most things)

//For ENT:CanTraverseArea(area).
//ENT.bAllowUnderwaterAreas = no

//If some ally finds that spot X is clear, and our bullseye/last alert pos/etc is <this> units nearby it, then its not a threat anymore
ENT.iNoThreatDistToFound = 1000
//I know this looks complicated, but its simple:
//When finding a Vector3 (LOS/Cover/etc),
//Check if all Allies' same thing (LOS/Cover/etc)
//Is atleast <this> Units far.
//(For optimizations this value should be squared)
ENT.flFindVecDistFromAllies = 10000

//How far to Patrol from our Last Alert Pos when Patrolling, per Ally
//`self.BasePatrolDist + self.PatrolDist * #self:HaveAllies()`
ENT.PatrolDistBase = 1500
ENT.PatrolDist = 500

//If we see the bullseye, and rand of <this> multiplied by vismiss is equal to 1, then stop firing and understand that nothing's there
ENT.BullseyeChnc = 200
ENT.BullseyeDist = 100 //Dist to the bullseye to understand nothing's there (so we wont melee air)

//How much time from last encouter with enemy (enemy see time) to wait, //To be able to call ENT.StealthBehaviour instead of ENT.CombatBehaviour again?
ENT.flUnspotTime = 2

//This is [m, n] duration for which we keep alert after hearing something
ENT.AlertTimes = { 60, 80 }
//Same as bullseye chance except for alert positions.
//Walk up first, understand nothing's there a few seconds later.
ENT.AlertChnc = 333

//This is [m, n] duration for which we keep high alert.
//A high alert is after an enemy was found, //and it means any new noise will cause us to open fire.
ENT.HighAlertTimes = { 40, 60 }

//ENT.VisNight = false
//ENT.VisOmniscient = false
//ENT.VisSeeInvis = false
ENT.VisConeHor = 99
ENT.VisConeVer = 55
ENT.VisDist = 8000
ENT.Vis360 = no
ENT.VisMissMul = 1
ENT.VisMissMulUW = 15 //For targets underwater

//We try to approximate where sound comes from, not just GetPos!
ENT.SndApproxMinMul = 4 //For 60DB
ENT.SndApproxMaxMul = 1 //For 150DB
ENT.SndApproxBase = 0.16 //Base spread
//If the spread is more than this, set only our alert pos, NEVER our bullseye's pos!
ENT.SndApproxNoBEyeSpr = 0.33 //29.7 degrees.

ENT.iVehAct = ACT_IDLE_ANGRY

ENT.flRunAwayDist = 300 //Called iRunAwayDist before V160
ENT.bCanFear = true

//Return True to prevent the change
function ENT:OnActivityChanged(old, new) end

function ENT:UpdatePose() end

//OVERRIDE AT YOUR OWN RISK!
ENT.PoseParameters = {
	Body = {
		Yaw = 'body_yaw',
		Pitch = 'body_pitch',
		MulMaxSpeed = 1.25,
		MulAccel = 1.25,
		MulDecel = 1.25
	},
	Aim = {
		Yaw = 'aim_yaw',
		Pitch = 'aim_pitch',
		MulMaxSpeed = 1.5,
		MulAccel = 1.5,
		MulDecel = 1.5
	}
}

ENT.flYawSpeed = 0
ENT.flMaxYawSpeed = nil
ENT.flYawAccel = 1
ENT.flYawDecel = 1

ENT.tSetLookAnglePoseParameterVelocities = {}

function ENT:SetMaxYawSpeed( f ) self.flMaxYawSpeed = f end

function ENT:GetCurrentYawSpeed() return self.flYawSpeed || 0 end

function ENT:SetLookAngle( dir, aim )
	self.flMaxYawSpeed = self.flMaxYawSpeed || self.loco:GetMaxYawRate()
	if !aim && dir then aim = dir end
	if dir && !isangle( dir ) then dir = dir:Angle() end
	if aim && !isangle( aim ) then aim = aim:Angle() end
	local d = self:GetAngles()
	d.p = d.p + self:GetPoseParameter( self.PoseParameters.Aim.Pitch )
	d.y = d.y + self:GetPoseParameter( self.PoseParameters.Aim.Yaw )
	d.p = math.ApproachAngle( d.p, aim.p, 5 )
	d.y = math.ApproachAngle( d.y, aim.y, 5 )
	self.AimVector = d:Forward()
	if aim then
		local aim = aim - self:GetAngles()
		local tVel = self.tSetLookAnglePoseParameterVelocities
		local flBaseSpeed = self.flMaxYawSpeed
		for _, Data in pairs( self.PoseParameters ) do
			if !Data.Pitch || !Data.Yaw then continue end
			local Pitch, Yaw = self:LookupPoseParameter( Data.Pitch ), self:LookupPoseParameter( Data.Yaw )
			if Pitch == -1 || Yaw == -1 then continue end
			if !tVel[ Data.Pitch ] then tVel[ Data.Pitch ] = 0 end
			if !tVel[ Data.Yaw ] then tVel[ Data.Yaw ] = 0 end
			local flCur = self:GetPoseParameter( Data.Pitch )
			local diff = math.AngleDifference( aim.p, flCur )
			local n = flBaseSpeed * Data.MulMaxSpeed
			local m = -n
			local spd = math.Clamp( math.Remap( clamp( diff, -90, 90 ), -90, 90, m, n ), m, n )
			if spd <= 0 then
				if spd < tVel[ Data.Pitch ] then
					tVel[ Data.Pitch ] = math.max( spd, tVel[ Data.Pitch ] - flBaseSpeed * Data.MulAccel * FrameTime() )
				else
					tVel[ Data.Pitch ] = math.min( spd, tVel[ Data.Pitch ] + flBaseSpeed * Data.MulDecel * FrameTime() )
				end
			else
				if spd > tVel[ Data.Pitch ] then
					tVel[ Data.Pitch ] = math.max( spd, tVel[ Data.Pitch ] + flBaseSpeed * Data.MulAccel * FrameTime() )
				else
					tVel[ Data.Pitch ] = math.min( spd, tVel[ Data.Pitch ] - flBaseSpeed * Data.MulDecel * FrameTime() )
				end
			end
			self:SetPoseParameter( Data.Pitch, flCur + tVel[ Data.Pitch ] * FrameTime() )
			local flCur = self:GetPoseParameter( Data.Yaw )
			local diff = math.AngleDifference( aim.y, flCur )
			local n = flBaseSpeed * Data.MulMaxSpeed
			local m = -n
			local spd = math.Clamp( math.Remap( diff, -90, 90, m, n ), m, n )
			if spd <= 0 then
				if spd < tVel[ Data.Yaw ] then
					tVel[ Data.Yaw ] = math.max( spd, tVel[ Data.Yaw ] - flBaseSpeed * Data.MulAccel * FrameTime() )
				else
					tVel[ Data.Yaw ] = math.min( spd, tVel[ Data.Yaw ] + flBaseSpeed * Data.MulDecel * FrameTime() )
				end
			else
				if spd > tVel[ Data.Yaw ] then
					tVel[ Data.Yaw ] = math.max( spd, tVel[ Data.Yaw ] + flBaseSpeed * Data.MulAccel * FrameTime() )
				else
					tVel[ Data.Yaw ] = math.min( spd, tVel[ Data.Yaw ] - flBaseSpeed * Data.MulDecel * FrameTime() )
				end
			end
			self:SetPoseParameter( Data.Yaw, flCur + tVel[ Data.Yaw ] * FrameTime() )
		end
	end
	if dir && !self:InVehicle() && self.bNoPhysics then
		local diff = math.AngleDifference( self:GetAngles().y, dir.y )
		local spd = math.Clamp( math.Remap( diff, -90, 90, -self.flMaxYawSpeed, self.flMaxYawSpeed ), -self.flMaxYawSpeed, self.flMaxYawSpeed )
		if spd <= 0 then
			if spd < self.flYawSpeed then
				self.flYawSpeed = math.max( spd, self.flYawSpeed - self.flMaxYawSpeed * self.flYawAccel * FrameTime() )
			else
				self.flYawSpeed = math.min( spd, self.flYawSpeed + self.flMaxYawSpeed * self.flYawDecel * FrameTime() )
			end
		else
			if spd > self.flYawSpeed then
				self.flYawSpeed = math.max( spd, self.flYawSpeed + self.flMaxYawSpeed * self.flYawAccel * FrameTime() )
			else
				self.flYawSpeed = math.min( spd, self.flYawSpeed - self.flMaxYawSpeed * self.flYawDecel * FrameTime() )
			end
		end
		self.loco:SetMaxYawRate( math.abs( self.flYawSpeed ) )
		local v = self:GetPos() + Angle( 0, dir.y, 0 ):Forward() * 100
		//Doesnt Make Them Turn Faster! This is Here to Trick The Locomotion System into Prioritizing Our Custom Turn!
		for _ = 1, 10 do self.loco:FaceTowards( v ) end
	end
	self:UpdatePose()
end

function ENT:GetRelationship( ent )
	if !IsValid( ent ) then return D_NU end
	return ( ent.Classify && ent:Classify() || 0 ) == self:Classify() && D_LI || ( ent:IsEnvironment() && D_NU || D_HT )
end
