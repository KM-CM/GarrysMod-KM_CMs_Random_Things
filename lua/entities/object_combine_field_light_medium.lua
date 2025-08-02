AddCSLuaFile()
DEFINE_BASECLASS 'base_object'

ENT.PrintName = '#object_combine_field_light_medium'
if CLIENT then language.Add( 'object_combine_field_light_medium', 'Combine Medium Field Light' ) end

ENT.VisNight = true

ENT.iClass = CLASS_COMBINE
function ENT:GetNPCClass() return self.iClass end
ENT.Classify = ENT.GetNPCClass
function ENT:SetNPCClass( i ) self.iClass = i end

ENT.bCombineTerminal = true

//ENT.Terminal = NULL
//ENT.Light = NULL
//ENT.CombatLoop = nil

function ENT:Initialize()
	self:SetModel( 'models/props_combine/combine_light001a.mdl' )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
	end
end

sound.Add {
	name = 'Combine_FieldLight_Medium_CombatLoop',
	sound = 'ambient/alarms/citadel_alert_loop2.wav',
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_Combat',
	sound = 'ambient/levels/citadel/zapper_warmup4.wav',
	pitch = 126,
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_CombatBright',
	sound = 'ambient/levels/citadel/zapper_warmup1.wav',
	pitch = 126,
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_Alert',
	sound = 'ambient/levels/citadel/zapper_warmup4.wav',
	pitch = 126,
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_AlertBright',
	sound = 'ambient/levels/citadel/zapper_warmup1.wav',
	pitch = 126,
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_On',
	sound = 'ambient/levels/citadel/zapper_warmup1.wav',
	pitch = 143,
	level = 130,
	channel = CHAN_AUTO
}
sound.Add {
	name = 'Combine_FieldLight_Medium_Off',
	sound = 'ambient/levels/citadel/zapper_warmup4.wav',
	pitch = 143,
	level = 130,
	channel = CHAN_AUTO
}

