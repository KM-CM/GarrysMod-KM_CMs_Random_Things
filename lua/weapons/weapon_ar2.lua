SWEP.Category="Assault Rifles"
SWEP.PrintName="OSIPR"
if CLIENT then language.Add("weapon_ar2","OSIPR") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Overwatch Standart Issue Pulse Rifle."
SWEP.WorldModel=Model("models/weapons/w_irifle.mdl")
SWEP.Primary.ClipSize=40
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo=AMMO.PULSE
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1
SWEP.Secondary.Automatic=yes
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=2

function SWEP:Initialize()
	self:SetHoldType("AR2")
end

PrecacheSounds("weapon_ar2",{
	["fire"]={
		sound="^gunfire/weapon_ar2.wav",
		level = 140,
		channel=CHAN_WEAPON,
	},
	["reload"]={
		sound="weapons/ar2/npc_ar2_reload.wav",
		level=100, //The last click is the inner-programming of the rifle recharging. So it's canonically loud.
		channel=CHAN_WEAPON,
	}
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.ShootColor="127 255 255 750"
	self.MFlashFlags=5
	self:FireBullets({
		Damage=35,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.02,0.02,0.02),
		Num=1,
		Tracer=1,
		TracerName="AR2Tracer",
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_ar2.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+.075)
end

function SWEP:DoImpactEffect(tr,dt)
	if tr.HitSky then return end
	local ed=EffectData()
	ed:SetOrigin(tr.HitPos+tr.HitNormal)
	ed:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact",ed)
	return true //Clean type rifle. No one knows what hit them....
end

function SWEP:Reload()
	if self:Clip1()<self:GetMaxClip1()&&self:Ammo1()>0 then
		self:EmitSound("weapon_ar2.reload")
		self:DefaultReload(ACT_VM_RELOAD)
	end
end

function SWEP:SecondaryAttack() end 