SWEP.Category="Pistols"
SWEP.PrintName="USP"
if CLIENT then language.Add("weapon_usp","USP") end
SWEP.Instructions="Primary to shoot, secondary to attach silencer."
SWEP.Purpose="USP."
SWEP.WorldModel=Model("models/weapons/w_pist_usp.mdl")
SWEP.Primary.ClipSize=15
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

function SWEP:GetNPCBurstSettings() return 1,15,0.06666666666 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=16,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.01944444444,0.01944444444,0.01944444444),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/fiveseven/fiveseven-1.wav"),500,math.random(135,145)) //This is NOT silenced version of USP! For the other one,see weapon_usp_s.
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06666666666)
end

function SWEP:SecondaryAttack()
	local ent=self:GetOwner()
	local am=self:Clip1()
	self:Remove()
	local new=ent:Give("weapon_usp_s")
	if IsValid(new) then new:SetClip1(am) end
end

list.Add("NPCUsableWeapons",{class="weapon_usp",title="#weapon_usp",category=SWEP.Category})