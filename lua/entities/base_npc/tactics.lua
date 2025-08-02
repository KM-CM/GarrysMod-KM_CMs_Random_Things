NPC.Tactics = {}

/*How Quick Do We want to Advance? Multiplier of Cover to Cover Range.
0 Means Standing in Place. Negative Values Mean Retreating.*/
ENT.flCombatState = 1

ENT.flHandGesDelay = 0
ENT.flPeek = 0
ENT.flHide = 0
ENT.bPeeking = nil

function ENT:IsShootable( vec )
	if Trace( {
		start = self:GetShootPos(),
		endpos = vec,
		filter = function( ent ) local d = self:Disposition( ent ) return d == D_NU end,
		mask = MASK_SHOT_HULL
	} ).Hit then return end
	return true
end

ENT.GAME_flSuppressionWeight = 0

function ENT:GetExposedWeight() return self.GAME_flSuppressionWeight end

function ENT:CanExpose()
	if self:GetExposedWeight() > ( self:Health() * self.flExposedHideHealth ) || self.GAME_flSuppressionWeight > ( self:Health() * self.flSuppressionHideHealth ) then return false end
	return true
end

function ENT:IsScared()
	if !self.bCanFear || self.GAME_God then return end
	if (
		self:Health() < ( self:GetMaxHealth() * self.flHealthPercentScared ) ||
		CurTime() < self.flHide ||
		self.bScaredOfFire && self:IsOnFire()
	) then return true end
	return false
end

function ENT:ShouldRunAway( ent )
	if !IsValid( ent ) && IsValid( self.Enemy )  then ent = self.Enemy end
	if isentity( ent ) && !IsValid( ent ) then return false end
	if !self:Visible( ent ) then return false end
	local vec = isvector( ent ) && ent || ent:GetCenter()
	return pcall_ret( function()
		if IsValid( ent ) && self.bScaredOfVehicles && ent.InVehicle && ent:InVehicle() && !self:InVehicle() then return true end
		return vec:DistToSqr( self:GetPos() ) < sqr( self.flRunAwayDist )
	end ) == true
end

ENT.Allies = Void
ENT.flNextFindAllies = 0
ENT.flAllyWeight = 0
//ENT.bAllyVisNight = false //Do All My Allies have Night Vision?
function ENT:UpdateAllies( bForce )
	if bForce || CurTime() > self.flNextFindAllies then
		self.bAllyVisNight = self.VisNight
		local l, w, dsqr = {}, self:Health(), sqr( self.flAllySearchDist )
		for _, ent in pairs( ents.GetAll() ) do
			if ent != self && ent:GetPos():DistToSqr( self:GetPos() ) < dsqr && self:Disposition( ent ) == D_LI then
				table.insert( l, ent )
				w = w + ent:Health()
				if self.bAllyVisNight && !ent.VisNight then self.bAllyVisNight = nil end
			end
		end
		self.Allies = l
		self.flAllyWeight = w
		self.flNextFindAllies = CurTime() + math.rand( .8, 1.4 )
	end
end
function ENT:HaveAllies() return self.Allies || {} end

function ENT:FindChaseWay( ent )
	if !IsValid( ent ) && IsValid( self.Enemy ) then ent = self.Enemy end
	if !IsValid( ent ) then return end
	return ent:GetPos()
end

//ENT.RunAwayLeft=no
function ENT:FindRunWay(tar)
	if isentity(tar)&&IsValid(tar) then tar=tar:GetCenter() end
	if type(tar)!='Vector'&&IsValid(self:GetEnemy()) then tar=self:GetEnemy():GetPos() end
	if !tar then return void end
	if rand(100)==1 then self.RunAwayLeft=BoolRand() end
	local d=(self:GetCenter()-tar):Angle()
	local m=math.clamp((tar:DistToSqr(self:GetCenter())/self.flRunAwayDist^2)*50,30,50)
	d.y=self.RunAwayLeft&&d.y-m||d.y+m d=d:Forward()
	return Trace({
		start=self:GetCenter(),
		endpos=self:GetCenter()+d*math.max(tar:Distance(self:GetPos())*0.66,rand(500,750)),
		mask=MASK_SOLID,
		filter=self:AllRelatedEntities(),
	}).HitPos
end

function ENT:GetSuppressionDistance( d ) return math.Clamp( math.Remap( d, 1000, 4000, 250, 750 ), 250, 750 ) end
function ENT:GetMoveForDistance( d ) return math.Clamp( math.Remap( d, 1000, 4000, 250, 750 ), 250, 750 ) end

function ENT:IsInCombatZone( vec, flMove, enemy, tEnemies )
	if !IsValid( enemy ) then enemy = self.Enemy end
	if !IsValid( enemy ) then return end
	if !tEnemies then tEnemies = self.tEnemies end
	if !vec then vec = self:GetCenter() end
	local tEnemiesAreas = {}
	//Screw Up of The Year Lmao
	//local bEnemiesAreas = !table.IsEmpty( tEnemiesAreas )
	local ed = self:GetEngagementAreaDistance( self:GetPos():Distance( enemy:GetCenter() ) )
	for _, enemy in pairs( self.tEnemies ) do
		for _, area in ipairs( navmesh.Find( enemy:GetCenter(), ed, ed, ed ) ) do
			table.insert( tEnemiesAreas, area )
		end
	end
	local bEnemiesAreas = !table.IsEmpty( tEnemiesAreas )
	local area = navmesh.GetNearestNavArea( vec )
	if !area then return end
	local flMove = tonumber( flMove ) || self:GetMoveForDistance( self:GetPos():Distance( enemy:GetPos() ) )
	for _, area in ipairs( navmesh.Find( area:GetCenter(), flMove, flMove, flMove, true ) ) do
		if !b then break end
		for _, new in ipairs( tEnemiesAreas ) do if area:IsPotentiallyVisible( new ) then return true end end
	end
