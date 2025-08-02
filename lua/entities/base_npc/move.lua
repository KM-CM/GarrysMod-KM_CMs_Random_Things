ENT.flGunSweepP = 0
ENT.flGunSweepY = 0
ENT.flSweepReachedTime = nil

//ENT.bAllyAvoidLeft = false

sv_gravity = GetConVar 'sv_gravity'
function ENT:AddMovementMixins( dir, flHeight, tFilter )
	local vel = GetVelocity( self )
	local vlen = #vel
	local len = lmax( self:OBBMaxs().z * 2, vlen )
	dir = dir:GetFlat():GetNormalized()
	local tr = Trace {
		start = self:GetCenter(),
		endpos = self:GetCenter() + dir * len,
		filter = tFilter && table.add( tFilter, self:AllRelatedEntities() ) || self:AllRelatedEntities(),
		mask = MASK_SOLID
	}
	local ent = tr.Entity
	/*At First I Thought It was a Good Idea to Jump Above Allies, But in Practice,
	That Just Made Hordes of Antlion Chaotic. Because They werent Jumping to Intercept,
	Which was a Mechanic I was Creating, But Instead Jumping Above EachOther*/
	if tr.Hit && ( !IsValid( ent ) || self:Disposition( ent ) != D_LI ) && ( !self.MovePath || ( !self.MovePath:GetCurrentGoal() || tr.HitPos:DistToSqr( self:GetPos() ) > self.MovePath:GetCurrentGoal().pos:DistToSqr( self:GetPos() ) ) ) then
		if self:IsOnGround() then
			if tr.StartPos:Distance( tr.HitPos ) <= self:OBBMaxs().x * 1.5 then return ( tr.StartPos - tr.HitPos ):GetNormalized(), flHeight end
			local flNewHeight = 0 //NOT Related to flHeight!
			local flMaxJumpLength = ( 2 * sv_gravity:GetFloat() * self.loco:GetJumpHeight() ) ^ .5
			while true do
				flNewHeight = flNewHeight + 32
				if !self.bCanClimbUp && flNewHeight > self.loco:GetJumpHeight() || Trace( {
					start = self:GetPos() + self:GetUp() * self:OBBMaxs().z,
					endpos = self:GetPos() + self:GetUp() * self:OBBMaxs().z + Vector( 0, 0, flNewHeight ),
					filter = self:AllRelatedEntities(),
					mask = MASK_SOLID
				} ).Hit then break end
				local tr = Trace {
					start = self:GetCenter() + Vector( 0, 0, flNewHeight ),
					endpos = self:GetCenter() + Vector( 0, 0, flNewHeight ) + dir * len,
					filter = self:AllRelatedEntities(),
					mask = MASK_SOLID
				}
				if tr.Hit then continue end
				local flDist = tr.HitPos:Distance( self:GetPos() )
				if tr.HitPos:Distance2D( self:GetPos() ) > flMaxJumpLength || abs( tr.HitPos.z - self:GetPos().z ) > self.loco:GetJumpHeight() then break end
				//Dont Use The Vector to MakeShift Goal Option, and Instead Pretend to be a Jump Across Gap Goal
				local ntr = Trace( {
					start = tr.HitPos,
					endpos = tr.HitPos + Vector( 0, 0, flDist ),
					filter = self:AllRelatedEntities(),
					mask = MASK_SOLID
				} )
				if ntr.Hit then continue end
				self:Jump { type = 3, pos = tr.HitPos }
				return
			end
		end
	end
	local tr = Trace {
		start = self:GetCenter(),
		endpos = self:GetCenter() + dir * self:OBBMaxs().z,
		filter = self:AllRelatedEntities(),
		mask = MASK_SOLID
	}
	local ent = tr.Entity
	if tr.Hit && IsValid( ent ) && self:Disposition( ent ) == D_LI then
		if rand( 8000 * FrameTime() ) == 1 then self.bAllyAvoidLeft = rand( 2 ) == 1 end
		if self.bAllyAvoidLeft then return ( dir + dir:Angle():Right() * -.5 ):GetNormalized(), flHeight else return ( dir + dir:Angle():Right() * .5 ):GetNormalized(), flHeight end
	end
	return dir, flHeight
end

function ENT:SweepGun( d, p, y, r, t )
	p, y, r, t = tonumber( p ) || 45, tonumber( y ) || 70, tonumber( r ) || .2, tonumber( t ) || .33
	local ang = d || self:GetForward()
	if !isangle( ang ) then ang = ang:Angle() end
	ang.p = ang.p + self.flGunSweepP
	ang.y = ang.y + self.flGunSweepY
	if self.AimVector:Dot( ang:Forward() ) > math.cos( math.rad( ( p + y ) * .5 * r ) ) || self.flGunSweepP > p || self.flGunSweepY > y then
		self.flSweepReachedTime = self.flSweepReachedTime || CurTime()
		if CurTime() > self.flSweepReachedTime + t then
			self.flGunSweepP = math.rand( -p * .5, p * .5)
			self.flGunSweepY = math.rand( -y * .5, y * .5)
			self.flSweepReachedTime = nil
		end
	end
	return ang
end

