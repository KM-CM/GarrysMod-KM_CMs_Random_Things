ENT.BehaviourType = ''

//DO NOT USE UNLESS YOU KNOW WHAT YOU ARE DOING!
//Creates physics, internally called in ENT.Initialize after ENT.Init if ENT.bNoPhysics is disabled.
function ENT:CreatePhysics( s )
	self:CallPhysicsInit( s )
	self.loco:SetStepHeight( 0 )
	self.loco:SetJumpHeight( 0 )
end

function ENT:OnOtherKilled( ent )
	if ent == self:GetEnemy() then self:ThisIsClear( ent ) end
	self:OnKillEntity( ent )
end

ENT.iClass = CLASS_NONE
function ENT:GetNPCClass() return self.iClass end
function ENT:SetNPCClass( i ) self.iClass = i end
ENT.Classify = ENT.GetNPCClass

ENT.flLastSeenEnemy = 0
ENT.flHighAlert = 0

function ENT:OnKilled( DmgInf ) self:OnDeath( DmgInf ) end

function ENT:UpdateSpawnResetVars()
	self.flHighAlert=0
	self.flHandGesDelay=0

	self.flHide=0

	self.flVolleyShootUntil=0
	self.flVolleyDontShootUntil=0

	self.flNextMelee=0
	self.flNextShot=0

	self.flLastSeenEnemy=0
	self.flNextCatAndMouse=0
	self.flCatAndMouseStop=0
	self.flAlertUntil=0

	self.flNextLUpdate=0
	self.flNextTUpdate=0
	self.flNextEUpdate=0
	self.flNextPUpdate=0

	self.flNextFindAllies=0
	self.flNextFindCover=0

	self.flNextGunSweep=0

	self.tVisible={}
	self.tEnemies={}
	self.tEnemiesLastSeen={}
	self.Enemy=void

	self.flPeek=0
	self.bPeeking=no

	for Key, Value in pairs( self.tSpawnResetVars ) do self[ Key ] = Value end
	//for k,v in pairs(self.tSpawnResetVars) do pcall(function()RunString(("Entity("+self:EntIndex()+")."+k+"="+v),_,no)end) end
end

function ENT:IsPlayingCatAndMouse()
	local enemy=self:GetEnemy()
	if !IsValid(enemy) then return no end
	return !self:ShouldRunAway()&&enemy:Health()<(self.iCatAndMouseHealth||self:Health()*0.33)&&self:Health()>(self:GetMaxHealth()*0.9)&&CurTime()<self.flCatAndMouseStop&&CurTime()>self.flNextCatAndMouse
end

ENT.AimVector = Vector( 0, 0, 0 )
function ENT:GetAimVector() return self.AimVector end
function ENT:SetAimVector( v ) self.AimVector = v end

ENT.flCatAndMouseStop=0
ENT.flNextCatAndMouse=0

ENT.flAlertUntil=0
ENT.flLastEnemy=0

ENT.SpecialRelationships={}
function ENT:AddEntityRelationship( ent, dsp ) self.SpecialRelationships[ ent ] = dsp || D_NU end

ENT.EIRBF = void //Exec In Run Behaviour Func
function ENT:ExecInRB( code ) self.EIRBF = code end

function ENT:IsHateDisp( ... ) local d = self:Disposition( ... ) return d != D_LI && d != D_NU end

ENT.GetEyeAngles = ENT.GetAngles
ENT.SetEyeAngles = ENT.SetAngles

function ENT:OnHurtSomething( ent, dmg )
	//HACK: Before V154, We Didnt have This.
	//As Such, We Bursted Doors Out Just on Touch.
	//Now This is Fixed and We have to Melee Them.
	if dmg:IsDamageType( DMG_CRUSH ) && self.bNoPhysics then return True end
end

NPC_FLAGS = FL_OBJECT + FL_NPC

