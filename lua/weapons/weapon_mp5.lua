SWEP.Category="Submachine Guns"
SWEP.PrintName="MP5"
if CLIENT then language.Add("weapon_mp5","MP5") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="MP5."
SWEP.WorldModel=Model("models/weapons/w_smg_mp5.mdl")
SWEP.Primary.ClipSize=40
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo="SMG1"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=2
SWEP.DrawHUDCrosshair=CROSSHAIR_SMG

function SWEP:GetNPCBurstSettings() return 1,30,0.075 end

function SWEP:Initialize()
	self:SetHoldType("SMG")
end

PrecacheSounds("weapon_mp5",{
	["fire"]={
		sound="^gunfire/weapon_mp5.wav",
		pitch=100,
		level = 140,
		channel=CHAN_WEAPON,
	},
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=7,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.02222222222,0.02222222222,0.02222222222),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_mp5.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06)
end

function SWEP:SecondaryAttack() end

list.Add( 'NPCUsableWeapons', { class = 'weapon_mp5', title = '#weapon_mp5', category = SWEP.Category } )