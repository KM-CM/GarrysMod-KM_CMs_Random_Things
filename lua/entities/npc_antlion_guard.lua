/*////////////////////////////////////////////////////////

A MUCH STRONGER VERSION OF THE ALREADY TERRIFYING ANTLION - AVOID AT ALL COSTS!

////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.vHullMins = VECTOR_HULL_HUMAN_MINS
ENT.vHullMaxs = VECTOR_HULL_HUMAN_MAXS
ENT.vHullDuckMins = ENT.vHullMins
ENT.vHullDuckMaxs = ENT.vHullMaxs

ENT.Name = 'Antlion Guard'

ENT.HAS_MELEE_ATTACK = true

ENT.bAttackStalkTarget = true
//ENT.StalkTarget = NULL

ENT.iClass = CLASS_ANTLION

ENT.VisNight = true
ENT.Vis360 = true

ENT.bNoThreat = true
ENT.bAltHate = true
ENT.bOrganized = false

ENT.flAltHateDist = ALT_HATE_DIST_PERSONAL_SPACE

ENT.flHunger = 0

//ENT.NoiseLoop = nil

ENT.GAME_HearDistMul = 3

if SERVER then function ENT:CustomOnRemove() if self.NoiseLoop then self.NoiseLoop:Stop() end end end

ENT.CATEGORIZE = {
	Antlion = true,
	AntlionGuard = true
}

local npc_antlion_guard_health = CreateConVar(
	'npc_antlion_guard_health',
	12000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Health"
)
function ENT:Init()
	self:SetModel 'models/antlion_guard.mdl'
	if SERVER then
		local NoiseLoop = CreateSound( self, 'Antlion_Guard_NoiseLoop' )
		self.NoiseLoop = NoiseLoop
		NoiseLoop:Play()
		NoiseLoop:ChangeVolume( 0 )
		self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
		self:SetBloodColor( BLOOD_COLOR_ANTLION )
		self:SetHealth( npc_antlion_guard_health:GetInt() )
		self:SetMaxHealth( npc_antlion_guard_health:GetInt() )
	end
end

function ENT:GetMeleeTrace()
	local t = table.tohasvalue( self:AllRelatedEntities() )
	return TraceBox( {
		start = self:GetCenter(),
		endpos = self:GetCenter() + self:GetForward() * 64,
		mins = Vector( -24, -24, -12 ),
		maxs = Vector( 24, 24, 64 ),
		filter = function( ent ) return !t[ ent ] && self:Disposition( ent ) != D_LI end
	} )
end

function ENT:GetMeleeTarget() return self:GetMeleeTrace().Entity end

local npc_antlion_guard_melee_forgive_dist = CreateConVar(
	'npc_antlion_guard_melee_forgive_dist',
	192,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"How Much Distance to Forgive During a Melee Attack? If The Original Melee Target - for Example, The Enemy - is Closer to Us Than This, Then He will Take Damage from The Melee, Even if He isnt in The Trace Anymore."
)

local npc_antlion_guard_melee_shove_damage = CreateConVar(
	'npc_antlion_guard_melee_shove_damage',
	240,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Damage"
)
local npc_antlion_guard_melee_shove_force = CreateConVar(
	'npc_antlion_guard_melee_shove_force',
	2400,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Force"
)
local npc_antlion_guard_melee_shove_force_enemy_scale = CreateConVar(
	'npc_antlion_guard_melee_shove_force_enemy_scale',
	.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Force Multiplier when Shoving The Enemy"
)

local VOICE_PITCH_MIN, VOICE_PITCH_MAX = 90, 110

sound.Add {
	name = 'Antlion_Guard_Warning',
	sound = {
		'npc/antlion_guard/angry1.wav',
		'npc/antlion_guard/angry2.wav',
		'npc/antlion_guard/angry3.wav'
	},
	pitch = { VOICE_PITCH_MIN, VOICE_PITCH_MAX },
	level = 150,
	channel = CHAN_AUTO
}

sound.Add {
	name = 'Antlion_Guard_Hit',
	sound = 'npc/antlion_guard/shove1.wav',
	pitch = 100,
	level = 150,
	channel = CHAN_AUTO
}

local npc_antlion_guard_melee_shove_damage = CreateConVar(
	'npc_antlion_guard_melee_shove_damage',
	240,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Damage"
)
local npc_antlion_guard_melee_shove_force = CreateConVar(
	'npc_antlion_guard_melee_shove_force',
	3200,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Force"
)
local npc_antlion_guard_melee_shove_force_enemy_scale = CreateConVar(
	'npc_antlion_guard_melee_shove_force_enemy_scale',
	.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Shove Force Multiplier when Throwing The Enemy"
)

function ENT:MeleeShoveC( vec, b )
	local s = math.Rand( .9, 1.1 )
	local t, mt, b = CurTime() + .5 / s, self:GetMeleeTarget()
	self:EmitSound 'Antlion_Guard_Warning'
	self:PlaySequenceAndWaitC( 'shove', s, .4 / s, function( self )
		if b then return end
		if CurTime() > t then
			local ent = ( IsValid( mt ) && mt:GetPos():Distance( self:GetPos() ) < npc_antlion_guard_melee_forgive_dist:GetFloat() ) && mt || self:GetMeleeTarget()
			if IsValid( ent ) then
				self:EmitSound 'Antlion_Guard_Hit'
				local dmg = DamageInfo()
				if b then dmg:SetDamage( 0 ) else dmg:SetDamage( npc_antlion_guard_melee_shove_damage:GetFloat() ) end
				if isfunction( vec ) then vec = vec( self ) end
				if vec then dmg:SetDamageForce( vec ) SetVelocity( ent, vec ) end
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				ent:TakeDamageInfo( dmg )
			end
			b = true
		end
	end )
end

local npc_antlion_guard_melee_throw_damage = CreateConVar(
	'npc_antlion_guard_melee_throw_damage',
	180,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Throw Damage"
)
local npc_antlion_guard_melee_throw_force = CreateConVar(
	'npc_antlion_guard_melee_throw_force',
	1800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Throw Force"
)
local npc_antlion_guard_melee_throw_force_enemy_scale = CreateConVar(
	'npc_antlion_guard_melee_throw_force_enemy_scale',
	.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Throw Force Multiplier when Throwing The Enemy"
)

function ENT:MeleeThrowC( vec, b )
	local s = math.Rand( 1.2, 1.4 )
	local t, mt, b = CurTime() + .5 / s, self:GetMeleeTarget()
	self:EmitSound 'Antlion_Guard_Warning'
	self:PlaySequenceAndWaitC( 'physthrow', s, .6 / s, function( self )
		if b then return end
		if CurTime() > t then
			local ent = ( IsValid( mt ) && mt:GetPos():Distance( self:GetPos() ) < npc_antlion_guard_melee_forgive_dist:GetFloat() ) && mt || self:GetMeleeTarget()
			if IsValid( ent ) then
				self:EmitSound 'Antlion_Guard_Hit'
				local dmg = DamageInfo()
				if b then dmg:SetDamage( 0 ) else dmg:SetDamage( npc_antlion_guard_melee_throw_damage:GetFloat() ) end
				if isfunction( vec ) then vec = vec( self ) end
				if vec then dmg:SetDamageForce( vec ) SetVelocity( ent, vec ) end
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				ent:TakeDamageInfo( dmg )
			end
			b = true
		end
	end )
end

local npc_antlion_guard_run_speed = CreateConVar(
	'npc_antlion_guard_run_speed',
	300,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Run Speed"
)
local npc_antlion_guard_jump_height = CreateConVar(
	'npc_antlion_guard_jump_height',
	300,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Jump Height"
)

sound.Add {
	name = 'Antlion_Guard_NoiseLoop',
	sound = 'npc/antlion_guard/growl_high.wav',
	pitch = 100,
	level = 150,
	channel = CHAN_AUTO
}

//ENT.bCharging = false
function ENT:_HandleStateChanges()
	if self.bCharging then
		self.bCharging = nil
		self:PlaySequenceAndWaitC( 'charge_stop', 1, nil, nil, nil, true )
	end
end

local npc_antlion_guard_turn = CreateConVar(
	'npc_antlion_guard_turn',
	180,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Turn"
)
local npc_antlion_guard_charge_chance = CreateConVar(
	'npc_antlion_guard_charge_chance',
	10000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Chance"
)
local npc_antlion_guard_charge_speed = CreateConVar(
	'npc_antlion_guard_charge_speed',
	450,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Speed"
)
local npc_antlion_guard_charge_turn = CreateConVar(
	'npc_antlion_guard_charge_turn',
	40,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Turn"
)
local npc_antlion_guard_charge_crash_size = CreateConVar(
	'npc_antlion_guard_charge_crash_size',
	128,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"If a Charging `npc_antlion_guard` Hits Something Bigger Than This, Consider It a Crash"
)
local npc_antlion_guard_charge_backfire = CreateConVar(
	'npc_antlion_guard_charge_backfire',
	.2,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"If an `npc_antlion_guard` Crashes, It will Take ( Charge Damage * This ) Damage"
)
local npc_antlion_guard_charge_damage = CreateConVar(
	'npc_antlion_guard_charge_damage',
	800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Damage"
)
local npc_antlion_guard_charge_force = CreateConVar(
	'npc_antlion_guard_charge_force',
	3200,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Force"
)
local npc_antlion_guard_charge_force_enemy_scale = CreateConVar(
	'npc_antlion_guard_charge_force_enemy_scale',
	.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Charge Force"
)

local npc_antlion_guard_intercept = CreateConVar(
	'npc_antlion_guard_intercept',
	2,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"If an `npc_antlion_guard` is Closer to Its Enemy Than Its Current Speed Multiplied by This, Try to Intercept"
)

local npc_antlion_guard_phys_mass_max = CreateConVar(
	'npc_antlion_guard_phys_mass_max',
	500,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"An `npc_antlion_guard` will Not Try to Throw Physics Objects Who's Mass is Bigger Than This at The Enemy"
)

//ENT.PhysTarget = NULL

function ENT:CombatBehaviour( enemy )
	local NoiseLoop = self.NoiseLoop
	self.bNoThreat = nil
	if self.bCharging then
		self:NewActivity( self:SeqAct 'charge_loop' )
		NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), 1, FrameTime() ) )
		NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), 100, FrameTime() * 100 ) )
		local v, s = GetVelocity( self ), npc_antlion_guard_charge_speed:GetFloat()
		SetVelocity( self, CalcAcceleration( self:GetForward() * s, v, s * ACCELERATION_NORMAL ) )
		self.loco:SetDesiredSpeed( 0 )
		self.loco:SetAcceleration( 0 )
		self.loco:SetDeceleration( 0 )
		self.loco:SetDeathDropHeight( 999999 )
		self.loco:SetAvoidAllowed( true )
		self.loco:SetClimbAllowed( false )
		self.loco:SetJumpHeight( 0 )
		self:SetMaxYawSpeed( npc_antlion_guard_charge_turn:GetFloat() )
		self:SetMoveTarget( enemy:GetPos() )
		self:ComputePath()
		self:Advance()
		if self:GetPos():Distance( enemy:GetPos() ) < s * npc_antlion_guard_intercept:GetFloat() then
			self:SetLookAngle( ( enemy:GetPos() + ( GetVelocity( enemy ) * ( enemy:GetPos():Distance( self:GetPos() ) / npc_antlion_guard_charge_speed:GetFloat() ) ) - self:GetPos() ):Angle(), ( enemy:GetPos() - self:GetPos() ):Angle() )
		else
			local goal = self.MovePath:GetCurrentGoal()
			if goal then self:SetLookAngle( goal.forward, ( enemy:GetPos() - self:GetPos() ):Angle() ) end
		end
		local tr = self:GetMeleeTrace()
		if tr.Hit then
			local ent = tr.Entity
			if IsValid( ent ) && ( self:IsHateDisp( ent ) || ent:GetSize() <= npc_antlion_guard_charge_crash_size:GetFloat() ) then
				self:EmitSound 'Antlion_Guard_Hit'
				local dmg = DamageInfo()
				dmg:SetDamage( npc_antlion_guard_charge_damage:GetFloat() )
				dmg:SetDamageForce( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_charge_force:GetFloat() * ( self:IsHateDisp( ent ) && npc_antlion_guard_charge_force_enemy_scale:GetFloat() || 1 ) )
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				SetVelocity( ent, dmg:GetDamageForce() )
				ent:TakeDamageInfo( dmg )
				self.bCharging = nil
				self:PlaySequenceAndWaitC( 'charge_stop', 1 )
			else
				self:EmitSound 'Antlion_Guard_Hit'
				local dmg = DamageInfo()
				dmg:SetDamage( npc_antlion_guard_charge_damage:GetFloat() )
				dmg:SetDamageForce( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_charge_force:GetFloat() * ( self:IsHateDisp( ent ) && npc_antlion_guard_charge_force_enemy_scale:GetFloat() || 1 ) )
				dmg:SetDamageType( DMG_CLUB )
				dmg:SetAttacker( self )
				dmg:SetInflictor( self )
				SetVelocity( ent, dmg:GetDamageForce() )
				ent:TakeDamageInfo( dmg )
				dmg:SetDamage( dmg:GetDamage() * npc_antlion_guard_charge_backfire:GetFloat() )
				dmg:SetDamageForce( Vector( 0, 0, 0 ) )
				self:TakeDamageInfo( dmg )
				self.bCharging = nil
				self:PlaySequenceAndWaitC( table.Random { 'charge_crash', 'charge_crash2', 'charge_crash3', 'charge_crash02', 'charge_crash03' }, 1 )
			end
		end
		return
	end
	local tar = self.PhysTarget
	if IsValid( tar ) && tar:Visible( enemy ) && tar != enemy && tar:GetPos():DistToSqr( self:GetPos() ) < self:GetPos():DistToSqr( enemy:GetPos() ) then
		local ent, b = self:GetMeleeTarget()
		if IsValid( ent ) then
			if tar == ent then
				if tar:GetPos():DistToSqr( enemy:GetPos() ) < self:GetPos():DistToSqr( enemy:GetPos() ) then
					if tar:GetPos():Distance( enemy:GetPos() ) <= npc_antlion_guard_melee_throw_force:GetFloat() then
						self:MeleeThrowC( function() local r = pcall_ret( function() return CalcThrow( tar:GetCenter(), enemy:GetCenter(), npc_antlion_guard_melee_throw_force:GetFloat() ) end ) if isvector( r ) then return r end end, true )
					else
						self:MeleeShoveC( function() local r = pcall_ret( function() return CalcThrow( tar:GetCenter(), enemy:GetCenter(), npc_antlion_guard_melee_shove_force:GetFloat() ) end ) if isvector( r ) then return r end end, true )
					end
				else b = true end
			else
				if ent:Health() <= ( npc_antlion_guard_melee_throw_damage:GetFloat() * DAMAGE_MULTIPLIER_MIN ) then
					self:MeleeThrowC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_throw_force:GetFloat() * npc_antlion_guard_melee_throw_force_enemy_scale:GetFloat() )
				else
					if rand( 3 ) == 1 then
						self:MeleeThrowC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_throw_force:GetFloat() * npc_antlion_guard_melee_throw_force_enemy_scale:GetFloat() )
					else
						self:MeleeShoveC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_shove_force:GetFloat() * npc_antlion_guard_melee_shove_force_enemy_scale:GetFloat() )
					end
				end
			end
		else b = true end
		if b then
			self:SetMoveTarget( tar:GetPos() + ( tar:GetPos() - enemy:GetPos() ):GetNormalized() * 32 )
			self:ComputePath()
			local vel = GetVelocity( self )
			self.loco:SetDesiredSpeed( npc_antlion_guard_run_speed:GetFloat() )
			self.loco:SetAcceleration( npc_antlion_guard_run_speed:GetFloat()* ACCELERATION_NORMAL )
			self:Advance()
			local ang = #vel < 10 && vel:Angle() || self:GetAngles()
			local goal = self.MovePath:GetCurrentGoal()
			if goal then ang = goal.forward:Angle() end
			self:SetLookAngle( ang, ( enemy:GetPos() - self:GetPos() ):Angle() )
			self:NewActivity( #vel < 10 && ACT_IDLE || ACT_RUN )
			NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
			self.loco:SetDeceleration( self.loco:GetAcceleration() )
			self.loco:SetDeathDropHeight( 999999 )
			self.loco:SetAvoidAllowed( true )
			self.loco:SetClimbAllowed( false )
			self.loco:SetJumpHeight( npc_antlion_guard_jump_height:GetFloat() )
			self:SetMaxYawSpeed( npc_antlion_guard_turn:GetFloat() )
			if self:Visible( enemy ) && rand( npc_antlion_guard_charge_chance:GetFloat() * 3 * FrameTime() ) == 1 then
				self.bCharging = true
				self:EmitSound 'Antlion_Guard_Warning'
				self:PlaySequenceAndWaitC( 'charge_startfast', 1 )
			end
		end
		return
	else
		if rand( 5000 * FrameTime() ) == 1 then
			local npd, m, n, np = self:GetPos():DistToSqr( enemy:GetPos() ), npc_antlion_guard_phys_mass_max:GetFloat(), sqr( npc_antlion_guard_melee_shove_force:GetFloat() * 2 )
			for _, ent in ipairs( ents.FindInSphere( self:GetPos(), 1024 ) ) do
				if ent == enemy || self:Disposition( ent ) == D_LI then continue end
				ent:SetPhysicsAttacker( self )
				local p = ent:GetPhysicsObject()
				if !IsValid( p ) || p:GetMass() > m then continue end
				local d = self:GetPos():DistToSqr( ent:GetPos() )
				if d >= npd || ent:GetPos():DistToSqr( enemy:GetPos() ) > n || !ent:Visible( enemy ) then continue end
				np, npd = ent, d
			end
			self.PhysTarget = np
		else self.PhysTarget = nil end
	end
	NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), .5, FrameTime() ) )
	self:SetMoveTarget( lmax( 0, self.flEnemyDamage - self.flAllyWeight ) > ( self:Health() * 2 ) && self:FindRunWay( enemy:GetPos() ) || enemy:GetPos() )
	/*
	local b = lmax( 0, self.flEnemyDamage - self.flAllyWeight ) > self:Health()
	if b then self.bNoThreat = true else self.bNoThreat = nil end
	self:SetMoveTarget( b && self:FindRunWay( enemy:GetPos() ) || enemy:GetPos() )
	*/
	self:ComputePath()
	local vel = GetVelocity( self )
	local s = npc_antlion_guard_run_speed:GetFloat()
	self.loco:SetDesiredSpeed( s )
	self.loco:SetAcceleration( s * ACCELERATION_NORMAL )
	if self:GetPos():Distance( enemy:GetPos() ) < s * npc_antlion_guard_intercept:GetFloat() then
		local vec = enemy:GetPos() + ( GetVelocity( enemy ) * ( enemy:GetPos():Distance( self:GetPos() ) / s ) )
		self:SetLookAngle( ( vec - self:GetPos() ):Angle(), ( enemy:GetPos() - self:GetPos() ):Angle() )
		self.loco:Approach( vec, 1 )
	else
		self:Advance()
		local ang = #vel < 10 && vel:Angle() || self:GetAngles()
		local goal = self.MovePath:GetCurrentGoal()
		if goal then ang = goal.forward:Angle() end
		self:SetLookAngle( ang, ( enemy:GetPos() - self:GetPos() ):Angle() )
	end
	local v = #vel
	self:NewActivity( v < 10 && ACT_IDLE || ACT_RUN )
	NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( npc_antlion_guard_jump_height:GetFloat() )
	self:SetMaxYawSpeed( npc_antlion_guard_turn:GetFloat() )
	self.bMusicActive = self:Visible( enemy )
	self.flCombatState = -1
	local ent = self:GetMeleeTarget()
	if IsValid( ent ) then
		if ent:Health() <= ( npc_antlion_guard_melee_throw_damage:GetFloat() * DAMAGE_MULTIPLIER_MIN ) then
			self:MeleeThrowC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_throw_force:GetFloat() * npc_antlion_guard_melee_throw_force_enemy_scale:GetFloat() )
		else
			if rand( 3 ) == 1 then
				self:MeleeThrowC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_throw_force:GetFloat() * npc_antlion_guard_melee_throw_force_enemy_scale:GetFloat() )
			else
				self:MeleeShoveC( ( self:GetForward() + self:GetUp() * math.Rand( 0, 1 ) ):GetNormalized() * npc_antlion_guard_melee_shove_force:GetFloat() * npc_antlion_guard_melee_shove_force_enemy_scale:GetFloat() )
			end
		end
	else
		if self:Visible( enemy ) && rand( npc_antlion_guard_charge_chance:GetFloat() * FrameTime() ) == 1 then
			self.bCharging = true
			self:EmitSound 'Antlion_Guard_Warning'
			self:PlaySequenceAndWaitC( 'charge_startfast', 1 )
		end
	end
