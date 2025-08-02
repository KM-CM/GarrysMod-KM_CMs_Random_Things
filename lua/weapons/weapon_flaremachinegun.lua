SWEP.Category="Flare"
SWEP.PrintName="#weapon_flaremachinegun"
if CLIENT then language.Add("weapon_flaremachinegun","Flare Machine-Gun") end
SWEP.Instructions="Primary to shoot flare."
SWEP.Purpose="Fun. No other use."
//Unrequired stuff.
//SWEP.UseHands=yes
//SWEP.ViewModel=Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel=Model("models/weapons/w_pistol.mdl")
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
SWEP.Slot=1

function SWEP:Initialize()
	self:SetHoldType("Pistol")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local flare=ents.Create("env_flare")
	flare:SetPos((self:GetOwner():GetShootPos()+GetAimVector(self:GetOwner())*100))
	flare:SetAngles(GetAimVector(self:GetOwner()):Angle())
	flare:Spawn()
	timer.Simple(2,function() if IsValid(flare) then flare:EmitSound(Sound("ambient/fire/gascan_ignite1.wav")) flare:Remove() end end)
	flare:Fire("Launch","1500")
	self:GetOwner().GAME_FireImmunity=CurTime()+1
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/flaregun/fire.wav"),500,100)
	self:SetNextPrimaryFire(CurTime()+0.075)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_flaremachinegun",title="#weapon_flaremachinegun",category=SWEP.Category})