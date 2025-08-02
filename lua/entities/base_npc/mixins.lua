/*////////////////////////////////////////////////////////

All The Things Here are Extremely Sitational. This File should Not be Considered a Part of The Base.
It is Made so That We Dont have to Update Everything Here for Each NPC Individually.

////////////////////////////////////////////////////////*/

/*Short Term Suppression - Quickly Becomes Strong But Wears Off, with Not That High of a Limit.
This is Why NPCs Move Back and Forth when They have Lots of Cover.*/
ENT.flSuppressedShort = 0
/*Long Term Suppression - Slowly Becomes Strong and Slowly Wears Off.
Caused by The Battle Itself, Slowly Coming into Play.*/
ENT.flSuppressedLong = 0

function ENT:MI_CalcCombatState()
	local flSuppressedLongMax, flSuppressedShortMax = self:Health() * 12, self:Health() * 60
	local s = clamp( self.flSuppressedShort + self:GetExposedWeight() * FrameTime(), 0, flSuppressedShortMax )
	self.flSuppressedShort = s
	if self.flSuppressedShort == s then self.flSuppressedShort = lmax( 0, self.flSuppressedShort - FrameTime() * self:Health() * 6 ) end
	local s = clamp( self.flSuppressedLong + self:GetExposedWeight() * FrameTime(), 0, flSuppressedLongMax )
	self.flSuppressedLong = s
	if self.flSuppressedLong == s then self.flSuppressedLong = lmax( 0, self.flSuppressedLong - FrameTime() * self:Health() ) end
	if self.flSuppressedShort < self.flSuppressedLong then
		self.flCombatState = clamp( math.Remap( self.flSuppressedShort, 0, self:Health() * 6, 1, -1 ), -1, 1 )
	else
		self.flCombatState = clamp( math.Remap( self.flSuppressedLong, 0, self:Health() * 12, 1, -1 ), -1, 1 )
	end
end

function ENT:MI_CalcPeek( t )
	self.flPeek = CurTime() + math.rand( t.flDelayMin || 0,
	                                     t.flDelayMax || 0 )
	local ne, nep, ned = nil, nil, math.huge
	local flMove = t.flMove || self:GetMoveForDistance( self.Enemy:GetPos():Distance( self:GetPos() ) )
	local tPoints = NPC.Tactics.CalcPoints( self )
	local vMyHeight = Vector( 0, 0, self.GAME_HullZ || ( self.GetHull && select( 2, self:GetHull() ).z ) || self.GAME_OBBMaxs.z || self:OBBMaxs().z )
	local vMyHeightDuck = Vector( 0, 0, self.GAME_HullDuckZ || ( self.GetHullDuck && select( 2, self:GetHullDuck() ).z ) || vHeight.z )
	for _, vec in ipairs( FindSpots( self:GetPos(), flMove, flMove, flMove, true ) ) do
		local vecNull = vec + Vector( 0, 0, 10 )
		local v = vec + vMyHeightDuck
		if !Trace( {
			start = vecNull,
			endpos = v,
			filter = f,
			mask = MASK_SOLID
		} ).Hit then table.insert( tPoints, v ) end
		local v = vec + vMyHeight
		if !Trace( {
			start = vecNull,
			endpos = v,
			filter = f,
			mask = MASK_SOLID
		} ).Hit then table.insert( tPoints, v ) end
	end
	local function Handle( enemy )
		local d = self:GetPos():DistToSqr( enemy:GetPos() )
		if d >= ned then return end
		local vPos = enemy:GetCenter()
		local f = table.add( self:AllRelatedEntities(), enemy:AllRelatedEntities() )
		local tAttack = {}
		for _, v in ipairs( tPoints ) do
			if !Trace( {
				start = v,
				endpos = vPos,
				filter = f,
				mask = MASK_SHOT_HULL
			} ).Hit then
				table.insert( tAttack, v )
			end
		end
		if table.IsEmpty( tAttack ) then return end
		ne, nep, ned = enemy, table.Random( tAttack ), d
	end
	Handle( self.Enemy )
	for _, enemy in ipairs( self.tEnemies ) do Handle( enemy ) end
	if IsValid( ne ) then self:CHAT "Firing at an exposed target!" return { ne, nil, nep, true } end
	local enemy = self.Enemy
	local t, f = self:FindSuppress( enemy )
	if t && f then
		self:CHAT "Suppressive fire!"
		return { enemy, t + Vector( 0, 0, ( abs( enemy:OBBMins().z ) + abs( enemy:OBBMaxs().z ) ) * .5 ), f }
	end
end

function ENT:MI_FindCombatMove( t )
	local enemy = self.Enemy
	//Set `bCvrOldCrouch` to `false`, NEVER `nil`, as `nil` is Treated as `true`!
	local v, c = self.vCover, self.bCvrCrouch || false
	if !v then return end
	local w = self.flCombatState
	local b = true
	if w > 0 then
		self:FindCoverAdvance { flAdvance = w * ( t.flDistance || 400 ) }
		if self.vCover != v then
			self.flPeek = 0
			self:CHAT "Advancing!"
			self:EmitSound( t.sMoveForward )
			self.bCvrMove = true
			return true
		end
	else
		self:FindCoverRetreat { flRetreat = w * ( t.flDistance || 400 ) }
		if self.vCover != v then
			self.flPeek = 0
			self:CHAT "Retreating!"
			self:EmitSound( t.sMoveBackward )
			self.bCvrMove = true
			return true
		end
	end
end
