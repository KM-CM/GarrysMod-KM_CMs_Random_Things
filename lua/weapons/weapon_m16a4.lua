SWEP.Category = 'Assault Rifles'
SWEP.PrintName = '#weapon_m16a4'
if CLIENT then language.Add( 'weapon_m16a4', 'M16A4' ) end
SWEP.Instructions = "Primary to shoot, secondary to attach or detach silencer."
SWEP.WorldModel = 'models/weapons/w_rif_m4a1.mdl'
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'SMG1'
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = ''
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.DrawAmmo = true
SWEP.Slot = 2
//SWEP.bSilenced = false

function SWEP:Initialize() self:SetHoldType( 'AR2' ) end

sound.Add {
	name = 'weapon_m16a4.fire',
	channel = CHAN_WEAPON,
	volume = 1,
	level = 140,
	pitch = { 95, 110 },
	sound = '^gunfire/weapon_m16a4.wav'
}

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	if self.bSilenced then
		self.DisableFlash = true
		self:FireBullets( {
			Damage = 12,
			Dir = GetAimVector( self:GetOwner() ),
			Src = self:GetOwner():GetShootPos() || self:GetPos(),
			Attacker = self:GetOwner(),
			Spread = Vector( .02, .02, .02 ),
			Tracer = 0
		} )
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:EmitSound( 'weapon.silenced_shot' )
		if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo( 1 ) end
		self:SetNextPrimaryFire( CurTime() + .063 )
	else
		self:FireBullets( {
			Damage = 12,
			Dir = GetAimVector( self:GetOwner() ),
			Src = self:GetOwner():GetShootPos() || self:GetPos(),
			Attacker = self:GetOwner(),
			Spread = Vector( .022, .022, .022 ),
			Tracer = 1
		} )
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
		self:EmitSound( 'weapon_m16a4.fire' )
		if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo( 1 ) end
		self:SetNextPrimaryFire( CurTime() + .063 )
	end
end

function SWEP:SecondaryAttack()
	local b = !self.bSilenced
	self.bSilenced = b
	self.WorldModel = b && 'models/weapons/w_rif_m4a1_silencer.mdl' || 'models/weapons/w_rif_m4a1.mdl'
	self:SetModel( self.WorldModel )
	self:SetHoldType( 'AR2' )
end

list.Add( 'NPCUsableWeapons', { class = 'weapon_m16a4', title = SWEP.PrintName, category = SWEP.Category } )