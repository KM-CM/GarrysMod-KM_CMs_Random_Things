AddCSLuaFile()
DEFINE_BASECLASS 'base_object'

ENT.PrintName = '#object_combine_buoy'
if CLIENT then language.Add( 'object_combine_buoy', 'Combine Buoy' ) end

ENT.VisNight = true

ENT.iClass = CLASS_COMBINE
function ENT:GetNPCClass() return self.iClass end
ENT.Classify = ENT.GetNPCClass
function ENT:SetNPCClass( i ) self.iClass = i end

ENT.bCombineTerminal = true

//ENT.Terminal = NULL

function ENT:Initialize()
	self:SetModel( 'models/props_wasteland/buoy01.mdl' )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetColor( Color( 127, 127, 255 ) )
	end
end

sound.Add {
	name = 'Combine_Buoy_Siren',
	sound = 'ambient/alarms/alarm_citizen_loop1.wav',
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_Buoy_WeakSiren',
	sound = 'ambient/alarms/combine_bank_alarm_loop1.wav',
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_Buoy_Idle',
	sound = {
		'ambient/levels/citadel/zapper_warmup1.wav',
		'ambient/levels/citadel/zapper_warmup4.wav',
	},
	pitch = { 150, 200 },
	level = 130,
	channel = CHAN_AUTO
}

if SERVER then
	ENT.flBuoyancyRatio = 1
	ENT.flSwim = 0
	ENT.flSwimForward = 0
	ENT.flSwimSide = 0
	ENT.flSpeed = 0
	ENT.flNextSpeed = 0

	local npc_combine_buoy_turn = CreateConVar(
		'npc_combine_buoy_turn',
		400,
		FCVAR_NEVER_AS_STRING+
		FCVAR_CHEAT+
		FCVAR_NOTIFY+
		FCVAR_SERVER_CAN_EXECUTE,
		"`npc_combine_buoy`'s Turn Speed"
	)
	local npc_combine_buoy_speed = CreateConVar(
		'npc_combine_buoy_speed',
		4000,
		FCVAR_NEVER_AS_STRING+
		FCVAR_CHEAT+
		FCVAR_NOTIFY+
		FCVAR_SERVER_CAN_EXECUTE,
		"`npc_combine_buoy`'s Idle Top Speed"
	)
	local npc_combine_buoy_speed_alert = CreateConVar(
		'npc_combine_buoy_speed_alert',
		6000,
		FCVAR_NEVER_AS_STRING+
		FCVAR_CHEAT+
		FCVAR_NOTIFY+
		FCVAR_SERVER_CAN_EXECUTE,
		"`npc_combine_buoy`'s Alert Top Speed"
	)
	local npc_combine_buoy_speed_combat = CreateConVar(
		'npc_combine_buoy_speed_combat',
		8000,
		FCVAR_NEVER_AS_STRING+
		FCVAR_CHEAT+
		FCVAR_NOTIFY+
		FCVAR_SERVER_CAN_EXECUTE,
		"`npc_combine_buoy`'s Combat Top Speed"
	)
	function ENT:Think()
		local p = self:GetPhysicsObject()
		if IsValid( p ) then
			p:SetBuoyancyRatio( self.flBuoyancyRatio )
			local s, a = npc_combine_buoy_turn:GetFloat(), self:GetAngles()
			p:AddAngleVelocity( Vector( math.AngleDifference( 0, a.r ) * s, math.AngleDifference( 0, a.p ) * s, 0 ) * FrameTime() )
			if self:WaterLevel() != 0 then
				if rand( 20000 * FrameTime() ) == 1 then self:EmitSound( 'Combine_Buoy_Idle' ) end
				if CurTime() > self.flNextSpeed then
					local var = npc_combine_buoy_speed:GetFloat()
					if IsValid( self.Terminal ) then
						if self.Terminal.bSirens then npc_combine_buoy_speed_combat:GetFloat()
						elseif self.Terminal.bWeakSirens then var = npc_combine_buoy_speed_alert:GetFloat()
						else var = npc_combine_buoy_speed:GetFloat() end
					end
					self.flSpeed = var * math.Rand( 0, 1 )
					self.flNextSpeed = CurTime() + math.Rand( 0, 3 )
				end
				if CurTime() > self.flSwim then
					self.flSwimForward = math.Rand( -1, 1 )
					self.flSwimSide = math.Rand( -1, 1 )
					self.flSwim = CurTime() + math.Rand( 0, 3 )
				end
				self:GetPhysicsObject():AddVelocity( ( self:GetForward() * self.flSwimForward + self:GetRight() * self.flSwimSide ):GetNormalized() * self.flSpeed * FrameTime() )
			end
		end
		if !IsValid( self.Terminal ) then
			if self.Siren then self.Siren:Stop() self.Siren = nil end
			if self.WeakSiren then self.WeakSiren:Stop() self.WeakSiren = nil end
			return
		end
		if rand( self.Terminal:GetChangeChance() ) == 1 then
			if self.Terminal.bSirens then
				if self.WeakSiren then self.WeakSiren:Stop() self.WeakSiren = nil end
				if !self.Siren then
					self.Siren = CreateSound( self, 'Combine_Buoy_Siren' )
					self.Siren:Play()
				end
			elseif self.Terminal.bWeakSirens then
				if self.Siren then self.Siren:Stop() self.Siren = nil end
				if !self.WeakSiren then
					self.WeakSiren = CreateSound( self, 'Combine_Buoy_WeakSiren' )
					self.WeakSiren:Play()
				end
			else
				if self.Siren then self.Siren:Stop() self.Siren = nil end
				if self.WeakSiren then self.WeakSiren:Stop() self.WeakSiren = nil end
			end
		end
	end

	function ENT:OnRemove()
		if self.Siren then self.Siren:Stop() self.Siren = nil end
		if self.WeakSiren then self.WeakSiren:Stop() self.WeakSiren = nil end
	end
end

list.Set( 'SpawnableEntities', 'object_combine_buoy', {
	PrintName = '#object_combine_buoy',
	ClassName = 'object_combine_buoy',
	Category = 'Combine'
} )
