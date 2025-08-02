/*///////////////////////////////////////////
	=== CvarTBL ===
A useful and short way to store data in ConVars!
(DO NOT USE IF YOU ONLY HAVE 1 CVAR!!!)
///////////////////////////////////////////*/

CCvarTBL={}
CCvarTBL.__index=CCvarTBL
CCvarTBL._n={}
CCvarTBL._s={}

function CCvarTBL:AddNum(k,v,d) self._n[k]=CreateConVar(k,v,bit.bor(FCVAR_NEVER_AS_STRING,FCVAR_CHEAT,FCVAR_NOTIFY,FCVAR_SERVER_CAN_EXECUTE),d||"") end
function CCvarTBL:SetNum(k,v) self._n[k]:SetInt(v) end
function CCvarTBL:GetNum(k) return self._n[k]:GetInt() end
function CCvarTBL:SetFlt(k,v) self._n[k]:SetFloat(v) end
function CCvarTBL:GetFlt(k) return self._n[k]:GetFloat() end

function CCvarTBL:AddStr(k,v,d) self._n[k]=CreateConVar(k,v,bit.bor(FCVAR_CHEAT,FCVAR_NOTIFY,FCVAR_SERVER_CAN_EXECUTE),d||"") end
function CCvarTBL:SetStr(k,v) self._n[k]:SetString(v) end
function CCvarTBL:GetStr(k) return self._n[k]:GetString() end

function CvarTBL()
	local self=setmetatable({},CCvarTBL)
	return self
end
cvartbl=CvarTBL