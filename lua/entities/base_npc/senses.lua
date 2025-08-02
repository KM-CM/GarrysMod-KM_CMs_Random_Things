//ENT.vLastAlertPos = nil
//ENT.vLastAlertPos=Vector(0,0,0)
//CUT!
//ENT.vLastAlertDir=Vector(0,0,0)
//ENT.iLastAlertDirAddL=0
//ENT.vLastAlertFacing=Vector(0,0,0)

function ENT:AllyAwareness( ent )
	if !ent.__ACTOR__ then return end
	if ent:IsCombat() then
		local enemy = ent.Enemy
		if IsValid( enemy ) then self:CreateBullseyeFromEntity( enemy ) end
		for _, enemy in pairs( ent.tEnemies ) do self:CreateBullseyeFromEntity( enemy ) end
		for _, enemy in pairs( ent.tBullseyes ) do self:CreateBullseyeFromEntity( enemy ) end
		self:UpdateEnemies( true )
		self:UpdateEnemy( true )
	elseif ent:IsAlert() && !self:IsAlert() then
		self.vLastAlertPos = ent.vLastAlertPos
		self:Alert()
	end
end

function ENT:GetPatrolDist() return self.PatrolDistBase + self.PatrolDist * #self:HaveAllies() end

function ENT:FindAlertPos() return self.vLastAlertPos end

//ENT.bReinforcement=Void
function ENT:CanShady()
	for _,P in ipairs(player.GetAll()) do if /*P!=self&&*/P:Visible(self) then return no end end
	for _,C in pairs(NPC.List) do if C!=self&&C:Visible(self) then return no end end
	return yes
end

//ENT.vPatrolPos=Void
function ENT:FindPatrolPos()
	if !isvector(self.vPatrolPos)||self.vPatrolPos==Vector(0,0,0)||self:GetPos():DistToSqr(self.vPatrolPos)<sqr(self.BullseyeDist) then
		local d = self:GetPatrolDist()
		local a = table.Random( navmesh.Find( self.vLastAlertPos, d, d, d ) )
		if a then
			self.vPatrolPos = self:ModifyPatrolPos( a:GetRandomPoint() )
		else self.vPatrolPos = self:GetPos() end
	end
	return self.vPatrolPos
end

function ENT:SetWanderMoveTarget() self.vMoveToPos=table.Random(navmesh.Find(self:GetPos(),2500,2500,2500)):GetRandomPoint() end
function ENT:SetAlertedMoveTarget() self.vMoveToPos=table.Random(navmesh.Find(self:GetPos(),3000,3000,3000)):GetRandomPoint() endfunction ENT:SetInVehicleWanderMoveTarget() self.vMoveToPos=table.Random(navmesh.Find(self:GetPos(),5000,5000,5000)):GetRandomPoint() endfunction ENT:SetDistMoveTarget(d) self.vMoveToPos=table.Random(navmesh.Find(self:GetPos(),d,d,d)):GetRandomPoint() end
function ENT:SetDistMoveTargetForVector(v,d) self.vMoveToPos=table.Random(navmesh.Find(v,d,d,d)):GetRandomPoint() endfunction ENT:GetPosOfWanderMoveTarget() return table.Random(navmesh.Find(self:GetPos(),2500,2500,2500)):GetRandomPoint() end
function ENT:GetPosOfAlertedMoveTarget() return table.Random(navmesh.Find(self:GetPos(),3000,3000,3000)):GetRandomPoint() endfunction ENT:GetPosOfInVehicleWanderMoveTarget() return table.Random(navmesh.Find(self:GetPos(),5000,5000,5000)):GetRandomPoint() endfunction ENT:GetPosOfDistMoveTarget(d) return table.Random(navmesh.Find(self:GetPos(),d,d,d)):GetRandomPoint() end
function ENT:GetPosOfDistMoveTargetForVector(v,d) return table.Random(navmesh.Find(v,d,d,d)):GetRandomPoint() end