function ENT:Initialize()
	NPC.List[ self:EntIndex() ] = self
	pcall( function() self:PreInit()end )
	pcall( function() self:Init()end )
	self.MovePath = Path 'Follow'
	self:AddFlags( NPC_FLAGS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	if self.bNoPhysics then
		self:PhysicsInitShadow()
		if IsValid( self:GetPhysicsObject() ) then
			//THIS DOES NOT AFFECT THE DOOR BURSTING!
			//See ENT.OnHurtSomething for more info.
			self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		end
	else self:CreatePhysics() end
	self:AddCallback( 'PhysicsCollide', function( self, Data )
		if IsValid( Data.HitObject ) && Data.HitObject:HasGameFlag( FVPHYSICS_NO_IMPACT_DMG ) then return end
		//Dont Take Physics Damage from Our Buddies
		if IsValid( Data.HitEntity ) && self:Disposition( Data.HitEntity ) == D_LI then return end
		if pcall_ret( function() return self:AllowPhysicsDamage( Data ) end ) != true then return end
		local da = math.floor( Data.TheirOldVelocity:Length() * Data.HitObject:GetMass() ) * .001
		local ent = Data.HitEntity
		if da < 10 then return end
		local d = DamageInfo()
		d:SetAttacker( ent )
		d:SetInflictor( ent )
		d:SetDamage( da )
		d:SetDamageType( DMG_CRUSH )
		d:SetDamageForce( Data.TheirOldVelocity )
		d:SetDamagePosition( Data.HitPos )
		self:TakeDamageInfo( d )
	end )
	self:UpdateSpawnResetVars()
	pcall( function() self:PostInit() end )
end
function ENT:OnRemove()
	self:CustomOnRemove()
	self:RemoveBullseyes()
	if IsValid( self.VehDriver ) then self.VehDriver:Remove() end
	NPC.List[ self:EntIndex() ] = nil
end

ai_disabled, developer = GetConVar 'ai_disabled', GetConVar 'developer'
sv_gravity = GetConVar 'sv_gravity'

//ENT.NPCParent = NULL
function ENT:SetNPCParent( Parent )
	if !IsValid( Parent ) || Parent == self.NPCParent then return end
	self.NPCParent = Parent
end
function ENT:GetNPCParent( Parent ) return self.NPCParent end
function ENT:RemoveNPCParent() self.NPCParent = nil end

function ENT:Think()
	if self.MoveBlendMotor then self.MoveBlendMotor:Think() end //Let Our MoveBlendMotor Think if We have One
	if developer:GetInt() == 1 then self.MovePath:Draw() end
	if !self:InVehicle() then self.loco:SetGravity( sv_gravity:GetInt() * self.flGravityMul ) end
	local p = self:GetPhysicsObject()
	if self.bNoPhysics then
		if IsValid( p ) then
			local o = self.NPCParent
			if IsValid( o ) then
				if self:WaterLevel() == 0 then
					p:SetPos( o:GetPos() )
					p:SetAngles( o:GetAngles() )
				else
					p:UpdateShadow( o:GetPos(), o:GetAngles(), 0 )
				end
			else
				if self:WaterLevel() == 0 then
					p:SetPos( self:GetPos() )
					p:SetAngles( self:GetAngles() )
				else
					p:UpdateShadow( self:GetPos(), self:GetAngles(), 0 )
				end
			end
			p:Sleep()
		end
		if self:GetAngles().p != 0 || self:GetAngles().r != 0 then
			self:SetAngles( self:GetAngles():RemoveAxis( AXIS_ROLL ):RemoveAxis( AXIS_PITCH ) )
		end
	else
		local o = self.NPCParent
		if IsValid( p ) then
			p:Wake()
			if IsValid( o ) then
				p:SetPos( o:GetPos() )
				p:SetAngles( o:GetAngles() )
			end
		end
		if IsValid( o ) then self:SetPos( o:GetPos() ) self:SetAngles( o:GetAngles() ) end
		self.loco:SetMaxYawRate( 0 )
		self.loco:SetAcceleration( 0 )
		self.loco:SetDeceleration( self.loco:GetAcceleration() )
		self.loco:SetDesiredSpeed( 0 )
		self.loco:SetStepHeight( 0 )
		self.loco:SetVelocity( Vector( 0, 0, 0 ) )
	end
	pcall( function() self:ForceTick() end )
	self:NextThink( CurTime() + .01 )
	return true
end

function ENT:KilledCleanup()
	if IsValid(self.VehDriver) then self.VehDriver:Remove() end
	if IsValid(self.Vehicle) then self.Vehicle.VehDriver=void end
end

ENT.bAILocked=no
function ENT:LockAI() self.bAILocked=yes end
function ENT:UnlockAI() self.bAILocked=no end
ENT.DisableAI=ENT.LockAI ENT.EnableAI=ENT.UnlockAI
function ENT:IsAILocked() return self.bAILocked end
function ENT:IsAIUnlocked() return !self.bAILocked end
ENT.IsAIDisabled=ENT.IsAIUnlocked ENT.IsAIEnabled=ENT.IsAIUnlocked
function ENT:SetAIEnabled(b) self.bAILocked=!b end
function ENT:GetAIEnabled() return !self:GetAILocked() end
function ENT:SetAILocked(b) self.bAILocked=b end
ENT.tAILocks = {}
function ENT:GetAILocked()
	if self.bAILocked then return true end
	if !table.IsEmpty( self.tAILocks ) then return true end
	return
end
function ENT:AddAILock( Name ) self.tAILocks[ Name ] = true end
function ENT:RemoveAILock( Name ) self.tAILocks[ Name ] = nil end
function ENT:HasAILock( Name ) return self.tAILocks[ Name ] end

function ENT:AllowRunBehaviour() return ai_disabled:GetInt() != 1 && self:GetAIEnabled() end

ENT.flEnemyDamage = 0

function ENT:RunBehaviour()
	while true do
	self.flEnemyDamage = lmax( 0, self.flEnemyDamage - self:CalcEnemyDamageDecrease() * FrameTime() )
	if self.EIRBF then self.EIRBF( self ) self.EIRBF = void coroutine.yield() continue end
	if !self.iCatAndMouseHealth then self.iCatAndMouseHealth = self:Health() * .33 end
	pcall( function() self:Tick() end )
	if !self:GetMoveTarget() then self:SetMoveTarget(self:GetPos()) end
	if IsValid(self:GetActiveWeapon())&&!self:GetActiveWeapon().ActivityTranslateAI&&self:GetActiveWeapon().SetupWeaponHoldTypeForAI then self:GetActiveWeapon():SetupWeaponHoldTypeForAI(self:GetActiveWeapon():GetHoldType()) end
	if !self.MovePath then self.MovePath = Path( 'Follow' ) end //We set this in ENT:Initialize(). Adding this just in case
	self.MovePath:SetGoalTolerance(self.flPathTol)
	if !self:InVehicle() && !IsValid( self.NPCParent ) then
		//if self.bNoPhysics then
		//	/*`base_nextbot`'s That Use `loco` Only Move when Move Functions are Called!
		//	Sounds Logical, Right? Well... by "Move", I Dont Just Mean Walk, I Mean ANY Kind of Motion.
		//	Punted and Flying at The Speed of Light, But Forgot to Call Them? No Motion at All!
		//	And a Cherry on Top - `self.loco:GetVelocity` and `self.loco:SetVelocity` Work Correctly,
		//	It's Just That Our Position is Never Actually Updated without These Calls!*/
		//	self.loco:SetDesiredSpeed( 0 )
		//	self.loco:SetAcceleration( 0 )
		//	self.loco:SetDeceleration( 0 )
		//	self.loco:SetDeathDropHeight( 999999 )
		//	self.loco:SetAvoidAllowed( true )
		//	self.loco:SetClimbAllowed( false )
		//	self.loco:SetJumpHeight( 0 )
		//	self.loco:SetMaxYawRate( 0 )
		//	self.loco:Approach( Vector( 0, 0, 0 ), -1 )
		//end
		self.loco:SetGravity( sv_gravity:GetInt() * self.flGravityMul )
		if self.bNoPhysics&&!self.bFlying&&!self:IsOnGround()&&self.bAllowAirYields then pcall(function()self:InAir(self.MovePath:GetCurrentGoal())end)coroutine.yield()continue end
	else
		if self:InVehicle() then
			self:UpdateVehiclePose( self:GetVehicle() )
		else
			self:SetLocalPos( Vector( 0, 0, 0 ) )
		end
		self.loco:SetGravity( 0 )
		self.loco:SetVelocity( Vector( 0, 0, 0 ) )
	end
	if !self:AllowRunBehaviour() then coroutine.yield() continue end

	local d = sqr( self.BullseyeDist )
	local tBullseyes, tBullseyesOld = {}, self.tBullseyes
	for _, ent in pairs( tBullseyesOld ) do
		if !IsValid( ent ) then continue end
		if self:GetPos():DistToSqr( ent:GetPos() ) < d ||
		   self:CanSee( ent ) && rand( self:CalcVisMiss( _, ent ) * self.BullseyeChnc ) == 1 then
			self:ThisIsClear( ent )
			ent:Remove()
		else tBullseyes[ ent.Enemy ] = ent end
	end
	self.tBullseyes = tBullseyes
	
	self:Look()
	self:UpdateEnemies()
	self:UpdateEnemy()
	self:UpdateAllies()

	local enemy = self.Enemy

	local b = true
	if self.Behaviour then self:Behaviour() b = nil end

	self.GAME_flSuppressionWeight = math.Clamp( self.GAME_flSuppressionWeight - self:Health() * self.flSuppressionWeakenRate * FrameTime(), 0, self:Health() * self.flSuppressionMaxAmount )

	if IsValid( enemy ) then
		self.flHighAlert=CurTime()+math.rand(unpack(self.HighAlertTimes))
		self.vPatrolPos=Void
		if self:CanSee(enemy)&&rand(self:CalcVisMiss(enemy:GetPos()))==1 then self.flLastSeenEnemy=CurTime() end
		self:Alert() self:SetLastAlertPos(enemy:GetPos())
		self.bPatrolling=no
		if b then
			if self:IsPlayingCatAndMouse() then
				if math.diff(CurTime(),self.flCatAndMouseStop)<1 then self.flNextCatAndMouse=CurTime()+math.rand(self.CatAndMouseMinDelay,self.CatAndMouseMaxDelay) end
				self.BehaviourType = 'Hunt'
				pcall(function()self:HuntBehaviour(enemy)end)
			else
				self.BehaviourType = 'Combat'
				pcall(function()self:CombatBehaviour(enemy)end)
			end
		end
	elseif CurTime()<self.flAlertUntil&&self.vLastAlertPos then
		self:RemoveBullseyes()
		self.bInCatAndMouse=no
		if !self.bPatrolling then
			self.vPatrolPos=Void
			local pos=self:FindAlertPos()
			if self:GetPos():DistToSqr(pos)<sqr(self.BullseyeDist)||self:CanSee(pos)&&rand(self.AlertChnc*self:CalcVisMiss(pos))==1 then
				self:ThisIsClear(pos)
			else
				if b then
					self.BehaviourType = 'Alert'
					pcall(function()self:AlertBehaviour(pos)end)
				end
			end
		else
			if b then
				self.BehaviourType = 'Patrol'
				pcall( function() self:PatrolBehaviour( self:FindPatrolPos() ) end )
			end
		end
	else
		self:RemoveBullseyes()
		if IsValid(self.Bullseye) then self.Bullseye:Remove() end
		self.vPatrolPos=Void
		self.bInCatAndMouse=no
		self.bPatrolling=no
		if b then
			self.BehaviourType = 'Idle'
			pcall(function()self:IdleBehaviour()end)
		end
	end
	coroutine.yield()
	end
end

local BASE_KEYVALUES = {
	[ 'weapon' ] = function( self, Key, Value ) self:Give( Value ) end,
	[ 'health' ] = function( self, Key, Value ) local v = tonumber( Value ) if v != nil then self:SetMaxHealth( v ) end end,
	[ 'model' ] = function( self, Key, Value ) self:SetModel( Value ) end,
	[ 'skin' ] = function( self, Key, Value ) local v = tonumber( Value ) if v != nil then self:SetSkin( v ) end end
}
BASE_KEYVALUES[ 'additionalequipment' ] = BASE_KEYVALUES[ 'weapon' ]
function ENT:KeyValue( Key, Value )
	Key = string.lower( Key )
	local v = BASE_KEYVALUES[ Key ]
	if v != nil then v( self, Key, Value ) end
	self:HandleKeyValue( Key, Value )
end 