end

function ENT:FindSuppress( enemy, tEnemies, flDist, flMove, vPos )
	if istable( enemy ) then
		tEnemies = enemy.tEnemies
		flDist = enemy.flDist
		flDistSearch = enemy.flDistSearch
		vPos = enemy.vPos
		enemy = enemy.enemy
	end
	if !IsValid( enemy ) then enemy = self.Enemy end
	if !IsValid( enemy ) then return end
	if !IsValid( tEnemies ) then tEnemies = self.tEnemies end
	local d = enemy:GetPos():Distance( self:GetPos() )
	flDist = tonumber( flDist ) || self:GetSuppressionDistance( d )
	//flMove = tonumber( flMove ) || self:GetMoveForDistance( d )
	if !isvector( vPos ) then vPos = self:GetPos() end
	/*
	local vStand
	if self.vHullMaxs.z != self.vHullDuckMaxs.z then vStand = self:GetPos() + Vector( 0, 0, self.vHullMaxs.z ) end
	*/
	local f = table.add( self:AllRelatedEntities(), enemy:AllRelatedEntities() )
	local vTarget = enemy:GetCenter()
	local tPoints = NPC.Tactics.CalcPoints( self, vPos )
	//local tPoints = {}
	local vMyHeight = Vector( 0, 0, self.GAME_HullZ || ( self.GetHull && select( 2, self:GetHull() ).z ) || self.GAME_OBBMaxs.z || self:OBBMaxs().z )
	local vMyHeightDuck = Vector( 0, 0, self.GAME_HullDuckZ || ( self.GetHullDuck && select( 2, self:GetHullDuck() ).z ) || vHeight.z )
	/*
	local flMoveSqr = sqr( flMove )
	for _, area in ipairs( navmesh.Find( self:GetPos(), flMove, flMove, flMove ) ) do
		for _, vec in ipairs( table.add( area:GetHidingSpots(), area:GetExposedSpots() ) ) do
			if vec:DistToSqr( self:GetPos() ) > flMoveSqr then continue end
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
	end
	*/
	local nstd, nsfd, nst, nsf = sqr( flDist ), math.huge
	for _, vec in ipairs( tPoints ) do
		local df = vec:DistToSqr( self:GetPos() )
		if df >= nsfd then continue end
		local tr = Trace {
			start = vec,
			endpos = vTarget,
			filter = f,
			mask = MASK_SHOT_HULL
		}
		if IsValid( tr.Entity ) && self:Disposition( tr.Entity ) == D_LI then continue end
		local v = tr.HitPos
		local dt = v:DistToSqr( vTarget )
		if dt >= nstd then continue end
		nst, nsf, nstd, nsfd = v, vec, dt, df
	end
	return nst, nsf
end

//function ENT:FindSuppress( enemy, tEnemies, flDist, flMove, flDistSearch )
//	if istable( enemy ) then
//		tEnemies = enemy.tEnemies
//		flDist = enemy.flDist
//		flDistSearch = enemy.flDistSearch
//		enemy = enemy.enemy
//	end
//	if !IsValid( enemy ) then enemy = self.Enemy end
//	if !IsValid( enemy ) then return end
//	if !IsValid( tEnemies ) then tEnemies = self.tEnemies end
//	local d = enemy:GetPos():Distance( self:GetPos() )
//	flDist = tonumber( flDist ) || self:GetSuppressionDistance( d )
//	flMove = tonumber( flMove ) || self:GetMoveForDistance( d )
//	/*
//	local vStand
//	if self.vHullMaxs.z != self.vHullDuckMaxs.z then vStand = self:GetPos() + Vector( 0, 0, self.vHullMaxs.z ) end
//	*/
//	local ns, nsp, nsd = nil, nil, sqr( flDist )
//	local f = table.add( self:AllRelatedEntities(), enemy:AllRelatedEntities() )
//	local vPos = enemy:GetPos()
//	local vHeight = Vector( 0, 0, enemy.GAME_HullZ || ( enemy.GetHull && select( 2, enemy:GetHull() ).z ) || enemy.GAME_OBBMaxs.z || enemy:OBBMaxs().z )
//	local vHeightDuck = Vector( 0, 0, enemy.GAME_HullDuckZ || ( enemy.GetHullDuck && select( 2, enemy:GetHullDuck() ).z ) || vHeight.z )
//	local b = vHeight.z != vHeightDuck.z
//	local tPoints = {}
//	local vMyHeight = Vector( 0, 0, self.GAME_HullZ || ( self.GetHull && select( 2, self:GetHull() ).z ) || self.GAME_OBBMaxs.z || self:OBBMaxs().z )
//	local vMyHeightDuck = Vector( 0, 0, self.GAME_HullDuckZ || ( self.GetHullDuck && select( 2, self:GetHullDuck() ).z ) || vHeight.z )
//	local flMoveSqr = sqr( flMove )
//	for _, vec in ipairs( FindSpots( self:GetPos(), flMove, flMove, flMove, true ) ) do
//		if vec:DistToSqr( self:GetPos() ) > flMoveSqr then continue end
//		local vecNull = vec + Vector( 0, 0, 10 )
//		local v = vec + vMyHeightDuck
//		if !Trace( {
//			start = vecNull,
//			endpos = v,
//			filter = f,
//			mask = MASK_SOLID
//		} ).Hit then table.insert( tPoints, v ) end
//		local v = vec + vMyHeight
//		if !Trace( {
//			start = vecNull,
//			endpos = v,
//			filter = f,
//			mask = MASK_SOLID
//		} ).Hit then table.insert( tPoints, v ) end
//	end
//	local function HandleSpot( vec )
//		local d = vec:DistToSqr( vPos )
//		if d >= nsd then return end
//		local vecHeight = vec + vHeight
//		local vecHeightDuck
//		if b then vecHeightDuck = vec + vHeightDuck end
//		local vecHeightNull = vec + Vector( 0, 0, 10 )
//		local t = {}
//		/*Points Already Include This
//		if vStand then
//			if vecHeight && !Trace( {
//				start = vStand,
//				endpos = vecHeight,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { vStand, vecHeight } ) end
//			if vecHeightDuck && !Trace( {
//				start = vStand,
//				endpos = vecHeightDuck,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { vStand, vecHeightDuck } ) end
//			if vecNull && !Trace( {
//				start = vStand,
//				endpos = vecHeightNull,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { vStand, vecHeightNull } ) end
//		end
//		*/
//		for _, v in ipairs( tPoints ) do
//			if vecHeight && !Trace( {
//				start = v,
//				endpos = vecHeight,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { v, vecHeight } ) end
//			if vecHeightDuck && !Trace( {
//				start = v,
//				endpos = vecHeightDuck,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { v, vecHeightDuck } ) end
//			if vecNull && !Trace( {
//				start = v,
//				endpos = vecHeightNull,
//				filter = f,
//				mask = MASK_SHOT_HULL
//			} ).Hit then table.insert( t, { v, vecHeightNull } ) end
//		end
//		if !table.IsEmpty( t ) then
//			local v = table.Random( t )
//			if !v then return end
//			nsp, ns = unpack( v )
//			nsd = d
//		end
//	end
//	for _, vec in ipairs( FindSpots( vPos, flDist, flDist, flDist, true ) ) do HandleSpot( vec ) end
//	return ns, nsp
//end

