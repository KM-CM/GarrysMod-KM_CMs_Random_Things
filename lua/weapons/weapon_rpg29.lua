SWEP.Category="RPGs"
SWEP.PrintName="РПГ-29 Vampire"
if CLIENT then language.Add("weapon_rpg29","РПГ-29 Vampire") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Ручной Противотанковый Гранатомёт 29 Vampire."
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
	self:SetMaterial("models/debug/debugwhite")
	self:SetHoldType("RPG")
	self:SetColor(Color(200,255,0))
end

function SWEP:HasAmmo()
	if !self:GetOwner():IsPlayer() then return true end
	return (self:Ammo1()>0)
end

function SWEP:CanPrimaryAttack()
	if self:GetOwner():IsPlayer()&&!(self:Ammo1()>0) then
		//self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime()+0.2)
		return no
	end
	return true
end

function SWEP:GetNPCBurstSettings() return 1,1,.8 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	
	local dir=GetAimVector(self:GetOwner()):GetSpread(Vector(0.05,0.05,0.05))
	
	local m=ents.Create("apc_missile")
	m:SetOwner(self:GetOwner())
	m:SetPos((self:GetOwner():GetShootPos()+dir:Angle():Up()*50+dir*10))
	m:SetAngles(dir:Angle())
	m:Spawn()
	self:GetOwner().GAME_FireImmunity=CurTime()+1
	
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound(Sound("weapons/mortar/mortar_fire1.wav"),500,115)
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+.8)
end

function SWEP:SecondaryAttack() end; function SWEP:GetNPCBulletSpread() return 0 end; function SWEP:GetNPCRestTimes() return 1.5,1.5 end

list.Add("NPCUsableWeapons",{class="weapon_rpg29",title="#weapon_rpg29",category=SWEP.Category})