ENT.bPatrolling=no
function ENT:Patrol(t) self:Alert(t) self.bPatrolling=yes end
ENT.StartPatrol=ENT.Patrol
function ENT:UnPatrol() if self.bPatrolling then self:UnAlert() self.bPatrolling=no end end

ENT.bAlert=no
function ENT:Alert(t) self.flAlertUntil=CurTime()+(tonumber(t)||math.rand(unpack(self.AlertTimes))) end
function ENT:UnAlert() self.flAlertUntil=0 end

function ENT:SetLastAlertPos(p) self.vLastAlertPos=p end
function ENT:GetLastAlertPos() return self.vLastAlertPos end
function ENT:HaveLastAlertPos() return IsValid(self.Bullseye)&&self.Bullseye:GetPos()||self.vLastAlertPos end

function ENT:ApproximatePosition(vTo,flSpread)
	local d=vTo:Distance(self:GetPos())
	return self:GetPos()+(vTo-self:GetPos()):GetNormalized():GetSpread(Vector(flSpread,flSpread,flSpread))*d
end

ai_ignoreplayers = GetConVar( 'ai_ignoreplayers' )
function ENT:OnHeardSomething( ent, data )
	local D = self:Disposition( ent ) //NOT `data.Entity`! See `EntityEmitSound`, There's `tent` (Target Entity) and data.Entity! These are 2 Different Things!
	if D == D_LI then
		self:AllyAwareness( ent )
	elseif ( D == D_HT || D == D_FR ) && !ent:IsFlagSet( FL_NOTARGET ) && ( !ent:IsPlayer() || ai_ignoreplayers:GetInt() != 1 ) then
		local v = data.Pos || data.Entity:GetPos()
		local m = Math.Clamp( v:DistToSqr( self:GetPos() ) / ( DBToDistanceSqr( data.SoundLevel ) * sqr( self.GAME_HearDistMul || 1 ) ), 0, 1 )
		local spr = (
			m * 10 *
			self.SndApproxBase *
			math.Remap( data.SoundLevel, 60, 150, self.SndApproxMinMul, self.SndApproxMaxMul )
		)
		self:AlertedByEntity( ent, NavMesh.GetClosestPos( self:ApproximatePosition( v, spr ) ), spr > self.SndApproxNoBEyeSpr )
	end
end

function ENT:GetActHorVisCone() return ( self.Vis360 || self:InVehicle() ) && 360 || self.VisConeHor end
function ENT:GetActVerVisCone() return ( self.Vis360 || self:InVehicle() ) && 360 || self.VisConeVer end

function ENT:OnAttacked( DmgInf )
	local Attacker = DmgInf:GetAttacker()
	if !IsValid( Attacker ) || Attacker:IsEnvironment() || self:Disposition( Attacker ) == D_LI then return end
	if self.BEHAVIOUR && self.BEHAVIOUR.OnAttacked then self.BEHAVIOUR:OnAttacked( self, DmgInf ) end
	self.flHighAlert = CurTime() + math.rand( unpack( self.HighAlertTimes ) )
	self:AlertedByEntity( Attacker )
end

local function t()
	function ENT:CalcVisMiss( pos, ent )
		if IsValid( ent ) && !IsVector( pos ) then pos = ent:GetCenter() end
		local aim, req = self:GetAimVector():Angle(), ( pos - self:GetPos() ):Angle()
		local p, y = Diff( aim.p, req.p ), Diff( aim.y, req.y )
		local r = pos:DistToSqr( self:GetPos() ) / Sqr( self.VisDist ) * 0.1 * Max( p / self:GetActVerVisCone() * 0.25, 1 ) * Max( y / self:GetActHorVisCone() * 0.25, 1 )
		if IsValid( ent ) && ent:WaterLevel() > 2 then r = r * self.VisMissMulUW end
		return Max( Ceil( r * self.VisMissMul / ( self.VisNight && 1 || ( 1 / ColorStabilizeDivider() ) ) ), 1 )
	end