end

local npc_antlion_guard_hostile_chance_min = CreateConVar(
	'npc_antlion_guard_hostile_chance_min',
	20000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Attack Chance when Hungry"
)

local npc_antlion_guard_hostile_chance_max = CreateConVar(
	'npc_antlion_guard_hostile_chance_max',
	100000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Attack Chance when Not Hungry"
)

local npc_antlion_guard_hostile_attack_chance_min = CreateConVar(
	'npc_antlion_guard_hostile_chance_min',
	10000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Chance to Go into The Actual Attacking Phase After Stalking a Target when Hungry"
)

local npc_antlion_guard_hostile_attack_chance_max = CreateConVar(
	'npc_antlion_guard_hostile_chance_max',
	100000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Chance to Go into The Actual Attacking Phase After Stalking a Target when Not Hungry"
)

local npc_antlion_guard_hostile_length_min = CreateConVar(
	'npc_antlion_guard_hostile_length_min',
	CREATURE_HOSTILE_LENGTH_MIN || 0,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard` will Chase Prey for This Amount of Time"
)

local npc_antlion_guard_hostile_length_max = CreateConVar(
	'npc_antlion_guard_hostile_length_max',
	CREATURE_HOSTILE_LENGTH_MAX || 0,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard` will Chase Prey for This Amount of Time"
)

