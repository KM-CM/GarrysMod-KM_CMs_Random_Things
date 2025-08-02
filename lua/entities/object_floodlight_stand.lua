AddCSLuaFile()
DEFINE_BASECLASS 'base_object'

ENT.PrintName="Floodlight Stand"
if CLIENT then language.Add("object_floodlight_stand","Floodlight Stand") end

//ENT.LLight=void
//ENT.RLight=void

sound.Add({
	name="object_floodlight_stand.toggle",
	sound="buttons/lightswitch2.wav",
	pitch=90,
	level=110,
	channel=CHAN_WEAPON,
})

function ENT:SetupDataTables()
	------- Misc -------
	self:NetworkVar("Bool",0,"State",{KeyName="raw.state"})
	self:NetworkVar("Bool",1,"Lock",{KeyName="raw.lock"})

	------- Power -------
	self:NetworkVar("Float",0,"PowerCur",{KeyName="raw.powercur"})
	self:NetworkVar("Float",1,"PowerMax",{KeyName="raw.powermax"})
	self:NetworkVar("Float",2,"PowerDrain",{KeyName="raw.powerdrain"})
	self:NetworkVar("Float",3,"PowerRegen",{KeyName="raw.powerregen"})
	
	------- Left Light -------
	self:NetworkVar("Vector",0,"LColor",{KeyName="raw.lcolor"})
	self:NetworkVar("Float",4,"LForceShutUntil",{KeyName="raw.lforceshutuntil"})
	self:NetworkVar("Float",5,"LBrightness",{KeyName="raw.lbrightness"})
	
	------- Right Light -------
	self:NetworkVar("Vector",1,"RColor",{KeyName="raw.rcolor"})
	self:NetworkVar("Float",6,"RForceShutUntil",{KeyName="raw.rforceshutuntil"})
	self:NetworkVar("Float",7,"RBrightness",{KeyName="raw.rbrightness"})
end

function ENT:Initialize()
	self:SetModel("models/props_c17/light_floodlight02_off.mdl")
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local p=self:GetPhysicsObject()
		if IsValid(p) then p:SetDamping(0,15) p:Wake() else self:Remove() end
		
		self:SetPowerMax(60)
		self:SetPowerCur(self:GetPowerMax())
		self:SetPowerDrain(1)
		self:SetPowerRegen(1)
		
		local c=Vector(math.rand(.33,.66),math.rand(.33,.66),math.rand(.33,.66))
		
		self:SetLColor(c)
		self:SetLForceShutUntil(0)
		self:SetLBrightness(700)

		self:SetRColor(c)
		self:SetRForceShutUntil(0)
		self:SetRBrightness(700)
		
		timer.Simple(0.01,function()pcall(function()
		self:SetState(Off)
		self:SetLock(Off)
		end)end)
	end
end

function ENT:GetLLightPos() return self:GetPos()+self:GetUp()*78+self:GetLeft()*14 end
function ENT:GetLLightAng() return self:GetAng() end

function ENT:GetRLightPos() return self:GetPos()+self:GetUp()*78+self:GetRight()*14 end
function ENT:GetRLightAng() return self:GetAng() end

function ENT:GetActLBrightness() return self:GetPowerCur()/self:GetPowerMax()*self:GetLBrightness() end
function ENT:GetActRBrightness() return self:GetPowerCur()/self:GetPowerMax()*self:GetRBrightness() end