end
setfenv( t, {
	ENT = ENT,
	IsValid = IsValid,
	Map = Math.Map,
	Max = Math.max,
	Diff = Math.AngleDifference,
	Sqr = Math.Sqr,
	Ceil = Math.ceil,
	Clamp = Math.Clamp,
	GetVel = GetVelocity,
	IsVector = isvector,
	ColorStabilizeDivider = ColorStabilizeDivider
} ) t()
local function t()
	function ENT:CanSee( ent, bIgnoreDist )
		if self.VisOmniscient then return true end
		if IsVec(ent) then
			if bIgnoreDist&&ent:DistToSqr(self:GetPos())>Sqr(self.VisDist) then return false end
			local v=self:VisibleVec(ent)
			if !v then return false end
			if self:InVehicle()||self.Vis360 then return v end
			local aim,req=self:GetAngles(),(ent-self:GetPos()):Angle()
			return /*self:VisibleVec(ent)*/Diff(aim.y,req.y)<self:GetActHorVisCone()&&Diff(aim.y,req.y)<self:GetActVerVisCone()
		end
		if !IsValid(ent) then return false end
		if bIgnoreDist&&ent:GetPos():DistToSqr(self:GetPos())>Sqr(self.VisDist) then return false end
		if ent:IsFlagSet(Invis) then return false end
		if ent:IsPlayer()&&ai_ignoreplayers:GetInt()==1 then return false end
		local v=self:Visible(ent)
		if !v then return end
		if self:InVehicle()||self.Vis360 then return v end
		local aim,req=self:GetAngles(),(ent:GetPos()-self:GetPos()):Angle()
		return Diff(aim.y,req.y)<self:GetActHorVisCone()&&Diff(aim.y,req.y)<self:GetActVerVisCone()
	end
end
setfenv(t,{
	ENT=ENT,
	IsValid=IsValid,
	Invis=FL_NOTARGET,
	ai_ignoreplayers=ai_ignoreplayers,
	Diff=Math.AngleDifference,
	Sqr=Math.Sqr,
	IsVec=isvector,
})t()
//I only put this here cuz it is also better to optimize it
local function t()
	function ENT:Disposition( ent )
		if !IsValid( ent ) then return n end
		if ent == self.Bullseye then return h end //Hate My Bullseye...
		if ent.__ACTOR__Bullseye then return n end //...But Dont Hate Other Bullseyes.
		if ai_ignoreplayers:GetInt() == 1 && ent:IsPlayer() then return n end
		local v = self.SpecialRelationships[ ent ]
		if v != nil then return v end
		if !ent.Classify && self.bIgnoreProps && ent:IsEnvironment() then return n end
		return self:GetRelationship( ent )
	end
end
setfenv( t, {
	ENT = ENT,
	IsValid = IsValid,
	n = D_NU, h = D_HT,
	ai_ignoreplayers = GetConVar( 'ai_ignoreplayers' )
} ) t()

