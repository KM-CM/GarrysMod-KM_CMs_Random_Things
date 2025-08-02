function ENT:BehaveStart() self.BehaveThread = coroutine.create( function() self:RunBehaviour() end ) end
function ENT:BehaveUpdate()
	local s, e = coroutine.resume( self.BehaveThread )
	if !s then MsgC(Color(255,0,0,255),self,": UNEXPECTER ERROR OCCURED!: "+e+"\nThis is NOT a behaviour error, but rather a **base** error!\nSend it, and how you made it happen, to me (KM_CM), and I'll try and investigate.\nRestarting The ENT:RunBehaviour() coroutine....\n") self.BehaveThread=coroutine.create(function() self:RunBehaviour() end) end
end

function ENT:__SetVelocity__(v) self.loco:SetVelocity(v) end
function ENT:__GetVelocity__() return self.loco:GetVelocity() end
function ENT:__AddVelocity__(v) return self.loco:SetVelocity(GetVelocity(self)+v) end

function ENT:PlaySequenceAndWait( name, speed, cut, run, runend, pos, ang ) self:ExecInRB( function( self ) self:PlaySequenceAndWaitC( name, speed, cut, run, runend, pos, ang ) end ) end

ENT.sPlaySequenceAndWait = '' //Not Guaranteed to Actually be a String!
function ENT:PlaySequenceAndWaitC( name, speed, cut, run, runend, pos, ang )
	self:StartActivity( ACT_INVALID )
	self.sPlaySequenceAndWait = name
	if isstring( name ) then name = self:LookupSequence( name ) end
	local length = self:SetSequence( name )
	speed = tonumber( speed ) || 1
	local len = math.abs( length ) / math.abs( speed )
	cut = tonumber( cut ) || .2
	self:ResetSequenceInfo()
	self:SetCycle( 0 )
	self:SetPlaybackRate( speed )
	local t = CurTime() + len - cut
	self.bPlaySequenceAndWait = true
	local v, a = self.vPlaySequenceAndWait || self:GetPos(), self.aPlaySequenceAndWait || self:GetAngles()
	while CurTime() <= t do
		local b, vec, ang = self:GetSequenceMovement( name, 0, self:GetCycle() )
		if b then
			vec:Rotate( a )
			local nv = v + vec
			local na = a + ang
			if pos then
				self.loco:SetVelocity( Vector( 0, 0, 0 ) )
				self.loco:SetGravity( 0 )
				self:SetPos( nv )
			else self:A_MaintainVelocity() end
			if ang then self:SetAngles( na ) end
			local p = self:GetPhysicsObject()
			if IsValid( p ) then p:SetPos( nv ) p:SetAngles( na ) end
		end
		pcall( function() run( self ) end )
		coroutine.yield()
	end
	local b, vec, ang = self:GetSequenceMovement( name, 0, 1 )
	if b then
		vec:Rotate( a )
		local nv = v + vec
		local na = a + ang
		if pos then
			self.loco:SetVelocity( Vector( 0, 0, 0 ) )
			self.loco:SetGravity( 0 )
			self:SetPos( nv )
		else self:A_MaintainVelocity() end
		if ang then self:SetAngles( na ) end
		local p = self:GetPhysicsObject()
		if IsValid( p ) then p:SetPos( nv ) p:SetAngles( na ) end
	end
	pcall( function() runend( self ) end )
	self.vPlaySequenceAndWait = nil
	self.aPlaySequenceAndWait = nil
	self.bPlaySequenceAndWait = nil
end
