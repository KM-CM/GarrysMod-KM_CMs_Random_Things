AddCSLuaFile()

ENT.Base = 'base_ai'
ENT.Type = 'ai'

ENT.PrintName = '#npc_gunfire'

if CLIENT then language.Add( 'npc_gunfire', 'GunFire' ) return end

function ENT:Initialize()
	self:SetModel( 'models/roller.mdl' )
	self:SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 ) )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:SetMoveType( MOVETYPE_FLY )
	self:SetNoDraw( true )
	self:SetHealth( 999999 )
	self:SetMaxHealth( 999999 )
	self:CapabilitiesAdd( CAP_INNATE_RANGE_ATTACK1 )
end

function ENT:OnTakeDamage() return 0 end

//IsInCone(pos,start,dir,vertical,horizontal)
local function IsInCone(p,s,d,v,h) local dr=(p-s):GetNormalized():Angle() return math.abs(math.AngleDifference(d:Angle().p,dr.p))<=v&&math.abs(math.AngleDifference(d:Angle().y,dr.y))<=h end

ENT.flBurstNext = 0

local ai_disabled = GetConVar( 'ai_disabled' )

function ENT:Think()
	if !self.bState || ai_disabled:GetInt() == 1 then
		self.flTargetTime = CurTime() + math.Rand( self.flTargetTimeMin, self.flTargetTimeMax )
		return
	end
	if !IsValid( self.Target ) || CurTime() > self.flTargetTime then
		self.Target = table.Random( self.tTargets || {} )
		self.flTargetTime = CurTime() + math.Rand( self.flTargetTimeMin, self.flTargetTimeMax )
	end
	if !IsValid( self.Target ) then return end
	local ang = self:GetAngles()
	local tang = ( self.Target:GetPos() - self:GetPos() ):GetNormalized():Angle()
	ang.p = math.ApproachAngle( ang.p, tang.p, self.flVerticalSpeed * FrameTime() )
	ang.y = math.ApproachAngle( ang.y, tang.y, self.flHorizontalSpeed * FrameTime() )
	self:SetAngles( ang )
	if CurTime() > self.flBurstNext then
		local b = IsInCone( self.Target:GetPos(), self:GetPos(), self:GetForward(), self.flVerticalSpread * 90, self.flHorizontalSpread * 90 )
		if !b then self.flTargetTime = CurTime() + math.Rand( self.flTargetTimeMin, self.flTargetTimeMax ) end
		if self.bTurnShoot || b then
			local iSize = math.random( self.iBurstMin, self.iBurstMax )
			local flDelay = self.flDelay
			local flLength = iSize * flDelay
			for I = 0, flLength, flDelay do timer.Simple( I, function()
				if !IsValid( self ) || !IsValid( self.Target ) || !self.bTurnShoot && !IsInCone( self.Target:GetPos(), self:GetPos(), self:GetForward(), self.flVerticalSpread * 90, self.flHorizontalSpread * 90 ) then return end
				self:FireBullets( {
					Src = self:GetPos(),
					Dir = self:GetForward(),
					Tracer = self.flTracer,
					Damage = self.flDamage,
					AmmoType = self.sAmmo,
					Force = self.flForce,
					Distance = self.flDistance,
					Num = self.iNum,
					Spread = Vector( self.flHorizontalSpread, self.flVerticalSpread, 0 )
				} )
				if self.sSound then self:EmitSound( self.sSound ) end
			end ) end
			self.flBurstNext = CurTime() + flLength + math.Rand( self.flBurstDelayMin, self.flBurstDelayMax )
		end
	end
end

