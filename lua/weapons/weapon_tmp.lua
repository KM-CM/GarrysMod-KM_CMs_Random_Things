SWEP.Category="Submachine Guns"
SWEP.PrintName="Steyr TMP"
if CLIENT then language.Add("weapon_tmp","Steyr TMP") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Steyr TMP."
SWEP.WorldModel=Model("models/weapons/w_smg_tmp.mdl")
SWEP.Primary.ClipSize=30
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo="SMG1"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=2
SWEP.DrawHUDCrosshair=CROSSHAIR_SMG

function SWEP:Initialize()
	self:SetHoldType("Pistol")
end

function SWEP:GetNPCBurstSettings() return 1,30,0.07 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.DisableFlash=yes
	self:FireBullets({
		Damage=10,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.02222222222,0.02222222222,0.02222222222),
		Tracer=0,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon.silenced_shot")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06666666666)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_tmp",title="#weapon_tmp",category=SWEP.Category})