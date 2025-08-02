SWEP.Category="Machine Guns"
SWEP.PrintName="M249 SAW"
if CLIENT then language.Add("weapon_m249","M249 SAW") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="M249 Squad Automatic Weapon."
SWEP.WorldModel=Model("models/weapons/w_mach_m249para.mdl")
SWEP.Primary.ClipSize=200
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo="AR2"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=yes
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=2
SWEP.DrawHUDCrosshair=CROSSHAIR_AR

function SWEP:GetNPCBurstSettings() return 1,200,0.05 end

PrecacheSounds("weapon_m249",{
	["fire"]={
		sound="gunfire/weapon_m249.wav",
		pitch=100,
		level = 140,
		channel=CHAN_WEAPON,
	},
})

function SWEP:Initialize()
	self:SetHoldType("AR2")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.MFlashFlags=7
	self:FireBullets({
		Damage=20,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.03333333333,0.03333333333,0.03333333333),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_m249.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.05) //They, unironically, had the same fire rate as OSIMG.
end

function SWEP:SecondaryAttack() end

list.Add( 'NPCUsableWeapons', { class = 'weapon_m249', title = '#weapon_m249', category = SWEP.Category } )