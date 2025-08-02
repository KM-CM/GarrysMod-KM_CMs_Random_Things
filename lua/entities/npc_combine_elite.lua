/*////////////////////////////////////////////////////////
	=== Combine Elite ===

Similar to a Combine Soldier, Except Much, Much Tougher.
////////////////////////////////////////////////////////*/

AddCSLuaFile()

ENT.Name = 'Combine Elite'

ENT.bCantStackUp = true

ENT.CATEGORIZE = {
	Combine = true,
	Soldier = true,
	Elite = true
}

ENT.tSmokes = {}
ENT.bSmokes = true

ENT.vHullMins = VECTOR_HULL_HUMAN_MINS
ENT.vHullMaxs = VECTOR_HULL_HUMAN_MAXS
ENT.vHullDuckMins = VECTOR_HULL_HUMAN_DUCK_MINS
ENT.vHullDuckMaxs = VECTOR_HULL_HUMAN_DUCK_MAXS

ENT.tCapabilities = { CAP_PATROL_BUDDY = true }

ENT.VisNight = true

ENT.VehicleTime=0
ENT.PrefferedVehicle=NULL

ENT.flHide = 0
ENT.flPeek = 0
ENT.flNextPeek = 0

ENT.flHandGesDelay=0
ENT.flDontSturmUntil=0
//ENT.vStand=void
ENT.flStandStop=0
//ENT.bCrouchShoot=no
//ENT.bCrouchCover=no
ENT.iVehAct = ACT_IDLE_ANGRY
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

ENT.GAME_HearDistMul = 2

function ENT:OnDeath( d ) self:DeathMessage( d ) self:EmitSound( 'npc_combine_elite.die' ) self:BecomeRagdoll( d ) end

