SWEP.Category="Pistols"
SWEP.PrintName="USP Match"
if CLIENT then language.Add("weapon_pistol","USP Match") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="USP Match."
// Unrequired stuff.
// SWEP.UseHands=yes
// SWEP.ViewModel=Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel=Model("models/weapons/w_pistol.mdl")
SWEP.Primary.ClipSize=15
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no // yes :: Respect real-life!
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

PrecacheSounds("weapon_pistol",{
	["fire"]={
		sound="weapons/pistol/pistol_fire3.wav",
		pitch=95,
		level = 140,
		channel=CHAN_WEAPON,
	},
	["reload"]={
		sound="weapons/pistol/pistol_reload1.wav", //Fun fact: The HL2 Pistol's reloading sound !only matches what happens on VM, but also what happens on The WM!
		pitch=95,
		level=70,
		channel=CHAN_WEAPON,
	},
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=16,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.03,0.03,0.03),// 0.022667 :: Balancing purposes.
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_pistol.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06666666666)
end

function SWEP:Reload()
	if self:Clip1()<self:GetMaxClip1()&&self:Ammo1()>0 then
		self:EmitSound("weapon_pistol.reload")
		self:DefaultReload(ACT_VM_RELOAD)
	end
end

function SWEP:SecondaryAttack() end