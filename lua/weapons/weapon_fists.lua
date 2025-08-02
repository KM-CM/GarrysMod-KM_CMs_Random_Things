SWEP.Category="Hands"
SWEP.PrintName="Fists"
if CLIENT then language.Add("weapon_fists","Fists") end
SWEP.Instructions=""
SWEP.Purpose="Fists."
SWEP.WorldModel=Model("models/hunter/plates/plate.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=0

function SWEP:Initialize()
	self:SetHoldType("Fist")
	self:SetNoDraw(yes)
end

function SWEP:HasAmmo() return yes end

if SERVER then
	local CAP = CAP_WEAPON_MELEE_ATTACK1 + CAP_WEAPON_MELEE_ATTACK2 + CAP_INNATE_MELEE_ATTACK1 + CAP_INNATE_MELEE_ATTACK2
	function SWEP:GetCapabilities() return CAP end
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	local owner=self:GetOwner()
	self:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
	self.DisableFlash=yes
	self.IsMelee=yes
	self:FireBullets({
		Damage=40,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Tracer=0,
		Distance=80,
	})
	self:SetNextPrimaryFire(CurTime()+.3)
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	local owner=self:GetOwner()
	self:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
	self.DisableFlash=yes
	self:FireBullets({
		Damage=40,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Tracer=0,
		Distance=80,
	})
	self:SetNextSecondaryFire(CurTime()+.3)
end



function SWEP:OnDrop() self:Remove() end                                             //Its literally hands....
function SWEP:OwnerChanged() if !IsValid(self:GetOwner()) then self:Remove() end end //Its literally hands....