function ENT:GetEngagementAreaDistance( d ) return clamp( math.Remap( d, 500, 3000, 500, 1000 ), 500, 1000 ) end

//We Need to Find Cover - NOW!
function ENT:FindCover( enemy, tEnemies, flSize, flSizeCrouch, vPos, flDistMin, bAllowUnderwater )
	if istable( enemy ) then
		tEnemies = enemy.tEnemies
		flSize = enemy.flSize
		flSizeCrouch = enemy.flSizeCrouch
		flDistMin = enemy.flDistMin
		bAllowUnderwater = enemy.bAllowUnderwater
		enemy = enemy.enemy
	end
	if !istable( tEnemies ) then tEnemies = self.tEnemies end
	if !isentity( enemy ) then enemy = self.Enemy end
	if !IsValid( enemy ) then return end
	flSize = tonumber( flSize ) || self.vHullMaxs.z
	flSizeCrouch = tonumber( flSizeCrouch ) || self.vHullDuckMaxs.z
	local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
	local area = navmesh.GetNearestNavArea( self:GetPos() )
	if !area then return end
	local tQueue, tVisited = { { area, 0 } }, {}
	local flDistSqrMin = sqr( flDistMin || self.flRunAwayDist )
	local ncd, nc = math.huge
	while !table.IsEmpty( tQueue ) do
		table.SortByMember( tQueue, 2, true )
		local area, dist = unpack( table.remove( tQueue, 1 ) )
		tVisited[ area:GetID() ] = true
		for _, new in ipairs( area:GetAdjacentAreas() ) do
			if tVisited[ new:GetID() ] then continue end
			tVisited[ new:GetID() ] = true
			table.insert( tQueue, { new, new:GetCenter():DistToSqr( self:GetPos() ) } )
		end
		for _, vec in ipairs( table.add( area:GetHidingSpots(), area:GetExposedSpots() ) ) do
			local d = vec:DistToSqr( self:GetPos() )
			if d >= ncd || Trace( {
				start = vec + vCheckStart,
				endpos = vec + vCheck,
				mask = MASK_SOLID,
				filter = self:AllRelatedEntities()
			} ).Hit then continue end
			local b
			for _, ent in ipairs( self:HaveAllies() ) do
				if !ent.__ACTOR__ then continue end
				if !IsValid( ent ) || ent == self then continue end
				if CurTime() < ent.flNextFindCover &&
				   isvector( ent.vCover ) &&
				   ent.vCover:DistToSqr( vec ) < self.flFindVecDistFromAllies then b = true end
			end
			if b then continue end
			local r = self:AllRelatedEntities()
			for _, ent in pairs( tEnemies ) do
				if HasMeleeAttack( ent ) && vec:DistToSqr( ent:GetPos() ) <= flDistSqrMin then b = true break end
				if !HasRangeAttack( ent ) then continue end
				local f = table.add( r, ent:AllRelatedEntities() )
				for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = v,
						endpos = vec + Vector( 0, 0, flSizeCrouch ),
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = true break end
				end
			end
			if b then continue end
			cr = Trace( {
				start = vec + vCheckStart,
				endpos = vec + vCheckStand,
				mask = MASK_SOLID,
				filter = self:AllRelatedEntities()
			} ).Hit
			if !cr then
				for _, ent in pairs( tEnemies ) do
					if !HasRangeAttack( ent ) then continue end
					local f = table.add( r, ent:AllRelatedEntities() )
					for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
						if !Trace( {
							start = v,
							endpos = vec + Vector( 0, 0, flSize ),
							filter = function( ent ) return self:Disposition( ent ) != D_LI end,
							mask = MASK_SHOT_HULL
						} ).Hit then cr = true break end
					end
				end
			end
			nc, ncd = vec, d
		end
		if nc then self.vCover = nc self.bCvrCrouch = cr return nc, cr end
	end
