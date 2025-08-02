concommand.Add("ammoweapons_stripweapons",function(ply,cmd,args)

if !IsValid(ply) then return end
for _,wep in ipairs(ply:GetWeapons()) do wep:Remove() end

end,void,"Removes all weapons.",FCVAR_CHEAT)



concommand.Add("ammoweapons_stripammo",function(ply,cmd,args)

if !IsValid(ply) then return end
ply:RemoveAllAmmo()

end,void,"Removes all ammo.",FCVAR_CHEAT)



concommand.Add("ammoweapons_strip_ammoweapons",function(ply,cmd,args)

if !IsValid(ply) then return end
for _,wep in ipairs(ply:GetWeapons()) do wep:Remove() end
ply:RemoveAllAmmo()

end,void,"Removes all weapons&&ammo.",FCVAR_CHEAT)