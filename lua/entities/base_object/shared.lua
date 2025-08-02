AddCSLuaFile()
DEFINE_BASECLASS("base_anim")

include("!public.lua") //Yep! This once it is shared!
if SERVER then
	function ENT:Initialize()
		pcall(function()self:Init()end)
		s=tonumber(s)||SOLID_VPHYSICS
		self:PhysicsInit(s)
	end
else
	//Our baseclass(base_anim) doesnt do this automatically. Why?
	function ENT:Draw(f)self:DrawModel(f)end
	function ENT:DrawTranslucent(f)self:Draw(f)end
	function ENT:Initialize()pcall(function()self:Init()end)end
end

function ENT:__SetVelocity__(v) local p=self:GetPhysicsObject() if IsValid(p) then p:SetVelocity(v) end end
function ENT:__AddVelocity__(v) local p=self:GetPhysicsObject() if IsValid(p) then p:AddVelocity(v) end end
function ENT:__GetVelocity__(v) local p=self:GetPhysicsObject() if IsValid(p) then return p:GetVelocity(v) end end

//There are things that baseclass will do for us,
//But they look so goddamn awful I rewrite them.
ENT.AutomaticFrameAdvance=false //Awful variable name! Why did they make it unoverridable?!
function ENT:SetAutomaticFrameAdvance(b) self.AutomaticFrameAdvance=b end 