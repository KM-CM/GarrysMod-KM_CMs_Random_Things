SWEP.Category="Shotguns"
SWEP.PrintName="Winchester Model 1886"
if CLIENT then language.Add("weapon_winchester1886","Winchester Model 1886") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Winchester Model 1886,also known as \"Your Grandpa's Rifle\"."
SWEP.WorldModel=Model("models/weapons/w_annabelle.mdl")
SWEP.Primary.ClipSize=7
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="357" //Its STRONG.
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

function SWEP:GetNPCBurstSettings() return 1,7,0.2 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=30,
		Num=1,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.022,0.022,0.022),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/shotgun/shotgun_fire7.wav"),500,math.random(90,100))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.2)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_winchester1886",title="#weapon_winchester1886",category=SWEP.Category})