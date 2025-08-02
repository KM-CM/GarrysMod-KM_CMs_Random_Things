SWEP.Category="Submachine Guns"
SWEP.PrintName="P90"
if CLIENT then language.Add("weapon_p90","P90") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="P90."
SWEP.WorldModel=Model("models/weapons/w_smg_p90.mdl")
SWEP.Primary.ClipSize=50
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

function SWEP:GetNPCBurstSettings() return 1,50,0.066 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=8,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.04444444444,0.04444444444,0.04444444444),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/p90/p90-1.wav"),500,math.random(95,105))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_p90",title="#weapon_p90",category=SWEP.Category})