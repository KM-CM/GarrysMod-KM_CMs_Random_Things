SWEP.Category="Snipers"
SWEP.PrintName="AWM"
if CLIENT then language.Add("weapon_awm","AWM") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Arctic Warfare Magnum."
SWEP.WorldModel=Model("models/weapons/w_snip_awp.mdl")
SWEP.Primary.ClipSize=5
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="SMG1"
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1
SWEP.Secondary.Automatic=yes
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=3
SWEP.ZoomState=20

function SWEP:Initialize()
	self:SetHoldType("AR2")
end

function SWEP:GetNPCBurstSettings() return 1,5,1.25 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=80,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.0048,0.0048,0.0048),
		Tracer=1,
		Force=35,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/awp/awp1.wav"),500,95)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	if self:GetOwner():IsPlayer() then self:GetOwner():SetFOV(100) self.ZoomState=0 end
	self:SetNextPrimaryFire(CurTime()+0.33)
end

function SWEP:SecondaryAttack() if self:GetOwner():IsPlayer() then
	if !self:CanSecondaryAttack() then return end
	if (self.ZoomState-0.33)<4 then self:GetOwner():SetFOV(100) self.ZoomState=20 self:SetNextSecondaryFire(CurTime()+0.5) return end
	self.ZoomState=math.clamp(self.ZoomState-0.33,4,20)
	self:GetOwner():SetFOV(self.ZoomState)
	self:SetNextSecondaryFire(CurTime()+0.001)
end end

list.Add( 'NPCUsableWeapons', { class = 'weapon_awm', title = '#weapon_awm', category = SWEP.Category } )