ENT.Target = nil
ENT.tTargets = nil
ENT.sTargets = nil
ENT.flTargetTime = 0
ENT.flTargetTimeMin = 2
ENT.flTargetTimeMax = 14
ENT.flTracer = 1
ENT.flHorizontalSpeed = 90
ENT.flVerticalSpeed = 90
ENT.flDamage = 4
ENT.sAmmo = nil
ENT.sTracerName = nil
ENT.sSound = 'Weapon_SMG1.Single'
ENT.flForce = 0
ENT.flDistance = nil
ENT.flHorizontalSpread = .08
ENT.flVerticalSpread = .08
ENT.iNum = 1
ENT.flDelay = .1
ENT.iBurstMin = 1
ENT.iBurstMax = 45
ENT.flBurstDelayMin = .2
ENT.flBurstDelayMax = 3
ENT.bTurnShoot = true
ENT.bState = true

function ENT:HandleKeyValue( Key, Value )
	if Key == 'target' then
		self.Target = ents.FindByName( Value )[ 1 ]

	elseif Key == 'targets' then
		self.tTargets = {}
		self.sTargets = Value
		for _, ent in ipairs( ents.FindByName( Value ) ) do self.tTargets[ ent ] = ent end
	
	elseif Key == 'targettimemin' then
		self.flTargetTimeMin = tonumber( Value ) || self.flTargetTimeMin
	elseif Key == 'targettimemax' then
		self.flTargetTimeMax = tonumber( Value ) || self.flTargetTimeMax

	elseif Key == 'tracer' then
		self.flTracer = tonumber( Value ) || self.flTracer

	elseif Key == 'horizontalspeed' then
		self.flHorizontalSpeed = tonumber( Value ) || self.flHorizontalSpeed
	elseif Key == 'verticalspeed' then
		self.flVerticalSpeed = tonumber( Value ) || self.flVerticalSpeed

	elseif Key == 'damage' then
		self.flDamage = tonumber( Value ) || self.flDamage

	elseif Key == 'ammo' then
		if Value == '' then self.sAmmo = nil else self.sAmmo = Value end

	elseif Key == 'tracername' then
		if Value == '' then self.sTracerName = nil else self.sTracerName = Value end

	elseif Key == 'sound' then
		if Value == '' then self.sSound = nil else self.sSound = Value end

	elseif Key == 'force' then
		self.flForce = tonumber( Value ) || self.flForce

	elseif Key == 'distance' then
		self.flDistance = tonumber( Value ) || self.flDistance
	
	elseif Key == 'horizontalspread' then
		Value = tonumber( Value )
		if Value then self.flHorizontalSpread = Value * 0.011111111111111 end
	elseif Key == 'verticalspread' then
		Value = tonumber( Value )
		if Value then self.flVerticalSpread = Value * 0.011111111111111 end

	elseif Key == 'num' then
		self.iNum = tonumber( Value ) || self.iNum

	elseif Key == 'delay' then
		self.flDelay = tonumber( Value ) || self.flDelay

	elseif Key == 'burstmin' then
		self.iBurstMin = tonumber( Value ) || self.iBurstMin
	elseif Key == 'burstmax' then
		self.iBurstMax = tonumber( Value ) || self.iBurstMax

	elseif Key == 'burstdelaymin' then
		self.flBurstDelayMin = tonumber( Value ) || self.flBurstDelayMin
	elseif Key == 'burstdelaymax' then
		self.flBurstDelayMax = tonumber( Value ) ||  self.flBurstDelayMax
	
	elseif Key == 'turnshoot' then
		self.bTurnShoot = Value == '1'
	
	elseif Key == 'state' then
		self.bState = Value == '1'
	end
end

function ENT:KeyValue( Key, Value )
	Key = string.lower( Key )
	self:HandleKeyValue( Key, Value )
end

function ENT:AcceptInput( Key, _, _, Value )
	Key = string.lower( Key )
	if Key == 'enable' then self.bState = true
	elseif Key == 'disable' then self.bState = false
	elseif Key == 'toggle' then self.bState = !self.bState
	
	elseif Key == 'targets_flush' then
		local sTargets = self.sTargets
		if sTargets then for _, ent in ipairs( ents.FindByName( sTargets ) ) do self.tTargets[ ent ] = ent end end
	
	else self:HandleKeyValue( Key, Value ) end
end