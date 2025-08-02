SWEP.Category="Pistols"
SWEP.PrintName="Five-SeveN"
if CLIENT then language.Add("weapon_fiveseven","Five-SeveN") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Five-SeveN."
SWEP.WorldModel=Model("models/weapons/w_pist_fiveseven.mdl")
SWEP.Primary.ClipSize=20
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="Pistol"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=1

function SWEP:Initialize()
	self:SetHoldType("Pistol")
end

function SWEP:GetNPCBurstSettings() return 1,20,0.11 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=16,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.02777777777,0.02777777777,0.02777777777),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/fiveseven/fiveseven-1.wav"),500,math.random(95,105))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.11) // 0.08 :: Respect recoil!
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_fiveseven",title="#weapon_fiveseven",category=SWEP.Category})