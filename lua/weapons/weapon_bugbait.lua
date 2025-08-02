SWEP.Category="Bodyparts"
SWEP.PrintName="Antlion Pheropods"
if CLIENT then language.Add("weapon_bugbait","Antlion Pheropods") end
SWEP.Instructions="Primary to shoot."
SWEP.Purpose="Antlion Pheropods."
SWEP.WorldModel=Model("models/weapons/w_bugbait.mdl")
SWEP.Primary.ClipSize=1
SWEP.Primary.DefaultClip=1
SWEP.Primary.Automatic=yes
SWEP.Primary.Ammo=""
SWEP.Secondary.ClipSize=1
SWEP.Secondary.DefaultClip=1
SWEP.Secondary.Ammo=""
SWEP.Secondary.Automatic=yes //You can rape a bugbait. Happy?
SWEP.Spawnable=yes
SWEP.AdminOnly=no; SWEP.Weight=1
SWEP.DrawAmmo=yes
SWEP.Slot=5

function SWEP:Initialize()
	self:SetHoldType("Grenade")
end

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	local tar=Trace({
		start=self:GetOwner():EyePos(),
		endpos=self:GetOwner():EyePos()+GetAimVector(self:GetOwner())*3000,
		filter=self:GetOwner():AllRelatedEntities(),
		mask=MASK_VISIBLE_AND_NPCS,
	}).Entity
	if IsValid(tar)&&!vararg({["npc_antlion"]=yes,["npc_antlion_worker"]=yes,["npc_antlionguard"]=yes,["npc_antlion_grub"]=yes})[tar:GetClass()] then
		for _,ent in ipairs(ents.FindInSphere(self:GetOwner():GetPos(),3000)) do if vararg({["npc_antlion"]=yes,["npc_antlion_worker"]=yes,["npc_antlionguard"]=yes,["npc_antlion_grub"]=yes})[ent:GetClass()] then ent:SetEnemy(tar) end end
		self:EmitSound(Sound("weapons/bugbait/bugbait_squeeze"+rand(1,3)+".wav"),500,100)
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
		self:SetNextPrimaryFire(CurTime()+3)
	end
end

function SWEP:SecondaryAttack()
	if !self:CanSecondaryAttack() then return end
	//This shit's purpose is that it makes a disgusting noise..why? Dont know
	self:EmitSound(Sound("weapons/bugbait/bugbait_squeeze"+rand(1,3)+".wav"),500,100)
	//self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	self:SetNextSecondaryFire(CurTime()+0.33)
end

list.Add("NPCUsableWeapons",{class="weapon_bugbait",title="#weapon_bugbait",category=SWEP.Category})