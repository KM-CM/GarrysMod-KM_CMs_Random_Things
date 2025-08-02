SWEP.Category="Submachine Guns"
SWEP.PrintName="MP7"
if CLIENT then language.Add("weapon_smg1","MP7") end
SWEP.Instructions="Primary to shoot,secondary to switch to auto/semi."
SWEP.Purpose="MP7."
SWEP.WorldModel=Model("models/weapons/w_smg1.mdl")
SWEP.Primary.ClipSize=40
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
SWEP.Mode=1

function SWEP:Initialize() self:SetHoldType("SMG") end

function SWEP:GetNPCBurstSettings() return 1,40,0.06315789473 end

PrecacheSounds("weapon_smg1",{
	["fire"]={
		sound="^gunfire/weapon_smg1.wav",
		level = 140,
		channel=CHAN_WEAPON,
	},
	["reload"]={
		sound="weapons/smg1/smg1_reload.wav",
		pitch=100,
		level=70,
		channel=CHAN_WEAPON,
	},
})

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:FireBullets({
		Damage=7.5,
		Dir=GetAimVector(self:GetOwner()),
		Src=self:GetOwner():GetShootPos()||self:GetPos(),
		Attacker=self:GetOwner(),
		Spread=Vector(0.03378,0.03378,0.03378),//Its ok,its just ok,ok.
		Tracer=1,
	})
	self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:EmitSound("weapon_smg1.fire")
	if self:GetOwner():IsPlayer() then self:TakePrimaryAmmo(1) end
	self:SetNextPrimaryFire(CurTime()+0.06315789473)
end

function SWEP:Reload()
	if self:Clip1()<self:GetMaxClip1()&&self:Ammo1()>0 then
		self:EmitSound("weapon_smg1.reload")
		self:DefaultReload(ACT_VM_RELOAD)
	end
end

function SWEP:SecondaryAttack() self:EmitSound(Sound("buttons/lightswitch2.wav")) self.Primary.Automatic=!self.Primary.Automatic end