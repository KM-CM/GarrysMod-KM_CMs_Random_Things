SWEP.Category="Pistols"
SWEP.PrintName="OSIP"
if CLIENT then language.Add("weapon_osip","OSIP") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Overwatch Standart Issue Pistol."
SWEP.WorldModel=Model("models/weapons/w_pist_glock18.mdl")
SWEP.Primary.ClipSize=11
SWEP.Primary.DefaultClip=1
SWEP.Primary.Automatic=No //yes
SWEP.Primary.Ammo=AMMO.PULSE
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
	self:SetColor(Color(150,150,255))
end

PrecacheSounds("weapon_osip",{
	["fire"]={
		sound="weapons/glock18/glock18-1.wav",
		pitch=90,
		level = 140,
		channel=CHAN_WEAPON,
	},
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.ShootColor="127 255 255 750"
	self.MFlashFlags=5
	self:FireBullets({
		Damage=35,
		Num=1,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.04,0.04,0.04),
		Tracer=1,
		TracerName="AR2Tracer",
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_osip.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.11)
end

function SWEP:DoImpactEffect(tr,dt)
	if tr.HitSky then return end
	local ed=EffectData()
	ed:SetOrigin(tr.HitPos+tr.HitNormal)
	ed:SetNormal(tr.HitNormal)
	util.Effect("AR2Impact",ed)
	return true
end

function SWEP:SecondaryAttack() end

list.Add( 'NPCUsableWeapons', { class = 'weapon_osip', title = '#weapon_osip', category = SWEP.Category } )