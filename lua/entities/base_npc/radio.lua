//This is a better version of commands.lua,
//Use this only if you know what youre doing

ENT.bHasRadio=yes
ENT.RadioAnswerQuery=ENT.RadioAnswerQuery||{
	["sectornotsecure"]=function(self,sender)
		self.bPatrolling=sender.bPatrolling
		if self.bPatrolling then self:SetLastAlertPos(self:GetPos()) else self:SetLastAlertPos(sender:GetLastAlertPos()) end
		self:Alert()
	end,
}

ENT.flNextRadMsg=0
function ENT:RadioMessage(name,len,func,dist)
	//Dont spam them
	if CurTime()<self.flNextRadMsg then return end
	self.flNextRadMsg=CurTime()+len
	//Wait till we finish speaking before anyone is able to answer
	timer.Simple(len,function()pcall(function()
		local d=d(dist)
		for _,ent in ipairs(ents.GetAll()) do
			if ent!=self&&ent.bHasRadio&&self:Disposition(ent)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<d then
				//You should answer with another radio message here
				local v=ent.RadioAnswerQuery[name]
				if type(v)=='function'&&CurTime()<ent.flNextRadMsg then
					pcall(function()v(ent,self)end)
				end
			end
		end
	end)end)
	//Speak
	pcall(function()func(self)end)
end 