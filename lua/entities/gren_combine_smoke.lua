AddCSLuaFile()
DEFINE_BASECLASS 'base_grenade'

function ENT:Init()
	self:SetModel 'models/weapons/w_eq_flashbang.mdl'
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetColor( Color( 127, 127, 255 ) )
	end
end

if !SERVER then return end

function ENT:IsSmoking( vec ) return self:GetPos():Distance( vec ) < ( self.SMOKE_SIZE * 5 ) end

ENT.SMOKE_TIME = 20
ENT.SMOKE_TURN = 45
ENT.SMOKE_SIZE = 200
ENT.SMOKE_SPEED = 20
ENT.SMOKE_TRANSPARENCY = 255

//ENT.flRemoveTime = nil
//ENT.Smoke = NULL

function ENT:Think()
	if self.flRemoveTime && CurTime() > self.flRemoveTime then self:Remove() return end
	if !self.GRENADE_TIME || CurTime() <= self.GRENADE_TIME || IsValid( self.Smoke ) then return end
	local Smoke = ents.Create 'env_smokestack'
	Smoke:SetPos( self:GetPos() )
	Smoke:SetParent( self )
	Smoke:SetKeyValue( 'InitialState', '1' )
	Smoke:SetKeyValue( 'SpreadSpeed', '0' )
	local flDist = self.SMOKE_SIZE
	local flSpeed = self.SMOKE_SPEED
	Smoke:SetKeyValue( 'Speed', flSpeed )
	local flTurn = self.SMOKE_TURN
	Smoke:SetKeyValue( 'Twist', flTurn )
	Smoke:SetKeyValue( 'Roll', flTurn )
	Smoke:SetKeyValue( 'BaseSpread', flDist )
	Smoke:SetKeyValue( 'StartSize', flDist )
	Smoke:SetKeyValue( 'EndSize', '0' )
	Smoke:SetKeyValue( 'Rate', '8' )
	Smoke:SetKeyValue( 'JetLength', '100' )
	Smoke:SetKeyValue( 'RenderColor', '255 255 255' )
	local flTransparency = self.SMOKE_TRANSPARENCY
	Smoke:SetKeyValue( 'RenderAmt', flTransparency )
	Smoke:SetKeyValue( 'SmokeMaterial', 'particle/SmokeStack.vmt' )
	Smoke:Spawn()
	self.Smoke = Smoke
	local t = CurTime()
	local flStart, flEnd = t, t + self.SMOKE_TIME
	self.flRemoveTime = flEnd
	Smoke:AddThink( function( Smoke )
		local t = math.Clamp( math.Remap( CurTime(), flStart, flEnd, flTransparency, 0 ), 0, flTransparency )
		if t == 0 then if IsValid( self ) then self:Remove() end Smoke:Remove() return end
		Smoke:SetKeyValue( 'RenderAmt', t )
		local t = math.Clamp( math.Remap( CurTime(), flStart, flEnd, flTurn, 0 ), 0, flTurn )
		Smoke:SetKeyValue( 'Twist', t )
		Smoke:SetKeyValue( 'Roll', t )
		Smoke:SetKeyValue( 'Speed', math.Clamp( math.Remap( CurTime(), flStart, flEnd, flSpeed, 0 ), 0, flSpeed ) )
		Smoke:SetKeyValue( 'BaseSpread', rand( math.Clamp( math.Remap( CurTime(), flStart, flEnd, flDist, 0 ), 0, flDist ) ) )
	end )
end