end

function ENT:FindCoverRetreat( enemy, tEnemies, flSize, flSizeCrouch, flDistMin, flRetreat, bAllowUnderwater )
	if istable( enemy ) then
		tEnemies = enemy.tEnemies
		flSize = enemy.flSize
		flSizeCrouch = enemy.flSizeCrouch
		flDistMin = enemy.flDistMin
		flRetreat = enemy.flRetreat
		bAllowUnderwater = enemy.bAllowUnderwater
		enemy = enemy.enemy
	end
	if !istable( tEnemies ) then tEnemies = self.tEnemies end
	if !isentity( enemy ) then enemy = self.Enemy end
	if !IsValid( enemy ) then return end
	flSize = tonumber( flSize ) || self.vHullMaxs.z
	flSizeCrouch = tonumber( flSizeCrouch ) || self.vHullDuckMaxs.z
	local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
	local area = navmesh.GetNearestNavArea( self:GetPos() )
	if !area then return end
	local tQueue, tVisited = { { area, 0 } }, {}
	local flDistSqrMin = sqr( flDistMin || self.flRunAwayDist )
	local dd, ncf, nc = self:GetPos():Distance( enemy:GetPos() ) + flRetreat, math.huge
	while !table.IsEmpty( tQueue ) do
		table.SortByMember( tQueue, 2, true )
		local area, dist = unpack( table.remove( tQueue, 1 ) )
		tVisited[ area:GetID() ] = true
		for _, new in ipairs( area:GetAdjacentAreas() ) do
			if tVisited[ new:GetID() ] then continue end
			tVisited[ new:GetID() ] = true
			table.insert( tQueue, { new, dist + new:GetCenter():DistToSqr( area:GetCenter() ) } )
		end
		for _, vec in ipairs( table.add( area:GetHidingSpots(), area:GetExposedSpots() ) ) do
			local f = abs( vec:Distance( enemy:GetPos() ) - dd )
			if f >= ncf then continue end
			local b
			for _, ent in ipairs( self:HaveAllies() ) do
				if !ent.__ACTOR__ then continue end
				if !IsValid( ent ) || ent == self then continue end
				if CurTime() < ent.flNextFindCover &&
				   isvector( ent.vCover ) &&
				   ent.vCover:DistToSqr( vec ) < self.flFindVecDistFromAllies then b = true end
			end
			if b then continue end
			local r = self:AllRelatedEntities()
			for _, ent in pairs( tEnemies ) do
				if HasMeleeAttack( ent ) && vec:DistToSqr( ent:GetPos() ) <= flDistSqrMin then b = true break end
				if !HasRangeAttack( ent ) then continue end
				local f = table.add( r, ent:AllRelatedEntities() )
				for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = v,
						endpos = vec + Vector( 0, 0, flSizeCrouch ),
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = true break end
				end
			end
			if b then continue end
			cr = Trace( {
				start = vec + vCheckStart,
				endpos = vec + vCheckStand,
				mask = MASK_SOLID,
				filter = self:AllRelatedEntities()
			} ).Hit
			if !cr then
				for _, ent in pairs( tEnemies ) do
					if !HasRangeAttack( ent ) then continue end
					local f = table.add( r, ent:AllRelatedEntities() )
					for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
						if !Trace( {
							start = v,
							endpos = vec + Vector( 0, 0, flSize ),
							filter = function( ent ) return self:Disposition( ent ) != D_LI end,
							mask = MASK_SHOT_HULL
						} ).Hit then cr = true break end
					end
				end
			end
			nc, ncf = vec, f
		end
		if nc then self.vCover = nc self.bCvrCrouch = cr return nc, cr end
	end
end

