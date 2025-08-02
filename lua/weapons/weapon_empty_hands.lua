SWEP.Category="Hands"
SWEP.PrintName="Empty Hands"
if CLIENT then language.Add("weapon_empty_hands","Empty Hands") end
SWEP.Instructions=""
SWEP.Purpose="Empty Hands."
SWEP.WorldModel=Model("models/hunter/plates/plate.mdl")
SWEP.Primary.ClipSize=-1
SWEP.Primary.DefaultClip=-1
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=0
function SWEP:GetNPCBurstSettings() return 0,0,1 end
function SWEP:Initialize() self:SetHoldType("Normal") self:SetNoDraw(yes) end
function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end; function SWEP:GetNPCBulletSpread() return 0 end; function SWEP:GetNPCRestTimes() return 0.1,0.2 end; function SWEP:AllowAutoSwitchTo() return yes end; function SWEP:AllowAutoSwitchFrom() return yes end
function SWEP:OnDrop() self:Remove() end                                             //Its literally hands....
function SWEP:OwnerChanged() if !IsValid(self:GetOwner()) then self:Remove() end end //Its literally hands....
function SWEP:GetCapabilities() return 0 end