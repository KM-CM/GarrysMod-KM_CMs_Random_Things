/*////////////////////////////////////////////////////////

TODO: Title Card

////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.Name = "Combine Helicopter"

ENT.bCantStackUp = true

ENT.CATEGORIZE = {
	Combine = true,
	Gunship = true //Huge Helicopter. Counts?
}

ENT.HAS_RANGE_ATTACK = true

ENT.VisNight = true

ENT.vHullMins = Vector( -300, -300, -100 )
ENT.vHullMaxs = Vector( 300, 300, 160 )
ENT.vHullDuckMins = ENT.vHullMins
ENT.vHullDuckMaxs = ENT.vHullMaxs

ENT.bUseFindLookAng = false
ENT.bNoPhysics = false
ENT.bFlying = true

ENT.ShootBone = 'Chopper.Gun'

ENT.PoseParameters = {
	Body = {
		Yaw = 'body_yaw',
		Pitch = 'body_pitch',
		MulMaxSpeed = 1,
		MulAccel = 1,
		MulDecel = 1
	},
	Aim = {
		Yaw = 'weapon_yaw',
		Pitch = 'weapon_pitch',
		MulMaxSpeed = 1,
		MulAccel = 1,
		MulDecel = 1
	}
}

ENT.iClass = CLASS_COMBINE
function ENT:GetRelationship( ent ) return ( ent.Classify && ent:Classify() || 0 ) == self:Classify() && D_LI || D_HT end

function ENT:OnDeath( dmg )
	self:DeathMessage( dmg )
	self:Remove()
end

if SERVER then function ENT:CustomOnRemove() if self.RotorLoop then self.RotorLoop:Stop() end end end

local npc_combine_helicopter_health = CreateConVar(
	'npc_combine_helicopter_health',
	400000, //Armor!
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Health"
)
local npc_combine_helicopter_health_rotor = CreateConVar(
	'npc_combine_helicopter_health_rotor',
	400000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Main Rotor Health"
)
local npc_combine_helicopter_health_guide = CreateConVar(
	'npc_combine_helicopter_health_guide',
	80000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Guide Rotor Health"
)
local npc_combine_helicopter_health_rudder = CreateConVar(
	'npc_combine_helicopter_health_rudder',
	80000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Rudder Rotor Health"
)

sound.Add {
	name = 'Combine_Helicopter_RotorLoop',
	sound = '^npc/attack_helicopter/aheli_rotor_loop1.wav',
	level = 150,
	channel = CHAN_STATIC
}

function ENT:Init()
	self:SetModel( 'models/combine_helicopter.mdl' )
	if SERVER then
		local RotorLoop = CreateSound( self, 'Combine_Helicopter_RotorLoop' )
		self.RotorLoop = RotorLoop
		RotorLoop:Play()
		self:SetSolid( SOLID_VPHYSICS )
		self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
		self:SetBloodColor( BLOOD_COLOR_MECH )
		self.flRotorHealth = npc_combine_helicopter_health_rotor:GetFloat()
		self.flGuideHealth = npc_combine_helicopter_health_guide:GetFloat()
		self.flRudderHealth = npc_combine_helicopter_health_rudder:GetFloat()
		self:SetHealth( npc_combine_helicopter_health:GetInt() )
		self:SetMaxHealth( npc_combine_helicopter_health:GetInt() )
	end
end

//ENT.vDesiredMove = Vector( 0, 0, 0 )
//ENT.vDesiredAim = Vector( 0, 0, 0 )

function ENT:SetDesiredMove( v ) self.vDesiredMove = v end
function ENT:GetDesiredMove() return self.vDesiredMove end

function ENT:SetDesiredAim( v ) self.vDesiredAim = v end
function ENT:GetDesiredAim() return self.vDesiredAim end

//ENT.flRotorHealth = 0
//ENT.flGuideHealth = 0
//ENT.flRudderHealth = 0

local npc_combine_helicopter_rotor_speed = CreateConVar(
	'npc_combine_helicopter_rotor_speed',
	2000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Maximum Main Rotor Speed"
)
local npc_combine_helicopter_rotor_force = CreateConVar(
	'npc_combine_helicopter_rotor_force',
	800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Maximum Main Rotor Force"
)
local npc_combine_helicopter_guide_force = CreateConVar(
	'npc_combine_helicopter_guide_force',
	800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Maximum Guide Rotor Force"
)
local npc_combine_helicopter_rudder_force = CreateConVar(
	'npc_combine_helicopter_rudder_force',
	800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Maximum Rudder Rotor Force"
)

sv_gravity = GetConVar 'sv_gravity'

//Do Not Ask Me for Clarification on What This Function Does. I Dont Know Myself. But It Works.
function ENT:HandleMotion()
	self:NewActivity( ACT_INVALID )
	if self:GetSequence() != self:LookupSequence( 'idle' ) then
		self:ResetSequenceInfo()
		self:SetSequence( 'idle' )
		self:SetPlaybackRate( 1 )
	end
	local vDesMove, vDesAim = self.vDesiredMove, self.vDesiredAim
	if !vDesMove || !vDesAim then return end
	local phys = self:GetPhysicsObject()
	if !IsValid( phys ) then return end
	//Try Not Crashing into Things
	local danger = phys:GetVelocity()
	danger.z = danger.z - sv_gravity:GetFloat()
	local tr = Trace( {
		start = self:GetCenter(),
		endpos = self:GetCenter() + danger,
		mask = MASK_SOLID,
		filter = table.add( self:AllRelatedEntities() )
	} )
	if tr.Hit then vDesMove = vDesMove + ( self:GetPos() - tr.HitPos ):GetNormalized() * math.Remap( tr.HitPos:Distance( self:GetPos() ), 0, #danger, npc_combine_helicopter_rotor_speed:GetFloat(), 0 ) end
	if self.flRotorHealth > 0 then
		local flForce = npc_combine_helicopter_rotor_force:GetFloat() * math.max( 0, self.flRotorHealth / npc_combine_helicopter_health_rotor:GetFloat() )
		local n = self:GetAngles()
		local d = vDesMove:GetFlat():GetNormalized()
		local vDesMoveRot = Vector( vDesMove ):GetNormalized() * clamp( #vDesMove, 0, npc_combine_helicopter_rotor_speed:GetFloat() )
		vDesMove:Rotate( self:GetAngles() )
		vDesMoveRot = ( vDesMoveRot - phys:GetVelocity() ):GetFlat():GetNormalized()
		local f = clamp( #vDesMove / npc_combine_helicopter_rotor_speed:GetFloat(), 0, 1 )
		n.p = vDesMoveRot:Dot( self:GetForward():GetFlat():GetNormalized() ) * f * 45
		n.r = vDesMoveRot:Dot( self:GetRight():GetFlat():GetNormalized() ) * f * 45
		local flForce = npc_combine_helicopter_rotor_force:GetFloat() * math.max( 0, self.flRotorHealth / npc_combine_helicopter_health_rotor:GetFloat() )
		phys:AddAngleVelocity( Vector( clamp( math.AngleDifference( n.r, self:GetAngles().r ) * .0055555555555556 * flForce - phys:GetAngleVelocity().x, -flForce, flForce ), clamp( math.AngleDifference( n.p, self:GetAngles().p ) * .0055555555555556 * flForce - phys:GetAngleVelocity().y, -flForce, flForce ), 0 ) * FrameTime() )
		local flSpeed = npc_combine_helicopter_rotor_speed:GetFloat() * math.max( 0, self.flRotorHealth / npc_combine_helicopter_health_rotor:GetFloat() )
		local f = clamp( math.Remap( lmax( math.AngleDifference( self:GetAngles().p, 0 ), math.AngleDifference( self:GetAngles().r, 0 ) ), 0, 45, 1, 1.5 ), 1, 2 )
		local flCurSpeed = vDesMove.z * f
		flCurSpeed = flCurSpeed + sv_gravity:GetFloat() * f
		flCurSpeed = flCurSpeed + math.abs( vDesMove.x ) * clamp( math.Remap( self:GetAngles().p, 0, n.p, 0, 1 ), 0, 1 )
		flCurSpeed = flCurSpeed + math.abs( vDesMove.y ) * clamp( math.Remap( self:GetAngles().r, 0, n.r, 0, 1 ), 0, 1 )
		self.RotorLoop:ChangeVolume( clamp( math.Remap( flCurSpeed, 0, flSpeed, .33, .66 ), .33, .66 ) )
		self.RotorLoop:ChangePitch( clamp( math.Remap( flCurSpeed, 0, flSpeed, 80, 100 ), 80, 100 ) )
		phys:AddVelocity( self:GetUp() * clamp( flCurSpeed, -flSpeed, flSpeed ) * FrameTime() )
	end
	if self.flGuideHealth > 0 then
		local flForce = npc_combine_helicopter_guide_force:GetFloat() * math.max( 0, self.flGuideHealth / npc_combine_helicopter_health_guide:GetFloat() )
		phys:AddAngleVelocity( Vector( 0, 0, clamp( math.AngleDifference( vDesAim:Angle().y, self:GetAngles().y ) * .0055555555555556 * flForce - phys:GetAngleVelocity().z, -flForce, flForce ) ) * FrameTime() )
	end
	if self.flRudderHealth > 0 then
		local flForce = npc_combine_helicopter_rudder_force:GetFloat() * math.max( 0, self.flRudderHealth / npc_combine_helicopter_health_rudder:GetFloat() )
		local f = clamp( math.AngleDifference( vDesAim:Angle().y, self:GetAngles().y ) * .0055555555555556 * flForce - phys:GetAngleVelocity().z, -flForce, flForce )
		phys:AddAngleVelocity( Vector( 0, 0, f ) * FrameTime() )
		self:SetPoseParameter( 'rudder', math.Approach( clamp( math.AngleDifference( self:GetAngles().y, vDesAim:Angle().y ), -45, 45 ), f / flForce * 45, 90 * FrameTime() ) )
	end
end

//ENT.vRoam = nil
function ENT:_ChopperRoam()
	local b = !self.vRoam || self:GetPos():Distance( self.vRoam ) < ( ( #self:OBBMins() + #self:OBBMaxs() ) * .2 )
	if !b && Trace( {
		start = self:GetPos(),
		endpos = self.vRoam,
		mask = MASK_SOLID,
		filter = self:AllRelatedEntities()
	} ).Hit then self.vRoam = nil b = true end
	if b then
		for _ = 1, 128 do
			self.vRoam = self:GetPos() + VectorRand() * math.Rand( 0, npc_combine_helicopter_rotor_speed:GetFloat() )
		end
	end
end

local npc_combine_helicopter_weapon_turn = CreateConVar(
	'npc_combine_helicopter_weapon_turn',
	1200,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Weapon Turn Speed"
)
local npc_combine_helicopter_weapon_spread = CreateConVar(
	'npc_combine_helicopter_weapon_spread',
	6,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Gun Spread"
)
local npc_combine_helicopter_weapon_damage = CreateConVar(
	'npc_combine_helicopter_weapon_damage',
	80,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Gun Damage"
)
local npc_combine_helicopter_weapon_num = CreateConVar(
	'npc_combine_helicopter_weapon_num',
	3,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Gun Number of Rounds Per Burst"
)
local npc_combine_helicopter_weapon_rate = CreateConVar(
	'npc_combine_helicopter_weapon_rate',
	13,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Gun Rate"
)

local npc_combine_helicopter_fight_tight = CreateConVar(
	'npc_combine_helicopter_fight_tight',
	.3,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Multiplier for `fight_sphere` and `fight_sphere_large` when Not Suppressed"
)
local npc_combine_helicopter_fight_sphere = CreateConVar(
	'npc_combine_helicopter_fight_sphere',
	4000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_helicopter`'s Fly Distance from The Enemy"
)
local npc_combine_helicopter_fight_sphere_large = CreateConVar(
	'npc_combine_helicopter_fight_sphere_large',
	6000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"An `npc_combine_helicopter` will ReCalculate His WayPoint if It is This Far from The Enemy"
)

sound.Add {
	name = 'Combine_Helicopter_Fire',
	sound = 'gunfire/weapon_m249.wav',
	pitch = 95,
	level = 150,
	channel = CHAN_WEAPON
}

ENT.flNextShot = 0

function ENT:CombatBehaviour( enemy )
	self.bMusicActive = self:Visible( enemy )
	self:MI_CalcCombatState()
	if self.flCombatState > .5 then
		local f = table.add( self:AllRelatedEntities(), enemy:GetCenter() )
		local flMul = math.Remap( self:GetExposedWeight(), 0, self.flExposedHideHealth, npc_combine_helicopter_fight_tight:GetFloat(), 1 )
		local b = !self.vRoam || self.vRoam:Distance( enemy:GetCenter() ) > npc_combine_helicopter_fight_sphere_large:GetFloat() * flMul
		//Only Truly Throw It Away if We Physically cant Reach It
		if !b && Trace( {
			start = self:GetPos(),
			endpos = self.vRoam,
			mask = MASK_SOLID,
			filter = self:AllRelatedEntities()
		} ).Hit then self.vRoam = nil b = true end
		if b || self:GetPos():Distance( self.vRoam ) < ( ( #self:OBBMins() + #self:OBBMaxs() ) * .2 ) && rand( math.Remap( self:Health(), 0, self:GetMaxHealth(), 0, 1000 ) * FrameTime() ) == 1 then
			local b, d = true, npc_combine_helicopter_fight_sphere:GetFloat() * flMul
			for _ = 1, 128 do
				local vec = enemy:GetCenter() + VectorRand() * math.Rand( 0, d )
				if !Trace( {
					start = self:GetPos(),
					endpos = vec,
					mask = MASK_SOLID,
					filter = self:AllRelatedEntities()
				} ).Hit && !Trace( {
					start = vec,
					endpos = enemy:GetCenter(),
					mask = MASK_SOLID,
					filter = f
				} ).Hit then self.vRoam = vec b = nil break end
			end
			//Well... Well, Shit...
			if b then self:_ChopperRoam() end
		end
		self:SetDesiredMove( ( self.vRoam || self:GetPos() ) - self:GetPos() )
	elseif self.flCombatState < -.5 then
		self:SetDesiredMove( ( self:GetPos() - enemy:GetCenter() ) * math.Remap( self.flCombatState, -.5, -1, npc_combine_helicopter_rotor_speed:GetFloat() * .5, npc_combine_helicopter_rotor_speed:GetFloat() ) )
	else
		self:_ChopperRoam()
		self:SetDesiredMove( ( self.vRoam || enemy:GetCenter() ) - self:GetPos() )
	end
	self:HandleMotion()
	self:SetMaxYawSpeed( npc_combine_helicopter_weapon_turn:GetFloat() )
	self:SetLookAngle( ( enemy:GetCenter() - self:GetShootPos() ):Angle() )
	local vDesMove = self.vDesiredMove
	if vDesMove && !self:Visible( enemy ) then
		self:SetDesiredAim( ( vDesMove - self:GetShootPos() ):GetNormalized() )
	else
		self:SetDesiredAim( ( enemy:GetCenter() - self:GetShootPos() ):GetNormalized() )
	end
	if CurTime() > self.flNextShot && self:VisibleVec( enemy:GetCenter() ) && IsInCone( enemy:GetCenter(), self:GetShootPos(), self:GetAimVector(), 1, 1 ) then
		self:FireBullets {
			Src = self:GetShootPos(),
			Dir = self:GetAimVector(),
			Spread = Vector( npc_combine_helicopter_weapon_spread:GetFloat() * .011111111111111, npc_combine_helicopter_weapon_spread:GetFloat() * .011111111111111, 0 ),
			Damage = npc_combine_helicopter_weapon_damage:GetInt(),
			Num = npc_combine_helicopter_weapon_num:GetInt(),
			TracerName = 'HelicopterTracer'
		}
		self.flNextShot = CurTime() + 1 / npc_combine_helicopter_weapon_rate:GetFloat()
		self.ShootColor = '127 255 255 750'
		self.MFlashFlags = 5
		self:EmitSound 'Combine_Helicopter_Fire'
	end
end

function ENT:AlertBehaviour( vLastAlertPos )
	self.bMusicActive = self:VisibleVec( vLastAlertPos )
	self:MI_CalcCombatState()
	if self.flCombatState > .5 then
		local f = self:AllRelatedEntities()
		local flMul = math.Remap( self:GetExposedWeight(), 0, self.flExposedHideHealth, npc_combine_helicopter_fight_tight:GetFloat(), 1 )
		local b = !self.vRoam || self.vRoam:Distance( vLastAlertPos ) > npc_combine_helicopter_fight_sphere_large:GetFloat() * flMul
		//Only Truly Throw It Away if We Physically cant Reach It
		if !b && Trace( {
			start = self:GetPos(),
			endpos = self.vRoam,
			mask = MASK_SOLID,
			filter = f
		} ).Hit then self.vRoam = nil b = true end
		if b || self:GetPos():Distance( self.vRoam ) < ( ( #self:OBBMins() + #self:OBBMaxs() ) * .2 ) && rand( math.Remap( self:Health(), 0, self:GetMaxHealth(), 0, 1000 ) * FrameTime() ) == 1 then
			local b, d = true, npc_combine_helicopter_fight_sphere:GetFloat() * flMul
			for _ = 1, 128 do
				local vec = vLastAlertPos + VectorRand() * math.Rand( 0, d )
				if !Trace( {
					start = self:GetPos(),
					endpos = vec,
					mask = MASK_SOLID,
					filter = self:AllRelatedEntities()
				} ).Hit && !Trace( {
					start = vec,
					endpos = vLastAlertPos,
					mask = MASK_SOLID,
					filter = f
				} ).Hit then self.vRoam = vec b = nil break end
			end
			//Well... Well, Shit...
			if b then self:_ChopperRoam() end
		end
		self:SetDesiredMove( ( self.vRoam || self:GetPos() ) - self:GetPos() )
	elseif self.flCombatState < -.5 then
		self:SetDesiredMove( ( self:GetPos() - vLastAlertPos ) * math.Remap( self.flCombatState, -.5, -1, npc_combine_helicopter_rotor_speed:GetFloat() * .5, npc_combine_helicopter_rotor_speed:GetFloat() ) )
	else
		self:_ChopperRoam()
		self:SetDesiredMove( ( self.vRoam || vLastAlertPos ) - self:GetPos() )
	end
	self:HandleMotion()
	self:SetMaxYawSpeed( npc_combine_helicopter_weapon_turn:GetFloat() )
	self:SetLookAngle( ( vLastAlertPos - self:GetShootPos() ):Angle() )
	local vDesMove = self.vDesiredMove
	if vDesMove && !self:VisibleVec( vLastAlertPos ) then
		self:SetDesiredAim( ( vDesMove - self:GetShootPos() ):GetNormalized() )
	else
		self:SetDesiredAim( ( vLastAlertPos - self:GetShootPos() ):GetNormalized() )
	end
end

function ENT:IdleBehaviour()
	self:HandleMotion()
	self:_ChopperRoam()
	self:SetDesiredMove( ( self.vRoam || self:GetPos() ) - self:GetPos() )
	self:SetDesiredAim( self:GetDesiredMove() )
end
ENT.PatrolBehaviour = ENT.IdleBehaviour

function ENT:Damaged( d )
	self.flRotorHealth = lmax( 0, self.flRotorHealth - d:GetDamage() )
	self.flGuideHealth = lmax( 0, self.flGuideHealth - d:GetDamage() )
	self.flRudderHealth = lmax( 0, self.flRudderHealth - d:GetDamage() )
end

function ENT:ForceTick()
	if !self:CanRegenerate() then return end
	self.flRotorHealth = lmin( npc_combine_helicopter_health_rotor:GetFloat(), self.flRotorHealth + npc_combine_helicopter_health_rotor:GetFloat() * .012 * FrameTime() )
	self.flGuideHealth = lmin( npc_combine_helicopter_health_guide:GetFloat(), self.flGuideHealth + npc_combine_helicopter_health_guide:GetFloat() * .012 * FrameTime() )
	self.flRudderHealth = lmin( npc_combine_helicopter_health_rudder:GetFloat(), self.flRudderHealth + npc_combine_helicopter_health_rudder:GetFloat() * .012 * FrameTime() )
end

list.Set( 'NPC', 'npc_helicopter', {
	Name = '#npc_combine_helicopter',
	Class = 'npc_combine_helicopter',
	Category = 'Combine',
	AdminOnly = false,
	Offset = 300
} )

ENT.Class = 'npc_combine_helicopter' NPC.Register( ENT )
scripted_ents.Alias( 'npc_helicopter', 'npc_combine_helicopter' )