/*I am Advancing, Where Do I Go?

I Know This isnt The Best Solution, I Dont Know a Better Way to Implement This!
I could Use a Custom Area Pathing, But That would be Expensive, Plus, Usually,
when a Direct Path has No Cover, No Path has Cover, so That Expensiveness would be UseLess.*/
function ENT:FindCoverAdvance( enemy, tEnemies, MovePath, MoveTarget, flAdvance, flTolerance, flSize, flSizeCrouch, flDistSearch, flDistMin, flDistDown, flDistUp, bAllowUnderwater )
	if istable( enemy ) then
		tEnemies = enemy.tEnemies
		flAdvance = enemy.flAdvance
		MovePath = enemy.MovePath
		MoveTarget = enemy.MoveTarget
		flSize = enemy.flSize
		flSizeCrouch = enemy.flSizeCrouch
		flTolerance = enemy.flTolerance
		flDistMin = enemy.flDistMin
		bAllowUnderwater = enemy.bAllowUnderwater
		enemy = enemy.enemy
	end
	if !istable( tEnemies ) then tEnemies = self.tEnemies end
	if !isentity( enemy ) then enemy = self.Enemy end
	if !IsValid( enemy ) then return end
	flSize = tonumber( flSize ) || self.vHullMaxs.z
	flSizeCrouch = tonumber( flSizeCrouch ) || self.vHullDuckMaxs.z
	local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
	if !MoveTarget then MoveTarget = enemy:GetPos() end
	if !MovePath then MovePath = Path 'Follow' MovePath:Compute( self, MoveTarget ) end
	flAdvance = tonumber( flAdvance ) || 400
	flTolerance = tonumber( flTolerance ) || flAdvance
	local tVisited, tEnemiesAreas = {}, {}
	//Screw Up of The Year Lmao
	//local bEnemiesAreas = !table.IsEmpty( tEnemiesAreas )
	local ed = self:GetEngagementAreaDistance( self:GetPos():Distance( enemy:GetCenter() ) )
	for _, enemy in pairs( self.tEnemies ) do
		for _, area in ipairs( navmesh.Find( enemy:GetCenter(), ed, ed, ed ) ) do
			table.insert( tEnemiesAreas, area )
		end
	end
	local bEnemiesAreas = !table.IsEmpty( tEnemiesAreas )
	local ncf, dir, nc = math.huge, ( enemy:GetPos() - self:GetPos() ):GetNormalized()
	local flDistSqrMin = sqr( flDistMin || self.flRunAwayDist )
	local flMove = self:GetMoveForDistance( self:GetPos():Distance( enemy:GetPos() ) )
	for I = 0, MovePath:GetLength(), flTolerance do
		MovePath:MoveCursorTo( I )
		local area = navmesh.GetNearestNavArea( MovePath:GetPositionOnPath( I ) )
		if !area || tVisited[ area:GetID() ] then continue end
		tVisited[ area:GetID() ] = true
		local b = bEnemiesAreas
		local t = {}
		for _, vec in ipairs( area:GetHidingSpots() ) do table.insert( t, vec ) end
		for _, vec in ipairs( area:GetExposedSpots() ) do table.insert( t, vec ) end
		for _, area in ipairs( navmesh.Find( area:GetCenter(), flMove, flMove, flMove, true ) ) do
			if tVisited[ area:GetID() ] then continue end
			tVisited[ area:GetID() ] = true
			for _, vec in ipairs( area:GetHidingSpots() ) do table.insert( t, vec ) end
			for _, vec in ipairs( area:GetExposedSpots() ) do table.insert( t, vec ) end
			if b then for _, new in ipairs( tEnemiesAreas ) do if area:IsPotentiallyVisible( new ) then b = nil break end end end
		end
		if b then continue end
		for _, vec in ipairs( t ) do
			local f = abs( vec:Distance( self:GetPos() ) - flAdvance )
			if f >= ncf ||
			Trace( {
				start = vec + vCheckStart,
				endpos = vec + vCheck,
				mask = MASK_SOLID,
				filter = self:AllRelatedEntities()
			} ).Hit ||
			//Make Sure It Doesnt Take Us Past The Enemy
			( vec - self:GetPos() ):GetNormalized():Dot( dir ) < 0 then continue end
			local b
			for _, ent in ipairs( self:HaveAllies() ) do
				if !ent.__ACTOR__ then continue end
				if !IsValid( ent ) || ent == self then continue end
				if CurTime() < ent.flNextFindCover &&
				   isvector( ent.vCover ) &&
				   ent.vCover:DistToSqr( vec ) < self.flFindVecDistFromAllies then b = true end
			end
			if b then continue end
			local r = self:AllRelatedEntities()
			for _, ent in pairs( tEnemies ) do
				if HasMeleeAttack( ent ) && vec:DistToSqr( ent:GetPos() ) <= flDistSqrMin then b = true break end
				if !HasRangeAttack( ent ) then continue end
				local f = table.add( r, ent:AllRelatedEntities() )
				for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = v,
						endpos = vec + Vector( 0, 0, flSizeCrouch ),
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = true break end
				end
			end
			if b then continue end
			cr = Trace( {
				start = vec + vCheckStart,
				endpos = vec + vCheckStand,
				mask = MASK_SOLID,
				filter = self:AllRelatedEntities()
			} ).Hit
			if !cr then
				for _, ent in pairs( tEnemies ) do
					if !HasRangeAttack( ent ) then continue end
					local f = table.add( r, ent:AllRelatedEntities() )
					for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
						if !Trace( {
							start = v,
							endpos = vec + Vector( 0, 0, flSize ),
							filter = function( ent ) return self:Disposition( ent ) != D_LI end,
							mask = MASK_SHOT_HULL
						} ).Hit then cr = true break end
					end
				end
			end
			nc, ncf = vec, f
		end
		if nc && I >= flAdvance then
			self.vCover = nc
			self.bCvrCrouch = cr
			return nc, cr
		end
	end
end

