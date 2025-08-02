/*////////////////////////////////////////////////////////

Augmented SuperSoldiers. Only Loyal to The Combine.

////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.Name = "Combine Soldier"

ENT.vHullMins = VECTOR_HULL_HUMAN_MINS
ENT.vHullMaxs = VECTOR_HULL_HUMAN_MAXS
ENT.vHullDuckMins = VECTOR_HULL_HUMAN_DUCK_MINS
ENT.vHullDuckMaxs = VECTOR_HULL_HUMAN_DUCK_MAXS

ENT.VisNight = true
ENT.iVehAct = ACT_IDLE_ANGRY

ENT.GAME_HearDistMul = 1.66

ENT.iClass = CLASS_COMBINE

local npc_combine_soldier_health = CreateConVar(
	'npc_combine_soldier_health',
	400,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Health"
)
function ENT:Init()
	self:SetModel 'models/combine_soldier.mdl'
	self:SetHealth( npc_combine_soldier_health:GetInt() )
	self:SetMaxHealth( npc_combine_soldier_health:GetInt() )
	self:DefaultWeapon 'weapon_ar2'
	self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
	self:CreateMoveBlendMotor()
end

local npc_combine_soldier_run_speed = CreateConVar(
	'npc_combine_soldier_run_speed',
	250,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Run Speed"
)
local npc_combine_soldier_prowl_speed = CreateConVar(
	'npc_combine_soldier_prowl_speed',
	150,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Prowl Speed"
)
local npc_combine_soldier_walk_speed = CreateConVar(
	'npc_combine_soldier_walk_speed',
	75,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Walk Speed"
)

local npc_combine_soldier_jump_height = CreateConVar(
	'npc_combine_soldier_jump_height',
	200,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Jump Height"
)

local npc_combine_soldier_turn = CreateConVar(
	'npc_combine_soldier_turn',
	300,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_combine_soldier`'s Turn Rate"
)

function ENT:ForceTick()
	self.flTopSpeed = npc_combine_soldier_run_speed:GetFloat()
	self:SetMaxYawSpeed( npc_combine_soldier_turn:GetFloat() )
	self:MI_CalcCombatState()
end

function ENT:A_CombatMove( dir, flSpeed, flHeight, bAim, tFilter )
	if !self.bNoPhysics then return end
	local odir = dir
	dir, flHeight = self:AddMovementMixins( dir, flHeight, tFilter )
	if !dir || !flHeight then return end
	self.dLastMotion = dir
	local s = self.flTopSpeed * flSpeed
	self.MoveBlendMotor:SetPrimarySequence( self:SelectWeightedSequence( self:ActWep( s < npc_combine_soldier_walk_speed:GetFloat() && ( bAim && ACT_WALK_AIM || ACT_WALK ) || ( bAim && ACT_RUN_AIM || ACT_RUN ) ) ) )
	self.loco:SetDesiredSpeed( s )
	self.loco:SetAcceleration( ( s * ACCELERATION_NORMAL ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( npc_combine_soldier_jump_height:GetFloat() )
	self.loco:Approach( self:GetPos() + dir, 1 )
end

function ENT:A_CalcCombatStandSequence( flHeight ) return self:SelectWeightedSequence( self:ActWep( flHeight < .5 && ACT_CROUCHIDLE || ACT_IDLE_ANGRY ) ) end
function ENT:A_CombatStand( ... ) self:A_MaintainVelocity() self.MoveBlendMotor:SetRatioTarget( 1 ) self.MoveBlendMotor:SetSecondarySequence( self:A_CalcCombatStandSequence( ... ) ) end

local VOICE_PITCH_MIN, VOICE_PITCH_MAX = 90, 110

sound.Add {
	name = 'Combine_Soldier_Death',
	sound = {
		'npc/combine_soldier/die1.wav',
		'npc/combine_soldier/die2.wav',
		'npc/combine_soldier/die3.wav'
	},
	pitch = { VOICE_PITCH_MIN, VOICE_PITCH_MAX },
	level = 150,
	channel = CHAN_VOICE
}

function ENT:OnDeath( d ) self:DeathMessage( d ) self:EmitSound 'Combine_Soldier_Death' self:BecomeRagdoll( d ) end

function ENT:CHAT_CanMove() return self:CanExpose() end
function ENT:CHAT_Move() self:SetSchedule 'COVER_MOVE' end

ENT.CHAT_CanMoveForward = ENT.CHAT_CanMove
function ENT:CHAT_MoveForward() self:SetSchedule 'TAKE_COVER_ADVANCE' end

ENT.CHAT_CanMoveBackward = ENT.CHAT_CanMove
function ENT:CHAT_MoveBackward() self:SetSchedule 'TAKE_COVER_RETREAT' end

function ENT:SelectSchedule( prev, pret )
	if IsValid( self.Enemy ) || !table.IsEmpty( self.tEnemies ) then
		self:SetSchedule 'COMBAT_SOLDIER'
	end
end

function ENT:Behaviour() self:SCHEDULE() end

list.Set( 'NPC', 'npc_combine_s', {
	Name = '#npc_combine_soldier',
	Class = 'npc_combine_soldier',
	Category = 'Combine',
	AdminOnly = false
} )

ENT.Class = 'npc_combine_soldier' NPC.Register( ENT )
scripted_ents.Alias( 'npc_combine_s', 'npc_combine_soldier' )