local npc_antlion_guard_hostile_ally_count = CreateConVar(
	'npc_antlion_guard_hostile_ally_count',
	6,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard` will Not Share Information About Its Prey to More Than This Allies"
)

local npc_antlion_guard_hostile_dist = CreateConVar(
	'npc_antlion_guard_hostile_dist',
	3000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard` will Not Go After Prey This Far Away or Farther"
)

local npc_antlion_guard_stalk_dist = CreateConVar(
	'npc_antlion_guard_stalk_dist',
	CREATURE_STALK_DISTANCE || 0,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Stalking Distance"
)

local npc_antlion_guard_walk_speed = CreateConVar(
	'npc_antlion_guard_walk_speed',
	75,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Walk Speed"
)

function ENT:GetAltHateDistLength() return math.Remap( self.flHunger, 0, 1, npc_antlion_guard_hostile_length_min:GetFloat(), npc_antlion_guard_hostile_length_max:GetFloat() ) end

function ENT:_HandleHungerAttack()
	local ent = self.StalkTarget
	if IsValid( ent ) && ent:GetPos():Distance( self:GetPos() ) < npc_antlion_guard_hostile_dist:GetFloat() then
		self.tAltHateDistIgnore[ ent ] = CurTime() + 1
		local NoiseLoop = self.NoiseLoop
		NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), .25, FrameTime() ) )
		self.bNoThreat = true
		if !self:GetMoveTarget() || self:GetMoveTarget():Distance( self:GetPos() ) < self.iPathTol || self:GetMoveTarget():Distance( ent:GetPos() ) > npc_antlion_guard_stalk_dist:GetFloat() then self:SetDistMoveTargetForVector( ent:GetPos(), npc_antlion_guard_stalk_dist:GetFloat() ) end
		local vel = GetVelocity( self )
		local ang = #vel < 10 && vel:Angle() || self:GetAngles()
		local goal = self.MovePath:GetCurrentGoal()
		if goal then ang = goal.forward:Angle() end
		self:ComputePath()
		local v = #GetVelocity( self )
		if self:GetPos():Distance( self:GetMoveTarget() ) < 1000 then
			self.loco:SetDesiredSpeed( npc_antlion_guard_walk_speed:GetFloat() )
			self.loco:SetAcceleration( npc_antlion_guard_walk_speed:GetFloat() * ACCELERATION_NORMAL )
			self:NewActivity( v < 10 && ACT_IDLE || ACT_WALK )
		else
			self.loco:SetDesiredSpeed( npc_antlion_guard_run_speed:GetFloat() )
			self.loco:SetAcceleration( npc_antlion_guard_run_speed:GetFloat() * ACCELERATION_NORMAL )
			self:NewActivity( v < 10 && ACT_IDLE || ACT_RUN )
		end
		NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
		self.loco:SetDeceleration( self.loco:GetAcceleration() )
		self.loco:SetDeathDropHeight( 999999 )
		self.loco:SetAvoidAllowed( true )
		self.loco:SetClimbAllowed( false )
		self.loco:SetJumpHeight( 0 )
		self:Advance()
		local d
		local goal = self.MovePath:GetCurrentGoal()
		if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
		if !d then d = ( self.vMoveToPos - self:GetPos() ):GetNormalized() end
		self:SetLookAngle( d, ( ent:GetPos() - self:GetPos() ):Angle() )
		if rand( math.Remap( self:GetPos():Distance( ent:GetPos() ), 0, npc_antlion_guard_stalk_dist:GetFloat(), npc_antlion_guard_hostile_attack_chance_max:GetFloat(), npc_antlion_guard_hostile_attack_chance_min:GetFloat() ) * FrameTime() ) == 1 then
			local tm = CurTime() + math.Remap( self.flHunger, 0, 1, npc_antlion_guard_hostile_length_min:GetFloat(), npc_antlion_guard_hostile_length_max:GetFloat() )
			self.tThreat[ ent ] = tm
			local t = {}
			for _, ally in ipairs( self:HaveAllies() ) do if ally.__ACTOR__ && ally.bAttackStalkTarget then table.insert( t, ally ) end end
			if !table.IsEmpty( t ) then
				local n, i, m = {}, 0, rand( 0, npc_antlion_guard_hostile_ally_count:GetInt() )
				while i <= m && !table.IsEmpty( t ) do
					local ent, k = table.Random( t )
					t[ k ] = nil
					table.insert( n, ent )
				end
				for _, ally in ipairs( n ) do ally.tThreat[ ent ] = tm end
				return true
			end
		end
		return true
	else self.StalkTarget = nil end
	if rand( math.Remap( self.flHunger, 0, 1, npc_antlion_guard_hostile_chance_max:GetFloat(), npc_antlion_guard_hostile_chance_min:GetFloat() ) * FrameTime() ) == 1 then
		local nhh, nhf, nh = math.huge, math.huge
		local ds, mx = npc_antlion_guard_melee_throw_damage:GetFloat() * ( ( DAMAGE_MULTIPLIER_MIN + DAMAGE_MULTIPLIER_MAX ) * .5 ), npc_antlion_guard_hostile_dist:GetFloat()
		for _, ent in pairs( self.tHostiles ) do
			if !IsValid( ent ) || ent:GetPos():Distance( self:GetPos() ) > mx then continue end
			local h = ent:Health()
			if h >= nhh then continue end
			local d = abs( ds - h )
			if d > nhf then continue end
			nh, nhh, nhf = ent, h, d
		end
		if IsValid( nh ) then
			self.StalkTarget = nh
			local t = {}
			for _, ally in ipairs( self:HaveAllies() ) do if ally.__ACTOR__ && ally.bAttackStalkTarget then table.insert( t, ally ) end end
			if !table.IsEmpty( t ) then
				local n, i, m = {}, 0, rand( 0, npc_antlion_guard_hostile_ally_count:GetInt() )
				while i <= m && !table.IsEmpty( t ) do
					local ent, k = table.Random( t )
					t[ k ] = nil
					table.insert( n, ent )
				end
				for _, ally in ipairs( n ) do ally.StalkTarget = nh end
			end
			return true
		end
	end