////We Need to Get to Cover - NOW!
//function ENT:FindCover( enemy, tEnemies, flSize, flSizeCrouch, vPos, flDistSearch, flDistMin, flDistMax, flDistDown, flDistUp, bAllowUnderwater )
//	if istable( enemy ) then
//		tEnemies = enemy.tEnemies
//		flSize = enemy.flSize
//		flSizeCrouch = enemy.flSizeCrouch
//		vPos = enemy.vPos
//		flDistSearch = enemy.flDistSearch
//		flDistMin = enemy.flDistMin
//		flDistMax = enemy.flDistMax
//		flDistDown = enemy.flDistDown
//		flDistUp = enemy.flDistUp
//		bAllowUnderwater = enemy.bAllowUnderwater
//		enemy = enemy.enemy
//	end
//	if !istable( tEnemies ) then tEnemies = self.tEnemies end
//	if !isentity( enemy ) then enemy = self.Enemy end
//	if !IsValid( enemy ) then return end
//	flSize = tonumber( flSize ) || self.vHullMaxs.z
//	flSizeCrouch = tonumber( flSizeCrouch ) || self.vHullDuckMaxs.z
//	local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
//	vPos = isvector( vPos ) && vPos || enemy:GetPos()
//	flDistMin = tonumber( flDistMin )
//	if !flDistMax && flDistMin || flDistMin && flDistMax && flDistMin > flDistMax then
//		flDistMax = flDistMin + 2000
//	else
//		flDistMin = 0
//		//flDistMin = math.max( 0, tonumber( flDistMin ) || self.flRunAwayDist )
//		flDistMax = tonumber( flDistMax )
//	end
//	if flDistMax then
//		flDistSearch = tonumber( flDistSearch ) || ( flDistMax + 2000 )
//	else
//		flDistMax = math.huge
//		flDistSearch = 4000
//	end
//	flDistDown = tonumber( flDistDown ) || 250
//	flDistUp = tonumber( flDistUp ) || 250
//	local flDistSqrMin = sqr( flDistMin )
//	local flDistSqrMax = sqr( flDistMax )
//	local nc, ncd, cr = nil, sqr( flDistSearch )
//	local function HandleSpot( vec )
//		local d = vec:DistToSqr( self:GetPos() )
//		if d >= ncd || Trace( {
//			start = vec + vCheckStart,
//			endpos = vec + vCheck,
//			mask = MASK_SOLID,
//			filter = self:AllRelatedEntities()
//		} ).Hit then return end
//		for _, ent in ipairs( self:HaveAllies() ) do
//			if !ent.__ACTOR__ then continue end
//			if !IsValid( ent ) || ent == self then continue end
//			if CurTime() < ent.flNextFindCover &&
//			   isvector( ent.vCover ) &&
//			   ent.vCover:DistToSqr( vec ) < self.flFindVecDistFromAllies then return end
//		end
//		local ne = math.huge
//		for _, ent in pairs( tEnemies ) do
//			if /*!IsValid( ent ) || */!HasRangeAttack( ent ) then continue end
//			local dt = vec:DistToSqr( ent:GetPos() )
//			if dt <= flDistSqrMin then return end
//			if dt < ne then ne = dt end
//			local f = table.add( self:AllRelatedEntities(), ent:AllRelatedEntities() )
//			for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
//				if !Trace( {
//					start = v,
//					endpos = vec + Vector( 0, 0, flSizeCrouch ),
//					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
//					mask = MASK_SHOT_HULL
//				} ).Hit then return end
//			end
//		end
//		if ne > flDistSqrMax then return end
//		cr = Trace( {
//			start = vec + vCheckStart,
//			endpos = vec + vCheckStand,
//			mask = MASK_SOLID,
//			filter = self:AllRelatedEntities()
//		} ).Hit
//		if !cr then
//			for _, ent in pairs( tEnemies ) do
//				if /*!IsValid( ent ) || */!HasRangeAttack( ent ) then continue end
//				local f = table.add( self:AllRelatedEntities(), ent:AllRelatedEntities() )
//				for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
//					if !Trace( {
//						start = v,
//						endpos = vec + Vector( 0, 0, flSize ),
//						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
//						mask = MASK_SHOT_HULL
//					} ).Hit then cr = true break end
//				end
//			end
//		end
//		nc, ncd = vec, d
//	end
//	for _, vec in ipairs( FindSpots( self:GetPos(), flDistSearch, flDistDown, flDistUp, bAllowUnderwater ) ) do HandleSpot( vec ) end
//	for _, vec in ipairs( FindSpots( vPos, flDistSearch, flDistDown, flDistUp, bAllowUnderwater ) ) do HandleSpot( vec ) end
//	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
//	self.vCover = nc
//	self.bCvrCrouch = cr
//	return nc, cr
//end
//
//function ENT:FindCoverRetreat( enemy, tEnemies, flSize, flSizeCrouch, flDistMin, flRetreat, bAllowUnderwater )
//	if istable( enemy ) then
//		tEnemies = enemy.tEnemies
//		flSize = enemy.flSize
//		flSizeCrouch = enemy.flSizeCrouch
//		flDistMin = enemy.flDistMin
//		flRetreat = enemy.flRetreat
//		bAllowUnderwater = enemy.bAllowUnderwater
//		enemy = enemy.enemy
//	end
//	if !istable( tEnemies ) then tEnemies = self.tEnemies end
//	if !isentity( enemy ) then enemy = self.Enemy end
//	if !IsValid( enemy ) then return end
//	return self:FindCover { enemy = enemy, tEnemies = tEnemies, flSize = flSize, flSizeCrouch = flSizeCrouch, flDistMin = ( flDistMin || self.flRunAwayDist ) + self:GetPos():Distance( enemy:GetPos() ) * flRetreat, bAllowUnderwater = bAllowUnderwater }
//end
//
////I am Advancing, Where Do I Go?
//function ENT:FindCoverAdvance( enemy, tEnemies, MovePath, flAdvance, flSize, flSizeCrouch, vPos, flDistSearch, flDistMin, flDistDown, flDistUp, bAllowUnderwater )
//	if istable( enemy ) then
//		tEnemies = enemy.tEnemies
//		MovePath = enemy.MovePath
//		flAdvance = enemy.flAdvance
//		flSize = enemy.flSize
//		flSizeCrouch = enemy.flSizeCrouch
//		vPos = enemy.vPos
//		flDistSearch = enemy.flDistSearch
//		flDistMin = enemy.flDistMin
//		flDistDown = enemy.flDistDown
//		flDistUp = enemy.flDistUp
//		bAllowUnderwater = enemy.bAllowUnderwater
//		enemy = enemy.enemy
//	end
//	if !istable( tEnemies ) then tEnemies = self.tEnemies end
//	if !isentity( enemy ) then enemy = self.Enemy end
//	if !IsValid( enemy ) then return end
//	if !MovePath then
//		MovePath = Path( 'Follow' )
//		MovePath:Compute( self, enemy:GetPos() )
//	end
//	MovePath:MoveCursorToStart()
//	MovePath:MoveCursor( flAdvance )
//	flSize = tonumber( flSize ) || self.vHullMaxs.z
//	flSizeCrouch = tonumber( flSizeCrouch ) || self.vHullDuckMaxs.z
//	local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
//	vPos = isvector( vPos ) && vPos || enemy:GetPos()
//	flDistMin = tonumber( flDistMin || nil ) || self.flRunAwayDist
//	if !flDistSearch then flDistSearch = flAdvance * 4 end
//	flDistDown = tonumber( flDistDown ) || 250
//	flDistUp = tonumber( flDistUp ) || 250
//	local flDistSqrMin = sqr( flDistMin )
//	local ncd, ncf, nc, cr = 0, math.huge
//	local function HandleSpot( vec )
//		MovePath:MoveCursorToClosestPosition( vec )
//		local d = MovePath:GetCursorPosition()
//		/*
//		if d <= ncd then return end //Closer Than The Current... We're Advancing, Not Retreating!
//		*/
//		local f = abs( d - flAdvance )
//		if f > ncf then return end //Farther Than The Current... We Dont want to Advance Across The Whole Place!
//		for _, ent in ipairs( self:HaveAllies() ) do
//			if !ent.__ACTOR__ then continue end
//			if !IsValid( ent ) || ent == self then continue end
//			if CurTime() < ent.flNextFindCover &&
//			   isvector( ent.vCover ) &&
//			   ent.vCover:DistToSqr( vec ) < self.flFindVecDistFromAllies then return end
//		end
//		for _, ent in pairs( tEnemies ) do
//			if /*!IsValid( ent ) || */!HasRangeAttack( ent ) then continue end
//			local dt = vec:DistToSqr( ent:GetPos() )
//			if dt <= flDistSqrMin then return end
//			local f = table.add( self:AllRelatedEntities(), ent:AllRelatedEntities() )
//			for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
//				if !Trace( {
//					start = v,
//					endpos = vec + Vector( 0, 0, flSizeCrouch ),
//					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
//					mask = MASK_SHOT_HULL
//				} ).Hit then return end
//			end
//		end
//		cr = Trace( {
//			start = vec + vCheckStart,
//			endpos = vec + vCheckStand,
//			mask = MASK_SOLID,
//			filter = self:AllRelatedEntities()
//		} ).Hit
//		if !cr then
//			for _, ent in pairs( tEnemies ) do
//				if /*!IsValid( ent ) || */!HasRangeAttack( ent ) then continue end
//				local f = table.add( self:AllRelatedEntities(), ent:AllRelatedEntities() )
//				for _, v in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
//					if !Trace( {
//						start = v,
//						endpos = vec + Vector( 0, 0, flSize ),
//						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
//						mask = MASK_SHOT_HULL
//					} ).Hit then cr = true break end
//				end
//			end
//		end
//		nc, ncd, ncf = vec, d, f
//	end
//	for _, vec in ipairs( FindSpots( self:GetPos(), flDistSearch, flDistDown, flDistUp, bAllowUnderwater ) ) do HandleSpot( vec ) end
//	MovePath:MoveCursorToStart()
//	MovePath:MoveCursor( flDistSearch )
//	for _, vec in ipairs( FindSpots( MovePath:GetPositionOnPath( MovePath:GetCursorPosition() ), flDistSearch, flDistDown, flDistUp, bAllowUnderwater ) ) do HandleSpot( vec ) end
//	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
//	self.vCover = nc
//	self.bCvrCrouch = cr
//	return nc, cr
//end

