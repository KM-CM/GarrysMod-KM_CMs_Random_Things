/*////////////////////////////////////////////////////////

A Traditional Explosion.

If You're Looking to Create a Special Explosion - for Example,
Napalm, Name The Entity in Format `env_explosion_*`.

Internally Made as a Replacement for `env_explosion`.

////////////////////////////////////////////////////////*/

AddCSLuaFile()
DEFINE_BASECLASS( 'base_point' )

ENT.PrintName = '#env_explosion'
if CLIENT then language.Add( 'env_explosion', 'Explosion' ) return end

ENT.flMagnitude = 5

function ENT:KeyValue( Key, Value )
	Key = string.lower( Key )
	if Key == 'imagnitude' || k == 'magnitude' then self.flMagnitude = tonumber( v ) || 100 end
end
function ENT:AcceptInput( Key, _, _, Value )
	if string.lower( Key || '' ) == 'explode' then
		self:Explode()
	end
end

sound.Add {
	name = 'BaseExplosionEffect.Sound',
	sound = {
		'weapons/explode3.wav',
		'weapons/explode4.wav',
		'weapons/explode5.wav'
	},
	pitch = 100,
	level = 500,
	channel = CHAN_WEAPON
}

sound.Add {
	name = 'BaseExplosionEffect.Water',
	sound = {
		'weapons/underwater_explode3.wav',
		'weapons/underwater_explode4.wav'
	},
	pitch = 100,
	level = 500,
	channel = CHAN_WEAPON
}

ENT.SMOKE_TRANSPARENCY = 200
ENT.SMOKE_SPEED = .1
ENT.SMOKE_TURN = 45

ENT.FIRE_SPEED = 100

function ENT:Explode()
	self:EmitSound 'BaseExplosionEffect.Sound'
	local flMagnitude = self.flMagnitude
	local flRange = flMagnitude * 3
	local flDist = flRange + 50
	local flDamage = flMagnitude * 10
	BlastDamage( self, GetOwner( self ), self:GetPos(), flDist, flDamage )
	for _ = 1, lmax( 5, flRange * .2 ) do //Effects
		local dir = VectorRand()
		local tr = Trace {
			start = self:GetPos() + dir * 50,
			endpos = self:GetPos() + dir * 50 + VectorRand() * rand( flRange ),
			mask = MASK_SOLID
		}
		local ed = EffectData()
		ed:SetOrigin( tr.HitPos - Vector( 0, 0, 24 ) )
		ed:SetNormal( VectorRand() )
		util.Effect( 'Explosion', ed )
	end
	local flSpeed = flDist * self.FIRE_SPEED
	for i = 1, lmax( 5, flRange * math.Rand( .03, .06 ) ) do //Fire
		local dir = VectorRand()
		local tr = Trace {
			start = self:GetPos() + dir * 50,
			endpos = self:GetPos() + dir * 50 + VectorRand() * rand( flRange ),
			mask = MASK_SOLID
		}
		local p = ents.Create( 'prop_physics' )
		p:SetPos( tr.HitPos )
		p:SetCollisionGroup( COLLISION_GROUP_WORLD )
		p:SetModel( 'models/combine_helicopter/helicopter_bomb01.mdl' )
		p:SetNoDraw( true )
		p.bDontBreak = true
		p.GAME_DontIgnite = true
		p:Spawn()
		p:GodEnable()
		local f=ents.Create 'env_fire_trail'
		f:SetPos( p:GetPos() )
		f:SetParent( p )
		f:Spawn()
		f.GAME_DontIgnite = true
		p:GetPhysicsObject():AddVelocity( VectorRand() * math.Rand( 0, flSpeed ) )
		p:AddThink( function( self ) if rand( GetFlameStopChance( self ) * FrameTime() ) == 1 || self:WaterLevel() != 0 then self:Remove() end end )
	end
	for i = 1, lmax( 5, flRange * .1 ) do //Scorches
		local dir = VectorRand()
		util.Decal( 'Scorch', self:GetPos() + dir * 50, self:GetPos() + dir * 50 + VectorRand() * rand( flRange ) )
	end
	local Smoke = ents.Create 'env_smokestack'
	Smoke:SetPos( self:GetPos() )
	Smoke:SetKeyValue( 'InitialState', '1' )
	Smoke:SetKeyValue( 'SpreadSpeed', '0' )
	local flSpeed = flDist * self.SMOKE_SPEED
	Smoke:SetKeyValue( 'Speed', flSpeed )
	local flTurn = self.SMOKE_TURN
	Smoke:SetKeyValue( 'Twist', flTurn )
	Smoke:SetKeyValue( 'Roll', flTurn )
	Smoke:SetKeyValue( 'BaseSpread', flDist )
	Smoke:SetKeyValue( 'StartSize', flDist )
	Smoke:SetKeyValue( 'EndSize', '0' )
	Smoke:SetKeyValue( 'Rate', '8' )
	Smoke:SetKeyValue( 'JetLength', '100' )
	Smoke:SetKeyValue( 'RenderColor', '100 100 100' )
	local flTransparency = self.SMOKE_TRANSPARENCY
	Smoke:SetKeyValue( 'RenderAmt', flTransparency )
	Smoke:SetKeyValue( 'SmokeMaterial', 'particle/SmokeStack.vmt' )
	Smoke:Spawn()
	local t = CurTime()
	local flStart, flEnd = t, t + flMagnitude * .3
	Smoke:AddThink( function( self )
		local t = math.Clamp( math.Remap( CurTime(), flStart, flEnd, flTransparency, 0 ), 0, flTransparency )
		if t == 0 then self:Remove() return end
		self:SetKeyValue( 'RenderAmt', t )
		local t = math.Clamp( math.Remap( CurTime(), flStart, flEnd, flTurn, 0 ), 0, flTurn )
		self:SetKeyValue( 'Twist', t )
		self:SetKeyValue( 'Roll', t )
		self:SetKeyValue( 'Speed', math.Clamp( math.Remap( CurTime(), flStart, flEnd, flSpeed, 0 ), 0, flSpeed ) )
		self:SetKeyValue( 'BaseSpread', rand( math.Clamp( math.Remap( CurTime(), flStart, flEnd, flDist, 0 ), 0, flDist ) ) )
	end )
end