/*
ENT.flNextGunSweep=0
ENT.flGunSweepP=0
ENT.flGunSweepY=0

function ENT:SweepGun(p,y,rm,rn)
	p,y,rm,rn=tonumber(p)||45,tonumber(y)||70,tonumber(rm)||0.33,tonumber(rn)||0.66
	
	if self.flGunSweepP>p||self.flGunSweepY>y||CurTime()>self.flNextGunSweep then
		self.flGunSweepP=math.rand(-p*0.5,p*0.5)
		self.flGunSweepY=math.rand(-y*0.5,y*0.5)
		self.flNextGunSweep=CurTime()+math.rand(rm,rn)
	end
	
	local ang=self:GetForward():Angle()
	ang.p=ang.p+self.flGunSweepP
	ang.y=ang.y+self.flGunSweepY
	return ang
end
function ENT:ForceSweepGun(p,y)
	p,y=tonumber(p)||45,tonumber(y)||70
	
	self.flGunSweepP=math.rand(-p*0.5,p*0.5)
	self.flGunSweepY=math.rand(-y*0.5,y*0.5)
	
	local ang=self:GetForward():Angle()
	ang.p=ang.p+self.flGunSweepP
	ang.y=ang.y+self.flGunSweepY
	return ang
end
*/

function ENT:CanTraverseArea(area)
	if !self.loco:IsAreaTraversable(area) then return no end
	if !self.bAllowUnderwaterAreas&&area:IsUnderwater() then return no end
	return yes
end

ENT.flHordeMovementAdd = 0

/*
NPC_PATHGEN_DEFAULT=function(self,area,farea,lad,elv,len)
	if !IsValid(farea) then return 0 end
	//if !self.loco:IsAreaTraversable(area) then return -1 end :: This sucks, we need a better way to check this.
	if !self:CanTraverseArea(area) then return -1 end //Here it is
	local dist=0
	if IsValid(lad) then dist=lad:GetLength() elseif len>0 then dist=len else dist=(area:GetCenter()-farea:GetCenter()):GetLength() end
	local cost=dist+farea:GetCostSoFar()
	local z=farea:ComputeAdjacentConnectionHeightChange(area)
	//Its self.loco:GetGravity()*0.005, not 5*(self.loco:GetGravity()/1000). Avoid unnecessary calculations.
	if z>=self.loco:GetStepHeight() then if z>self.loco:GetMaxJumpHeight()||self:InVehicle() then return -1 end cost=cost+dist*(self.loco:GetGravity()*0.005) elseif z<-self.loco:GetDeathDropHeight() then return -1 end
	return cost
end
*/

function ENT:CreatePathGenerator( c ) return function( a, fa, l, e, n ) return c( self, a, fa, l, e, n ) end end

function ENT:BodyUpdate()
	self:SetPoseParameter( 'move_yaw', math.ceil( ( GetVelocity( self ):Angle() - self:GetAngles() ).y ) )
	if self.bPlaySequenceAndWait then self:FrameAdvance() else self:BodyMoveXY() end
end

function ENT:GetPath() return self.MovePath end

//ENT.vMoveToPos = nil
function ENT:SetMoveTarget( v ) self.vMoveToPos = v end
function ENT:GetMoveTarget() return self.vMoveToPos || self:GetPos() end

function ENT:GetRandomVector() return self.bFlying&&VectorRand()||Vector(math.rand(-1,1),math.rand(-1,1),math.rand(-0.1,0.1)):GetNormalized() end

ENT.bLastComputeStatus = true
ENT.bLastChaseComputeStatus = true

function ENT:Advance() //NOT for Flying NPCs!
	if IsValid( self:GetParent() ) then return end //Nope
	local goal = self.MovePath:GetCurrentGoal()
	if !goal || self:InVehicle() then return end
	if goal.type == 2 && IsValid( goal.ladder ) then
		pcall( function() self:Climb( goal ) end )
		return
	elseif goal.type == 2 || goal.type == 3 then
		pcall( function() self:Jump( goal ) end )
		return
	end
	self.MovePath:Update( self )
end

function ENT:AllowRepath( vec )
	if self.vLastMoveToPos then return vec:Distance( self.vLastMoveToPos ) > self.flPathTol * clamp( math.Remap( vec:Distance( self:GetPos() ), 0, 4000, 1, 8 ), 1, 8 ) end
	local Path = self.MovePath
	if !Path:IsValid() || !Path:GetCurrentGoal() then return true end
	return false
end

function ENT:ComputePath( vec, comp )
	vec = isvector( vec ) && vec || self.vMoveToPos
	if !vec then return nil end
	if !self:AllowRepath( vec ) then return false end
	self.vLastMoveToPos = vec
	self.bLastComputeStatus = self.MovePath:Compute( self, vec, Either( comp, self:CreatePathGenerator( comp ), nil ) )
	return self.bLastComputeStatus
end
function ENT:ComputeChase( ent, comp )
	local vec = self:FindChaseWay( ent )
	if !IsValid( ent ) then return nil end
	if !self:AllowRepath( vec ) then return false end
	self.vLastMoveToPos = vec
	self.bLastComputeStatus = self.MovePath:Compute( self, vec, Either( comp, self:CreatePathGenerator( comp ), nil ) )
	self.bLastChaseComputeStatus = self.bLastComputeStatus
	return self.bLastChaseComputeStatus
end
function ENT:ComputeRunAway( ent, comp )
	local vec = self:FindRunWay()
	if !vec then return nil end
	if !self:AllowRepath( vec ) then return false end
	self.vLastMoveToPos = vec
	self.bLastComputeStatus = self.MovePath:Compute( self, vec, Either( comp, self:CreatePathGenerator( comp ), nil ) )
	return self.bLastComputeStatus
end 