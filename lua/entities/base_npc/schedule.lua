/*
If You Know What You're Doing, Here's a Tip

function ENT:Behaviour() self:SCHEDULE() end
*/

local CActorSchedule = {}

//ENT.bSuppressing = false

COVERED_DONT_MOVE_CHANCE = 3 //Our Allies are Giving CoverFire. What are The Chances We will Do too, Instead of Moving?
COVERED_NOT_MOVE_CHANCE = 3 //Our Allies arent Giving CoverFire. What are The Chances We will Move?

//ENT.INTEL_AntlionJumpIntercept = false

ENT.SCHED_flAdvance = 800
ENT.SCHED_flRetreat = 800
//How Far to Advance to Allies at The BattleLine?
ENT.SCHED_flAdvanceMaxMultiplier = 2

local __SCHEDULE__ = {
	COMBAT_DOG = function( self, sched )
		local enemy, tEnemies = sched.Enemy || self.Enemy, sched.tEnemies || self.tEnemies
		if !IsValid( enemy ) then return {} end
		self:SetMoveTarget( enemy:GetPos() )
		self:ComputePath()
		if self.INTEL_AntlionJumpIntercept then
			local flMaxJumpLength = ( 2 * sv_gravity:GetFloat() * self.loco:GetJumpHeight() ) ^ .5
			local vel, dfor, dright, vec = GetVelocity( enemy )
			local vlen = #vel
			if vlen < 10 then
				vec = enemy:GetPos()
				dfor = math.Rand( -128, 128 )
				dright = math.Rand( -128, 128 )
			else
				vec = enemy:GetPos() + vel * ( enemy:GetPos():Distance( self:GetPos() ) / self.flTopSpeed )
				local d = lmin( vlen * 3, flMaxJumpLength )
				dfor = math.Rand( d * .5, d )
				dright = math.Rand( -d * .25, d * .25 ) //Half of d
			end
			local vForward = ( vec - self:GetPos() ):GetFlat():GetNormalized()
			local vRight = vForward:Angle():Right()
			local flDist = flMaxJumpLength * .4
			for _ = 1, 6 do
				local tar = vec + vForward * dfor + vRight * dright
				if rand( clamp( math.Remap( tar:Distance( enemy:GetPos() ), 0, flMaxJumpLength, 2000, 1000 ), 1000, 2000 ) * FrameTime() ) != 1 then break end
				local area = navmesh.GetNearestNavArea( tar )
				if area then
					local vec = area:GetClosestPointOnArea( tar )
					local flDist = vec:Distance( self:GetPos() )
					if vec:Distance2D( self:GetPos() ) > flMaxJumpLength || abs( vec.z - self:GetPos().z ) > self.loco:GetJumpHeight() then break end
					//Dont Use The Vector to MakeShift Goal Option, and Instead Pretend to be a Jump Across Gap Goal
					local ntr = Trace( {
						start = vec,
						endpos = vec + Vector( 0, 0, flDist ),
						filter = self:AllRelatedEntities(),
						mask = MASK_SOLID
					} )
					if ntr.Hit then continue end
					if !Trace( {
						start = self:GetCenter(),
						endpos = vec + Vector( 0, 0, enemy:OBBMaxs().z ),
						filter = table.add( { enemy }, table.add( tEnemies, self:AllRelatedEntities() ) ),
						mask = MASK_SOLID
					} ).Hit then self:Jump { type = 3, pos = vec } return end
				end
			end
		end
		self:A_CombatMoveRangeAttack( enemy )
		self:A_CombatMovePath( self.MovePath, 1, 1, nil, table.IsEmpty( tEnemies ) && { enemy } || table.add( tEnemies, { enemy } ) )
	end,
	COMBAT_SOLDIER = function( self, sched )
		local enemy, tEnemies = sched.Enemy || self.Enemy, sched.tEnemies || self.tEnemies
		if !IsValid( enemy ) then return {} end
		local b, v, cr = true, sched.vCover || self.vCover, Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch )
		if !v || self:GetPos():Distance( v ) > self.flPathTol then self:SetSchedule( ( HasRangeAttack( self ) && ( !self.SchedulePrev || self.SchedulePrev.m_sName != 'RANGE_ATTACK' ) ) && 'RANGE_ATTACK' || 'TAKE_COVER' ) return end
		local p = v + ( cr && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z ) )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = p,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then b = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
		if b then Handle( self.Enemy ) end
		if !b then self:SetSchedule( ( HasRangeAttack( self ) && ( !self.SchedulePrev || self.SchedulePrev.m_sName != 'RANGE_ATTACK' ) ) && 'RANGE_ATTACK' || 'TAKE_COVER' ) return end
		if !self:CanExpose() then
			local m, n = sched.flTimeMin || self.SCHED_flHideTimeMin || 0, sched.flTimeMax || self.SCHED_flHideTimeMax || 4
			sched.flTime = CurTime() + clamp( math.Remap( self:GetExposedWeight(), 0, self:Health() * self.flExposedHideHealth, m, n ), m, n )
			return
		end
		local b
		for _, ent in ipairs( self:HaveAllies() ) do if ent.__ACTOR__ && ent.bSuppressing || ent:IsPlayer() && ( ent:KeyDown( IN_ATTACK ) || ent:KeyDown( IN_ATTACK2 ) ) then b = true break end end
		if CurTime() > ( sched.flTime || 0 ) && rand( ( b && ( sched.flCoveredChance || self.SCHED_flPeekCoveredChance || 500 ) || ( sched.flChance || self.SCHED_flPeekChance || 1000 ) ) * FrameTime() ) == 1 then
			local enemy = self.Enemy
			local b
			for _, ent in ipairs( self:HaveAllies() ) do if ent.__ACTOR__ && ent.bSuppressing || ent:IsPlayer() && ( ent:KeyDown( IN_ATTACK ) || ent:KeyDown( IN_ATTACK2 ) ) then b = true break end end
			if b && rand( sched.flCoveredDontMoveChance || self.SCHED_flCoveredDontMoveIChance || COVERED_DONT_MOVE_CHANCE ) != 1 || !b && rand( sched.flNotCoveredMoveChance || self.SCHED_flNotConveredMoveChance || COVERED_NOT_MOVE_CHANCE ) == 1 then self:SetSchedule 'COVER_MOVE' return end
			local t, f = self:FindSuppress( enemy )
			if t && f then
				local sched = self:SetSchedule 'RANGE_ATTACK'
				sched.Enemy = enemy
				sched.vTarget = t + Vector( 0, 0, ( abs( enemy:OBBMins().z ) + abs( enemy:OBBMaxs().z ) ) * .5 )
				sched.vFrom = f
			else self:SetSchedule 'COVER_MOVE' end
		else self:A_CombatStand( cr && 0 || 1, true ) self:A_CombatAim( ( ( IsValid( sched.Enemy ) && sched.Enemy:GetCenter() || self.Enemy:GetCenter() ) - self:GetPos() ):Angle() ) end
	end,
	COVER_RANGE_OR_MOVE = function( self, sched )
		if !IsValid( sched.Enemy ) && !IsValid( self.Enemy ) then return {} end
		local b, v, cr = true, sched.vCover || self.vCover, Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch )
		if !v then self:SetSchedule( ( HasRangeAttack( self ) && rand( 2 ) == 1 ) && 'RANGE_ATTACK' || 'TAKE_COVER' ) return end
		local p = v + ( cr && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z ) )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = p,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then b = false return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
		if b then Handle( self.Enemy ) end
		if !b then self:SetSchedule( ( HasRangeAttack( self ) && rand( 2 ) == 1 ) && 'RANGE_ATTACK' || 'TAKE_COVER' ) return end
		if !self:CanExpose() then
			local m, n = sched.flTimeMin || self.SCHED_flHideTimeMin || 0, sched.flTimeMax || self.SCHED_flHideTimeMax || 2
			sched.flTime = CurTime() + clamp( math.Remap( self:GetExposedWeight(), 0, self:Health() * self.flExposedHideHealth, m, n ), m, n )
			return
		end
		local b
		for _, ent in ipairs( self:HaveAllies() ) do if ent.__ACTOR__ && ent.bSuppressing || ent:IsPlayer() && ( ent:KeyDown( IN_ATTACK ) || ent:KeyDown( IN_ATTACK2 ) ) then b = true break end end
		if CurTime() > ( sched.flTime || 0 ) && rand( ( b && ( sched.flCoveredChance || self.SCHED_flPeekCoveredChance || 500 ) || ( sched.flChance || self.SCHED_flPeekChance || 1000 ) ) * FrameTime() ) == 1 then
			self:SetSchedule 'RANGE_OR_MOVE'
		else self:A_CombatStand( cr && 0 || 1, true ) self:A_CombatAim( ( ( IsValid( sched.Enemy ) && sched.Enemy:GetCenter() || self.Enemy:GetCenter() ) - self:GetPos() ):Angle() ) end
	end,
	COVER_MOVE = function( self, sched )
		if self.flCombatState > 0 then
			self:CHAT "Advancing!"
			self:SetSchedule 'TAKE_COVER_ADVANCE'
		else
			self:CHAT "Retreating!"
			self:SetSchedule 'TAKE_COVER_RETREAT'
		end
	end,
	RANGE_OR_MOVE = function( self, sched )
		local enemy = self.Enemy
		local b
		for _, ent in ipairs( self:HaveAllies() ) do if ent.__ACTOR__ && ent.bSuppressing || ent:IsPlayer() && ( ent:KeyDown( IN_ATTACK ) || ent:KeyDown( IN_ATTACK2 ) ) then b = true break end end
		if b && rand( sched.flCoveredDontMoveChance || self.SCHED_flCoveredDontMoveIChance || COVERED_DONT_MOVE_CHANCE ) != 1 || !b && rand( sched.flNotCoveredMoveChance || self.SCHED_flNotConveredMoveChance || COVERED_NOT_MOVE_CHANCE ) == 1 then self:SetSchedule 'COVER_MOVE' return end
		local t, f = self:FindSuppress( enemy )
		if t && f then
			local sched = self:SetSchedule 'RANGE_ATTACK'
			sched.Enemy = enemy
			sched.vTarget = t + Vector( 0, 0, ( abs( enemy:OBBMins().z ) + abs( enemy:OBBMaxs().z ) ) * .5 )
			sched.vFrom = f
		else self:SetSchedule 'COVER_MOVE' end
	end,
	RANGE_ATTACK = function( self, sched )
		local v, enemy = sched.vFrom, sched.Enemy
		if !IsValid( enemy ) then
			enemy = self.Enemy
			if !IsValid( enemy ) then return {} end
		end
		if self.tBullseyes[ enemy ] then enemy = self.tBullseyes[ enemy ] end
		if !sched.bHandledAdvanceVersion && self.flCombatState > 0 then
			local na, nad = self, self:GetPos():DistToSqr( enemy:GetPos() )
			for _, ent in ipairs( self:HaveAllies() ) do
				if !HasRangeAttack( ent ) then continue end
				local d = ent:GetPos():DistToSqr( enemy:GetPos() )
				if d < nad then na, nad = ent, d end
			end
			local flAdvance = lmax( 0, self.flCombatState ) * ( sched.flAdvance || self.SCHED_flAdvance )
			local flAdvanceMax = flAdvance * self.SCHED_flAdvanceMaxMultiplier
			local d = clamp( lmax( 0, self:GetPos():Distance( enemy:GetPos() ) - nad ^ .5 ) * math.Rand( 0, 1 ) + flAdvance * math.Rand( 0, 1 ), 0, flAdvanceMax )
			if math.Rand( 0, clamp( math.Remap( d, flAdvance, 0, 1.5, 4 ), 1.5, 4 ) ) <= 1 then
				local Path = Path 'Follow'
				Path:Compute( self, enemy:GetPos() )
				if Path:GetLength() > self.flRunAwayDist then
					d = lmin( d, Path:GetLength() - self.flRunAwayDist )
					Path:MoveCursorTo( d )
					sched.bSuppressMove = true
					local t, f = self:FindSuppress { enemy = enemy, vPos = Path:GetPositionOnPath( Path:GetCursorPosition() ) }
					if t && f then
						local b = true
						for _, ent in ipairs( self:HaveAllies() ) do if ent.__ACTOR__ && ent.Schedule && ent.Schedule.m_sName == 'RANGE_ATTACK' && ent.Schedule.bSuppressMove && ent.Schedule.vFrom:DistToSqr( t ) <= self.flFindVecDistFromAllies then b = nil break end end
						if b then
							sched.Enemy = enemy
							sched.vTarget = t + Vector( 0, 0, ( abs( enemy:OBBMins().z ) + abs( enemy:OBBMaxs().z ) ) * .5 )
							sched.vFrom = f
							v = f
						end
					end
				end
			end
			sched.bHandledAdvanceVersion = true
		end
		if !v || !sched.vTarget then
			local t, f = self:FindSuppress( enemy )
			if t && f then
				sched.Enemy = enemy
				sched.vTarget = t + Vector( 0, 0, ( abs( enemy:OBBMins().z ) + abs( enemy:OBBMaxs().z ) ) * .5 )
				sched.vFrom = f
				v = f
			else return {} end
		end
		if !v || !self:CanExpose() then return {} end
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		if !sched.flHeight then sched.flHeight = math.Rand( 0, 1 ) end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
			self.bMusicActive = true
			if !IsValid( enemy ) || Trace( {
				start = sched.vFrom,
				endpos = sched.vTarget,
				mask = MASK_SHOT_HULL,
				filter = IsValid( enemy ) && table.add( self:AllRelatedEntities(), enemy:AllRelatedEntities() ) || self:AllRelatedEntities()
			} ).Hit then return {} end
			self:A_CombatStand( sched.flHeight )
			if self:IsShootable( enemy:GetCenter() ) then
				sched.vTarget = enemy:GetCenter()
				self:A_RangeAttack( enemy )
			else self:A_RangeAttack( sched.vTarget ) end
			self.bSuppressing = true
			if !sched.flTime then
				self:CHAT "Suppressive Fire!"
				sched.flTime = CurTime() + math.Rand( sched.flTimeMin || self.SCHED_flRangeAttackTimeMin || 0, sched.flTimeMax || self.SCHED_flRangeAttackTimeMax || 8 )
			end
			if CurTime() > sched.flTime then return { true } end
			return
		end
		self.bMusicActive = nil
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		local bStand = true
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		self.bMusicActive = true
		if bStand then
			self:A_CombatMovePathSlow { Path = self.MovePath, flSpeed = 1, flHeight = 1, bAim = IsValid( nve ), flTargetSequence = self:A_CalcCombatStandSequence( sched.flHeight ) }
		elseif bCrouch then
			self:A_CombatMovePathSlow { Path = self.MovePath, flSpeed = 1, flHeight = 0, bAim = IsValid( nve ), flTargetSequence = self:A_CalcCombatStandSequence( sched.flHeight ) }
		else
			self:A_CombatMovePath { Path = self.MovePath, flSpeed = 1, flHeight = 1, bAim = IsValid( nve ), flTargetSequence = self:A_CalcCombatStandSequence( sched.flHeight ) }
		end
	end,
	TAKE_COVER = function( self, sched )
		self.bMusicActive = nil
		self.flNextFindCover = 0
		local v = sched.vCover || self.vCover
		if v then
			local b = true
			local h = Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch ) && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z )
			local function Handle( ent )
				if !HasRangeAttack( ent ) then return end
				for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = vec,
						endpos = v + h,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = false return end
				end
			end
			for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
			if b then Handle( self.Enemy ) end
			if !b then
				self:FindCover()
				if !self.vCover then return {} end
				sched.vCover = self.vCover
				sched.bCvrCrouch = BOOL( self.bCvrCrouch )
			end
		else
			self:FindCover()
			if !self.vCover then return {} end
			sched.vCover = self.vCover
			sched.bCvrCrouch = BOOL( self.bCvrCrouch )
		end
		if !v then return {} end
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then return { true } end
		if self.MoveBlendMotor then self.MoveBlendMotor:SetSecondarySequence( self:A_CalcCombatStandSequence( sched.bCvrCrouch && 0 || 1, true ) ) end
		self:SetMoveTarget( v )
		self:ComputePath()
		local bStand = true
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self.bMusicActive = true self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		if bStand then
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		elseif bCrouch then
			self:A_CombatMovePath( self.MovePath, 1, 0, IsValid( nve ) )
		else
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		end
		self.flNextFindCover = math.huge
	end,
	TAKE_COVER_STAY = function( self, sched )
		self.bMusicActive = nil
		self.flNextFindCover = 0
		local v = sched.vCover || self.vCover
		if v then
			local b = true
			local h = Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch ) && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z )
			local function Handle( ent )
				if !HasRangeAttack( ent ) then return end
				for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = vec,
						endpos = v + h,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = false return end
				end
			end
			for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
			if b then Handle( self.Enemy ) end
			if !b then
				if HasRangeAttack( self ) && rand( 2 ) == 1 then self:SetSchedule 'RANGE_ATTACK' end
				self:FindCover()
				if !self.vCover then return {} end
				sched.vCover = self.vCover
				sched.bCvrCrouch = BOOL( self.bCvrCrouch )
			end
		else
			if HasRangeAttack( self ) && rand( 2 ) == 1 then self:SetSchedule 'RANGE_ATTACK' end
			self:FindCover()
			if !self.vCover then return {} end
			sched.vCover = self.vCover
			sched.bCvrCrouch = BOOL( self.bCvrCrouch )
		end
		if !v then return {} end
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		local enemy = sched.Enemy
		if !IsValid( enemy ) then
			enemy = self.Enemy
			if !IsValid( enemy ) then return {} end
		end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
			self:A_CombatStand( cr && 0 || 1, true )
			self:A_CombatAim( ( enemy:GetCenter() - self:GetPos() ):Angle() )
			return
		end
		self:SetMoveTarget( v )
		self:ComputePath()
		local bStand = true
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self.bMusicActive = true self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		if bStand then
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		elseif bCrouch then
			self:A_CombatMovePath( self.MovePath, 1, 0, IsValid( nve ) )
		else
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		end
		self.flNextFindCover = math.huge
	end,
	TAKE_COVER_CUSTOM = function( self, sched )
		self.bMusicActive = nil
		self.flNextFindCover = 0
		local v = sched.vCover
		if !v then return {} end
		self.vCover = v
		local enemy = sched.Enemy
		if !IsValid( enemy ) then
			enemy = self.Enemy
			if !IsValid( enemy ) then return {} end
		end
		local cr
		local p = v + Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = p,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then cr = true return true end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if Handle( ent ) then break end end
		if !cr then Handle( self.Enemy ) end
		sched.bCvrCrouch = cr
		self.bCvrCrouch = cr
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
			sched.bAtCover = true
			self:A_CombatStand( cr && 0 || 1, true )
			self:A_CombatAim( sched.dFacing || ( enemy:GetCenter() - self:GetPos() ):Angle() )
		else sched.bAtCover = nil end
		self:SetMoveTarget( v )
		self:ComputePath()
		local bStand = true
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self.bMusicActive = true self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		if bStand then
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		elseif bCrouch then
			self:A_CombatMovePath( self.MovePath, 1, 0, IsValid( nve ) )
		else
			self:A_CombatMovePath( self.MovePath, 1, 1, IsValid( nve ) )
		end
		self.flNextFindCover = math.huge
	end,
	TAKE_COVER_ADVANCE = function( self, sched )
		self.bMusicActive = nil //true
		self.flNextFindCover = 0
		local enemy = sched.Enemy
		if !IsValid( enemy ) then enemy = self.Enemy if !IsValid( enemy ) then return {} end end
		local v = sched.vCover// || self.vCover
		if v then
			local b = true
			local h = Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch ) && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z )
			local function Handle( ent )
				if !HasRangeAttack( ent ) then return end
				for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = vec,
						endpos = v + h,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = false return end
				end
			end
			for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
			if b then Handle( self.Enemy ) end
			if !b then
				local na, nad = self, self:GetPos():DistToSqr( enemy:GetPos() )
				for _, ent in ipairs( self:HaveAllies() ) do
					if !HasRangeAttack( ent ) then continue end
					local d = ent:GetPos():DistToSqr( enemy:GetPos() )
					if d < nad then na, nad = ent, d end
				end
				local flAdvance = lmax( 0, self.flCombatState ) * ( sched.flAdvance || self.SCHED_flAdvance )
				local flAdvanceMax = flAdvance * self.SCHED_flAdvanceMaxMultiplier
				local d = clamp( lmax( 0, self:GetPos():Distance( enemy:GetPos() ) - nad ^ .5 ) * math.Rand( 0, 1 ) + flAdvance * math.Rand( 0, 1 ), 0, flAdvanceMax )
				self:FindCoverAdvance { flAdvance = d }
				if !self.vCover then return {} end
				sched.vCover = self.vCover
				sched.bCvrCrouch = BOOL( self.bCvrCrouch )
			end
		else
			local na, nad = self, self:GetPos():DistToSqr( enemy:GetPos() )
			for _, ent in ipairs( self:HaveAllies() ) do
				if !HasRangeAttack( ent ) then continue end
				local d = ent:GetPos():DistToSqr( enemy:GetPos() )
				if d < nad then na, nad = ent, d end
			end
			local flAdvance = lmax( 0, self.flCombatState ) * ( sched.flAdvance || self.SCHED_flAdvance )
			local flAdvanceMax = flAdvance * self.SCHED_flAdvanceMaxMultiplier
			local d = clamp( lmax( 0, self:GetPos():Distance( enemy:GetPos() ) - nad ^ .5 ) * math.Rand( 0, 1 ) + flAdvance * math.Rand( 0, 1 ), 0, flAdvanceMax )
			self:FindCoverAdvance { flAdvance = d }
			if !self.vCover then return {} end
			sched.vCover = self.vCover
			sched.bCvrCrouch = BOOL( self.bCvrCrouch )
		end
		if !v then return {} end
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then return { true } end
		self:SetMoveTarget( v )
		self:ComputePath()
		local bStand = true
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self.bMusicActive = true self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		if bStand then
			self:A_CombatMovePathSlow( self.MovePath, 1, 1, IsValid( nve ) )
		elseif bCrouch then
			self:A_CombatMovePathSlow( self.MovePath, 1, 0, IsValid( nve ) )
		else
			self:A_CombatMovePathSlow( self.MovePath, 1, 1, IsValid( nve ) )
		end
		self.flNextFindCover = math.huge
	end,
	TAKE_COVER_RETREAT = function( self, sched )
		self.bMusicActive = nil
		self.flNextFindCover = 0
		local v = sched.vCover// || self.vCover
		if v then
			local b = true
			local h = Either( sched.bCvrCrouch == nil, self.bCvrCrouch, sched.bCvrCrouch ) && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z )
			local function Handle( ent )
				if !HasRangeAttack( ent ) then return end
				for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = vec,
						endpos = v + h,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = false return end
				end
			end
			for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
			if b then Handle( self.Enemy ) end
			if !b then self:FindCoverRetreat { flRetreat = -lmin( 0, self.flCombatState ) * ( sched.flRetreat || self.SCHED_flRetreat ) } if !self.vCover then return {} end sched.vCover = self.vCover sched.bCvrCrouch = BOOL( self.bCvrCrouch ) end
		else self:FindCoverRetreat { flRetreat = -lmin( 0, self.flCombatState ) * ( sched.flRetreat || self.SCHED_flRetreat ) } if !self.vCover then return {} end sched.vCover = self.vCover sched.bCvrCrouch = BOOL( self.bCvrCrouch ) end
		if !v then return {} end
		local b, p = self:GetPos():Distance( v ) < self.flPathTol
		if !b then
			self:SetMoveTarget( v )
			self:ComputePath()
			p = true
		end
		if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then return { true } end
		self:SetMoveTarget( v )
		self:ComputePath()
		local bStand = true
		local h = Vector( 0, 0, self.vHullMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bStand = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bStand then break end Handle( ent ) end
		if bStand then Handle( self.Enemy ) end
		local bCrouch = !bStand
		local h = Vector( 0, 0, self.vHullDuckMaxs.z )
		local function Handle( ent )
			if !HasRangeAttack( ent ) then return end
			for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
				if !Trace( {
					start = vec,
					endpos = v + h,
					filter = function( ent ) return self:Disposition( ent ) != D_LI end,
					mask = MASK_SHOT_HULL
				} ).Hit then bCrouch = nil return end
			end
		end
		for _, ent in pairs( self.tEnemies ) do if !bCrouch then break end Handle( ent ) end
		if bCrouch then Handle( self.Enemy ) end
		local tEnemies, nve = sched.tEnemies || self.tEnemies
		if tEnemies then
			local nved = math.huge
			for _, enemy in pairs( tEnemies ) do
				if !IsValid( enemy ) then continue end
				local d = self:GetPos():DistToSqr( enemy:GetCenter() )
				if d >= nved || !self:IsShootable( enemy:GetCenter() ) then continue end
				nve, nved = enemy, d
			end
			if IsValid( nve ) then self.bMusicActive = true self:A_CombatMoveRangeAttack( nve ) else self:A_FaceMotion() end
		else self:A_FaceMotion() end
		if bStand then
			self:A_CombatMovePathSlow( self.MovePath, 1, 1, IsValid( nve ) )
		elseif bCrouch then
			self:A_CombatMovePathSlow( self.MovePath, 1, 0, IsValid( nve ) )
		else
			self:A_CombatMovePathSlow( self.MovePath, 1, 1, IsValid( nve ) )
		end
		self.flNextFindCover = math.huge
	end,
	SEARCH_AGGRESSIVE = function( self, sched )
		if !table.IsEmpty( self.tEnemies ) then return { true } end
		if sched.vCurrent && sched.vCover then
			self.vCover = sched.vCover
			self.bCvrCrouch = sched.bCvrCrouch
			self.flNextFindCover = math.huge
			if sched.bPeeking then
				local tFilter = self:AllRelatedEntities()
				local tar = sched.vCurrent
				local v = sched.vFrom
				local vStand, vCrouch = Vector( 0, 0, self.vHullMaxs.z )
				if self.vHullMaxs.z != self.vHullDuckMaxs.z then vCrouch = Vector( 0, 0, self.vHullDuckMaxs.z ) end
				self.bMusicActive = nil
				if v then
					if vCrouch then
						local bStand, bCrouch = !Trace( {
							start = v + vStand,
							endpos = tar,
							filter = tFilter,
							mask = MASK_SHOT_HULL
						} ).Hit, !Trace( {
							start = v + vCrouch,
							endpos = tar,
							filter = tFilter,
							mask = MASK_SHOT_HULL
						} ).Hit
						if !bStand && !bCrouch then sched.vFrom = nil return end
						local b, p = self:GetPos():Distance( v ) < self.flPathTol
						if !b then
							self:SetMoveTarget( v )
							self:ComputePath()
							p = true
						end
						if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
							if !sched.flTime then sched.flTime = CurTime() + math.Rand( sched.flWatchTimeMin || self.SCHED_flAggressiveSearchWatchTimeMin || 0, sched.flWatchTimeMax || self.SCHED_flAggressiveSearchWatchTimeMax || 4 ) end
							if CurTime() > sched.flTime then sched.flTime = nil sched.vCover = nil sched.vCurrent = nil return end
							if bStand && bCrouch then
								if sched.flCrouch == nil || rand( 10000 * FrameTime() ) == 1 then
									sched.flCrouch = math.Rand( 0, 1 )
								end
								self:A_CombatStand( sched.flCrouch, true )
								self:A_CombatAim( ( tar - self:GetPos() ):Angle() )
							elseif bStand then
								self:A_CombatStand( 1, true )
								self:A_CombatAim( ( tar - self:GetPos() ):Angle() )
							else
								self:A_CombatStand( 1, true )
								self:A_CombatAim( ( tar - self:GetPos() ):Angle() )
							end
						end
						local bShootable = self:IsShootable( tar )
						self:A_CombatMovePathSlow( self.MovePath, 1, 1, bShootable )
						if bShootable then self:A_CombatAim( ( tar - self:GetPos() ):Angle() ) self.bMusicActive = true else self:A_FaceMotion() end
						self.bMusicActive = bShootable
					else
						if Trace( {
							start = v + vStand,
							endpos = tar,
							filter = tFilter,
							mask = MASK_SHOT_HULL
						} ).Hit then sched.vFrom = nil return end
						if !sched.flTime then sched.flTime = CurTime() + math.Rand( sched.flWatchTimeMin || self.SCHED_flAggressiveSearchWatchTimeMin || 0, sched.flWatchTimeMax || self.SCHED_flAggressiveSearchWatchTimeMax || 4 ) end
						if CurTime() > sched.flTime then sched.flTime = nil sched.vCover = nil sched.vCurrent = nil return end
						local b, p = self:GetPos():Distance( v ) < self.flPathTol
						if !b then
							self:SetMoveTarget( v )
							self:ComputePath()
							p = true
						end
						if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
							if !sched.flTime then sched.flTime = CurTime() + math.Rand( sched.flTimeMin || self.SCHED_flRangeAttackTimeMin || 0, sched.flTimeMax || self.SCHED_flRangeAttackTimeMax || 16 ) end
							self:A_CombatStand( 1, true )
							self:A_CombatAim( ( tar - self:GetPos() ):Angle() )
						end
						local bShootable = self:IsShootable( tar )
						self:A_CombatMovePathSlow( self.MovePath, 1, 1, bShootable )
						if bShootable then self:A_CombatAim( ( tar - self:GetPos() ):Angle() ) else self:A_FaceMotion() end
						self.bMusicActive = bShootable
					end
					return
				end
				local nld = math.huge
				local area = navmesh.GetNearestNavArea( self:GetPos() )
				if !area then return {} end
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
					local b, vec = area:IsVisible( tar )
					if b then
						if !Trace( {
							start = vec + vStand,
							endpos = tar,
							filter = tFilter,
							mask = MASK_SHOT_HULL
						} ).Hit || vCrouch && !Trace( {
							start = vec + vCrouch,
							endpos = tar,
							filter = tFilter,
							mask = MASK_SHOT_HULL
						} ).Hit then
							sched.vFrom = vec
							return
						end
					end
				end
			else
				local v, t = sched.vCover, sched.vCurrent
				if v then
					local b = true
					local p = v + ( sched.bCvrCrouch && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z ) )
					for _, vec in ipairs( sched.tPoints ) do
						if !Trace( {
							start = vec,
							endpos = p,
							filter = function( ent ) return self:Disposition( ent ) != D_LI end,
							mask = MASK_SHOT_HULL
						} ).Hit then sched.vCover = nil return end
					end
				end
				local b, p = self:GetPos():Distance( v ) < self.flPathTol
				if !b then
					self:SetMoveTarget( v )
					self:ComputePath()
					p = true
				end
				if b || p && self.MovePath:GetCursorPosition() >= self.MovePath:GetLength() then
					if !sched.flCoverTime then sched.flCoverTime = CurTime() + math.Rand( sched.flCoverTimeMin || self.SCHED_flAggressiveSearchCoverTimeMin || 0, sched.flCoverTimeMax || self.SCHED_flAggressiveSearchCoverTimeMax || 4 ) end
					if CurTime() > sched.flCoverTime then
						sched.bPeeking = true
						sched.flCoverTime = nil
					else
						if self.bCvrCrouch then
							self:A_CombatStand( 0, true )
							self:A_CombatAim( ( t - self:GetPos() ):Angle() )
						else
							if sched.flCrouch == nil || rand( 10000 * FrameTime() ) == 1 then
								sched.flCrouch = math.Rand( 0, 1 )
							end
							self:A_CombatStand( sched.flCrouch, true )
							self:A_CombatAim( ( t - self:GetPos() ):Angle() )
						end
					end
					return
				end
				self:SetMoveTarget( v )
				self:ComputePath()
				local bStand = true
				local p = self:GetPos() + Vector( 0, 0, self.vHullMaxs.z )
				for _, vec in ipairs( sched.tPoints ) do
					if !Trace( {
						start = vec,
						endpos = p,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then bStand = nil break end
				end
				local bCrouch = !bStand
				local p = self:GetPos() + Vector( 0, 0, self.vHullDuckMaxs.z )
				for _, vec in ipairs( sched.tPoints ) do
					if !Trace( {
						start = vec,
						endpos = p,
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then bCrouch = nil break end
				end
				self:A_FaceMotion()
				if bStand then
					self:A_CombatMovePathSlow( self.MovePath, 1, 1 )
				elseif bCrouch then
					self:A_CombatMovePathSlow( self.MovePath, 1, 0 )
				else
					self:A_CombatMovePathSlow( self.MovePath, 1, 1 )
				end
			end
		else
			sched.bPeeking = nil
			local area, vec = navmesh.GetNearestNavArea( self:GetPos() )
			if !area then return {} end
			local tQueue, tVisited = { { area, 0 } }, {}
			local flDistSqrMin = sqr( flDistMin || self.flRunAwayDist )
			local ncd, nc = math.huge
			while !table.IsEmpty( tQueue ) do
				table.SortByMember( tQueue, 2, true )
				local area, dist = unpack( table.remove( tQueue, 1 ) )
				tVisited[ area:GetID() ] = true
				for _, new in ipairs( area:GetAdjacentAreas() ) do
					if tVisited[ new:GetID() ] || !self.loco:CanTraverseArea( new ) then continue end
					local h = area:ComputeAdjacentConnectionHeightChange( new )
					if h < -self.loco:GetDeathDropHeight() || h > self.loco:GetJumpHeight() then continue end
					tVisited[ new:GetID() ] = true
					table.insert( tQueue, { new, new:GetCenter():DistToSqr( self:GetPos() ) } )
				end
				if !area:IsVisible( self:GetCenter() ) then
					vec = area:GetRandomPoint() + Vector( 0, 0, rand( 2 ) == 1 && self.vHullMaxs.z * .5 || self.vHullDuckMaxs.z * .5 )
				end
			end
			if !vec then return {} end
			local flSize = self.vHullMaxs.z
			local flSizeCrouch = self.vHullDuckMaxs.z
			local vCheckStart, vCheck, vCheckStand = Vector( 0, 0, 10 ), Vector( 0, 0, flSizeCrouch ), Vector( 0, 0, flSize )
			self.flNextFindCover = CurTime() + math.rand( .8, 1.2 )
			local MovePath = Path 'Follow'
			MovePath:Compute( self, vec )
			local tVisited = {}
			local ncf, dir, nc = -1, ( vec - self:GetPos() ):GetNormalized()
			local flMove = self:GetMoveForDistance( self:GetPos():Distance( vec ) )
			local tar = vec //For References in The Loop Below
			local p = NPC.Tactics.CalcPoints( vec, self:GetPos(), self:GetCenter(), self:GetPos() + Vector( 0, 0, self.vHullMaxs.z ), self:GetPos() + Vector( 0, 0, self.vHullDuckMaxs.z ), self:GetSize() )
			sched.tPoints = p
			for I = 0, MovePath:GetLength(), 200 do
				MovePath:MoveCursorTo( I )
				local area = navmesh.GetNearestNavArea( MovePath:GetPositionOnPath( I ) )
				if !area || tVisited[ area:GetID() ] then continue end
				tVisited[ area:GetID() ] = true
				local t = {}
				for _, vec in ipairs( area:GetHidingSpots() ) do table.insert( t, vec ) end
				for _, vec in ipairs( area:GetExposedSpots() ) do table.insert( t, vec ) end
				for _, area in ipairs( navmesh.Find( area:GetCenter(), flMove, flMove, flMove, true ) ) do
					if tVisited[ area:GetID() ] then continue end
					tVisited[ area:GetID() ] = true
					for _, vec in ipairs( area:GetHidingSpots() ) do table.insert( t, vec ) end
					for _, vec in ipairs( area:GetExposedSpots() ) do table.insert( t, vec ) end
				end
				for _, vec in ipairs( t ) do
					MovePath:MoveCursorToClosestPosition( vec )
					local d = MovePath:GetCursorPosition()
					if d <= ncf ||
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
					for _, v in ipairs( p ) do
						if !Trace( {
							start = v,
							endpos = vec + Vector( 0, 0, flSizeCrouch ),
							filter = function( ent ) return self:Disposition( ent ) != D_LI end,
							mask = MASK_SHOT_HULL
						} ).Hit then b = true break end
					end
					if b then continue end
					cr = Trace( {
						start = vec + vCheckStart,
						endpos = vec + vCheckStand,
						mask = MASK_SOLID,
						filter = self:AllRelatedEntities()
					} ).Hit
					if !cr then
						for _, v in ipairs( p ) do
							if !Trace( {
								start = v,
								endpos = vec + Vector( 0, 0, flSize ),
								filter = function( ent ) return self:Disposition( ent ) != D_LI end,
								mask = MASK_SHOT_HULL
							} ).Hit then cr = true break end
						end
					end
					nc, ncf = vec, d
				end
			end
			if !nc then return {} end
			sched.vCurrent = vec
			sched.vCover = nc
			sched.bCvrCrouch = cr
		end
	end
}

function CActorSchedule:__tostring() return 'ActorSchedule "' .. self.m_sName .. '" [ ' .. ( IsValid( self.m_Owner ) && tostring( self.m_Owner ) || 'No Owner' ) .. ' ]' end

function CActorSchedule:SetName( sName ) self.m_sName = sName end
function CActorSchedule:GetName() return self.m_sName end

function CActorSchedule:SetOwner( ent ) self.m_Owner = ent end
function CActorSchedule:GetOwner() return self.m_Owner end

function CActorSchedule:IsValid() return IsValid( self.m_Owner ) end

CActorSchedule.__index = CActorSchedule

NPC.__SCHEDULE__ = __SCHEDULE__

ENT.__SCHEDULE__ = __SCHEDULE__ //Return `true` to Run `SelectSchedule`

//This is a Constructor, Not Neccessarily a Method. But I Made It The Way You CAN Use It as One!
function NPC.ActorSchedule( self, sName )
	local sched = setmetatable( {}, CActorSchedule )
	if sName then sched.m_sName = sName end
	if IsValid( self ) then
		sched.m_Owner = self
		self.SchedulePrev = self.Schedule
		self.Schedule = sched
	end
	return sched
end

ENT.SetSchedule = NPC.ActorSchedule
function ENT:GetSchedule() return self.Schedule end

function NPC.SCHEDULE( Name, Func ) __SCHEDULE__[ Name ] = Func end

//If Your Schedule is Very Specific - Like a Hunter Planting, Firing a Flechette Volley and UnPlanting, Use This
function NPC.SCHEDULE_SPECIAL( Name, Fall ) __SCHEDULE__[ Name ] = function( self, sched ) return self.__SCHEDULE__[ Fall ]( self, sched ) end end

function ENT:SelectSchedule( prev ) end

//"MAINTAIN SCHEDULE!" Yes, That's a Tom Clancy's Splinter Cell: Blacklist "MAINTAIN FIRE!" Reference
function ENT:SCHEDULE()
	self.bSuppressing = nil
	local sched = self.Schedule
	if sched == nil then
		if self.BEHAVIOUR then if self.BEHAVIOUR:SelectSchedule( self ) then return end end
		self:SelectSchedule()
		return
	end
	//Kids, Dont Do That! Here, I Know What I'm Doing!
	local f = self.__SCHEDULE__[ sched.m_sName ]
	if f then
		local r = f( self, sched )
		if istable( r ) then
			//Behaviour Schedules Take Predecence
			if self.BEHAVIOUR then if self.BEHAVIOUR:SelectSchedule( self, sched, r ) then return end end
			self:SelectSchedule( sched, r )
		end
	else self.Schedule = nil end
end

RegisterMetaTable( 'ActorSchedule', CActorSchedule )
