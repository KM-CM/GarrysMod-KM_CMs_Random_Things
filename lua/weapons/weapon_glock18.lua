SWEP.Category="Pistols"
SWEP.PrintName="Glock-18"
if CLIENT then language.Add("weapon_glock18","Glock-18") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Glock-18."
SWEP.WorldModel=Model("models/weapons/w_pist_glock18.mdl")
SWEP.Primary.ClipSize=17
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

function SWEP:GetNPCBurstSettings() return 1,17,0.05 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=16,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.04444444444,0.04444444444,0.04444444444),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/glock18/glock18-1.wav"),500,math.random(95,105))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.05)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_glock18",title="#weapon_glock18",category=SWEP.Category})