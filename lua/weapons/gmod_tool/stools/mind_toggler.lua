TOOL.Category="Mind"
TOOL.Name="Toggler"
TOOL.Command=void
TOOL.ConfigName=""

if CLIENT then
	language.Add("tool.mind_toggler.name","Toggler")
	language.Add("tool.mind_toggler.desc","Toggles NPC's AI.")
	language.Add("tool.mind_toggler.0","Left Click - Lock AI, Right Click - Unlock AI.")
else
	function TOOL:LeftClick(tr)
		local ent=tr.Entity
		if ent.__ACTOR__ then ent:LockAI() end
	end
	
	function TOOL:RightClick(tr)
		local ent=tr.Entity
		if ent.__ACTOR__ then ent:UnlockAI() end
	end
end 