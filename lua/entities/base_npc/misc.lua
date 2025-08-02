function ENT:DeathMessage(dmginfo) if dmginfo then hook.Run("OnNPCKilled",self,dmginfo:GetAttacker(),dmginfo:GetInflictor()) end end

local function StringToCode( s )
	return '"' .. ( s:gsub( '"', '\\"' ):gsub( '\n', '\\n' ):gsub( '\r', '\\r' ):gsub( '\t', '\\t' ) ) .. '"'
end

function ENT:CHAT( msg )
    local t = {}
    local l = #msg
    for i = 1, l, 200 do
        table.insert( t, StringToCode( string.sub( msg, i, math.min( i + 200 - 1, l ) ) ) )
    end
	for _, ply in ipairs( self:HaveAllies() ) do
		if !ply:IsPlayer() then continue end
		ply:SendLua( '_C=language.GetPhrase("' .. self:GetClass() .. '")..": "' )
		for _, p in ipairs( t ) do ply:SendLua( '_C=_C..' .. p ) end
		ply:SendLua( 'chat.AddText(_C)_C=nil' )
	end
end

function ENT:CHAT_PRINT_TO( dest, msg )
	if !dest:IsPlayer() then return end
    local t = {}
    local l = #msg
    for i = 1, l, 200 do
        table.insert( t, StringToCode( string.sub( msg, i, math.min( i + 200 - 1, l ) ) ) )
    end
	dest:SendLua( '_C=language.GetPhrase("' .. self:GetClass() .. '")..": "' )
	for _, p in ipairs( t ) do dest:SendLua( '_C=_C..' .. p ) end
	dest:SendLua( 'chat.AddText(_C)_C=nil' )
end

function ENT:CHAT_ORDER( msg, tok )
	local tkc = 'CHAT_Can' + tok
	tok = 'CHAT_' + tok
	self:CHAT( msg )
	local b
	for _, ent in ipairs( self:HaveAllies() ) do
		if !ent.__ACTOR__ || rand( ORDER_NOT_ALL_IGNORE_CHANCE ) == 1 then continue end
		if ent == self then b = true continue end
		local v = ent[ tkc ]
		if isfunction( v ) && v( ent ) then ent[ tok ]( ent ) end
	end
	return b
end

function ENT:CHAT_ORDER_CUSTOM( msg, fun )
	local b
	for _, ent in ipairs( self:HaveAllies() ) do
		if !ent.__ACTOR__ || rand( ORDER_NOT_ALL_IGNORE_CHANCE ) == 1 then continue end
		if ent == self then b = true continue end
		fun( ent, self )
	end
	return b
end

function ENT:CHAT_ORDER_ALL( msg, tok )
	local tkc = 'CHAT_Can' + tok
	tok = 'CHAT_' + tok
	self:CHAT( msg )
	for _, ent in ipairs( self:HaveAllies() ) do
		if !ent.__ACTOR__ then continue end
		local v = ent[ tkc ]
		if isfunction( v ) && v( ent ) then ent[ tok ]( ent ) end
	end
	return true
end

function ENT:CHAT_ORDER_ALL_CUSTOM( msg, tok )
	for _, ent in ipairs( self:HaveAllies() ) do
		if !ent.__ACTOR__ then continue end
		if ent == self then b = true continue end
		fun( ent, self )
	end
	return true
end

function ENT:GetWeaponHandle()
	local wep = self:GetActiveWeapon()
	if !IsValid( wep ) then return {} end
	if istable( wep.tHandle ) then return wep.tHandle end
	return { [ wep:GetHoldType() ] = true }
end

function ENT:HasWeaponHandle( x )
	local wep = self:GetActiveWeapon()
	if !IsValid( wep ) then return false end
	if istable( wep.tHandle ) then return wep.tHandle[ x ] end
	return wep:GetHoldType() == x
end

ENT.tBullseyes = {}

function ENT:RemoveBullseyes()
	for _, ent in pairs( self.tBullseyes ) do if IsValid( ent ) then ent:Remove() end end
	self.tBullseyes = {}
end

function ENT:AlertedByEntity( ent, vPos, bNoBullseye )
	if !bNoBullseye && CurTime() < self.flHighAlert then self:CreateBullseyeFromEntity( ent, vPos ) return end
	if !IsValid( ent ) then return end
	if !vPos then vPos = ent:GetCenter() end
	if !self.vLastAlertPos || vPos:DistToSqr( self:GetPos() ) < self.vLastAlertPos:DistToSqr( self:GetPos() ) then self.vLastAlertPos = vPos end
	self.flLastSeenEnemy = 0
	self:Alert()
	self.bPatrolling = no
	self.vLastAlertPos = vPos
	self.tEnemiesLastSeen[ ent:EntIndex() ] = CurTime()
	if !bNoBullseye then
		local b = self.tBullseyes[ ent ]
		if IsValid( b ) then
			b:SetPos( vPos )
			b:SetAng( GetAimVector( ent ):Angle() )
		end
	end
end

