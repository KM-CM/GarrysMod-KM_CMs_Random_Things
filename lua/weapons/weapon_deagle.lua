SWEP.Category="Pistols"
SWEP.PrintName="Desert Eagle"
if CLIENT then language.Add("weapon_deagle","Desert Eagle") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Desert Eagle."
SWEP.WorldModel=Model("models/weapons/w_pist_deagle.mdl")
SWEP.Primary.ClipSize=9
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="357" //Pistol //Its closer
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=1

function SWEP:Initialize()
	self:SetHoldType("Revolver")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=65,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.025,0.025,0.025),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("gunfire/weapon_deagle.wav"),500,100,1,CHAN_WEAPON)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.12)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_deagle",title="#weapon_deagle",category=SWEP.Category})