ENT.flNextLUpdate = 0
ENT.flLastLookDelay = 0
ENT.tVisible = {}
local function t()
	function ENT:Look( bForced )
		if !bForced && Time() < self.flNextLUpdate then return end
		self.tVisible = {}
		for _, ent in Iter( self.tBullseyes ) do Insert( self.tVisible, ent ) end
		if self.VisOmniscient then
			self.tVisible = ALL()
		else
			local d = Sqr( self.VisDist )
			for _, ent in Iter( PVS( self:EyePos() ) ) do
				if ent:GetPos():DistToSqr( self:GetPos() ) < d && self:CanSee( ent, true ) && IRand( 1, self:CalcVisMiss( ent:GetPos(), ent ) * self.flLastLookDelay ) == 1 then
					Insert( self.tVisible, ent )
					if self:Disposition( ent ) == D_LI then self:AllyAwareness( ent ) end
				end
			end
		end
		for _, ent in Iter( self.tVisible ) do
			if ent.DEAD && ( !ent.DEAD_ATTACKER_CLASS || ent.DEAD_ATTACKER_CLASS != self.iClass ) then
				if !ent.DEAD_DISCOVERED_CLASS then
					ent.DEAD_DISCOVERED_CLASS = { [ self.iClass ] = true }
				elseif !ent.DEAD_DISCOVERED_CLASS[ self.iClass ] then
					ent.DEAD_DISCOVERED_CLASS[ self.iClass ] = true
				end
				local b
				if !ent.DEAD_DISCOVERED_ENTITY then
					ent.DEAD_DISCOVERED_ENTITY = { [ self ] = true }
					b = true
				elseif !ent.DEAD_DISCOVERED_ENTITY[ self ] then
					ent.DEAD_DISCOVERED_ENTITY[ self ] = true
					b = true
				end
				if b then self.flEnemyDamage = self.flEnemyDamage + ( ent.DEAD_HEALTH || 0 ) end
			end
		end
		local l = Rand( .2, .3 )
		self.flLastLookDelay = l
		self.flNextLUpdate = Time() + l
		return true
	end
end
setfenv( t, {
	ENT=ENT,
	IsValid=IsValid,
	n=D_NU,h=D_HT,
	Sqr=sqr,
	Insert=table.insert,
	Rand=math.rand,
	Time=CurTime,
	PVS=ents.FindInPVS,
	ALL=ents.GetAll,
	Iter=pairs,
	IRand=rand,
	Rand=math.rand,
} ) t()
t = nil

//ENT.Enemy = NULL
ENT.tEnemies = {}
ENT.EnemyWeight = 0
function ENT:GetEnemy() return self.Enemy end
function ENT:SetEnemy( ent ) self.Enemy = ent end
function ENT:GetEnemies()
	local t = {}
	for _, enemy in pairs( self.tEnemies ) do table.insert( t, enemy ) end
	return t
end
ENT.GetKnownEnemies = ENT.GetEnemies

