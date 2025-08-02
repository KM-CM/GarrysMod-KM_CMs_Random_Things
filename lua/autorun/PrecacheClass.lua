/*Note that running it only on SV makes sound bug out in MP.
We only need a class for returns (CPrecClass:Get*() funcs).*/

CPrecClass={} //Precached Class
CPrecClass.__index=CPrecClass

//CPrecClass._class=void
//CPrecClass._cvrtbl=void

function CPrecClass:GetClass() return self._class end
if SERVER then
	function CPrecClass:GetCvarTBL() return self._cvrtbl end
	function CPrecClass:GetNum(n) return self._cvrtbl:GetNum(self._class+"_"+n) end
	function CPrecClass:GetFlt(n) return self._cvrtbl:GetFlt(self._class+"_"+n) end
	function CPrecClass:GetStr(n) return self._cvrtbl:GetStr(self._class+"_"+n) end
end

if SERVER then
	function PrecacheClass(tbl)
		local self=setmetatable({},CPrecClass)
		self._class=tostring(tbl.Class||void)
		self._cvrtbl=CvarTBL()
		for name,data in pairs(tbl.Cvars||{}) do
			local t,n,d,dc=data.type,name,data.def,data.desc
			if t=="num" then self._cvrtbl:AddNum(self._class+"_"+n,d,dc) //That can also be flt. You just have to get it with CPrecClass:GetFlt(n) instead of CPrecClass:GetNum(n).
			else self._cvrtbl:AddStr(self._class+"_"+n,d,dc) end
		end
		for n,d in pairs(tbl.Sounds||{}) do d.name=self._class+"."+n sound.Add(d) end //I ALMOST REPLACED WITH "." WITH "_" AND DELETED WHOLE SCRIPT BECAUSE IT WASNT WORKING!! XD
		return self
	end
	function PrecacheSounds(class,tbl) for n,d in pairs(tbl||{}) do d.name=class+"."+n sound.Add(d) end end
else
	function PrecacheClass(tbl)
		local self=setmetatable({},CPrecClass)
		self._class=tostring(tbl.Class||void)
		self._cvrtbl=void
		for n,d in pairs(tbl.Sounds||{}) do d.name=self._class+"."+n sound.Add(d) end //I ALMOST REPLACED WITH "." WITH "_" AND DELETED WHOLE SCRIPT BECAUSE IT WASNT WORKING!! XD
		return self
	end
	function PrecacheSounds(class,tbl) for n,d in pairs(tbl||{}) do d.name=class+"."+n sound.Add(d) end end
end 