//ENT.vCover = nil
//ENT.bCvrCrouch = false
ENT.flNextFindCover = 0
function ENT:Cache_FindCover( ... )
	if self.vCover && CurTime() <= self.flNextFindCover then return self.vCover, self.bCvrCrouch end
	self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
	local nc, cr = self:FindCover( ... )
	self.vCover = nc
	self.bCvrCrouch = cr
	return nc, cr
end

function ENT:UpdateFlankData() self.flHordeMovementAdd = math.rand( -1, 1 ) end

function NPC.Tactics.CalcPoints( VecOrEnt, vStart, vOrigin, vOrigin2, vOrigin3, flOff )
	if IsValid( VecOrEnt ) && isentity( VecOrEnt ) then
		flOff = ( #( VecOrEnt.GAME_OBBMins || VecOrEnt:OBBMins() ) + #( VecOrEnt.GAME_OBBMaxs || VecOrEnt:OBBMaxs() ) ) * ( tonumber( flOff ) || 1.5 )
		local Filter = VecOrEnt:AllRelatedEntities()
		if !vStart then vStart = VecOrEnt:GetPos() end
		if !vOrigin then vOrigin = vStart + Vector( 0, 0, VecOrEnt.GAME_OBBMaxs && VecOrEnt.GAME_OBBMaxs.z || VecOrEnt:OBBMaxs().z ) end
		if VecOrEnt.GAME_HullZ && VecOrEnt.GAME_HullDuckZ then
			if !vOrigin2 then vOrigin2 = vStart + Vector( 0, 0, VecOrEnt.GAME_HullZ ) end
			if !vOrigin3 then vOrigin3 = vStart + Vector( 0, 0, VecOrEnt.GAME_HullDuckZ ) end
		elseif VecOrEnt.GetHull && VecOrEnt.GetHullDuck then
			if !vOrigin2 then vOrigin2 = vStart + Vector( 0, 0, select( 2, VecOrEnt:GetHull() ).z ) end
			if !vOrigin3 then vOrigin3 = vStart + Vector( 0, 0, select( 2, VecOrEnt:GetHullDuck() ).z ) end
		else
			if !vOrigin2 then vOrigin2 = vStart + Vector( 0, 0, VecOrEnt.GAME_OBBMaxs && VecOrEnt.GAME_OBBMaxs.z || VecOrEnt:OBBMaxs().z ) end
		end
		if vOrigin && vOrigin2 && vOrigin3 then
			return {
				vOrigin, vOrigin2, vOrigin3,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin3, endpos = vOrigin3 + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin3, endpos = vOrigin3 + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin3, endpos = vOrigin3 + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin3, endpos = vOrigin3 + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos
			}
		elseif vOrigin && vOrigin2 then
			return {
				vOrigin, vOrigin2,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin2, endpos = vOrigin2 + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos
			}
		else
			return {
				vOrigin,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( -flOff, 0, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos,
				Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, -flOff, 0 ), filter = Filter, mask = MASK_SOLID } ).HitPos
			}
		end
	elseif isvector( VecOrEnt ) then
		if !vOrigin then vOrigin = VecOrEnt end
		flOff = tonumber( flOff ) || 250
		return {
			VecOrEnt,
			Trace( { start = vOrigin, endpos = vOrigin + Vector( flOff, 0, 0 ), mask = MASK_SOLID } ).HitPos,
			Trace( { start = vOrigin, endpos = vOrigin + Vector( -flOff, 0, 0 ), mask = MASK_SOLID } ).HitPos,
			Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, flOff, 0 ), mask = MASK_SOLID } ).HitPos,
			Trace( { start = vOrigin, endpos = vOrigin + Vector( 0, -flOff, 0 ), mask = MASK_SOLID } ).HitPos
		}
	end
	return {}
