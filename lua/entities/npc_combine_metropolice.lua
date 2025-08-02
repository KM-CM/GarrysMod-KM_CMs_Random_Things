/*////////////////////////////////////////////////////////
	=== Combine Metro-Police ===

The People Who WILLINGLY Came to Serve The Combine.
They're Not Very Professional.
They're Also Very Easy to Scare into Going Back to Cover.
////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.Name = "Combine Metro-Police Unit"

ENT.vHullMins = VECTOR_HULL_HUMAN_MINS
ENT.vHullMaxs = VECTOR_HULL_HUMAN_MAXS
ENT.vHullDuckMins = VECTOR_HULL_HUMAN_DUCK_MINS
ENT.vHullDuckMaxs = VECTOR_HULL_HUMAN_DUCK_MAXS

ENT.bCantStackUp = true

ENT.CATEGORIZE = {
	Combine = true,
	CivilProtection = true
}

ENT.VehicleTime=0
ENT.PrefferedVehicle=NULL

ENT.flHide = 0
ENT.flPeek = 0
ENT.flNextPeek = 0

//ENT.Flashlight = NULL

ENT.flHandGesDelay=0
ENT.flDontSturmUntil=0
//ENT.vStand=void
ENT.flStandStop=0
//ENT.bCrouchShoot=no
//ENT.bCrouchCover=no
ENT.iVehAct=ACT_RANGE_ATTACK1
ENT.vAim = Vector( 0, 0, 0 )
ENT.bUseFindLookAng = false
//ENT.bCvrMove = false

ENT.tSpawnResetVars = {
	flHide = 0,
	flPeek = 0,
	flNextPeek = 0,
	flStandStop = 0,
	flDontSturmUntil = 0
}

ENT.GAME_HearDistMul = 1.33 //Good Mics. Still Not as Good as Soldier Ones.

function ENT:OnDeath(dmginfo,bname) self:DeathMessage(dmginfo) self:EmitSound("npc_combine_metropolice.die") self:BecomeRagdoll(dmginfo) end

npc_combine_metropolice = PrecacheClass {
	Class = 'npc_combine_metropolice',
	Cvars = {
		[ 'walkspeed' ] = { type = 'num', def = 75 },
		[ 'prowlspeed' ] = { type = 'num', def = 150 },
		[ 'runspeed' ] = { type = 'num', def = 250 },
		[ 'jumpheight' ] = { type = 'num', def = 133 },
		[ 'turnrate' ] = { type = 'num', def = 300 },
		
		[ 'peeklenm' ]={type = 'num', def = 0 },
		[ 'peeklenn' ]={type = 'num', def = 8 },
		
		[ 'peekhidelenm' ] = { type = 'num', def = 1 },
		[ 'peekhidelenn' ] = { type = 'num', def = 3 },

		[ 'exposedhidelenm' ] = { type = 'num', def = 2 },
		[ 'exposedhidelenn' ] = { type = 'num', def = 4 },

		[ 'suppressionrecoverrate' ] = { type = 'num', def = .1 },
		[ 'covertocoverrange' ] = { type = 'num', def = 400 }
	},
	Sounds={
		["radon"]={
			sound={
				"npc/metropolice/vo/on1.wav",
				"npc/metropolice/vo/on2.wav"
			},
			level=130,
			channel=CHAN_VOICE
		},
		["radoff"]={
			sound={
				"npc/metropolice/vo/off1.wav",
				"npc/metropolice/vo/off2.wav",
				"npc/metropolice/vo/off3.wav",
				"npc/metropolice/vo/off4.wav"
			},
			level=130,
			channel=CHAN_VOICE
		},
		["die"]={
			sound={
				"npc/metropolice/die1.wav",
				"npc/metropolice/die2.wav",
				"npc/metropolice/die3.wav",
				"npc/metropolice/die4.wav"
			},
			level=150,
			channel=CHAN_VOICE
		},
		["affirmative"]={
			sound={
				"npc/metropolice/vo/affirmative.wav",
				"npc/metropolice/vo/affirmative2.wav"
			},
			level=130,
			channel=CHAN_VOICE
		},
		[ 'hide' ]={
			sound={
				'npc/metropolice/vo/11-99officerneedsassistance.wav',
				'npc/metropolice/vo/reinforcementteamscode3.wav',
				'npc/metropolice/vo/requestsecondaryviscerator.wav',
				'npc/metropolice/vo/backmeupimout.wav',
				'npc/metropolice/vo/getdown.wav',
				'npc/metropolice/vo/help.wav',
				'npc/metropolice/vo/shit.wav',
				'npc/metropolice/vo/takecover.wav',
				'npc/metropolice/vo/watchit.wav',
				'npc/metropolice/vo/movingtocover.wav',
				'npc/metropolice/vo/officerunderfiretakingcover.wav'
			},
			level=150,
			channel=CHAN_VOICE
		},
		[ 'found' ]={
			sound={
				"npc/metropolice/vo/acquiringonvisual.wav",
				"npc/metropolice/vo/thereheis.wav",
				"npc/metropolice/vo/hesupthere.wav",
				"npc/metropolice/vo/isclosingonsuspect.wav"
			},
			level=150,
			channel=CHAN_VOICE
		},
		[ 'peek' ] = {
			sound = {
				'npc/metropolice/vo/breakhiscover.wav',
				'npc/metropolice/vo/destroythatcover.wav',
				'npc/metropolice/vo/firingtoexposetarget.wav',
				'npc/metropolice/vo/lockyourposition.wav',
				'npc/metropolice/vo/pacifying.wav',
				'npc/metropolice/vo/pressure.wav',
				'npc/metropolice/vo/restrict.wav',
				'npc/metropolice/vo/suspend.wav',
				'npc/metropolice/vo/covermegoingin.wav',
				'npc/metropolice/vo/goingtotakealook.wav',
				'npc/metropolice/vo/ismovingin.wav',
				'npc/metropolice/vo/prepareforjudgement.wav',
				'npc/metropolice/vo/preparingtojudge10-107.wav',
				'npc/metropolice/vo/readytoprosecute.wav',
				'npc/metropolice/vo/readytojudge.wav',
				'npc/metropolice/vo/holditrightthere.wav',
				'npc/metropolice/vo/inpositionathardpoint.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		}
	}
}

function ENT:FoundEnemy( enemy ) self:EmitSound( 'npc_combine_metropolice.found' ) end

local function OldActWep( self,act )
	local w = self:GetActiveWeapon()
	if IsValid( w ) && type( w.ActivityTranslateAI ) == 'table' && w.ActivityTranslateAI[ act ] then return w.ActivityTranslateAI[ act ] end
	return act
end
function ENT:ActWep( a )
	if !IsValid( self.Weapon ) then return OldActWep( self, a ) end
	if a == ACT_CROUCHIDLE then a = ACT_COVER_LOW
	elseif a == ACT_IDLE_ANGRY then a = ACT_RANGE_ATTACK1 end
	return OldActWep( self, a )
end
function ENT:OnActivityChanged( o, n )
	if o == ACT_INVALID || n == ACT_INVALID then return end
	local a = self:ActWep( ACT_CROUCHIDLE )
	if o != a && n == a then
		self:AddGestureSequence( self:LookupSequence( IsValid( self.Weapon ) && self.Weapon:GetHoldType() == 'pistol' && 'stand_to_crouchpistol' || 'stand_to_crouchsmg1' ) )
		//self:PlaySequenceAndWait(IsValid(self.Weapon)&&self.Weapon:GetHoldType()=='pistol'&&"stand_to_crouchpistol"||"stand_to_crouchsmg1",1)
	elseif o == a && n != a then
		self:AddGestureSequence( self:LookupSequence( IsValid( self.Weapon ) && self.Weapon:GetHoldType() == 'pistol' && 'crouch_to_lowcoverpistol' || 'crouch_to_lowcoversmg1' ) )
		//self:PlaySequenceAndWait(IsValid(self.Weapon)&&self.Weapon:GetHoldType()=='pistol'&&"crouch_to_lowcoverpistol"||"crouch_to_lowcoversmg1",1)
	end
end

function ENT:CombatCover() self:NewActivity(self:ActWep((self.bCvrCrouch||self.bCrouchCover)&&ACT_CROUCHIDLE||ACT_IDLE_ANGRY)) end
function ENT:MVCombat()
	if !self:GetMoveTarget() then return end
	local cvar=self:GetMoveTarget():DistToSqr(self:GetPos())<562500&&"prowl"||"run"
	if IsValid(self:GetEnemy())&&self:ShouldRunAway() then cvar="run" end
	//If you read npc_combine_soldier then you know why this is bad.
	//Cops also dont have walking (not walk aiming) animation.
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM /*self:ActWep(cvar=="prowl"&&ACT_WALK_AIM||ACT_RUN_AIM)*/ )
	self.loco:SetDesiredSpeed(npc_combine_metropolice:GetNum(cvar+"speed"))
	self.loco:SetAcceleration((npc_combine_metropolice:GetNum(cvar+"speed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight(500)
	self:Advance()
	if #GetVelocity( self ) < 10 then self:NewActivity( ACT_IDLE_ANGRY ) end
end
function ENT:MVWalk()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_WALK_AIM )
	self.loco:SetDesiredSpeed(npc_combine_metropolice:GetNum("walkspeed"))
	self.loco:SetAcceleration((npc_combine_metropolice:GetNum("walkspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight(500)
	self:Advance()
end
function ENT:MVProwl()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM )
	self.loco:SetDesiredSpeed(npc_combine_metropolice:GetNum("prowlspeed"))
	self.loco:SetAcceleration((npc_combine_metropolice:GetNum("prowlspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight(500)
	self:Advance()
end
function ENT:MVRun()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM )
	self.loco:SetDesiredSpeed(npc_combine_metropolice:GetNum("runspeed"))
	self.loco:SetAcceleration((npc_combine_metropolice:GetNum("runspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight(500)
	self:Advance()
end
function ENT:MVCivil()
	self:NewActivity(ACT_WALK)
	self.loco:SetDesiredSpeed(npc_combine_metropolice:GetNum("walkspeed"))
	self.loco:SetAcceleration((npc_combine_metropolice:GetNum("walkspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	//No jumping or climbing when walking!
	self.loco:SetDeathDropHeight(0)
	self.loco:SetJumpHeight(0)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self:Advance()
end

function ENT:Init()
	//This Nodel is Ass. Valve, What The Hell?!
	//Why Do I have to Override ENT.ActWep Because of You?
	//This Model has so Many Bad Made Activities!
	self:SetModel( 'models/police.mdl' )
	if SERVER then
		self:SetHealth( 200 )
		self:SetMaxHealth( 200 )
		self:DefaultWeapon( 'weapon_osip' )
	end
	self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
end

ENT.iClass=CLASS_COMBINE
function ENT:GetRelationship(ent) return (ent.Classify&&ent:Classify()||0)==self:Classify()&&D_LI||D_HT end

function ENT:HandleFlashlight()
	local ent = self.Flashlight
	if IsValid( ent ) then
		ent:SetPos( self:GetBonePosition( self:LookupBone( 'ValveBiped.Anim_Attachment_RH' ) ) )
		ent:SetLocalAngles( self:GetAimVector():Angle() - self:GetAngles() )
		ent:SetOwner( self )
	else
		ent = ents.Create( 'env_projectedtexture' )
		ent:SetKeyValue( 'lightfov', '20' )
		ent:SetKeyValue( 'lightcolor', '255 255 255 6000' )
		ent:SetKeyValue( 'distance', '2000' )
		ent:SetKeyValue( 'spritedisabled', '1' )
		ent:Input( 'SpotlightTexture', _, _, 'effects/flashlight001' )
		ent:Spawn()
		ent:SetOwner( self )
		ent:SetParent( self )
		self.Flashlight = ent
		self:DeleteOnRemove( ent )
	end
end

function ENT:Tick()
	if self.bCvrCrouch then self.bCrouchCover = true
	elseif rand( 300 ) == 1 then self.bCrouchCover = !self.bCrouchCover end
	if rand( self.bCrouchShoot == self.bCrouchCover && 300 || 100 ) == 1 then self.bCrouchShoot = !self.bCrouchShoot end
	if rand( 1, 300 ) == 1 || self.flHordeMovementAdd == 0 then self.flHordeMovementAdd=math.rand(-1,1) end
	self.flFightDist = math.Remap( self:Health(), self:GetMaxHealth(), 0, npc_combine_metropolice:GetFlt( 'fightrangem' ), npc_combine_metropolice:GetFlt( 'fightrangen' ) )
end

function ENT:StartPeek()
	self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
	                                         npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
	local t = self:MI_CalcPeek { flDelayMin = npc_combine_metropolice:GetFlt( 'peeklenm' ), flDelayMax = npc_combine_metropolice:GetFlt( 'peeklenn' ) }
	if !t || table.IsEmpty( t ) then return end
	if !self:CanExpose( t[ 3 ] ) || !self:CanExpose() then self:FailHide( true ) self:FailPeek( true ) return end
	self:EmitSound( 'npc_combine_metropolice.peek' )
	self.tPeek = t
end

function ENT:FailPeek()
	self.flPeek = 0
	self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
	                                         npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
	self.tPeek = nil
end

function ENT:FailHide( bSilent )
	self.flHide = CurTime() + math.rand( npc_combine_metropolice:GetFlt( 'exposedhidelenm' ),
										 npc_combine_metropolice:GetFlt( 'exposedhidelenn' ) )
	if !bSilent then self:EmitSound( 'npc_combine_metropolice.hide' ) end
end

function ENT:CombatBehaviour( enemy )
	self.bMusicActive = nil
	self:HandleFlashlight()
	self:SetMaxYawSpeed( npc_combine_metropolice:GetNum( 'turnrate' ) )
	self.vAim = GetVelocity( self ):GetNormalized()
	if self:InVehicle() then self.bMusicActive = true self:VehicleCombat( enemy ) return end
	self:MI_CalcCombatState()
	if !self:IsScared() && CurTime() > self.flHide && CurTime() <= self.flPeek && istable( self.tPeek ) then
		self.bMusicActive = true
		self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
												 npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
		local t = self.tPeek
		local ent = t[ 1 ]
		if !IsValid( ent ) then self:FailPeek() return end
		local p = t[ 3 ]
		if p == nil then self:FailHide( true ) self:FailPeek() return end
		if !self:CanExpose() then
			self:FailHide()
			self:FailPeek()
			return
		end
		if self:IsShootable( ent:GetCenter() ) then t[ 4 ] = true t[ 2 ] = ent:GetCenter() end
		self.vAim = ( self:Visible( ent ) || t[ 4 ] ) && ent:GetCenter() || t[ 2 ]
		if !self.vAim then self:FailPeek() return end
		if self:IsShootable( self.vAim ) && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
		self.vAim = ( self.vAim - self:GetShootPos() ):GetNormalized()
		if self.vCover && self.bCvrCrouch then
			local v = self.vCover
			local bStand = !Trace( {
				start = v + Vector( 0, 0, self.vHullMaxs.z ),
				endpos = self.vAim,
				filter = table.add( ent:AllRelatedEntities(), self:AllRelatedEntities() ),
				mask = MASK_SHOT_HULL
			} ).Hit
			local bCrouch = !Trace( {
				start = v + Vector( 0, 0, self.vHullDuckMaxs.z ),
				endpos = self.vAim,
				filter = table.add( ent:AllRelatedEntities(), self:AllRelatedEntities() ),
				mask = MASK_SHOT_HULL
			} ).Hit
			if bStand && bCrouch then self:NewActivity( self.bCrouchShoot && ACT_CROUCHIDLE || self:SeqAct( 'smgcover' ) ) return
			elseif bStand then self:NewActivity( self:SeqAct( 'smgcover' ) ) return
			elseif bCrouch then self:NewActivity( ACT_CROUCHIDLE ) return end
		end
		if t[ 4 ] && Trace( {
			start = p,
			endpos = ent:GetCenter(),
			filter = table.add( ent:AllRelatedEntities(), self:AllRelatedEntities() ),
			mask = MASK_SHOT_HULL
		} ).Hit then self:FailPeek() return end
		if self:GetPos():DistToSqr( p ) < 10000 then
			self:NewActivity( self.bCrouchShoot && ACT_CROUCHIDLE || ACT_IDLE_ANGRY )
		else
			self:ComputePath( p )
			self:MVCombat()
			self.flPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peeklenm' ),
												 npc_combine_metropolice:GetNum( 'peeklenn' ) )
		end
	else
		self.vAim = enemy:GetCenter()
		if self:IsShootable( self.vAim ) && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
		self.vAim = ( self.vAim - self:GetShootPos() ):GetNormalized()
		if !self.vCover || self.bCvrMove && !self:CanExpose() then
			self:FindCover()
			self.bCvrMove = nil
		else
			local v = self.vCover
			local b = true
			local function Handle( ent )
				if !HasRangeAttack( ent ) then return end
				for _, vec in ipairs( NPC.Tactics.CalcPoints( ent ) ) do
					if !Trace( {
						start = vec,
						endpos = v + Vector( 0, 0, 46 ),
						filter = function( ent ) return self:Disposition( ent ) != D_LI end,
						mask = MASK_SHOT_HULL
					} ).Hit then b = false return end
				end
			end
			for _, ent in pairs( self.tEnemies ) do if !b then break end Handle( ent ) end
			if b then Handle( self.Enemy ) end
			if !b then self:FindCover() self.bCvrMove = nil else self.flNextFindCover = CurTime() + 1 end
		end
		local v = self.vCover
		local b = !self:Visible( enemy )
		if b then
			for _, ent in ipairs( self.tEnemies ) do if self:Visible( ent ) then b = false end end
		end
		if !v then
			self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
													npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
			if !self.bEnemyClose || rand( clamp( math.Remap( self:GetPos():Distance( enemy:GetPos() ), 0, m * .5, 10000, 10000 ), 10000, 100000 ) * FrameTime() ) == 1 then self:EmitSound 'npc_combine_soldier.hide' self.bEnemyClose = true end
			self.vAim = enemy:GetCenter()
			if self:IsShootable( self.vAim ) && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
			self.vAim = ( self.vAim - self:GetShootPos() ):GetNormalized()
			self:SetLookAngle( self.vAim )
			self:SetMoveTarget( self:FindRunWay( enemy ) )
			self:ComputePath()
			self:MVRun()
			self.bMusicActive = self:Visible( enemy )
			self.flCombatState = -1
			return
		end
		if self:GetPos():DistToSqr( v ) < 1000 then
			self.bCvrMove = nil
			if b && !self:IsScared() && CurTime() > self.flNextPeek && self:CanExpose() then
				self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
														npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
				local b
				if rand( 2 ) == 1 then b = self:MI_FindCombatMove { flDistance = npc_combine_metropolice:GetFlt 'covertocoverrange', sMoveForward = 'npc_combine_metropolice.peek', sMoveBackward = 'npc_combine_metropolice.hide' } end
				if !b && self:StartPeek() then b = true end
				if b == nil then self:MI_FindCombatMove { flDistance = npc_combine_metropolice:GetFlt 'covertocoverrange', sMoveForward = 'npc_combine_metropolice.peek', sMoveBackward = 'npc_combine_metropolice.hide' } end
				return
			else self.tPeek = nil end
			self:CombatCover()
		else
			self.flNextPeek = CurTime() + math.rand( npc_combine_metropolice:GetNum( 'peekhidelenm' ),
													npc_combine_metropolice:GetNum( 'peekhidelenn' ) )
			self:SetMoveTarget( v )
			self:ComputePath()
			if self.bCvrMove then self.bMusicActive = true self:MVCombat() else self:MVRun() end
		end
	end
	self:SetLookAngle( self.vAim:Angle() )
end

function ENT:AlertBehaviour( vLastAlertPos )
	self:HandleFlashlight()
	self:SetMaxYawSpeed( npc_combine_metropolice:GetNum( 'turnrate' ) * .5 )
	if self:InVehicle() then
		if !self:ValidVehicle(self:GetVehicle()) then self:ExitVehicle() end
		self:NewActivity(self:ActWep(ACT_IDLE))
		
		self.loco:SetJumpHeight(0)
		self.loco:SetDeathDropHeight(math.huge)
		
		self:SetMoveTarget(vLastAlertPos)
		self:ComputePath()
		
		local cangostraight=yes
		for _,data in ipairs(self.MovePath:GetAllSegments()) do if (data.type!=0&&data.type!=1) then cangostraight=no end end
		
		self:SetVehicleSpeed(0.33)
		if cangostraight then self:VehicleMove((vLastAlertPos - self:GetPos()):GetNormalized()) else
		local cgoal=self.MovePath:GetCurrentGoal()
		if cgoal then
			self:VehicleMove(cgoal.pos)
		end end
		
		if !self:ValidVehicle(self:GetVehicle()) then self:ExitVehicle() end
		
		return
	end
	self:ComputePath( vLastAlertPos )
	self:MVProwl()
	self:SetLookAngle( self:SweepGun( ( vLastAlertPos - self:GetPos() ):GetNormalized() ) )
	self.vCover = nil
end

function ENT:PatrolBehaviour( vPatrolPos )
	self:HandleFlashlight()
	self:SetMaxYawSpeed( npc_combine_metropolice:GetNum( 'turnrate' ) * .5 )
	if self:InVehicle() then
		if !self:ValidVehicle(self:GetVehicle()) then self:ExitVehicle() end
	
		self:NewActivity(self:ActWep(ACT_IDLE))
		
		self.loco:SetJumpHeight(0)
		self.loco:SetDeathDropHeight(math.huge)
		
		self:SetMoveTarget(vLastAlertPos)
		self:ComputePath()
		
		local cangostraight=yes
		for _,data in ipairs(self.MovePath:GetAllSegments()) do if data.type!=0&&data.type!=1 then cangostraight=no end end
		
		self:SetVehicleSpeed(0.33)
		if cangostraight then self:VehicleMove((vLastAlertPos - self:GetPos()):GetNormalized()) else
		local cgoal=self.MovePath:GetCurrentGoal()
		if cgoal then
			self:VehicleMove(cgoal.pos)
		end end
		
		return
	end
	self:ComputePath( vPatrolPos )
	self:MVWalk()
	local d = self:GetForward()
	local goal = self.MovePath:GetCurrentGoal()
	if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
	self:SetLookAngle( self:SweepGun( d ) )
	self.vCover = nil
end

function ENT:IdleBehaviour()
	if IsValid( self.Flashlight ) then self.Flashlight:Remove() end
	self:SetMaxYawSpeed( npc_combine_metropolice:GetNum( 'turnrate' ) * .5 )
	if self:InVehicle() then
		if CurTime()>self.VehicleTime||!self:ValidVehicle(self.Vehicle) then self:ExitVehicle() self.VehicleTime=0 end
	
		self.loco:SetJumpHeight(npc_combine_metropolice:GetNum("jumpheight"))
		self.loco:SetDeathDropHeight(math.huge)

		if math.random(1,100)==1||self:GetPos():Distance(self:GetMoveTarget())<250 then self:SetInVehicleWanderMoveTarget() self:ComputePath() end
		
		self:SetVehicleSpeed(1)
		local cgoal=self.MovePath:GetCurrentGoal()
		if cgoal then
			self:VehicleMove(cgoal.pos)
		end
		return
	end
	if !self:IsOnGround() then self:NewActivity(self:GetSequenceActivity(self:LookupSequence("jump_holding_glide"))) end
	if rand(1,100)==1 then
		local veh=self:LookupVehicle(5000)
		if IsValid(veh) then self.PrefferedVehicle=veh self.VehicleTime=CurTime()+math.random(15,30) end
	end
	if self:ValidVehicle(self.PrefferedVehicle)&&CurTime()<self.VehicleTime then
		self:SetMoveTarget(self.PrefferedVehicle:GetPos())
		self:ComputePath()
		self:MVCivil()
		if self:GetPos():DistToSqr(self.PrefferedVehicle:GetPos())<62500 then self:EnterVehicle(self.PrefferedVehicle) end
	end
	if !self:GetMoveTarget() || self:GetMoveTarget():Distance( self:GetPos() ) < self.iPathTol then self:SetWanderMoveTarget() end
	self:ComputePath()
	self:MVCivil()
	local d
	local goal = self.MovePath:GetCurrentGoal()
	if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
	if !d then d = ( self.vMoveToPos - self:GetPos() ):GetNormalized() end
	self:SetLookAngle( d )
	self.vCover = nil
end

function ENT:Damaged( d )
	local t = CurTime() + clamp( d:GetDamage() * .05, 2, 6 )
	if self.flHide < t then self.flHide = t end
end

list.Set( 'NPC', 'npc_metropolice', {
	Name = '#npc_combine_metropolice',
	Class = 'npc_combine_metropolice',
	Category = 'Combine',
	AdminOnly = false
} )

ENT.Class = 'npc_combine_metropolice' NPC.Register( ENT )
scripted_ents.Alias( 'npc_metropolice', 'npc_combine_metropolice' )