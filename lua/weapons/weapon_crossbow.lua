SWEP.Category="Snipers"
SWEP.PrintName="Hot-Bolt Crossbow"
if CLIENT then language.Add("weapon_crossbow","Hot-Bolt Crossbow") end
SWEP.Instructions="Primary to shoot,Secondary to switch zoom."
SWEP.Purpose="Hot-Bolt Crossbow."
SWEP.WorldModel=Model("models/weapons/w_crossbow.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="XBowBolt"
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1
SWEP.Secondary.Automatic=yes
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=3
SWEP.ZoomState=40

function SWEP:Initialize()
	self:SetHoldType("Crossbow")
end

function SWEP:CanPrimaryAttack()
	if self:Clip1()<1 then
		//Thats why I copied this func - to get rid of this crap, a crossbow cant click
		//self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime()+0.2)
		self:Reload()
		return no
	end
	return yes
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self.ShootColor="255 50 0 750"
	self:FireBullets({
		Damage=95,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.007,0.007,0.007),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/crossbow/fire1.wav"),80,80)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	if self:GetOwner():IsPlayer() then self:GetOwner():SetFOV(99) self.ZoomState=0 end
	self:SetNextPrimaryFire(CurTime()+1)
end

function SWEP:SecondaryAttack() if self:GetOwner():IsPlayer() then
	if !self:CanSecondaryAttack() then return end
	if (self.ZoomState-0.33)<8 then self:GetOwner():SetFOV(99) self.ZoomState=40 self:SetNextSecondaryFire(CurTime()+0.5) return end
	self.ZoomState=math.clamp(self.ZoomState-0.33,8,40)
	self:GetOwner():SetFOV(self.ZoomState)
	self:SetNextSecondaryFire(CurTime()+0.001)
end end

function SWEP:GetNPCBulletSpread() return 0 end; function SWEP:GetNPCRestTimes() return 1,1 end; function SWEP:AllowAutoSwitchTo() return yes end; function SWEP:AllowAutoSwitchFrom() return yes end