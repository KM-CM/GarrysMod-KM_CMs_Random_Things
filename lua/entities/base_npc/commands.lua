function ENT:OnRecieveEnemy(enemy,sender) self.tEnemies[ enemy:EntIndex() ] = enemy end
function ENT:OnRecieveCheckPosAsk(pos,sender)
	if IsValid(self:GetEnemy()) then return end
	self.bPatrolling=no
	self:SetLastAlertPos(pos)
	self:Alert()
end
function ENT:OnRecieveAlertPatrol(sender)
	if IsValid(self:GetEnemy()) then return end
	self.bPatrolling=yes
	self:SetLastAlertPos(self:GetPos())
	self:Alert()
end
function ENT:OnRecieveThisIsClear( VecOrEnt, sender )
	local bEnt = isentity( VecOrEnt ) && IsValid( VecOrEnt )
	local vec = bEnt && VecOrEnt:GetCenter() || VecOrEnt
	local d = sqr( bEnt && self.iNoThreatDistToFound * 3 || self.iNoThreatDistToFound )
	local tBullseyes, tBullseyesOld = {}, self.tBullseyes
	for enemy, ent in pairs( tBullseyesOld ) do
		if self:GetPos():DistToSqr( vec ) < d then
			ent:Remove()
		else tBullseyes[ enemy ] = ent end
	end
	self.tBullseyes = tBullseyes
	local pos = self.vLastAlertPos
	if isvector( pos ) && pos:DistToSqr( vec ) < d then
		self.bPatrolling = true
		self:Alert()
	end
end
function ENT:OnRecieveFlank(sender) self:UpdateFlankData() end
function ENT:OnRecieveSomething(name,data,sender) end

function ENT:SendEnemy(anim,dist,tar)
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	if IsValid(self:GetEnemy())&&!tar then tar=self:GetEnemy() end
	self:Alert()
	for _,ent in pairs(NPC.List) do if IsValid(ent)&&ent!=self&&ent.Disposition&&ent:Disposition(self)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<dist then pcall(function() ent:OnRecieveEnemy(tar,self) end) end end
	if type(anim)=='function' then pcall(function() anim(self) end) end
end

function ENT:CheckPos(anim,pos,dist)
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	self:Alert()
	for _,ent in pairs(NPC.List) do if IsValid(ent)&&ent!=self&&ent.Disposition&&ent:Disposition(self)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<dist then pcall(function() ent:OnRecieveCheckPosAsk(pos,self) end) end end
	if type(anim)=='function' then pcall(function() anim(self) end) end
end

function ENT:AlertPatrol(anim,dist)
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	self:Alert()
	for _,ent in pairs(NPC.List) do if IsValid(ent)&&ent!=self&&ent.Disposition&&ent:Disposition(self)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<dist then pcall(function() ent:OnRecieveAlertPatrol(self) end) end end
	if type(anim)=='function' then pcall(function() anim(self) end) end
end

function ENT:Flank(anim,dist)
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	self:Alert()
	for _,ent in pairs(NPC.List) do if IsValid(ent)&&ent.Disposition&&ent:Disposition(self)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<dist then pcall(function() ent:OnRecieveFlank(pos,self) end) end end
	if type(anim)=='function' then pcall(function() anim(self) end) end
end

function ENT:ThisIsClear( VecOrEnt, dist )
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	for _,ent in ipairs( ents.GetAll() ) do if self:Disposition( ent )==D_LI && ent:GetPos():DistToSqr( self:GetPos() ) < dist then pcall( function() ent:OnRecieveThisIsClear( VecOrEnt, self) end ) end end
end

function ENT:SendSomething(anim,name,data,dist)
	dist = sqr( tonumber( dist || self.flAllySearchDist ) )
	for _,ent in pairs(NPC.List) do if (IsValid(ent)&&ent!=self&&ent.Disposition&&ent:Disposition(self)==D_LI&&ent:GetPos():DistToSqr(self:GetPos())<dist&&(hastosee&&(ent:CanSee(self)&&self:CanSee(ent))||!hastosee)) then pcall(function() ent:OnRecieveSomething(name,data,self) end) end end
	if type(anim)=='function' then pcall(function() anim(self) end) end
end 