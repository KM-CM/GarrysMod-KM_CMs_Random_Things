AddCSLuaFile()
DEFINE_BASECLASS 'base_projectile'

if SERVER then include '!public.lua' end

ENT.iClass = CLASS_NONE
function ENT:GetNPCClass() return self.iClass end
function ENT:SetNPCClass( i ) self.iClass = i end
