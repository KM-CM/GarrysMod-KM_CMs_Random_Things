AddCSLuaFile()
DEFINE_BASECLASS 'base_grenade'

function ENT:Init()
	self:SetModel 'models/weapons/w_grenade.mdl'
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetColor( Color( 127, 127, 255 ) )
	end
end

if !SERVER then return end

ENT.EXPLOSION_MAGNITUDE = 50

function ENT:Think()
	if !self.GRENADE_TIME || CurTime() <= self.GRENADE_TIME then return end
	local exp = ents.Create 'env_explosion'
	exp:SetPos( self:GetPos() )
	exp:Spawn()
	exp.flMagnitude = self.EXPLOSION_MAGNITUDE
	exp:Explode()
	self:Remove()
end