npc_combine_elite = PrecacheClass {
	Class = 'npc_combine_elite',
	Cvars = {
		[ 'walkspeed' ] = { type = 'num', def = 75 },
		[ 'prowlspeed' ] = { type = 'num', def = 150 },
		[ 'runspeed' ] = { type = 'num', def = 250 },
		[ 'jumpheight' ] = { type = 'num', def = 150 },
		[ 'turnrate' ] = { type = 'num', def = 300 },

		[ 'peeklenm' ] = { type = 'num', def = 0 },
		[ 'peeklenn' ] = { type = 'num', def = 8 },

		[ 'peekhidelenm' ] = { type = 'num', def = .8 },
		[ 'peekhidelenn' ] = { type = 'num', def = 1.6 },

		[ 'exposedhidelenm' ] = { type = 'num', def = 2 },
		[ 'exposedhidelenn' ] = { type = 'num', def = 4 },

		[ 'covertocoverrange' ] = { type = 'num', def = 400 },

		[ 'smokechancemin' ] = { type = 'num', def = 1000 },
		[ 'smokechancemax' ] = { type = 'num', def = 100000 },

		[ 'grenplace' ] = { type = 'num', def = 400 },
		[ 'grenroll' ] = { type = 'num', def = 800 },
		[ 'grenthrow' ] = { type = 'num', def = 1200 }
	},
	Sounds={
		[ 'radon' ] = {
			sound = {
				'npc/combine_soldier/vo/on1.wav',
				'npc/combine_soldier/vo/on2.wav'
			},
			level = 130,
			channel = CHAN_VOICE
		},
		[ 'radoff' ] = {
			sound = {
				'npc/combine_soldier/vo/off1.wav',
				'npc/combine_soldier/vo/off2.wav',
				'npc/combine_soldier/vo/off3.wav'
			},
			level = 130,
			channel = CHAN_VOICE
		},
		[ 'die' ]={
			sound={
				'npc/combine_soldier/die1.wav',
				'npc/combine_soldier/die2.wav',
				'npc/combine_soldier/die3.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		},
		[ 'affirmative' ] = {
			sound = {
				'npc/combine_soldier/vo/affirmative.wav',
				'npc/combine_soldier/vo/affirmative2.wav'
			},
			level = 130,
			channel = CHAN_VOICE
		},
		[ 'hide' ] = {
			sound = {
				'npc/combine_soldier/vo/cover.wav',
				'npc/combine_soldier/vo/coverhurt.wav',
				'npc/combine_soldier/vo/coverme.wav',
				'npc/combine_soldier/vo/heavyresistance.wav',
				'npc/combine_soldier/vo/displace.wav',
				'npc/combine_soldier/vo/displace2.wav',
				'npc/combine_soldier/vo/ripcordripcord.wav',
				'npc/combine_soldier/vo/callhotpoint.wav',
				'npc/combine_soldier/vo/sharpzone.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		},
		[ 'found' ] = {
			sound = {
				'npc/combine_soldier/vo/alert1.wav',
				'npc/combine_soldier/vo/affirmativewegothimnow.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		},
		[ 'peek' ] = {
			sound = {
				'npc/combine_soldier/vo/suppressing.wav',
				'npc/combine_soldier/vo/sweepingin.wav',
				'npc/combine_soldier/vo/stayalert.wav',
				'npc/combine_soldier/vo/stabilizationteamholding.wav',
				'npc/combine_soldier/vo/contact.wav',
				'npc/combine_soldier/vo/contactconfim.wav',
				'npc/combine_soldier/vo/contactconfirmprosecuting.wav',
				'npc/combine_soldier/vo/containmentproceeding.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		},
		[ 'movef' ] = {
			sound = {
				'npc/combine_soldier/vo/fixsightlinesmovein.wav',
				'npc/combine_soldier/vo/goactiveintercept.wav',
				'npc/combine_soldier/vo/gosharp.wav',
				'npc/combine_soldier/vo/gosharpgosharp.wav',
				'npc/combine_soldier/vo/movein.wav',
				'npc/combine_soldier/vo/sweepingin.wav',
				'npc/combine_soldier/vo/targetcompromisedmovein.wav',
				'npc/combine_soldier/vo/targetineffective.wav',
				'npc/combine_soldier/vo/unitismovingin.wav',
				'npc/combine_soldier/vo/closing.wav',
				'npc/combine_soldier/vo/closing2.wav',
				'npc/combine_soldier/vo/bearing.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		},
		[ 'moveb' ] = {
			sound = {
				'npc/combine_soldier/vo/displace.wav',
				'npc/combine_soldier/vo/displace2.wav',
				'npc/combine_soldier/vo/ripcordripcord.wav',
				'npc/combine_soldier/vo/callhotpoint.wav',
				'npc/combine_soldier/vo/sharpzone.wav'
			},
			level = 150,
			channel = CHAN_VOICE
		}
	}
}

function ENT:CombineDropshipContainerExit( ent, vec, ang )
	self:SetPos( vec )
	self:SetAngles( ang )
	local p = self:GetPhysicsObject()
	if IsValid( p ) then
		p:SetPos( vec )
		p:SetAngles( ang )
	end
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self.vPlaySequenceAndWait = vec
	self.aPlaySequenceAndWait = ang
	self:PlaySequenceAndWaitC( 'dropship_deploy', 1, nil, nil, function( self ) self:SetCollisionGroup( COLLISION_GROUP_NPC ) end )
	return self:SequenceDuration( self:LookupSequence( 'dropship_deploy' ) ) - .25
end

function ENT:CHAT_CanMove()
	if !IsValid( self.Enemy ) then return end
	return self:CanExpose()
end
function ENT:CHAT_Move()
	local enemy = self.Enemy
	local v, c = self.vCover, self.bCvrCrouch || false
	local w = self.flCombatState
	local b = true
	if w > 0 then
		self:FindCoverAdvance { flAdvance = w * npc_combine_elite:GetFlt( 'covertocoverrange' ) }
		if self.vCover != v then
			self.flPeek = 0
			self:CHAT( 'Copy that, advancing!' )
			self:EmitSound( 'npc_combine_elite.movef' )
			self.bCvrMove = true
			return true
		end
	else
		self:FindCover( { flDistMin = v:Distance( enemy:GetPos() ) + w * npc_combine_elite:GetFlt( 'covertocoverrange' ) } )
		if self.vCover != v then
			self.flPeek = 0
			self:CHAT( 'Copy that, retreating!' )
			self:EmitSound( 'npc_combine_elite.moveb' )
			self.bCvrMove = true
			return true
		end
	end
end
function ENT:CHAT_MoveForward()
	local enemy = self.Enemy
	local v, c = self.vCover, self.bCvrCrouch || false
	local w = self.flCombatState
	local b = true
	self:FindCoverAdvance { flAdvance = w * npc_combine_elite:GetFlt( 'covertocoverrange' ) }
	if self.vCover != v then
		self.flPeek = 0
		self:CHAT( 'Copy that, advancing!' )
		self:EmitSound( 'npc_combine_elite.movef' )
		self.bCvrMove = true
		return true
	end
end
ENT.CHAT_CanMoveForward = ENT.CHAT_CanMove
function ENT:CHAT_MoveBackward()
	local enemy = self.Enemy
	local v, c = self.vCover, self.bCvrCrouch || false
	local w = self.flCombatState
	local b = true
	self:FindCover( { flDistMin = v:Distance( enemy:GetPos() ) + w * npc_combine_elite:GetFlt( 'covertocoverrange' ) } )
	if self.vCover != v then
		self.flPeek = 0
		self:CHAT( 'Copy that, retreating!' )
		self:EmitSound( 'npc_combine_elite.moveb' )
		self.bCvrMove = true
		return true
	end
end
ENT.CHAT_CanMoveBackward = ENT.CHAT_CanMove

function ENT:FoundEnemy( enemy ) self:EmitSound( 'npc_combine_elite.found' ) end

function ENT:OnActivityChanged( o, n )
	if o == ACT_INVALID || n == ACT_INVALID then return end
	local t = {
		[ self:ActWep( ACT_CROUCHIDLE ) ] = true,
		[ self:ActWep( ACT_WALK_CROUCH ) ] = true,
		[ self:ActWep( ACT_RUN_CROUCH ) ] = true,
	}
	if t[ o ] && !t[ n ] then
		self:AddGestureSequence( self:LookupSequence 'crouch_to_combat_stand' )
		//self:PlaySequenceAndWait( 'crouch_to_combat_stand', 1 )
	elseif t[ n ] && !t[ o ] then
		self:AddGestureSequence( self:LookupSequence 'combat_stand_to_crouch' )
		//self:PlaySequenceAndWait( 'combat_stand_to_crouch', 1 )
	end
end

function ENT:CombatCover() self:NewActivity(self:ActWep((self.bCvrCrouch||self.bCrouchCover)&&ACT_CROUCHIDLE||ACT_IDLE_ANGRY)) end
function ENT:MVCombat()
	if !self:GetMoveTarget() then return end
	local cvar=self:GetMoveTarget():DistToSqr(self:GetPos())<562500&&"prowl"||"run"
	if IsValid(self:GetEnemy())&&self:ShouldRunAway() then cvar="run" end
	//If you read npc_combine_elite then you know why this is bad.
	//(Except cops dont have walking (not walk aiming) animation)
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM /*self:ActWep(cvar=="prowl"&&ACT_WALK_AIM||ACT_RUN_AIM)*/ )
	self.loco:SetDesiredSpeed(npc_combine_elite:GetNum(cvar+"speed"))
	self.loco:SetAcceleration((npc_combine_elite:GetNum(cvar+"speed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
	if #GetVelocity( self ) < 10 then self:NewActivity( ACT_IDLE_ANGRY ) end
end
function ENT:MVCombatCrouch() //NOT Crouching, WITH Crouching!
	if !self:GetMoveTarget() then return end
	local d = self:GetMoveTarget():DistToSqr( self:GetPos() )
	if d < 62500 then
		self:MVCrouchWalk()
	elseif d < 250000 then
		self:MVCrouchRun()
	elseif d < 562500 then
		self:MVProwl()
	else self:MVRun() end
end
function ENT:MVCrouchWalk()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_CROUCHIDLE || ACT_WALK_CROUCH )
	self.loco:SetDesiredSpeed( npc_combine_elite:GetNum( 'walkspeed' ) )
	self.loco:SetAcceleration( npc_combine_elite:GetNum( 'walkspeed' ) * ACCELERATION_NORMAL )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
end
function ENT:MVCrouchRun()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_CROUCHIDLE || ACT_RUN_CROUCH )
	self.loco:SetDesiredSpeed( npc_combine_elite:GetNum( 'prowlspeed' ) )
	self.loco:SetAcceleration( npc_combine_elite:GetNum( 'prowlspeed' ) * ACCELERATION_NORMAL )
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight( 999999 )
	self.loco:SetAvoidAllowed( true )
	self.loco:SetClimbAllowed( false )
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
end
function ENT:MVWalk()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_WALK_AIM )
	self.loco:SetDesiredSpeed(npc_combine_elite:GetNum("walkspeed"))
	self.loco:SetAcceleration((npc_combine_elite:GetNum("walkspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
end
function ENT:MVProwl()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM )
	self.loco:SetDesiredSpeed(npc_combine_elite:GetNum("prowlspeed"))
	self.loco:SetAcceleration((npc_combine_elite:GetNum("prowlspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
end
function ENT:MVRun()
	if !self:GetMoveTarget() then return end
	self:NewActivity( #GetVelocity( self ) < 10 && ACT_IDLE_ANGRY || ACT_RUN_AIM )
	self.loco:SetDesiredSpeed(npc_combine_elite:GetNum("runspeed"))
	self.loco:SetAcceleration((npc_combine_elite:GetNum("runspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	self.loco:SetDeathDropHeight(999999)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self.loco:SetJumpHeight( npc_combine_elite:GetFlt( 'jumpheight' ) )
	self:Advance()
end
function ENT:MVCivil()
	self:NewActivity( self:GetSequenceActivity( self:LookupSequence( 'walkeasy_all' ) ) )
	self.loco:SetDesiredSpeed(npc_combine_elite:GetNum("walkspeed"))
	self.loco:SetAcceleration((npc_combine_elite:GetNum("walkspeed")*ACCELERATION_NORMAL))
	self.loco:SetDeceleration( self.loco:GetAcceleration() )
	//No jumping or climbing when walking!
	self.loco:SetDeathDropHeight(0)
	self.loco:SetJumpHeight(0)
	self.loco:SetAvoidAllowed(yes)
	self.loco:SetClimbAllowed(no)
	self:Advance()
end

function ENT:Init()
	self:SetModel( 'models/combine_super_soldier.mdl' )
	if SERVER then
		self:SetHealth( 600 )
		self:SetMaxHealth( 600 )
		self:DefaultWeapon( 'weapon_ar2' )
	end
	self:SetCollisionBounds( self.vHullMins, self.vHullMaxs )
end

ENT.iClass=CLASS_COMBINE
function ENT:GetRelationship(ent) return (ent.Classify&&ent:Classify()||0)==self:Classify()&&D_LI||D_HT end

function ENT:FoundEnemy(enemy)
	self.bWasSpotted=no
	self:Flank(function()end,3000,no)
end

function ENT:Tick()
	if self.bCvrCrouch then self.bCrouchCover = true
	elseif rand( 300 ) == 1 then self.bCrouchCover = !self.bCrouchCover end
	if rand( self.bCrouchShoot == self.bCrouchCover && 300 || 100 ) == 1 then self.bCrouchShoot = !self.bCrouchShoot end
	if rand( 300 ) == 1 || self.flHordeMovementAdd == 0 then self.flHordeMovementAdd = math.rand( -1, 1 ) end
	self.flFightDist = math.Remap( self:Health(), self:GetMaxHealth(), 0, npc_combine_elite:GetFlt( 'fightrangem' ), npc_combine_elite:GetFlt( 'fightrangen' ) )
end

function ENT:StartPeek()
	/*
	self.flNextPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peekhidelenm' ),
	                                         npc_combine_elite:GetNum( 'peekhidelenn' ) )
	*/
	local t = self:MI_CalcPeek { flDelayMin = npc_combine_elite:GetFlt( 'peeklenm' ), flDelayMax = npc_combine_elite:GetFlt( 'peeklenn' ) }
	if !t || table.IsEmpty( t ) then return end
	if !self:CanExpose( t[ 3 ] ) || !self:CanExpose() then self:FailHide( true ) self:FailPeek() return end
	self.flPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peeklenm' ),
										 npc_combine_elite:GetNum( 'peeklenn' ) )
	self:EmitSound( 'npc_combine_elite.peek' )
	self.tPeek = t
	return t
end

function ENT:FailPeek()
	self.flPeek = 0
	/*
	self.flNextPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peekhidelenm' ),
	                                         npc_combine_elite:GetNum( 'peekhidelenn' ) )
	*/
	self.tPeek = nil
end

function ENT:FailHide( bSilent )
	self.flHide = CurTime() + math.rand( npc_combine_elite:GetFlt( 'exposedhidelenm' ),
										 npc_combine_elite:GetFlt( 'exposedhidelenn' ) )
	if !bSilent then self:CHAT( 'Pinned down!' ) self:EmitSound( 'npc_combine_elite.hide' ) end
end

//ENT.bEnemyClose = false //Very Important Variable That Decides when to Curse

function ENT:CombatBehaviour( enemy )
	self.bMusicActive = nil
	if IsValid( self.Buddy ) then self.Buddy.Buddy = nil self.Buddy = nil end
	self:SetMaxYawSpeed( npc_combine_elite:GetNum( 'turnrate' ) )
	if self:InVehicle() then self.bMusicActive = self:Visible( enemy ) self:VehicleCombat( enemy ) return end
	local c = self.CombineDropshipContainer
	self.vAim = nil
	if IsValid( c ) && c.sOrder == 'LANDED' then
		self.vAim = enemy:GetCenter()
		local bAimShootable = self:IsShootable( self.vAim )
		if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
		self:SetLookAngle( self.vAim )
		self:SetMoveTarget( c:GetPhysicsObject():GetPos() )
		self:ComputePath()
		self:MVRun( !bAimShootable )
		if self:GetPhysicsObject():GetPos():Distance( c:GetPhysicsObject():GetPos() ) < ( ( #self:OBBMins() + #self:OBBMaxs() + #c:OBBMins() + #c:OBBMaxs() ) * .75 ) then c:EnterDropshipContainer( self ) end
		self.bMusicActive = true
		return
	end
	self:MI_CalcCombatState()
	if self.bEnemiesHaveRangeAttack then
		local bAimShootable
		self.bEnemyClose = nil
		if !self:IsScared() && CurTime() > self.flHide && CurTime() <= self.flPeek && istable( self.tPeek ) then
			self.bMusicActive = true
			local t = self.tPeek
			if rand( clamp( math.Remap( self:GetExposedWeight() * self.flExposedHideHealth + ( self:GetMaxHealth() - self:Health() ) + lmax( 0, self.flEnemyDamage - self.flAllyWeight ), 0, self.flExposedHideHealth * self:Health(), npc_combine_elite:GetNum( 'smokechancemax' ), npc_combine_elite:GetNum( 'smokechancemin' ) ), npc_combine_elite:GetNum( 'smokechancemin' ), npc_combine_elite:GetNum( 'smokechancemax' ) ) * FrameTime() ) == 1 then
				local function Handle( enemy )
					if !HasRangeAttack( enemy ) || !self:Visible( enemy ) then return end
					local v = ( enemy:GetCenter() - self:GetPos() ):GetNormalized() * lmin( math.Rand( 0, npc_combine_elite:GetFlt( 'grenthrow' ) ), enemy:GetCenter():Distance( self:GetPos() ) * .5 )
					for _, ent in ipairs( self.tSmokes ) do if ent:IsSmoking( v ) then return end end
					table.insert( t, v )
				end
				Handle( self.Enemy )
				for _, enemy in ipairs( self.tEnemies ) do Handle( enemy ) end
				if !table.IsEmpty( t ) then
					local vec = table.Random( t )
					local d = vec:Distance( self:GetPos() )
					local t = {
						[ self:ActWep( ACT_CROUCHIDLE ) ] = true,
						[ self:ActWep( ACT_WALK_CROUCH ) ] = true,
						[ self:ActWep( ACT_RUN_CROUCH ) ] = true
					}
					if t[ self:GetActivity() ] then self:PlaySequenceAndWaitC( 'crouch_to_combat_stand', 1 ) end
					if d < npc_combine_elite:GetFlt( 'grenplace' ) then
						local t, b = CurTime() + .5
						self:PlaySequenceAndWaitC( 'grenplace', 1, nil, function( self )
							if b then return end
							if CurTime() > t then
								local gren = ents.Create 'gren_combine_smoke'
								gren:SetPos( self:GetBonePosition( self:LookupBone( 'ValveBiped.Anim_Attachment_RH' ) ) )
								gren:Spawn()
								gren:PhysWake()
								gren.GRENADE_TIME = CurTime() + gren:GetPos():Distance( vec ) / npc_combine_elite:GetFlt( 'grenplace' )
								gren.GRENADE_EXCLUDE = self.iClass
								if IsValid( gren:GetPhysicsObject() ) then
									gren:GetPhysicsObject():AddVelocity( CalcThrow( gren:GetPos(), vec, npc_combine_elite:GetFlt( 'grenplace' ) ) )
								end
								table.insert( self.tSmokes, gren )
								for _, ent in ipairs( self:HaveAllies() ) do
									if !ent.__ACTOR__ then continue end
									if !ent.bSmokes then continue end
									table.insert( ent.tSmokes, gren )
								end
								b = true
							end
						end, nil )
					elseif d < npc_combine_elite:GetFlt( 'grenroll' ) then
						local t, b = CurTime() + .5
						self:PlaySequenceAndWaitC( 'grendrop', 1, nil, function( self )
							if b then return end
							if CurTime() > t then
								local gren = ents.Create 'gren_combine_smoke'
								gren:SetPos( self:GetBonePosition( self:LookupBone( 'ValveBiped.Anim_Attachment_RH' ) ) )
								gren:Spawn()
								gren:PhysWake()
								gren.GRENADE_TIME = CurTime() + gren:GetPos():Distance( vec ) / npc_combine_elite:GetFlt( 'grenroll' )
								gren.GRENADE_EXCLUDE = self.iClass
								if IsValid( gren:GetPhysicsObject() ) then
									gren:GetPhysicsObject():AddVelocity( CalcThrow( gren:GetPos(), vec, npc_combine_elite:GetFlt( 'grenroll' ) ) )
								end
								table.insert( self.tSmokes, gren )
								for _, ent in ipairs( self:HaveAllies() ) do
									if !ent.__ACTOR__ then continue end
									if !ent.bSmokes then continue end
									table.insert( ent.tSmokes, gren )
								end
								b = true
							end
						end, nil )
					else
						local t, b = CurTime() + .5
						self:PlaySequenceAndWaitC( 'grenthrow', 1, nil, function( self )
							if b then return end
							if CurTime() > t then
								local gren = ents.Create 'gren_combine_smoke'
								gren:SetPos( self:GetBonePosition( self:LookupBone( 'ValveBiped.Anim_Attachment_RH' ) ) )
								gren:Spawn()
								gren:PhysWake()
								gren.GRENADE_TIME = CurTime() + gren:GetPos():Distance( vec ) / npc_combine_elite:GetFlt( 'grenthrow' )
								gren.GRENADE_EXCLUDE = self.iClass
								if IsValid( gren:GetPhysicsObject() ) then
									gren:GetPhysicsObject():AddVelocity( CalcThrow( gren:GetPos(), vec, npc_combine_elite:GetFlt( 'grenthrow' ) ) )
								end
								table.insert( self.tSmokes, gren )
								for _, ent in ipairs( self:HaveAllies() ) do
									if !ent.__ACTOR__ then continue end
									if !ent.bSmokes then continue end
									table.insert( ent.tSmokes, gren )
								end
								b = true
							end
						end, nil )
					end
				end
			end
			local ent = t[ 1 ]
			if !IsValid( ent ) then self:FailPeek() return end
			if t[ 4 ] then t[ 2 ] = ent:GetPos() end
			local p = t[ 3 ]
			if p == nil then self:FailHide( true ) self:FailPeek() return end
			if !self:CanExpose() then
				self:FailHide()
				self:FailPeek()
				return
			end
			if self:IsShootable( ent:GetCenter() ) then t[ 4 ] = true t[ 2 ] = ent:GetCenter() end
			self.vAim = t[ 4 ] && ent:GetCenter() || t[ 2 ]
			if !self.vAim then self:FailPeek() return end
			bAimShootable = self:IsShootable( self.vAim )
			if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
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
				if bStand && bCrouch then self:NewActivity( self.bCrouchShoot && ACT_CROUCHIDLE || ACT_IDLE_ANGRY ) return
				elseif bStand then self:NewActivity( ACT_IDLE_ANGRY ) return
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
				self.flPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peeklenm' ),
													 npc_combine_elite:GetNum( 'peeklenn' ) )
				if self.bCrouchShoot then
					self:MVCombatCrouch( !bAimShootable )
				else self:MVCombat( !bAimShootable ) end
			end
		else
			self.vAim = enemy:GetCenter()
			bAimShootable = self:IsShootable( self.vAim )
			//if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
			if !self.vCover || self.bCvrMove && !self:CanExpose() then
				if self.bCvrMove then self:CHAT( 'Pinned down!' ) end
				self:FindCover()
				self.bCvrMove = nil
			else
				local v = self.vCover
				local b = true
				local h = self.bCvrCrouch && Vector( 0, 0, self.vHullDuckMaxs.z ) || Vector( 0, 0, self.vHullMaxs.z )
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
				if !b then self:FindCover() self.bCvrMove = nil else self.flNextFindCover = CurTime() + 1 end
			end
			local v = self.vCover
			local b = !self:Visible( enemy )
			if b then
				for _, ent in ipairs( self.tEnemies ) do
					if !IsValid( ent ) then continue end
					if self:Visible( ent ) then b = false end
				end
			end
			if !v then
				self.flNextPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peekhidelenm' ),
														 npc_combine_elite:GetNum( 'peekhidelenn' ) )
				if !self.bEnemyClose || rand( clamp( math.Remap( self:GetPos():Distance( enemy:GetPos() ), 0, m * .5, 10000, 10000 ), 10000, 100000 ) * FrameTime() ) == 1 then self:EmitSound 'npc_combine_elite.hide' self.bEnemyClose = true end
				self:SetLookAngle( self.vAim )
				self:SetMoveTarget( self:FindRunWay( enemy ) )
				self:ComputePath()
				self:MVRun( !bAimShootable )
				self.bMusicActive = self:Visible( enemy )
				self.flCombatState = -1
				return
			end
			if self:GetPos():DistToSqr( v ) < 1000 then
				self.bCvrMove = nil
				if b && !self:IsScared() && CurTime() > self.flNextPeek && self:CanExpose() then
					self.flNextPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peekhidelenm' ),
															 npc_combine_elite:GetNum( 'peekhidelenn' ) )
					local b
					if rand( 2 ) == 1 then b = self:MI_FindCombatMove { flDistance = npc_combine_elite:GetFlt 'covertocoverrange', sMoveForward = 'npc_combine_elite.movef', sMoveBackward = 'npc_combine_elite.moveb' } end
					if !b && self:StartPeek() then b = true end
					if b == nil then self:MI_FindCombatMove { flDistance = npc_combine_elite:GetFlt 'covertocoverrange', sMoveForward = 'npc_combine_elite.movef', sMoveBackward = 'npc_combine_elite.moveb' } end
					return
				else self.tPeek = nil end
				self:CombatCover()
			else
				if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
				self.flNextPeek = CurTime() + math.rand( npc_combine_elite:GetNum( 'peekhidelenm' ),
														 npc_combine_elite:GetNum( 'peekhidelenn' ) )
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
				if self.bCvrMove then
					if bCrouch then self:MVCombatCrouch( !bAimShootable )
					elseif bStand then self:MVCombat( !bAimShootable )
					else self:MVRun( !bAimShootable ) end
				else
					if bCrouch then self:MVCrouchRun()
					else self:MVRun( !bAimShootable ) end
				end
			end
		end
		local v = GetVelocity( self )
		if self.vAim && ( bAimShootable || #v < 10 ) then
			self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
		else
			local ang = v:Angle()
			ang.p = self:GetAngles().p
			self:SetLookAngle( ang )
		end
	elseif self.bEnemiesHaveMeleeAttack then
		local m = lmax( 200, lmax( 200, GetVelocity( enemy ):Length() * 3 ) * GetVelocity( enemy ):GetNormalized():Dot( ( self:GetPos() - enemy:GetPos() ):GetNormalized() ) )
		if lmax( 0, self.flEnemyDamage - self.flAllyWeight ) > self:Health() then
			if lmax( 0, self.flEnemyDamage - self.flAllyWeight ) > self:Health() * 2 then
				if !self.bEnemyClose || rand( clamp( math.Remap( self:GetPos():Distance( enemy:GetPos() ), 0, m * .5, 10000, 10000 ), 10000, 100000 ) * FrameTime() ) == 1 then self:EmitSound 'npc_combine_elite.hide' self.bEnemyClose = true end
				self.vAim = enemy:GetCenter()
				local bAimShootable = self:IsShootable( self.vAim )
				if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
				local v = GetVelocity( self )
				if self.vAim && ( bAimShootable || #v < 10 ) then
					self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
				else
					local ang = v:Angle()
					ang.p = self:GetAngles().p
					self:SetLookAngle( ang )
				end
				self:SetMoveTarget( self:FindRunWay( enemy ) )
				self:ComputePath()
				self:MVRun( !bAimShootable )
				self.bMusicActive = self:Visible( enemy )
				self.flCombatState = -1
			else
				if self:GetPos():Distance( enemy:GetPos() ) < m * .5 then
					if !self.bEnemyClose || rand( clamp( math.Remap( self:GetPos():Distance( enemy:GetPos() ), 0, m * .5, 10000, 10000 ), 10000, 100000 ) * FrameTime() ) == 1 then self:EmitSound 'npc_combine_elite.hide' self.bEnemyClose = true end
					self.vAim = enemy:GetCenter()
					local bAimShootable = self:IsShootable( self.vAim )
					if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
					local v = GetVelocity( self )
					if self.vAim && ( bAimShootable || #v < 10 ) then
						self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
					else
						local ang = v:Angle()
						ang.p = self:GetAngles().p
						self:SetLookAngle( ang )
					end
					self:SetMoveTarget( self:FindRunWay( enemy ) )
					self:ComputePath()
					self:MVRun( !bAimShootable )
					self.bMusicActive = self:Visible( enemy )
					self.flCombatState = -1
				else
					self.bEnemyClose = nil
					self.vAim = enemy:GetCenter()
					local bAimShootable = self:IsShootable( self.vAim )
					if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
					local v = GetVelocity( self )
					if self.vAim && ( bAimShootable || #v < 10 ) then
						self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
					else
						local ang = v:Angle()
						ang.p = self:GetAngles().p
						self:SetLookAngle( ang )
					end
					self:SetMoveTarget( self:FindRunWay( enemy ) )
					self:ComputePath()
					self:MVProwl( !bAimShootable )
					self.bMusicActive = self:Visible( enemy )
					self.flCombatState = 0
				end
			end
			return
		end
		self.flCombatState = 1
		if self:GetPos():Distance( enemy:GetPos() ) < m then
			if self:GetPos():Distance( enemy:GetPos() ) < m * .5 then
				if !self.bEnemyClose || rand( clamp( math.Remap( self:GetPos():Distance( enemy:GetPos() ), 0, m * .5, 10000, 10000 ), 10000, 100000 ) * FrameTime() ) == 1 then self:EmitSound 'npc_combine_elite.hide' self.bEnemyClose = true end
				self.vAim = enemy:GetCenter()
				local bAimShootable = self:IsShootable( self.vAim )
				if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
				local v = GetVelocity( self )
				if self.vAim && ( bAimShootable || #v < 10 ) then
					self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
				else
					local ang = v:Angle()
					ang.p = self:GetAngles().p
					self:SetLookAngle( ang )
				end
				self:SetMoveTarget( self:FindRunWay( enemy ) )
				self:ComputePath()
				self:MVRun( !bAimShootable )
				self.bMusicActive = self:Visible( enemy )
			else
				self.bEnemyClose = nil
				self.vAim = enemy:GetCenter()
				local bAimShootable = self:IsShootable( self.vAim )
				if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
				local v = GetVelocity( self )
				if self.vAim && ( bAimShootable || #v < 10 ) then
					self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
				else
					local ang = v:Angle()
					ang.p = self:GetAngles().p
					self:SetLookAngle( ang )
				end
				self:SetMoveTarget( self:FindRunWay( enemy ) )
				self:ComputePath()
				self:MVProwl( !bAimShootable )
				self.bMusicActive = self:Visible( enemy )
			end
		elseif self:VisibleVec( enemy:GetCenter() ) && self:GetPos():Distance( enemy:GetPos() ) < ( m + 64 ) then
			self.bEnemyClose = nil
			self.vAim = enemy:GetCenter()
			if self:IsShootable( self.vAim ) && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
			self:NewActivity( self.bCrouchShoot && ACT_CROUCHIDLE || ACT_IDLE_ANGRY )
		else
			self.bEnemyClose = nil
			self.vAim = enemy:GetCenter()
			local bAimShootable = self:IsShootable( self.vAim )
			if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
			local v = GetVelocity( self )
			if self.vAim && ( bAimShootable || #v < 10 ) then
				self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
			else
				local ang = v:Angle()
				ang.p = self:GetAngles().p
				self:SetLookAngle( ang )
			end
			self:SetMoveTarget( enemy:GetPos() )
			self:ComputePath()
			self:MVCombat( !bAimShootable )
			self.bMusicActive = self:Visible( enemy )
		end
	else
		self.bEnemyClose = nil
		self.vAim = enemy:GetCenter()
		local bAimShootable = self:IsShootable( self.vAim )
		if bAimShootable && IsInCone( self.vAim, self:EyePos(), self:GetAimVector(), 10, 10 ) then self:FireVolley() end
		local v = GetVelocity( self )
		if self.vAim && ( bAimShootable || #v < 10 ) then
			self:SetLookAngle( ( self.vAim - self:GetShootPos() ):Angle() )
		else
			local ang = v:Angle()
			ang.p = self:GetAngles().p
			self:SetLookAngle( ang )
		end
		self:SetMoveTarget( enemy:GetPos() )
		self:ComputePath()
		self:MVCombat( !bAimShootable )
		self.bMusicActive = self:Visible( enemy )
	end
end

function ENT:AlertBehaviour( vLastAlertPos )
	if IsValid( self.Buddy ) then self.Buddy.Buddy = nil self.Buddy = nil end
	self.flCombatState = 1
	self:SetMaxYawSpeed( npc_combine_elite:GetNum( 'turnrate' ) * .5 )
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

function ENT:CAP_PATROL_BUDDY_ALLOW() return !self:InVehicle() end
function ENT:CAP_PATROL_BUDDY_TEST( ent )
	self:CHAT( 'Of course, ' .. ent:GetClass() .. '!' )
	return true
end
function ENT:CAP_PATROL_BUDDY_ON( ent )
	self.Buddy = ent
	self.bBuddyLead = !ent.bBuddyLead
end
function ENT:CAP_PATROL_BUDDY_SPLIT( ent )
	self:CHAT( 'Of course, ' .. ent:GetClass() .. '!' )
	self.Buddy = nil
	return true
end
function ENT:CAP_PATROL_BUDDY_SWAP( ent )
	self:CHAT( 'Of course, ' .. ent:GetClass() .. '!' )
	self.bBuddyLead = !self.bBuddyLead
	return true
end

local BUDDY_CHANGE_CHANCE = 1500

function ENT:PatrolBehaviour( vPatrolPos )
	self.flCombatState = 1
	self:SetMaxYawSpeed( npc_combine_elite:GetNum( 'turnrate' ) * .5 )
	if self:InVehicle() then
		if !self:ValidVehicle(self:GetVehicle()) then self:ExitVehicle() end

		self:NewActivity(self:ActWep(ACT_IDLE))

		self.loco:SetJumpHeight(0)
		self.loco:SetDeathDropHeight(math.huge)

		self:SetMoveTarget(vLastAlertPos)
		self:ComputePath()

		local cangostraight=yes
		for _,data in ipairs(self.MovePath:GetAllSegments()) do if data.type!=0&&data.type!=1 then cangostraight=no end end

		self:SetVehicleSpeed(.33)
		if cangostraight then self:VehicleMove((vLastAlertPos - self:GetPos()):GetNormalized()) else
		local cgoal=self.MovePath:GetCurrentGoal()
		if cgoal then
			self:VehicleMove(cgoal.pos)
		end end

		return
	end
	if IsValid( self.Buddy ) then
		if !self:CAP_PATROL_BUDDY_ALLOW() || !self.Buddy:CAP_PATROL_BUDDY_ALLOW() then self.Buddy = nil return end
		if self.bBuddyLead then
			if self:GetPos():DistToSqr( self.Buddy:GetPos() ) > 22500 then
				self:NewActivity( ACT_IDLE_ANGRY )
				self:SetLookAngle( nil, self:SweepGun( self:GetForward() ) )
			else
				if math.random( BUDDY_CHANGE_CHANCE ) == 1 then
					self:CHAT( 'I think we should split up, ' .. tostring( self.Buddy:GetClass() ) .. '.' )
					if self.Buddy:CAP_PATROL_BUDDY_SPLIT( self ) then self.Buddy = nil return end
				end
				if math.random( BUDDY_CHANGE_CHANCE ) == 1 then
					local b = !self.bBuddyLead
					self:CHAT( 'I think we should swap, ' .. tostring( self.Buddy:GetClass() ) .. '. ' .. ( b && 'I\'ll' || 'You\'ll' ) .. ' be the lead.' )
					if self.Buddy:CAP_PATROL_BUDDY_SWAP( self ) then self.bBuddyLead = b end
				end
				self:ComputePath( vPatrolPos )
				self:MVWalk()
				local d = self:GetForward()
				local goal = self.MovePath:GetCurrentGoal()
				if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
				self:SetLookAngle( self:SweepGun( d ) )
			end
		else
			local d = self:GetPos():DistToSqr( self.Buddy:GetPos() )
			if d > 10000 then
				self:ComputePath( self.Buddy:GetPos() )
				self:MVProwl()
			else
				if math.random( BUDDY_CHANGE_CHANCE ) == 1 then
					self:CHAT( 'I think we should split up, ' .. tostring( self.Buddy:GetClass() ) .. '.' )
					if self.Buddy:CAP_PATROL_BUDDY_SPLIT( self ) then self.Buddy = nil return end
				end
				self:ComputePath( Trace( {
					start = self.Buddy:GetPos(),
					endpos = self.Buddy:GetPos() - self.Buddy:GetForward() * 50,
					filter = table.add( self:AllRelatedEntities(), self.Buddy:AllRelatedEntities() ),
					mask = MASK_SOLID
				} ).HitPos )
				self:MVWalk()
				self:SetLookAngle( self:SweepGun( -self.Buddy:GetForward() ) )
			end
		end
	else
		self:ComputePath( vPatrolPos )
		self:MVWalk()
		local d = self:GetForward()
		local goal = self.MovePath:GetCurrentGoal()
		if goal then d = ( goal.pos - self:GetPos() ):GetNormalized() end
		self:SetLookAngle( self:SweepGun( d ) )
		if math.random( BUDDY_CHANGE_CHANCE ) == 1 then
			local nb, nbd = nil, 2250000
			for _, ent in ipairs( self:HaveAllies() ) do
				if !IsValid( ent ) || !ent.__ACTOR__ then continue end
				if !ent.tCapabilities[ 'CAP_PATROL_BUDDY' ] || !ent:CAP_PATROL_BUDDY_ALLOW() || IsValid( ent.Buddy ) then continue end
				local d = ent:GetPos():DistToSqr( self:GetPos() )
				if d > nbd then continue end
				nb, nbd = ent, d
			end
			if IsValid( nb ) then
				self.bBuddyLead = rand( 2 ) == 1
				self:CHAT( 'Would you like to come here and help me search, ' .. nb:GetClass() .. '? ' .. ( self.bBuddyLead && 'I\'ll lead the way.' || 'You\'ll lead the way.' ) )
				if nb:CAP_PATROL_BUDDY_TEST( self ) then self.Buddy = nb nb:CAP_PATROL_BUDDY_ON( self ) end
			end
		end
	end
	self.vCover = nil
end

function ENT:IdleBehaviour()
	if IsValid( self.Buddy ) then self.Buddy.Buddy = nil self.Buddy = nil end
	self.flCombatState = 1
	self:SetMaxYawSpeed( npc_combine_elite:GetNum( 'turnrate' ) * .125 )
	if self:InVehicle() then
		if CurTime()>self.VehicleTime||!self:ValidVehicle(self.Vehicle) then self:ExitVehicle() self.VehicleTime=0 end

		self.loco:SetJumpHeight(npc_combine_elite:GetNum("jumpheight"))
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

list.Set( 'NPC', 'CombineElite', {
	Name = '#npc_combine_elite',
	Class = 'npc_combine_elite',
	Category = 'Combine',
	AdminOnly = false
} )

ENT.Class = 'npc_combine_elite' NPC.Register( ENT )