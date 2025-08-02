TOOL.Category="Mind"
TOOL.Name="Patrol"
TOOL.Command=void
TOOL.ConfigName=""
TOOL.ClientConVar["dist"]="1000"
TOOL.ClientConVar["len"]="0"

function TOOL.BuildCPanel(panel)
	panel:AddControl("Slider",{
		Label="Distance",
		Min="100",
		Max="10000",
		Command="mind_patrol_dist",
	})
	panel:AddControl("Slider",{
		Label="Length",
		Min="-1",
		Max="60",
		Command="mind_patrol_len",
	})
end

if CLIENT then
	language.Add("tool.mind_patrol.name","Patrol")
	language.Add("tool.mind_patrol.desc","Makes an NPC patrol. (0=patrol default time,-1=patrol forever)")
	language.Add("tool.mind_patrol.0","Left Click - Start Patrolling, Right Click - Stop Patrolling.")
else
	function TOOL:LeftClick(tr)
		local d=sqr(self:GetClientNumber("dist"))
		for _,ent in ipairs(ents.GetAll()) do if ent:GetPos():DistToSqr(tr.HitPos)<d then if ent.__ACTOR__ then
			ent.bPatrolling=yes
			ent:SetLastAlertPos(ent:GetPos())
			local n=self:GetClientNumber("len")
			if n==-1 then ent:Alert(999999)
			elseif n==0 then ent:Alert()
			else ent:Alert(n) end
		end end end
	end
	
	function TOOL:RightClick(tr)
		local ent=tr.Entity
		if ent.__ACTOR__ then ent:UnAlert() end
	end
end 