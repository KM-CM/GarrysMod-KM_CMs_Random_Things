SWEP.Category="Submachine Guns"
SWEP.PrintName="UMP45"
if CLIENT then language.Add("weapon_ump45","UMP45") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="UMP45."
SWEP.WorldModel=Model("models/weapons/w_smg_ump45.mdl")
SWEP.Primary.ClipSize=25
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
	self:SetHoldType("SMG")
end

function SWEP:GetNPCBurstSettings() return 1,25,0.08571428571 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=10,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.0333,0.0333,0.0333),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/ump45/ump45-1.wav"),500,math.random(105,110))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.08571428571)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_ump45",title="#weapon_ump45",category=SWEP.Category})