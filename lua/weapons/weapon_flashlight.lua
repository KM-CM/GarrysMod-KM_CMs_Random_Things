SWEP.Category="Flashlight"
SWEP.PrintName="Flashlight"
if CLIENT then language.Add("weapon_flashlight","Flashlight") end
SWEP.Instructions="Primary or secondary to toggle."
SWEP.Purpose="Light your way!"
SWEP.WorldModel=Model("models/weapons/w_pist_usp.mdl")
SWEP.Primary.ClipSize=-1
SWEP.Primary.DefaultClip=-1
SWEP.Primary.Automatic=no // yes :: Respect real-life!
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=0

function SWEP:Initialize()
	self:SetMaterial("models/debug/debugwhite")
	self:SetHoldType("Pistol")
end

function SWEP:PrimaryAttack()pcall(function()self:GetOwner():ConCommand("impulse 100")end)end
function SWEP:SecondaryAttack()pcall(function()self:GetOwner():ConCommand("impulse 100")end)end

function SWEP:GetCapabilities() return 0 end