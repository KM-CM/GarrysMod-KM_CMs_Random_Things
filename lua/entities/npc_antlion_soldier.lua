/*////////////////////////////////////////////////////////

Extremely Dangerous Bugs. Cant See, Rely on Sound and Smell.

////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.vHullMins = VECTOR_HULL_HUMAN_DUCK_MINS
ENT.vHullMaxs = VECTOR_HULL_HUMAN_DUCK_MAXS
ENT.vHullDuckMins = ENT.vHullMins
ENT.vHullDuckMaxs = ENT.vHullMaxs

ENT.Name = "Antlion Soldier"

ENT.HAS_MELEE_ATTACK = true

ENT.VisNight = true
ENT.iVehAct = ACT_IDLE_ANGRY

ENT.GAME_HearDistMul = 3

ENT.iClass = CLASS_ANTLION

local npc_antlion_soldier_health = CreateConVar(
	'npc_antlion_soldier_health',
	600,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Health"
)
function ENT:Init()
	self:SetModel 'models/antlion.mdl'
	self:SetSkin( rand( 0, 3 ) )
	self:SetHealth( npc_antlion_soldier_health:GetInt() )
	self:SetMaxHealth( npc_antlion_soldier_health:GetInt() )
	self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
	self:SetBloodColor( BLOOD_COLOR_ANTLION )
end

local npc_antlion_soldier_run_speed = CreateConVar(
	'npc_antlion_soldier_run_speed',
	500,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Run Speed"
)
local npc_antlion_soldier_prowl_speed = CreateConVar(
	'npc_antlion_soldier_prowl_speed',
	150,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Prowl Speed"
)
local npc_antlion_soldier_walk_speed = CreateConVar(
	'npc_antlion_soldier_walk_speed',
	75,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Walk Speed"
)

local npc_antlion_soldier_jump_height = CreateConVar(
	'npc_antlion_soldier_jump_height',
	800,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Jump Height"
)

local npc_antlion_soldier_turn = CreateConVar(
	'npc_antlion_soldier_turn',
	300,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`npc_antlion_soldier`'s Turn Rate"
)

function ENT:ForceTick()
	self.flTopSpeed = npc_antlion_soldier_run_speed:GetFloat()
	self:SetMaxYawSpeed( npc_antlion_soldier_turn:GetFloat() )
	self:MI_CalcCombatState()
end

function ENT:A_CombatMove( dir, flSpeed, _, _, tFilter )
	if !self.bNoPhysics then return end
	dir = self:AddMovementMixins( dir, 1, tFilter )
	if !dir then return end
	self.dLastMotion = dir
	local s = self.flTopSpeed * flSpeed
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE || s < npc_antlion_soldier_walk_speed:GetFloat() && ACT_WALK || ACT_RUN )
	self.loco:SetDesiredSpeed( s )
	self.loco:SetAcceleration( ( s * ACCELERATION_NORMAL ) )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( npc_antlion_soldier_jump_height:GetFloat() )
	self.loco:Approach( self:GetPos() + dir, 1 )
end

sound.Add {
	name = 'Antlion_Soldier_FlyLoop',
	sound = 'npc/antlion/fly1.wav',
	level = 150,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Antlion_Soldier_Land',
	sound = 'npc/antlion/land1.wav',
	level = 150,
	channel = CHAN_AUTO
}

ENT.INTEL_AntlionJumpIntercept = true

if SERVER then
	function ENT:CustomOnRemove() if self.FlyLoop then self.FlyLoop:Stop() self.FlyLoop = nil end end
	function ENT:OnLandOnGround()
		self:EmitSound 'Antlion_Soldier_Land'
		self:PlaySequenceAndWait( 'jump_stop', clamp( math.Remap( self:Health(), 0, self:GetMaxHealth(), .5, 1.25 ), .5, 1.25 ) )
	end
	function ENT:Jump( cg )
		if isvector( cg ) then cg = { pos = cg } end
		local dir = ( cg.pos - self:GetPos() ):GetFlat():GetNormalized()
		local ang = dir:Angle()
		self:ExecInRB( function( self )
			while self:GetForward():Dot( dir ) <= .97 do self:A_MaintainVelocity() self:SetLookAngle( ang ) coroutine.yield() end
			self:PlaySequenceAndWaitC( 'fly_in', clamp( math.Remap( self:Health(), 0, self:GetMaxHealth(), .5, 1.25 ), .5, 1.25 ), nil, nil, function( self )
				local old = self.loco:GetJumpHeight()
				self.loco:SetJumpHeight( lmin( old, cg.pos:Distance( self:GetPos() ) ) )
				if cg.type == 3 then self.loco:JumpAcrossGap( cg.pos, self:GetForward() ) else self.loco:Jump() end
				self.loco:SetJumpHeight( old )
			end )
		end )
	end
end

function ENT:Tick()
	if self:IsOnGround() then
		self:SetBodygroup( 1, self.bPlaySequenceAndWait && self.sPlaySequenceAndWait == 'fly_in' && 1 || 0 )
		if self.FlyLoop then self.FlyLoop:Stop() self.FlyLoop = nil end
	else
		self:SetBodygroup( 1, 1 )
		if !self.FlyLoop then
			local FlyLoop = CreateSound( self, 'Antlion_Soldier_FlyLoop' )
			self.FlyLoop = FlyLoop
			FlyLoop:Play()
		end
	end
end

function ENT:A_CombatStand() self:A_MaintainVelocity() self:NewActivity( ACT_IDLE ) end

function ENT:A_RangeAttack() return self:A_FaceMotion() end

function ENT:SelectSchedule( prev, pret )
	local tEnemies = self.tEnemies
	if IsValid( self.Enemy ) || !table.IsEmpty( tEnemies ) then
		self:SetSchedule 'COMBAT_DOG'
	end
end

function ENT:Behaviour() self:SCHEDULE() end

sound.Add {
	name = 'Antlion_Soldier_Step',
	sound = {
		'npc/antlion/foot1.wav',
		'npc/antlion/foot2.wav',
		'npc/antlion/foot3.wav',
		'npc/antlion/foot4.wav',
	},
	level = 150,
	channel = CHAN_AUTO
}
local tSteps = {
	AE_ANTLION_WALK_FOOTSTEP = true,
	AE_ANTLION_FOOTSTEP_SOFT = true,
	AE_ANTLION_FOOTSTEP_HEAVY = true
}
function ENT:HandleAnimEvent( event ) if tSteps[ util.GetAnimEventNameByID( event ) ] then self:EmitSound 'Antlion_Soldier_Step' return true end end

list.Set( 'NPC', 'npc_antlion', {
	Name = '#npc_antlion_soldier',
	Class = 'npc_antlion_soldier',
	Category = 'Antlions',
	AdminOnly = false
} )

ENT.Class = 'npc_antlion_soldier' NPC.Register( ENT )
scripted_ents.Alias( 'npc_antlion', 'npc_antlion_soldier' )