end

function ENT:AlertBehaviour( vLastAlertPos )
	self:SetMaxYawSpeed( npc_antlion_guard_turn:GetFloat() )
	self:_HandleStateChanges()
	self.bNoThreat = true
	if self:_HandleHungerAttack() then return end
	local NoiseLoop = self.NoiseLoop
	NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), .1, FrameTime() ) )
	self:SetMoveTarget( vLastAlertPos )
	self:ComputePath()
	local vel = GetVelocity( self )
	local ang = #vel < 10 && vel:Angle() || self:GetAngles()
	local goal = self.MovePath:GetCurrentGoal()
	if goal then ang = goal.forward:Angle() end
	self.loco:SetDesiredSpeed( npc_antlion_guard_walk_speed:GetFloat() )
	self.loco:SetAcceleration( npc_antlion_guard_walk_speed:GetFloat() * ACCELERATION_NORMAL )
	local v = #GetVelocity( self )
	self:NewActivity( v < 10 && ACT_IDLE || ACT_WALK )
	NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( 0 )
	self:Advance()
	local d
	local goal = self.MovePath:GetCurrentGoal()
	if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
	if !d then d = ( self.vMoveToPos - self:GetPos() ):GetNormalized() end
	self:SetLookAngle( d )
end

function ENT:PatrolBehaviour( vPatrolPos )
	self:SetMaxYawSpeed( npc_antlion_guard_turn:GetFloat() )
	self:_HandleStateChanges()
	self.bNoThreat = true
	if self:_HandleHungerAttack() then return end
	local NoiseLoop = self.NoiseLoop
	NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), .1, FrameTime() ) )
	self:SetMoveTarget( vPatrolPos )
	self:ComputePath()
	local vel = GetVelocity( self )
	local ang = #vel < 10 && vel:Angle() || self:GetAngles()
	local goal = self.MovePath:GetCurrentGoal()
	if goal then ang = goal.forward:Angle() end
	self.loco:SetDesiredSpeed( npc_antlion_guard_walk_speed:GetFloat() )
	self.loco:SetAcceleration( npc_antlion_guard_walk_speed:GetFloat() * ACCELERATION_NORMAL )
	local v = #GetVelocity( self )
	self:NewActivity( v < 10 && ACT_IDLE || ACT_WALK )
	NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( 0 )
	self:Advance()
	local d
	local goal = self.MovePath:GetCurrentGoal()
	if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
	if !d then d = ( self.vMoveToPos - self:GetPos() ):GetNormalized() end
	self:SetLookAngle( d )