if SERVER then
	ENT.sState = 'OFF'

	function ENT:StateCombat()
		if !self.CombatLoop then
			self.CombatLoop = CreateSound( self, 'Combine_FieldLight_Medium_CombatLoop' )
			self.CombatLoop:Play()
		end
		if IsValid( self.Light ) then
			local pt = self.Light
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '64 127 255 100' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '1000' )
			pt:SetTexture( 'effects/flashlight001' )
		else
			local pt = ents.Create 'env_projectedtexture'
			pt:SetPos( self:GetPos() + self:GetUp() * 32 )
			pt:SetAngles( ( -self:GetForward() ):Angle() )
			pt:SetParent( self )
			pt:SetOwner( self )
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 127 255 100' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '1000' )
			pt:SetTexture( 'effects/flashlight001' )
			pt:Spawn()
			self.Light = pt
		end
		if self.sState != 'COMBAT' then
			self:EmitSound( 'Combine_FieldLight_Medium_Combat' )
			self.sState = 'COMBAT'
		end
	end

	function ENT:StateCombatBright()
		if !self.CombatLoop then
			self.CombatLoop = CreateSound( self, 'Combine_FieldLight_Medium_CombatLoop' )
			self.CombatLoop:Play()
		end
		if IsValid( self.Light ) then
			local pt = self.Light
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '64 127 255 300' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
		else
			local pt = ents.Create 'env_projectedtexture'
			pt:SetPos( self:GetPos() + self:GetUp() * 32 )
			pt:SetAngles( ( -self:GetForward() ):Angle() )
			pt:SetParent( self )
			pt:SetOwner( self )
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 127 255 300' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
			pt:Spawn()
			self.Light = pt
		end
		if self.sState != 'COMBAT_BRIGHT' then
			self:EmitSound( 'Combine_FieldLight_Medium_CombatBright' )
			self.sState = 'COMBAT_BRIGHT'
		end
	end

	function ENT:StateAlert()
		if !self.CombatLoop then
			self.CombatLoop = CreateSound( self, 'Combine_FieldLight_Medium_CombatLoop' )
			self.CombatLoop:Play()
		end
		if IsValid( self.Light ) then
			local pt = self.Light
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 168 255 100' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
		else
			local pt = ents.Create 'env_projectedtexture'
			pt:SetPos( self:GetPos() + self:GetUp() * 32 )
			pt:SetAngles( ( -self:GetForward() ):Angle() )
			pt:SetParent( self )
			pt:SetOwner( self )
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 168 255 100' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
			pt:Spawn()
			self.Light = pt
		end
		if self.sState != 'ALERT' then
			self:EmitSound( 'Combine_FieldLight_Medium_Alert' )
			self.sState = 'ALERT'
		end
	end

	function ENT:StateAlertBright()
		if !self.CombatLoop then
			self.CombatLoop = CreateSound( self, 'Combine_FieldLight_Medium_CombatLoop' )
			self.CombatLoop:Play()
		end
		if IsValid( self.Light ) then
			local pt = self.Light
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 168 255 300' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
		else
			local pt = ents.Create 'env_projectedtexture'
			pt:SetPos( self:GetPos() + self:GetUp() * 10 )
			pt:SetAngles( ( -self:GetForward() ):Angle() )
			pt:SetParent( self )
			pt:SetOwner( self )
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '85 168 255 300' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
			pt:Spawn()
			self.Light = pt
		end
		if self.sState != 'ALERT_BRIGHT' then
			self:EmitSound( 'Combine_FieldLight_Medium_AlertBright' )
			self.sState = 'ALERT_BRIGHT'
		end
	end

	function ENT:StateOn()
		if self.CombatLoop then self.CombatLoop:Stop() self.CombatLoop = nil end
		if IsValid( self.Light ) then
			local pt = self.Light
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '127 255 255 500' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
		else
			local pt = ents.Create 'env_projectedtexture'
			pt:SetPos( self:GetPos() + self:GetUp() * 10 )
			pt:SetAngles( ( -self:GetForward() ):Angle() )
			pt:SetParent( self )
			pt:SetOwner( self )
			pt:SetKeyValue( 'fov', '120' )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'lightcolor', '127 255 255 500' )
			pt:SetKeyValue( 'NearZ', '15' )
			pt:SetKeyValue( 'FarZ', '500' )
			pt:SetTexture( 'effects/flashlight001' )
			pt:Spawn()
			self.Light = pt
		end
		if self.sState != 'ON' then
			self:EmitSound 'Combine_FieldLight_Medium_On'
			self.sState = 'ON'
		end
	end

	function ENT:StateOff()
		if self.CombatLoop then self.CombatLoop:Stop() self.CombatLoop = nil end
		if IsValid( self.Light ) then self.Light:Remove() end
		if self.sState != 'OFF' then
			self:EmitSound 'Combine_FieldLight_Medium_Off'
			self.sState = 'OFF'
		end
	end

	local _tModes = {
		[ 'OFF' ] = 'StateOff',
		[ 'ON' ] = 'StateOn',
		[ 'ALERT' ] = 'StateAlert',
		[ 'ALERT_BRIGHT' ] = 'StateAlertBright',
		[ 'COMBAT' ] = 'StateCombat',
		[ 'COMBAT_BRIGHT' ] = 'StateCombatBright',
	}

	function ENT:Think()
		if !IsValid( self.Terminal ) then self:StateOff() return end
		if rand( self.Terminal:GetChangeChance() ) == 1 then
			self[ _tModes[ self.Terminal.sLightOrders ] || 'OFF' ]( self )
		end
	end

	function ENT:OnRemove() if self.CombatLoop then self.CombatLoop:Stop() self.CombatLoop = nil end end
end

list.Set( 'SpawnableEntities', 'object_combine_field_light_medium', {
	PrintName = '#object_combine_field_light_medium',
	ClassName = 'object_combine_field_light_medium',
	Category = 'Combine'
} )
