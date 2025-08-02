SWEP.Category="Shotguns"
SWEP.PrintName="SPAS-12"
if CLIENT then language.Add("weapon_shotgun","SPAS-12") end
SWEP.Instructions="Primary to shoot,secondary to switch semi-automatic/pump-action."
SWEP.Purpose="SPAS-12."
SWEP.WorldModel=Model("models/weapons/w_shotgun.mdl")
SWEP.Primary.ClipSize=8
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
SWEP.Pump=yes

function SWEP:Initialize()
	self:SetHoldType("Shotgun")
end

PrecacheSounds("weapon_shotgun",{
	["fire"]={
		sound="gunfire/weapon_shotgun_pump.wav",
		level = 140,
		channel=CHAN_WEAPON,
	},
	["firealt"]={
		sound="weapons/shotgun/shotgun_dbl_fire7.wav",
		level = 140,
		channel=CHAN_WEAPON,
	},
})

function SWEP:GetNPCBurstSettings() return 1,8,self.Pump&&0.3||0.17142857142 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=(self.Pump&&15||10),
		Num=9,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=(self.Pump&&Vector(0.11,0.11,0)||Vector(0.16,0.16,0)),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(self.Pump&&"weapon_shotgun.fire"||"weapon_shotgun.firealt")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+(self.Pump&&0.45||0.35))
end

function SWEP:SecondaryAttack() self:EmitSound(Sound("npc/turret_floor/click1.wav")) self.Pump=!self.Pump; end
