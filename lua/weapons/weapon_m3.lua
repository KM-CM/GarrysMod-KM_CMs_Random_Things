SWEP.Category="Shotguns"
SWEP.PrintName="Benelli M3 Super 90"
if CLIENT then language.Add("weapon_m3","Benelli M3 Super 90") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Benelli M3 Super 90."
SWEP.WorldModel=Model("models/weapons/w_shot_m3super90.mdl")
SWEP.Primary.ClipSize=6
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

function SWEP:GetNPCBurstSettings() return 1,6,0.3 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=10,
		Num=9,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.083,0.083,0.083),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("gunfire/weapon_m3.wav"),500,math.random(105,95),1,CHAN_STATIC)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.125)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_m3",title="#weapon_m3",category=SWEP.Category})