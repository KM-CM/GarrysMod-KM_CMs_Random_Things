SWEP.Category="Fire & Anti-Fire"
SWEP.PrintName="#weapon_flamethrower"
if CLIENT then language.Add("weapon_flamethrower","Flamethrower") end
SWEP.Instructions="Primary attack to shoot flames! Yea,you can accidentaly burn yourself..."
SWEP.Purpose="Made after The Fire Update because normal GMod igniting method is just TRASH!!"
//Unrequired stuff.
//SWEP.UseHands=yes
//SWEP.ViewModel=Model("models/weapons/c_shotgun.mdl")
SWEP.WorldModel=Model("models/weapons/w_shotgun.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1//
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=no
SWEP.Slot=2

function SWEP:Initialize()
	self:SetHoldType("Shotgun")
end

function SWEP:GetNPCBurstSettings() return 1,30,0.075 end


function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local prop=ents.Create("prop_physics")
	prop.bDontBreak=yes
	prop.GAME_DontIgnite=yes
	prop:SetOwner(self:GetOwner())
	prop:SetPos((self:GetOwner():GetShootPos()+(GetAimVector(self:GetOwner())*35)+(-self:GetOwner():GetUp()*25)))
	prop:SetModel("models/roller.mdl")
	prop:SetNoDraw(yes)
	prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
	prop:Spawn()
	local flame=ents.Create("env_fire_trail")
	flame:SetOwner(self:GetOwner())
	flame:SetPos(prop:GetPos())
	flame:SetParent(prop)
	flame:Spawn()
	prop:GetPhysicsObject():AddVelocity((GetAimVector(self:GetOwner()):GetSpread(Vector(0.1,0.1,0.1))*1000))
	prop:GetPhysicsObject():EnableGravity(no)
	self:GetOwner().GAME_FireImmunity=CurTime()+1
	timer.Simple(1,function() if IsValid(prop) then prop:Remove() end end)
	timer.Simple(1,function() if IsValid(flame) then flame:Remove() end end)
	self:EmitSound(Sound("hl1/ambience/steamburst1.wav"),500,500,0.5,CHAN_STATIC)
	self:SetNextPrimaryFire(CurTime()+0.025)
end

function SWEP:SecondaryAttack() end

list.Add("NPCUsableWeapons",{class="weapon_flamethrower",title="#weapon_flamethrower",category=SWEP.Category})