CAppearance={}
CAppearance.__index=CAppearance

function CAppearance:SetMesh(m) self._mdl=m end
function CAppearance:GetMesh(m) return self._mdl end

function CAppearance:SetColor(c) self._clr=c end
function CAppearance:SetColor() return self._clr end

//To have mesh act as a model dont set any of this.
function CAppearance:SetOneMat(m) self._mat=m end
function CAppearance:GetOneMat() return self._mat end
function CAppearance:SetMaterial(i,m) if type(self._mat)!='table' then self._mat={} end self._mat[i]=m end
function CAppearance:GetMaterial(i) if type(self._mat)!='table' then return void end return self._mat end

//Currently only supports default material. ;-;
function CAppearance:__tocode() return "CreateAppearance({Mesh=\""+self._mdl+"\",Color="+tocode(self._clr)+"})" end

function Appearance() local self=setmetatable({},CAppearance) return self end
function CreateAppearance(tbl)
	local self=setmetatable({},CAppearance)
	self._mdl=tbl.Mesh||""
	self._mat=tbl.Material||void
	self._clr=tbl.Color||Color(255,255,255)
	return self
end

local CENT=FindMetaTable("Entity")
function CENT:SetAppearance(ap)
	self:SetModel(ap._mdl)
	self:SetColor(ap._clr||Color(255,255,255))
	if type(ap._mat)=='table' then for i,m in pairs(ap._mat) do self:SetSubMaterial(i-1,m) end elseif type(ap._mat)=='string' then self:SetMaterial(ap._mat) end
end
function CENT:GetAppearance() local mt=self:GetMaterial() return CreateAppearance({
	Mesh=self:GetModel(),
	Material=#mt>0&&mt||self:GetMaterials(),
	Color=self:GetColor(),
}) end 