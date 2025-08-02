SWEP.Category="Assault Rifles"
SWEP.PrintName="AK47"
if CLIENT then language.Add("weapon_ak47","AK47") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="AK47."
SWEP.WorldModel=Model("models/weapons/w_rif_ak47.mdl")
SWEP.Primary.ClipSize=30
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=true
SWEP.Primary.Ammo="SMG1"
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Ammo=""
SWEP.Spawnable=true
SWEP.AdminOnly=false
SWEP.Weight=1
SWEP.DrawAmmo=true
SWEP.Slot=2

function SWEP:Initialize() self:SetHoldType( 'AR2' ) end

sound.Add {
	name = 'weapon_ak47.fire',
	channel = CHAN_WEAPON,
	volume = 1,
	level = 140,
	pitch = { 95, 110 },
	sound = '^gunfire/weapon_ak47.wav'
}

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets {
		Damage = 14,
		Dir = GetAimVector(self:GetOwner()),
		Src = self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker = self:GetOwner(),
		Spread = Vector( .016, .016, .16 ),
		Tracer = 1
	}
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
	self:EmitSound( 'weapon_ak47.fire' )
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo( 1 ) end
	self:SetNextPrimaryFire( CurTime() + 0.092 )
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_ak47",title="#weapon_ak47",category=SWEP.Category})