end

/*////////////////////////////////////////////////////////
Vector ENT:GetOptimalShootingPosition(
	[Vector/Entity] [EnemyCover/Enemy]=self:GetEnemy(),
	Vector ProjectileStartPosition=self:GetShootPos(),
	Number ProjectileSpeed=0,
	Number MaxOffset=200,
	Number StepMul=.25
)

1/[Vector/Entity] [EnemyCover/Enemy]: Either a Vector for enemy's cover position or the enemy entity. Giving a entity makes speed predictions to fire ahead.
2/Vector ProjectileStartPosition: If provided allows for more sophiscated fire ahead checks.
3/Number ProjectileSpeed: Projectile's speed. Use only if you provided an Entity as first arg. Close relationship with firing ahead.
4/Number MaxOffset: Projectile's explosion distance if its explosive/toxic/etc. Set to 0 if your projectiles are stuff like physical bullets and cant push outta cover.
5/Number StepMul: How Much Steps from 1 to MaxOffset? MULTIPLIER, NOT DIVIDER (.25 = 4)!

Fires ahead of the enemy if he's visible,
And fires nearby him if he's in cover,
If we cant reach him, returns nothing.

Use this even for hitscan attacks. Its good, trust me.
In this case it makes the cinematic (and cover pushing) "CONTINUE FIRE!!" effect.

RETURN: Vector OptimalFireAt :: The optimal shoot-at position. Or void.
////////////////////////////////////////////////////////*/
function ENT:GetOptimalShootingPosition(enemy,ppos,pspd,moff,stps)
	local p=void
	pcall(function()
		if type(enemy)=='vector' then p,enemy=self,void
		elseif !IsValid(enemy)&&IsValid(self.Enemy) then enemy,p=self.Enemy,self.Enemy:GetCenter() else p=enemy:GetCenter() end
	end)
	if !IsValid(enemy)||!p then return void end
	if enemy==self then enemy=void end
	if !ppos then ppos=self:GetShootPos() end
	if !pspd then pspd=0 end
	moff=tonumber(moff)||200
	if IsValid(enemy)&&!Trace({
		start=self:GetShootPos()+Vector(0,0,10),
		endpos=enemy:GetCenter(),
		mask=MASK_SOLID,
		filter=self:AllRelatedEntities(),
	}).Hit then return pspd==0&&enemy:GetCenter()||IsValid(enemy)&&(enemy:GetCenter()+GetVelocity(enemy)*(ppos:Distance(enemy:GetCenter())/pspd)) else
		local res={}
		local fltr=table.add(self:AllRelatedEntities(),IsValid(enemy)&&enemy:AllRelatedEntities()||{})
		for i = 1, moff, moff * tonumber( stps || .25 ) do
			table.insert(res,Trace({start=p,endpos=p+Vector(i,0,0),filter=fltr,mask=MASK_SOLID}).HitPos)
			table.insert(res,Trace({start=p,endpos=p+Vector(-i,0,0),filter=fltr,mask=MASK_SOLID}).HitPos)
			table.insert(res,Trace({start=p,endpos=p+Vector(0,i,0),filter=fltr,mask=MASK_SOLID}).HitPos)
			table.insert(res,Trace({start=p,endpos=p+Vector(0,-i,0),filter=fltr,mask=MASK_SOLID}).HitPos)
			table.insert(res,Trace({start=p,endpos=p+Vector(0,0,i),filter=fltr,mask=MASK_SOLID}).HitPos)
			table.insert(res,Trace({start=p,endpos=p+Vector(0,0,-i),filter=fltr,mask=MASK_SOLID}).HitPos)
		end
		local nt,ntd=void,math.huge
		for _,pos in ipairs(res) do if self:VisibleVec(pos)&&pos:DistToSqr(p)<ntd then nt,ntd=pos,pos:DistToSqr(p) end end
		if nt then return nt end
	end
	return void
end 