SWEP.Category="Shotguns"
SWEP.PrintName="Benelli M4 Super 90"
if CLIENT then language.Add("weapon_m4","Benelli M4 Super 90") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Benelli M4 Super 90."
SWEP.WorldModel=Model("models/weapons/w_shot_xm1014.mdl")
SWEP.Primary.ClipSize=7
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="Buckshot"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=3
SWEP.DrawHUDCrosshair=CROSSHAIR_SHOTGUN

function SWEP:Initialize()
	self:SetHoldType("Shotgun")
end

PrecacheSounds("weapon_m4",{
	["fire"]={
		sound="^gunfire/weapon_m4.wav",
		level = 140,
		channel=CHAN_WEAPON,
	},
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=12.5,
		Num=9,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.13888888888,0.13888888888,0.13888888888),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_m4.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.12)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_m4",title="#weapon_m4",category=SWEP.Category})