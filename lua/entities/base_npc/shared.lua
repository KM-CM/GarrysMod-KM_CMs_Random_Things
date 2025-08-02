NPC = NPC || {}
NPC.List = NPC.List || {}
NPC.Class = NPC.Class || {}

if SERVER then
	function NPC.Register( t )
		t.PrintName = nil
		t.Base = nil
		t.Folder = nil
		NPC.Class[ t.Class ] = t
		t.Base = 'base_npc'
		t.PrintName = '#' + t.Class
		scripted_ents.Register( t, t.Class )
	end
else
	function NPC.Register( t )
		t.PrintName = nil
		t.Base = nil
		t.Folder = nil
		NPC.Class[ t.Class ] = t
		language.Add( t.Class, t.Name )
		t.Base='base_npc'
		t.PrintName = '#' + t.Class
		scripted_ents.Register( t, t.Class )
	end
end

AddCSLuaFile()

ENT.Base = 'base_nextbot'
ENT.Type = 'nextbot'

if CLIENT then language.Add( 'base_npc', 'Actor' ) end
ENT.PrintName = '#base_npc'

ENT.Purpose = "NPC Base."
ENT.Instructions = "NPC Base."

ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.__ACTOR__ = true
//ENT.bDead = false

if SERVER then
	include '!public.lua'
	include 'main.lua'
	include 'commands.lua'
	include 'radio.lua'
	include 'move.lua'
	include 'moveblend.lua'
	include 'weapons.lua'
	include 'tactics.lua'
	include 'vehicles.lua'
	include 'server.lua'
	include 'misc.lua'
	include 'senses.lua'
	include 'mixins.lua'
	include 'schedule.lua'
	include 'behaviour/!behaviour.lua'
else
	//Didnt knew flags were there before V154. Now theyre supported.
	//(To be honest, from what I read/found, theyre not that useful)
	function ENT:Draw(f)self:DrawModel(f)end
	function ENT:DrawTranslucent(f)self:Draw(f)end
	function ENT:FireAnimationEvent(pos,ang,event,options)end
end

function ENT:Damaged(d,b) end //Return true to suppress the damage event

if SERVER then
	function ENT:OnTakeDamage(dmginfo)
		if self.bDead then return 0 end
		local NB=void
		local NBD=math.huge
		for i=0,(self:GetBoneCount()-1) do
			if (self:GetBonePosition(i):Distance(dmginfo:GetDamagePosition())<NBD) then
				NB=self:GetBoneName(i)
				NBD=self:GetBonePosition(i):Distance(dmginfo:GetDamagePosition())
			end
		end
		local sup=pcall_ret(function()return self:Damaged(dmginfo,NB||void)end)==true
		if !sup then self:SetHealth((self:Health()-dmginfo:GetDamage())) end
		if self:Health()<1 then
			if SERVER then self:KilledCleanup() end
			self:GodEnable()
			self:DropWeapon()
			//Called automatically, somehow.
			//This isnt in any of my codes,
			//Nor is it desired, but okay.
			//(Also, calling it twice is a L,
			//As a invis yet collidable,
			//Second ragdoll, appears.)
			//self:OnKilled(dmginfo,NB||void)
			self.bDead=yes
		else if IsValid(dmginfo:GetAttacker())&&self:IsHateDisp(dmginfo:GetAttacker()) then self:OnAttacked(dmginfo) end return sup&&0||no end
	end
end

NPC.Base = ENT
scripted_ents.Register( ENT, 'base_npc' )