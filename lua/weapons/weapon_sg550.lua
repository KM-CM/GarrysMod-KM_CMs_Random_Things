SWEP.Category="Assault Rifles"
SWEP.PrintName="SIG SG 550"
if CLIENT then language.Add("weapon_sg550","SIG SG 550") end
SWEP.Instructions="Primary to shoot,Secondary to switch zoom."
SWEP.Purpose="SIG SG 550."
SWEP.WorldModel=Model("models/weapons/w_rif_sg552.mdl")
SWEP.Primary.ClipSize=30
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
SWEP.ZoomedIn=no

function SWEP:Initialize()
	self:SetHoldType("AR2")
end

function SWEP:GetNPCBurstSettings() return 1,30,0.08 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=10,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.02222222222,0.02222222222,0.02222222222),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/sg552/sg552-1.wav"),500,math.random(110,120))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.08)
end

function SWEP:SecondaryAttack()
	if self:GetOwner():IsPlayer() then if self.ZoomedIn then
		self:GetOwner():SetFOV(self:GetOwner():GetInfoNum("fov_desired",90))
		self.ZoomedIn=no
	elseif !self.ZoomedIn then
		self:GetOwner():SetFOV(35)
		self.ZoomedIn=yes
	end end
end

list.Add("NPCUsableWeapons",{class="weapon_sg550",title="#weapon_sg550",category=SWEP.Category})