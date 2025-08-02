//ENT.Vehicle=void
//ENT.VehDriver=void
//ENT.VehPathCorner=void

function ENT:InVehicle() return IsValid(self.Vehicle) end
function ENT:GetVehicle() return self.Vehicle end
function ENT:GetVehicleDummyDriver() return self.VehDriver end

function ENT:LookupVehicle(d)
	local nv,nvd=void,sqr(d)
	for _,ent in ipairs(ents.FindByClass("prop_veh*")) do if self:ValidVehicle(ent)&&ent:GetPos():DistToSqr(self:GetPos())<nvd then nv,nvd=ent,self:GetPos():DistToSqr(ent:GetPos()) end end
	return nv
end

//Theres enough visual,pathing and targeting bugs for airboats!
function ENT:ValidVehicle(ent) return IsValid(ent)&&ent:GetClass()!="prop_vehicle_airboat"&&ent:IsVehicle()&&ent:IsEngineEnabled()&&ent:Health()>0&&ent:GetMaxSpeed()>0&&(!IsValid(ent:GetDriver())||ent:GetDriver()==self.VehDriver)&&(!IsValid(ent.VehDriver)||ent.VehDriver==self.VehDriver) end

function ENT:UpdateVehiclePose(veh)
	local pos,ang=veh:GetPassengerSeatPoint(1)
	self:SetLocalPos((pos-veh:GetPos()))
	self:SetLocalAngles((-ang:Forward():Angle()-veh:GetAng()))
end

function ENT:EnterVehicle(veh)
	if !self:ValidVehicle(veh) then return end
	local pos,ang=veh:GetPassengerSeatPoint(1)
	self:SetParent(veh)
	self:SetLocalPos((pos-veh:GetPos()))
	self:SetLocalAngles((-ang:Forward():Angle()-veh:GetAng()))
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	veh:CallOnRemove("DrivenOnRemove",function(ent) if IsValid(self)&&self:GetVehicle()==ent then self:ExitVehicle() end end)
	local dummy=ents.Create("npc_vehicledriver")
	dummy:SetParent(self)
	dummy:SetKeyValue("vehicle",IOEnt(veh))
	dummy:SetKeyValue("driverminspeed","1")
	dummy:SetKeyValue("drivermaxspeed","1")
	dummy:AddThink(function(dummy) for _,ent in ipairs(ents.GetAll()) do if ent.AddEntityRelationship then ent:AddEntityRelationship(dummy,D_NU,99) end dummy:AddEntityRelationship(ent,D_NU,99) end end)
	dummy:Spawn()
	dummy:Activate()
	veh.VehDriver=dummy
	self.VehDriver=dummy
	self.Vehicle=veh
end

function ENT:ExitVehicle()
	if !IsValid(self:GetVehicle())||!self.Vehicle:CheckExitPoint(0,100) then return end
	if IsValid(self.VehDriver) then self.VehDriver:Remove() end
	self:SetParent(NULL)
	self:SetPos(self.Vehicle:CheckExitPoint(0,100))
	self:SetCollisionGroup(COLLISION_GROUP_NPC)
	self.Vehicle.VehDriver=NULL
	self.Vehicle=NULL
end

function ENT:SetVehicleSpeed(s) if IsValid(self.VehDriver) then self.VehDriver:Fire("SetDriversMinSpeed",tostring(s)) self.VehDriver:Fire("SetDriversMaxSpeed",tostring(s)) end end

//ENT.NextVehMove=0
ENT.flNextVehMove=0
function ENT:VehicleMove(pos)
	local pc=self.VehPathCorner
	if !IsValid(pc) then
		pc=ents.Create("path_corner")
		pc:SetPos(self.VehDriver:GetPos())
		pc:SetParent(self.VehDriver)
		pc:Spawn()
		self.VehPathCorner=pc
	end
	pc:SetLocalPos((pos-self.VehDriver:GetPos()):GetNormalized()*self.VehDriver:GetPos():Distance(pos))
	if IsValid(self.VehDriver)&&CurTime()>self.flNextVehMove then
		timer.Simple(0.0001,function()self.VehDriver:Fire("GotoPathCorner",IOEnt(pc))end)
		self.flNextVehMove=CurTime()+0.5
	end
	/*
	if !IsValid(self.VehDriver)||CurTime()<self.NextVehMove then return end
	local pc=ents.Create("path_corner")
	pc:SetPos((self.VehDriver:GetPos()+dir*1000))
	pc:Spawn()
	timer.Simple(0.0001,function() if IsValid(self.VehDriver)&&IsValid(pc) then self.VehDriver:Fire("GotoPathCorner",IOEnt(pc)) end end)
	timer.Simple(1,function() if IsValid(pc) then pc:Remove() end end)
	self.NextVehMove=CurTime()+1
	*/
end

function ENT:VehicleCombat(enemy)
	self:NewActivity(self.iVehAct)
	
	self.loco:SetJumpHeight(0)
	self.loco:SetDeathDropHeight(999999)
	
	self:SetMoveTarget(enemy:GetPos())
	self:ComputeChase(enemy)
	
	self:SetVehicleSpeed(1)
	local goal=self.MovePath:NextSegment()
	if goal then self:VehicleMove(goal.pos) end
	
	if self:Visible(enemy) then self:FireVolley() end
	
	if !self:ValidVehicle(self:GetVehicle()) then self:ExitVehicle() end
end 