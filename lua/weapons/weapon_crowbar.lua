SWEP.Category="Melees"
SWEP.PrintName="Crowbar"
if CLIENT then language.Add("weapon_crowbar","Crowbar") end
SWEP.Instructions="Primary to swing."
SWEP.Purpose="Crowbar."
SWEP.WorldModel=Model("models/weapons/w_crowbar.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=0
SWEP.DrawHUDCrosshair=CROSSHAIR_MELEE_HOR

function SWEP:Initialize()
	self:SetHoldType("Melee")
end

function SWEP:HasAmmo() return yes end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	local owner=self:GetOwner()
	self:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
	self.DisableFlash=yes
	self.IsMelee=yes
	for i=0,1,0.2 do
	timer.Simple((i/5),function()
	if IsValid(self)&&IsValid(owner) then
		local dir=(GetAimVector(self:GetOwner())+self:GetOwner():GetRight()*(0.5 - i)):GetNormalized()
		self:FireBullets({
			Damage=30,
			Dir=dir,
			Src=self:GetOwner():GetShootPos()||self:GetPos(),
			Attacker=self:GetOwner(),
			Tracer=0,
			Distance=80,
		})
		end
	end)
	end
	self:SetNextPrimaryFire( CurTime() + .3 )
end

function SWEP:SecondaryAttack() end

if SERVER then
	local CAP = CAP_WEAPON_MELEE_ATTACK1 + CAP_INNATE_MELEE_ATTACK1
	function SWEP:GetCapabilities() return CAP end
end
