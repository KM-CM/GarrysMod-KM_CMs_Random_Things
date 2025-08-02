/*
You should Probably Know What You're Doing.
*/

local CActorBehaviour = {}

function CActorBehaviour:Initialize() end

//Dont Return Anything to Let The Entity's Default Behaviour Run
function CActorBehaviour:SelectSchedule( self, ent, prev, ret ) end

function CActorBehaviour:IsValidParticipant( ent )
	if ent:IsPlayer() then
		return ent.GAME_Behaviour == nil
	elseif ent.__ACTOR__ then
		return ent.BEHAVIOUR == nil
	end
end

function CActorBehaviour:GatherParticipants( tParticipants ) end

function CActorBehaviour:AddParticipant( ent )
	self.m_tParticipants[ ent:EntIndex() ] = ent
	if ent:IsPlayer() then ent.GAME_Behaviour = self else ent.BEHAVIOUR = self end
end

function CActorBehaviour:RemoveParticipant( ent )
	self.m_tParticipants[ ent:EntIndex() ] = nil
	if ent:IsPlayer() then ent.GAME_Behaviour = nil else ent.BEHAVIOUR = nil ent.Schedule = nil end
end

function CActorBehaviour:GetParticipants() return self.m_tParticipants end

local __BEHAVIOUR__ = {}

NPC.__BEHAVIOUR__ = __BEHAVIOUR__

function NPC.BEHAVIOUR( Name, Class ) __BEHAVIOUR__[ Name ] = Class end

_ActorBehaviours = _ActorBehaviours || {}

function NPC.ActorBehaviour( Class )
	local c = __BEHAVIOUR__[ Class ]
	if !c then return end
	local c = setmetatable( c, { __index = function( self, Key )
		local v = rawget( self, Key )
		if v == nil then return CActorBehaviour[ Key ]
		else return v end
	end } )
	c.m_tParticipants = {}
	c:Initialize()
	_ActorBehaviours[ c ] = true
	return c
end
ENT.C_ActorBehaviour = NPC.ActorBehaviour

function CActorBehaviour:Remove()
	for _, ent in pairs( self.m_tParticipants ) do
		if IsValid( ent ) then
			if ent:IsPlayer() then ent.GAME_Behaviour = nil else ent.BEHAVIOUR = nil ent.Schedule = nil end
		end
	end
	_ActorBehaviours[ self ] = nil
end

function CActorBehaviour:Finish()
	for _, ent in pairs( self.m_tParticipants ) do
		if IsValid( ent ) then
			if ent:IsPlayer() then ent.GAME_Behaviour = nil else ent.BEHAVIOUR = nil end
		end
	end
	_ActorBehaviours[ self ] = nil
end

hook.Add( 'Think', 'ActorBehaviour', function() for beh in pairs( _ActorBehaviours ) do beh:Tick() end end )
hook.Add( 'PostCleanUpMap', 'ActorBehaviour', function() for beh in pairs( _ActorBehaviours ) do beh:Remove() end end )

RegisterMetaTable( 'ActorBehaviour', CActorBehaviour )
