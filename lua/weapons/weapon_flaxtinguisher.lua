SWEP.Category="Fire & Anti-Fire"
SWEP.PrintName="#weapon_flaxtinguisher"
if CLIENT then language.Add("weapon_flaxtinguisher","Flaxtinguisher") end
SWEP.Instructions="Primary to shoot flames,secondary to stop flames."
SWEP.Purpose="I dont want to carry two SWEPs,so get this lol."
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
SWEP.Secondary.Automatic=yes
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

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	self:GetOwner():Extinguish()
	for _,ent in ipairs(ents.FindInSphere((self:GetOwner():GetShootPos()+(GetAimVector(self:GetOwner())*250)),350)) do
		if ent:IsOnFire() then ent:Extinguish() end
		ent:SetColor(Color(math.Clamp(ent:GetColor().r+7.5,1,255),math.Clamp(ent:GetColor().g+7.5,1,255),math.Clamp(ent:GetColor().b+7.5,1,255)))
		if ent:GetClass()=="env_fire_trail"&&(IsValid(ent:GetOwner())&&ent:GetOwner():GetClass()||"")!="npc_helicopter" then ent:Remove() end
	end
	self:EmitSound(Sound("ambient/water/water_spray"+tostring(math.random(1,3))+".wav"),500,100)
	self:SetNextSecondaryFire(CurTime()+0.075)
end



list.Add("NPCUsableWeapons",{class="weapon_flaxtinguisher",title="#weapon_flaxtinguisher",category=SWEP.Category})