SWEP.Category="Pistols"
SWEP.PrintName="Beretta M9 (2x)"
if CLIENT then language.Add("weapon_beretta9x2","Beretta M9 (2x)") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Beretta M9 (2x)."
SWEP.WorldModel=Model("models/weapons/w_pist_elite.mdl")
SWEP.Primary.ClipSize=30
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
	self:SetHoldType("Duel")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=8,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.0333,0.0333,0.0333),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/elite/elite-1.wav"),500,100)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.025)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_beretta9x2",title="#weapon_beretta9x2",category=SWEP.Category})