SWEP.Category="Revolvers"
SWEP.PrintName="Colt Python"
if CLIENT then language.Add("weapon_357","Colt Python") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Colt Python."
SWEP.WorldModel=Model("models/weapons/w_357.mdl")
SWEP.Primary.ClipSize=6
SWEP.Primary.DefaultClip=1//
SWEP.Primary.Automatic=no // yes :: Respect real-life!
SWEP.Primary.Ammo="357"
SWEP.Secondary.ClipSize=-1
SWEP.Secondary.DefaultClip=-1
SWEP.Secondary.Automatic=no
SWEP.Secondary.Ammo=""
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=1

function SWEP:Initialize() self:SetHoldType("Revolver") end

PrecacheSounds("weapon_357",{
	["fire"]={
		sound="gunfire/weapon_357.wav",
		pitch=100,
		level = 140,
		channel=CHAN_WEAPON
	},
	["reload1"]={
		sound="weapons/357/357_reload1.wav",
		pitch=100,
		level=70,
		channel=CHAN_WEAPON,
	},
	["reload2"]={
		sound={"weapons/357/357_reload3.wav","weapons/357/357_reload4.wav"},
		pitch=100,
		level=70,
		channel=CHAN_WEAPON,
	},
	["reload3"]={
		sound="weapons/357/357_spin1.wav",
		pitch=100,
		level=70,
		channel=CHAN_WEAPON,
	},
})

function SWEP:GetNPCBurstSettings() return 1,6,0.28 end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=45,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.016666666666667,0.016666666666667,0.016666666666667),
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_357.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.133)
end

function SWEP:Reload()
	if self:Clip1()<self:GetMaxClip1()&&self:Ammo1()>0 then
		timer.Simple(0.5,function() if IsValid(self) then self:EmitSound("weapon_357.reload1") end end)
		timer.Simple(1.5,function() if IsValid(self) then self:EmitSound("weapon_357.reload2") end end)
		timer.Simple(2,function() if IsValid(self) then self:EmitSound("weapon_357.reload3") end end)
		self:DefaultReload(ACT_VM_RELOAD)
	end
end

function SWEP:SecondaryAttack() end