//ENT.bEnemiesHaveRangeAttack = false
//ENT.bEnemiesHaveMeleeAttack = false
ENT.flNextEUpdate = 0 //Enemies Update
ENT.tHostiles = {} //Enemies We CAN Attack, But That arent Actually Considered Enemies Yet
function ENT:UpdateEnemies( bForce )
	if CurTime() < self.flNextEUpdate && !bForce then return end
	local tEnemies, tEnemiesOld, tHostiles, tDistIgnore = {}, self.tEnemies, {}, {}
	for ent, time in pairs( self.tAltHateDistIgnore ) do if IsValid( ent ) && CurTime() <= time then tDistIgnore[ ent ] = time end end
	self.tHostiles = tHostiles
	self.EnemyWeight = 0
	local bHasRange, bHasMelee
	local tThreatOld = self.tThreat
	local tAllEnemies = {}
	for _, ent in ipairs( self:HaveAllies() ) do
		if !ent.__ACTOR__ then continue end
		if IsValid( ent.Enemy ) then tAllEnemies[ ent.Enemy ] = true end
		for _, enemy in pairs( ent.tEnemies ) do
			if IsValid( enemy ) then tAllEnemies[ enemy ] = true end
		end
		for ent, time in pairs( ent.tThreat ) do tThreatOld[ ent ] = time end
	end
	for enemy, ent in pairs( self.tBullseyes ) do tEnemies[ enemy:EntIndex() ] = ent end
	local tThreat = {}
	for ent, time in pairs( tThreatOld ) do if IsValid( ent ) && CurTime() <= time then tThreat[ ent ] = time end end
	self.tThreat = tThreat
	local tEnemiesLastSeen = {}
	self.tEnemiesLastSeen = tEnemiesLastSeen
	for _, ent in ipairs( self.tVisible ) do
		if ent.__ACTOR__Bullseye then continue end
		if !self:IsHateDisp( ent ) then continue end
		self.tEnemiesLastSeen[ ent:EntIndex() ] = CurTime()
		self.EnemyWeight = self.EnemyWeight + ent:Health()
		local b = self.bAltHate
		if b then
			b = nil
			if self:GetPos():Distance( ent:GetPos() ) < self.flAltHateDist && !tDistIgnore[ ent ] then self.tThreat[ ent ] = CurTime() + self:GetAltHateDistLength() b = true
			elseif CurTime() <= ( self.tThreat[ ent ] || 0 ) || tAllEnemies[ ent ] then b = true
			elseif ent.GetKnownEnemies then
				for _, ent in ipairs( ent:GetKnownEnemies() ) do
					if self:Disposition( ent ) == D_LI then b = true break end
				end
			end
		else b = true end
		if b && ( !ent.bNoThreat || CurTime() <= ( self.tThreat[ ent ] || 0 ) ) then
			tEnemies[ ent:EntIndex() ] = ent
			if !bHasRange && HasRangeAttack( ent ) then bHasRange = true end
			if !bHasMelee && HasMeleeAttack( ent ) then bHasMelee = true end
		else tHostiles[ ent:EntIndex() ] = ent end
		//Remove Bullseyes for Enemies We Already See
		local b = self.tBullseyes[ ent ]
		if IsValid( b ) then b:Remove() self.tBullseyes[ ent ] = nil end
	end
	for _, ent in pairs( tEnemiesOld ) do
		//If The Entity is NOT a Bullseye, and We Stopped Seeing It,
		//Then We Make a Bullseye for It to Simulate "Remembering" It,
		//All While Not Cheating by Getting a Direct Pointer to It.
		if !IsValid( ent ) then continue end
		if !bHasRange && HasRangeAttack( ent ) then bHasRange = true end
		if !bHasMelee && HasMeleeAttack( ent ) then bHasMelee = true end
		if ent.__ACTOR__Bullseye then continue end
		if !IsValid( tEnemies[ ent:EntIndex() ] ) then
			self:CreateBullseyeFromEntity( ent )
		end
	end
	self.bEnemiesHaveRangeAttack = bHasRange
	self.bEnemiesHaveMeleeAttack = bHasMelee
	self.tEnemies = tEnemies
	self.flNextEUpdate = CurTime() + math.rand( .2, .3 )
end

function ENT:GetEnemyWeight() return self.EnemyWeight end

function ENT:IsEnemyBetter( Target, Current )
	local bValidTarget, bValidCurrent = IsValid( Target ), IsValid( Current )
	if bValidTarget && bValidCurrent then
		if !self:IsHateDisp( Target ) then return end
		if self.tBullseyes[ Current ] == Target then return end
		return Target:GetPos():DistToSqr( self:GetPos() ) < Current:GetPos():DistToSqr( self:GetPos() )
	elseif bValidTarget then return true end
end

ENT.flNextTUpdate=0
function ENT:UpdateEnemy( bForce )
	if CurTime() < self.flNextTUpdate && !bForce then return end
	local enemy = self.Enemy
	local nt, ntd
	if IsValid( enemy ) then nt, ntd = enemy, self:GetPos():DistToSqr( enemy:GetPos() ) end
	for _, ent in pairs( self.tEnemies ) do
		if IsValid( ent ) && self:IsEnemyBetter( ent, nt ) then
			nt, ntd = ent, ent:GetPos():DistToSqr( self:GetPos() )
		end
	end
	local new = nt != enemy && CurTime() > self.flLastEnemy + 5
	if IsValid( nt ) then
		self:SetEnemy( nt )
		if new then
			if CurTime() > self.flNextCatAndMouse then self.flCatAndMouseStop = CurTime() + math.rand( self.CatAndMouseMinDur, self.CatAndMouseMaxDur ) end
			pcall( function() self:FoundEnemy( nt ) end )
		end
		self.flLastEnemy = CurTime()
	end
	self.flNextTUpdate = CurTime() + math.rand( .2 , .3 )
end 