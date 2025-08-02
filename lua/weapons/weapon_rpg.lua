SWEP.Category="RPGs"
SWEP.PrintName="AT4"
if CLIENT then language.Add("weapon_rpg","AT4") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Anti-Tank 4."
SWEP.WorldModel=Model("models/weapons/w_rocket_launcher.mdl") // WHY THEY DIDNT CALL IT w_rpg WHEN THEY HAVE c_rpg?!?!
SWEP.Primary.ClipSize=-1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no
SWEP.Primary.Ammo="RPG_Round"
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=4
SWEP.DrawHUDCrosshair=CROSSHAIR_HEAVY

function SWEP:Initialize()
	self:SetHoldType("RPG")
	self:SetColor(Color(165,200,165))
end

function SWEP:HasAmmo()
	if !self:GetOwner():IsPlayer() then return yes end
	return (self:Ammo1()>0)
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsPlayer()&&!(self:Ammo1()>0) then
		self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime()+0.2)
		return no
	end
	return yes
end

function SWEP:GetNPCBurstSettings() return 1,1,.6 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	local dir=GetAimVector(self:GetOwner()):GetSpread(Vector(0.05,0.05,0.05))
	
	local missile=ents.Create("apc_missile")
	missile:SetOwner(self:GetOwner())
	missile:SetPos((self:GetOwner():GetShootPos()+dir:Angle():Up()*50+dir*10))
	missile:SetAngles(dir:Angle())
	missile:Spawn()
	self:GetOwner().GAME_FireImmunity=(CurTime()+1)
	
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/ar2/npc_ar2_altfire.wav"),500,math.random(50,75))
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+.6)
end

function SWEP:SecondaryAttack() end; function SWEP:GetNPCBulletSpread() return 0 end; function SWEP:GetNPCRestTimes() return 2.5,2.5 end