AddCSLuaFile()

ENT.Name = 'Developer Dummy - Aim'

ENT.iClass = CLASS_COMBINE
function ENT:GetRelationship( ent ) return ( ent.Classify && ent:Classify() || 0 ) == self:Classify() && D_LI || D_HT end

ENT.bUseFindLookAng = false

local dev_npc_dummy_aim_health = CreateConVar(
	'dev_npc_dummy_aim_health',
	100,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`dev_npc_dummy_aim`'s Health"
)
function ENT:Init()
	self:SetModel( 'models/combine_soldier.mdl' )
	if SERVER then
		self:SetHealth( dev_npc_dummy_aim_health:GetInt() )
		self:SetMaxHealth( dev_npc_dummy_aim_health:GetInt() )
		self:DefaultWeapon( 'weapon_smg1' )
	end
	self:SetCollisionBounds( Vector( -16, -16, 0 ), Vector( 16, 16, 70 ) )
end

local dev_npc_dummy_aim_turnrate = CreateConVar(
	'dev_npc_dummy_aim_turnrate',
	400,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`dev_npc_dummy_aim`'s Yaw Rate"
)
local dev_npc_dummy_aim_shoots = CreateConVar(
	'dev_npc_dummy_aim_shoots',
	0,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"Should `dev_npc_dummy_aim` Shoot?",
	0, 1
)
local dev_npc_dummy_aim_activity = CreateConVar(
	'dev_npc_dummy_aim_activity',
	'ACT_IDLE_ANGRY',
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"`dev_npc_dummy_aim`'s Activity",
	0, 1
)
function ENT:CombatBehaviour( enemy )
	self:SetMaxYawSpeed( dev_npc_dummy_aim_turnrate:GetFloat() )
	self.vAim = enemy:GetCenter()
	if dev_npc_dummy_aim_shoots:GetInt() == 1 && self:IsShootable( self.vAim ) && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
	self.vAim = ( self.vAim - self:GetShootPos() ):GetNormalized()
	self:SetLookAngle( self.vAim )
	local v = _G[ dev_npc_dummy_aim_activity:GetString() ]
	if v == nil then v = ACT_IDLE_ANGRY end
	self:NewActivity( v )
end

list.Set( 'NPC', 'dev_npc_dummy_aim', {
	Name = 'Aim',
	Class = 'dev_npc_dummy_aim',
	Category = 'Developer',
	AdminOnly = false
} )

ENT.Class = 'dev_npc_dummy_aim' NPC.Register( ENT )
