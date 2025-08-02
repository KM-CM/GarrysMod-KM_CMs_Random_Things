SWEP.Category="Fire & Anti-Fire"
SWEP.PrintName="#weapon_extinguisher"
if CLIENT then language.Add("weapon_extinguisher","Extinguisher") end
SWEP.Instructions="Primary to stop flames!"
SWEP.Purpose="Made after The Fire Update because normal GMod extinguishing method is just TRASH!!"
//Unrequired stuff.
//SWEP.UseHands=yes
//SWEP.ViewModel=Model("models/weapons/c_shotgun.mdl")
SWEP.WorldModel=Model("models/weapons/w_shotgun.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=2

function SWEP:Initialize()
	self:SetHoldType("Shotgun")
end


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:GetOwner():Extinguish()
	for _,ent in ipairs(ents.FindInSphere((self:GetOwner():GetShootPos()+(GetAimVector(self:GetOwner())*250)),350)) do
		if ent:IsOnFire() then ent:Extinguish() end
		ent:SetColor(Color(math.Clamp(ent:GetColor().r+7.5,1,255),math.Clamp(ent:GetColor().g+7.5,1,255),math.Clamp(ent:GetColor().b+7.5,1,255)))
		if ent:GetClass()=="env_fire_trail"&&(IsValid(ent:GetOwner())&&ent:GetOwner():GetClass()||"")!="npc_helicopter" then ent:Remove() end
	end
	self:EmitSound(Sound("ambient/water/water_spray"+tostring(math.random(1,3))+".wav"),500,100)
	self:SetNextPrimaryFire(CurTime()+0.075)
end

function SWEP:SecondaryAttack() end