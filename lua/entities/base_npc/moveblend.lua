/*
This is a HUGE Pain in The Ass to Make, But It Looks VERY Cool.
VALVe Calls This Blended Movement, But I Thought That was Lame,
so I Called It The MoveBlendMotor.

Always Use The Moving Sequence as The Primary.
Always Use The Not Moving Sequence as The Secondary.
*/

local CActorMoveBlendMotor = {}
CActorMoveBlendMotor.__index = CActorMoveBlendMotor

function CActorMoveBlendMotor:Initialize()
	self.m_flRate = 4
	self.m_iPrimarySequence = -1
	self.m_iSecondarySequence = -1
	self.m_flRatio = 0
	self.m_flRatioTarget = 0
	local owner = self.Owner
	self.m_iPrimaryLayer = owner:AddGestureSequence( -1, false )
	owner:SetLayerPlaybackRate( self.m_iPrimaryLayer, 0 )
	owner:SetLayerCycle( self.m_iPrimaryLayer, 0 )
	owner:SetLayerWeight( self.m_iPrimaryLayer, 0 )
	owner:SetLayerLooping( self.m_iPrimaryLayer, true )
	self.m_iSecondaryLayer = owner:AddGestureSequence( -1, false )
	owner:SetLayerPlaybackRate( self.m_iSecondaryLayer, 0 )
	owner:SetLayerCycle( self.m_iSecondaryLayer, 0 )
	owner:SetLayerWeight( self.m_iSecondaryLayer, 0 )
	owner:SetLayerLooping( self.m_iSecondaryLayer, true )
end

function CActorMoveBlendMotor:Think()
	local owner = self.Owner
	if !IsValid( owner ) then return end
	if owner:GetLayerSequence( self.m_iPrimaryLayer ) != self.m_iPrimarySequence then owner:SetLayerSequence( self.m_iPrimaryLayer, self.m_iPrimarySequence ) end
	if owner:GetLayerSequence( self.m_iSecondaryLayer ) != self.m_iSecondarySequence then owner:SetLayerSequence( self.m_iSecondaryLayer, self.m_iSecondarySequence ) end
	if self.m_iSecondarySequence == -1 then
		local m_iPrimaryLayer = self.m_iPrimaryLayer
		self.m_flRatio = 0
		self.m_flRatioTarget = 0
		owner:SetLayerWeight( m_iPrimaryLayer, 1 )
		local spd = owner:GetSequenceGroundSpeed( self.m_iPrimarySequence )
		//If It Doesnt Move, Dont Bother
		if spd == 0 then owner:SetLayerPlaybackRate( m_iPrimaryLayer, 1 ) return end
		owner:SetLayerPlaybackRate( m_iPrimaryLayer, #GetVelocity( owner ) / spd )
	else
		if self.m_iPrimarySequence == -1 then
			local m_iSecondaryLayer = self.m_iSecondaryLayer
			self.m_flRatio = 1
			self.m_flRatioTarget = 1
			owner:SetLayerWeight( m_iSecondaryLayer, 1 )
			local spd = owner:GetSequenceGroundSpeed( self.m_iSecondarySequence )
			if spd == 0 then owner:SetLayerPlaybackRate( m_iSecondaryLayer, 1 ) return end
			owner:SetLayerPlaybackRate( m_iSecondaryLayer, #GetVelocity( owner ) / spd )
			return
		end
		self.m_flRatio = math.Approach( self.m_flRatio, self.m_flRatioTarget, self.m_flRate * FrameTime() )
		local m_iPrimaryLayer, m_iSecondaryLayer = self.m_iPrimaryLayer, self.m_iSecondaryLayer
		local spd = owner:GetSequenceGroundSpeed( self.m_iPrimarySequence )
		if spd == 0 then owner:SetLayerPlaybackRate( m_iPrimaryLayer, 1 )
		else owner:SetLayerPlaybackRate( m_iPrimaryLayer, #GetVelocity( owner ) / spd ) end
		owner:SetLayerWeight( m_iPrimaryLayer, 1 - self.m_flRatio )
		local spd = owner:GetSequenceGroundSpeed( self.m_iSecondarySequence )
		if spd == 0 then owner:SetLayerPlaybackRate( m_iSecondaryLayer, 1 )
		else owner:SetLayerPlaybackRate( m_iSecondaryLayer, #GetVelocity( owner ) / spd ) end
		owner:SetLayerWeight( m_iSecondaryLayer, self.m_flRatio )
	end
end

function CActorMoveBlendMotor:SetRatioTarget( f ) self.m_flRatioTarget = f end
function CActorMoveBlendMotor:GetRatioTarget() return self.m_flRatioTarget end

function CActorMoveBlendMotor:SetPrimarySequence( i ) self.m_iPrimarySequence = i end
function CActorMoveBlendMotor:SetSecondarySequence( i ) self.m_iSecondarySequence = i end

function CActorMoveBlendMotor:GetPrimarySequence() return self.m_iPrimarySequence end
function CActorMoveBlendMotor:GetSecondarySequence() return self.m_iSecondarySequence end

function NPC.ActorMoveBlendMotor( Actor )
	if !IsValid( Actor ) then ErrorNoHaltWithStack "Dude, We Need an Actor for This" return end
	if Actor.MoveBlendMotor then return Actor.MoveBlendMotor end
	local self = setmetatable( {}, CActorMoveBlendMotor )
	self.Owner = Actor
	Actor.MoveBlendMotor = self
	self:Initialize()
	return self
end
ENT.CreateMoveBlendMotor = NPC.ActorMoveBlendMotor

RegisterMetaTable( 'ActorMoveBlendMotor', CActorMoveBlendMotor )
