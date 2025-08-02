SWEP.Category="Assault Rifles"
SWEP.PrintName="Galil AR"
if CLIENT then language.Add("weapon_galilar","Galil AR") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Galil Assault Rifle."
SWEP.WorldModel=Model("models/weapons/w_rif_galil.mdl")
SWEP.Primary.ClipSize=35
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo="SMG1"
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=2
SWEP.DrawHUDCrosshair=CROSSHAIR_AR

function SWEP:Initialize()
	self:SetHoldType("AR2")
end

function SWEP:GetNPCBurstSettings() return 1,35,0.08 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=12,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.03,0.03,0.03),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("gunfire/weapon_galilar.wav"),500,100,1,CHAN_WEAPON)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.075)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_galilar",title="#weapon_galilar",category=SWEP.Category})