if SERVER then
	function ENT:Think()
		if self:GetState() then
			if self:GetPowerCur()<=0||CurTime()<self:GetLForceShutUntil()&&CurTime()<self:GetRForceShutUntil() then self:SetState(Off) return True end
			if CurTime()<self:GetLForceShutUntil() then
				if IsValid(self.LLight) then self.LLight:Remove()end
			elseif !IsValid(self.LLight) then
				local pt=ents.Create("env_projectedtexture")
				pt:SetPos(self:GetLLightPos())
				pt:SetAngles(self:GetAngles())
				pt:SetParent(self)
				pt:SetOwner( self )
				pt:SetKeyValue("fov","120")
				local c={}
				for n in string.gmatch(tostring(self:GetLColor():ToColor()),"%S+") do table.insert(c,tonumber(n)||255) end
				pt:SetKeyValue("lightcolor",c[1].." "..c[2].." "..c[3].." "..self:GetActLBrightness())
				pt:SetKeyValue("NearZ","15")
				pt:SetKeyValue("FarZ","600")
				pt:SetTexture("effects/flashlight001")
				pt:Spawn()
				self.LLight=pt
			elseif IsValid(self.LLight) then
				local pt=self.LLight
				pt:SetPos(self:GetLLightPos())
				pt:SetAng(self:GetLLightAng())
				local c={}
				for n in string.gmatch(tostring(self:GetLColor():ToColor()),"%S+") do table.insert(c,tonumber(n)||255) end
				pt:SetKeyValue("lightcolor",c[1].." "..c[2].." "..c[3].." "..self:GetActLBrightness())
			end
			if CurTime()<self:GetRForceShutUntil() then
				if IsValid(self.RLight) then self.RLight:Remove() end
			elseif !IsValid(self.RLight) then
				local pt=ents.Create("env_projectedtexture")
				pt:SetPos(self:GetRLightPos())
				pt:SetAngles(self:GetAngles())
				pt:SetParent(self)
				pt:SetOwner( self )
				pt:SetKeyValue("fov","120")
				local c={}
				for n in string.gmatch(tostring(self:GetRColor():ToColor()),"%S+") do table.insert(c,tonumber(n)||255) end
				pt:SetKeyValue("lightcolor",c[1].." "..c[2].." "..c[3].." "..self:GetActRBrightness())
				pt:SetKeyValue("NearZ","15")
				pt:SetKeyValue("FarZ","600")
				pt:SetTexture("effects/flashlight001")
				pt:Spawn()
				self.RLight=pt
			elseif IsValid(self.RLight) then
				local pt=self.RLight
				pt:SetPos(self:GetRLightPos())
				pt:SetAng(self:GetRLightAng())
				local c={}
				for n in string.gmatch(tostring(self:GetRColor():ToColor()),"%S+") do table.insert(c,tonumber(n)||255) end
				pt:SetKeyValue("lightcolor",c[1].." "..c[2].." "..c[3].." "..self:GetActRBrightness())
			end
			self:SetPowerCur(clamp(self:GetPowerCur()-self:GetPowerDrain()*((CurTime()<self:GetLForceShutUntil()||CurTime()<self:GetRForceShutUntil())&&(FrameTime()*.5)||FrameTime()),0,self:GetPowerMax()))
			return
		end
		if IsValid(self.LLight) then self.LLight:Remove() end
		if IsValid(self.RLight) then self.RLight:Remove() end
		self:SetPowerCur(clamp(self:GetPowerCur()+self:GetPowerRegen()*FrameTime(),0,self:GetPowerMax()))
	end
end

function ENT:KeyValue(k,v)
	k=string.lower(k)
	if self:SetNetworkKeyValue(k,v) then return end
end

function ENT:Enable()
	if self:GetLock()||CurTime()<self:GetLForceShutUntil()&&CurTime()<self:GetRForceShutUntil() then return end
	self:EmitSound("object_floodlight_stand.toggle")
	self:SetState(on)
end
function ENT:Disable()
	if self:GetLock()||CurTime()<self:GetLForceShutUntil()&&CurTime()<self:GetRForceShutUntil() then return end
	self:EmitSound("object_floodlight_stand.toggle")
	self:SetState(off)
end
function ENT:Toggle() if self:GetState() then self:Disable() else self:Enable() end end
function ENT:Use() self:Toggle() end

function ENT:Damaged(d)
	if d:GetDamagePosition():DistToSqr(self:GetLLightPos())<100 then
		if CurTime()>self:GetLForceShutUntil() then self:EmitSound("glass.break.small") end
		self:SetLForceShutUntil( CurTime() + 5 )
	elseif d:GetDamagePosition():DistToSqr(self:GetRLightPos())<100 then
		if CurTime()>self:GetRForceShutUntil() then self:EmitSound("glass.break.small") end
		self:SetRForceShutUntil( CurTime() + 5 )
	end
end

list.Set("SpawnableEntities","object_floodlight_stand",{
	PrintName="#object_floodlight_stand",
	ClassName="object_floodlight_stand",
	Category="Lights"
})