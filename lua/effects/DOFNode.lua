local mt=Material("pp/dof")
function EFFECT:Init(data)
	self.iScale=data:GetScale()
	DOF_Ents[self]=self
	self:SetRenderBounds(Vector(-1000,-1000,-1000),Vector(1000,1000,1000))
end
function EFFECT:Think()
	local ply=LocalPlayer()
	if !ply.GAME_PrpEyeDist then return yes end
	self:SetPos(ply:GetViewEntity():GetPos()+(ply:GetViewEntity():GetForward()*(ply.GAME_PrpEyeDist||0))+(ply:GetViewEntity():GetForward()*(ply.GAME_PrpEyeDist||0)*self.iScale))
	self:SetParent(ply:GetViewEntity())
	return yes
end
function EFFECT:Render()
	local ply=LocalPlayer()
	if !ply.GAME_PrpEyeDist then return end
	render.UpdateRefractTexture()
	render.SetMaterial(mt)
	local sz=((ply.GAME_PrpEyeDist||0)+(ply.GAME_PrpEyeDist||0)*self.iScale)*8
	render.DrawSprite(self:GetPos(),sz,sz,color_white)
end 