function ENT:CreateBullseyeFromEntity( enemy, pos )
	if !IsValid( enemy ) then return end
	self.flLastSeenEnemy = 0
	self.bPatrolling = false
	local ent = enemy.__ACTOR__Bullseye && enemy.Enemy || enemy
	local beye = self.tBullseyes[ ent ]
	if !IsValid( beye ) then
		beye = ents.Create 'info_target'
		self.tBullseyes[ ent ] = beye
		beye.Enemy = ent
		beye:SetPos( pos || enemy:GetCenter() )
		beye:SetAng( GetAimVector( enemy ):Angle() )
		beye:SetHealth( enemy:Health() )
		beye:SetMaxHealth( enemy:GetMaxHealth() )
		beye:Spawn()
	else
		beye.Enemy = ent
		beye:SetPos( pos || enemy:GetCenter() )
		beye:SetAng( GetAimVector( enemy ):Angle() )
		beye:SetHealth( enemy:Health() )
		beye:SetMaxHealth( enemy:GetMaxHealth() )
	end
	if HasRangeAttack( enemy ) then
		beye.HAS_RANGE_ATTACK = true
		beye.HAS_NOT_RANGE_ATTACK = nil
	else
		beye.HAS_RANGE_ATTACK = nil
		beye.HAS_NOT_RANGE_ATTACK = true
	end
	if HasMeleeAttack( enemy ) then
		beye.HAS_MELEE_ATTACK = true
		beye.HAS_NOT_MELEE_ATTACK = nil
	else
		beye.HAS_MELEE_ATTACK = nil
		beye.HAS_NOT_MELEE_ATTACK = nil
	end
	beye.__ACTOR__Bullseye = true //Update This Just in Case
	beye.GAME_OBBMins = enemy.GAME_OBBMins || enemy:OBBMins()
	beye.GAME_OBBMaxs = enemy.GAME_OBBMaxs || enemy:OBBMaxs()
	if enemy.GAME_HullZ then beye.GAME_HullZ = enemy.GAME_HullZ
	elseif enemy.GetHull then beye.GAME_HullZ = enemy:GetHull().z
	else beye.GAME_HullZ = enemy:OBBMaxs().z end
	if enemy.GAME_HullDuckZ then beye.GAME_HullDuckZ = enemy.GAME_HullDuckZ
	elseif enemy.GetHullDuck then beye.GAME_HullDuckZ = enemy:GetHullDuck().z
	else beye.GAME_HullDuckZ = enemy:OBBMaxs().z end
	self.flHighAlert = CurTime() + math.rand( unpack( self.HighAlertTimes ) )
	return beye
end

/*////////////////////////////////////////////////////////
Entity ENT:CreateNPC( String Class = self:GetClass() )

Creates an NPC and properly sets up the relationships.
The new NPC will consider us its friend,
And will have the same relationships as us.

WARNING: THIS DOES NOT SPAWN THE NEW NPC! ONLY CREATE IT!

RETURN: The new NPC. Or Null if we failed.
////////////////////////////////////////////////////////*/
function ENT:CreateNPC(Class)
	local ent=ents.Create(Class&&tostring(Class)||self:GetClass())
	if !IsValid(ent) then return null end
	ent.SpecialRelationships=table.Merge({},self.SpecialRelationships)
	ent.SpecialRelationships[self]=D_LI
	self.SpecialRelationships[ent]=D_LI
	ent.iClass=self.iClass
	return ent
end

function ENT:CopyAlert( Other )
	if !Other.__ACTOR__ then return False end
	self.flAlertUntil = Other.flAlertUntil
	self.vLastAlertPos = Other.vLastAlertPos
	for _, ent in pairs( Other.tEnemies ) do self:CreateBullseyeFromEntity( ent ) end
	for _, ent in pairs( Other.tBullseyes ) do self:CreateBullseyeFromEntity( ent ) end
	self.flLastSeenEnemy = 0
	return True
end

ENT.iCurAct=ACT_INVALID
function ENT:NewActivity(iAct,bRestart)
	if self.bPlaySequenceAndWait then return end
	if IsValid(self.Weapon) then iAct=self:ActWep(iAct) end //Handy. Just handy.
	if self:GetActivity()!=iAct||bRestart then
		local r=self:OnActivityChanged(self:GetActivity(),iAct)
		if !r then self.iCurAct=r self:StartActivity(iAct) end
	end
end

//These were moved to here because they're technically aliases and are miscellaneous
function ENT:IsCombat() return IsValid( self.Enemy ) end
function ENT:IsAlert() return CurTime() < self.flAlertUntil && !self.bPatrolling end
function ENT:IsPatrolling() return CurTime() < self.flAlertUntil && self.bPatrolling end
function ENT:IsIdle() return !IsValid( self.Enemy ) && CurTime() > self.flAlertUntil end

Enum( "NPC_STATUS", {
	"NONE",
	"IDLE",
	"ALERT",
	"SCARED",
	"HUNTING",
	"STEALTH",
	"COMBAT",
} )
function ENT:GetStatus(bIgnoreAIState)
	if !bIgnoreAIState&&!self:AllowRunBehaviour() then return NPC_STATUS_NONE end
	if IsValid(self.Enemy) then
		if self:IsPlayingCatAndMouse() then
			return NPC_STATUS_HUNTING
		else
			return self:ShouldRunAway()&&NPC_STATUS_COMBAT||NPC_STATUS_SCARED
		end
	elseif self:IsAlert()||self:IsPatrolling() then
		return NPC_STATUS_ALERT
	else
		return NPC_STATUS_IDLE
	end
	return NPC_STATUS_NONE
end

ENT.vHullMins = Vector( 0, 0, 0 )
ENT.vHullMaxs = Vector( 0, 0, 0 )
function ENT:SetHull( vMins, vMaxs ) self.vHullMins = vMins self.vHullMaxs = vMaxs end
function ENT:GetHull() return self.vHullMins, self.vHullMaxs end

ENT.vHullDuckMins = Vector( 0, 0, 0 )
ENT.vHullDuckMaxs = Vector( 0, 0, 0 )
function ENT:SetHullDuck( vMins, vMaxs ) self.vHullDuckMins = vMins self.vHullDuckMaxs = vMaxs end
function ENT:GetHullDuck() return self.vHullDuckMins, self.vHullDuckMaxs end