end

function ENT:IdleBehaviour()
	self:SetMaxYawSpeed( npc_antlion_guard_turn:GetFloat() )
	self:_HandleStateChanges()
	self.bNoThreat = true
	if self:_HandleHungerAttack() then return end
	local NoiseLoop = self.NoiseLoop
	NoiseLoop:ChangeVolume( math.Approach( NoiseLoop:GetVolume(), .05, FrameTime() ) )
	if !self:GetMoveTarget() || self:GetMoveTarget():Distance( self:GetPos() ) < self.iPathTol then self:SetWanderMoveTarget() end
	self:ComputePath()
	local vel = GetVelocity( self )
	local ang = #vel < 10 && vel:Angle() || self:GetAngles()
	local goal = self.MovePath:GetCurrentGoal()
	if goal then ang = goal.forward:Angle() end
	self.loco:SetDesiredSpeed( npc_antlion_guard_walk_speed:GetFloat() )
	self.loco:SetAcceleration( npc_antlion_guard_walk_speed:GetFloat() * ACCELERATION_NORMAL )
	local v = #GetVelocity( self )
	self:NewActivity( v < 10 && ACT_IDLE || ACT_WALK )
	NoiseLoop:ChangePitch( math.Approach( NoiseLoop:GetPitch(), clamp( math.Remap( v, 0, self.loco:GetDesiredSpeed(), 50, 100 ), 50, 100 ), FrameTime() * 100 ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( 0 )
	self:Advance()
	local d
	local goal = self.MovePath:GetCurrentGoal()
	if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
	if !d then d = ( self.vMoveToPos - self:GetPos() ):GetNormalized() end
	self:SetLookAngle( d )
end

function ENT:OnKillEntity( ent ) self.flHunger = clamp( self.flHunger - ent:GetMaxHealth() / self:GetMaxHealth(), 0, 1 ) end

function ENT:ForceTick() self.flHunger = clamp( self.flHunger + FrameTime() * .02, 0, 1 ) end

local npc_antlion_guard_stun_damage_min = CreateConVar(
	'npc_antlion_guard_stun_damage_min',
	300,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"Minimum Damage to Stun an `npc_antlion_guard`"
)
local npc_antlion_guard_stun_damage_max = CreateConVar(
	'npc_antlion_guard_stun_damage_max',
	900,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"Maximum Damage to Stun an `npc_antlion_guard`"
)
local npc_antlion_guard_stun_length_min = CreateConVar(
	'npc_antlion_guard_stun_length_min',
	1.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Minimum Stun Length"
)
local npc_antlion_guard_stun_length_max = CreateConVar(
	'npc_antlion_guard_stun_length_max',
	.5,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_guard`'s Maximum Stun Length"
)

function ENT:Damaged( d )
	if d:GetAttacker() == self then return end
	if d:GetDamage() > npc_antlion_guard_stun_damage_min:GetFloat() then
		local v = d:GetDamageForce():GetNormalized()
		self:PlaySequenceAndWait( 'physhit_' .. ( v:Dot( self:GetForward() ) > 0 && ( 'r' .. ( v:Dot( self:GetRight() ) > 0 && 'l' || 'r' ) ) || ( 'f' .. ( v:Dot( self:GetRight() ) > 0 && 'r' || 'l' ) ) ), clamp( math.Remap( d:GetDamage(), npc_antlion_guard_stun_damage_min:GetFloat(), npc_antlion_guard_stun_damage_max:GetFloat(), npc_antlion_guard_stun_length_min:GetFloat(), npc_antlion_guard_stun_length_max:GetFloat() ), npc_antlion_guard_stun_length_max:GetFloat(), npc_antlion_guard_stun_length_min:GetFloat() ) )
	end
end

list.Set( 'NPC', 'npc_antlionguard', {
	Name = '#npc_antlion_guard',
	Class = 'npc_antlion_guard',
	Category = 'Antlions',
	AdminOnly = false
} )

ENT.Class = 'npc_antlion_guard' NPC.Register( ENT )
scripted_ents.Alias( 'npc_antlionguard', 'npc_antlion_guard' )