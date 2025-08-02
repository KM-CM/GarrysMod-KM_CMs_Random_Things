function AddMusicSound( Name, Path )
	sound.Add {
		name = 'MUS_' .. Name,
		channel = CHAN_STATIC,
		level = 0,
		sound = 'dmusic/' .. Path
	}
end

AddMusicSound( 'LetsJustGetOutOfHere_StartA', 'combat/letsjustgetoutofhere/starta.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_StartB', 'combat/letsjustgetoutofhere/startb.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Hits1', 'combat/letsjustgetoutofhere/hits/1.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Hits2', 'combat/letsjustgetoutofhere/hits/2.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Hits3', 'combat/letsjustgetoutofhere/hits/3.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Hits4', 'combat/letsjustgetoutofhere/hits/4.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_HitBetween', 'combat/letsjustgetoutofhere/hitbetween.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Magic1', 'combat/letsjustgetoutofhere/magic/1.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Magic2', 'combat/letsjustgetoutofhere/magic/2.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Magic3', 'combat/letsjustgetoutofhere/magic/3.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_Magic4', 'combat/letsjustgetoutofhere/magic/4.wav' )
//Used by EndMagic
AddMusicSound( 'LetsJustGetOutOfHere_MagicFull', 'combat/letsjustgetoutofhere/magic/full.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_EndBuildUp', 'combat/letsjustgetoutofhere/endbuildup.wav' )
//The Intensity is Really High - Build Up from a Part of Start or The HitBetween
AddMusicSound( 'LetsJustGetOutOfHere_EndBuildUpSuffix', 'combat/letsjustgetoutofhere/endbuildupsuffix.wav' )
AddMusicSound( 'LetsJustGetOutOfHere_End', 'combat/letsjustgetoutofhere/end.wav' )

if !SERVER then return end

local CMusicPlayer = {}

debug.getregistry()[ 'MusicPlayer' ] = CMusicPlayer

function CMusicPlayer:IsValid() return IsValid( self.Owner ) end

function CMusicPlayer:UpdateVolumeInternal( flScale )
	self.flVolumeInternal = flScale
	local tSounds = {}
	for Name, Data in pairs( self.tSounds ) do
		if RealTime() > Data[ 3 ] then if !Data[ 4 ] then Data[ 1 ]:Stop() end continue end
		//The Small Amount is Required Because OtherWise It will Stop and RePlay as if CSoundPatch::Stop was Called!
		Data[ 1 ]:ChangeVolume( lmax( .1, Data[ 2 ] * flScale ) )
		tSounds[ Name ] = Data
	end
	self.tSounds = tSounds
end

function CMusicPlayer:Stop() for _, Data in pairs( self.tSounds ) do Data[ 1 ]:Stop() end end

function CMusicPlayer:CreateSound( sIndex, sName, flLength, flVolume, bNoEndStop )
	local ply = self.Owner
	local Filter = RecipientFilter()
	Filter:AddPlayer( ply )
	local Sound = CreateSound( ply, sName, Filter )
	flVolume = tonumber( flVolume ) || 0
	self.tSounds[ sIndex ] = { Sound, flVolume, RealTime() + flLength, bNoEndStop }
	ply.bNextSoundUnHearable = true
	Sound:PlayEx( flVolume * self.flVolumeInternal, 100 )
	return Sound
end

function CMusicPlayer:SetVolume( sTrack, flVolume ) self.tSounds[ sTrack ][ 2 ] = flVolume end
function CMusicPlayer:MoveVolume( sTrack, flVolume, flSpeed ) local t = self.tSounds[ sTrack ] local f = math.Approach( t[ 2 ], flVolume, flSpeed * FrameTime() ) t[ 2 ] = f return f end
function CMusicPlayer:GetVolume( sTrack ) return self.tSounds[ sTrack ][ 2 ] end

function CMusicPlayer:GetIntensity() return self.Owner.GAME_Director_flIntensity || 0 end

function CMusicPlayer:GetLength() return math.Rand( 0, 360 ) end

function CMusicPlayer:Play() ErrorNoHaltWithStack "CMusicPlayer::Play Not Overriden!" end

function MusicPlayer( Player, Data )
	local self = setmetatable( {}, { __index = function( self, Key )
		local v = rawget( Data, Key )
		if v == nil then return rawget( CMusicPlayer, Key )
		else return v end
	end } )
	self.tSounds = {}
	self.flVolumeInternal = 1
	self.Owner = Player
	return self
end

Director_Music_Combat, Director_Music_Search, Director_Music_Alert, Director_Music_Heat = {}

DIRECTOR_STATE_COMBAT = 4
DIRECTOR_STATE_SEARCH = 3
DIRECTOR_STATE_ALERT = 2
DIRECTOR_STATE_HEAT = 1
DIRECTOR_STATE_NULL = 0

function IsActiveForMusic( ent )
	if !IsValid( ent ) then return end
	if ent:IsPlayer() then return ent:KeyDown( IN_ATTACK ) || ent:KeyDown( IN_ATTACK2 ) end
	return ent.bMusicActive
end
hook.Add( 'Think', 'Director', function()

for _, ply in ipairs( player.GetAll() ) do
	ply.GAME_flSuppressionWeight = math.Clamp( ( tonumber( ply.GAME_flSuppressionWeight ) || 0 ) - ply:Health() * .5 * FrameTime(), 0, ply:Health() * 10 )
	if CurTime() > ( ply.GAME_Director_flNextUpdate || 0 ) then
		ply.GAME_Director_flLastCombat = 0
		ply.GAME_Director_flLastSearch = 0
		ply.GAME_Director_flLastAlert = 0
		ply.GAME_Director_flLastHeat = 0
		ply.GAME_Director_flIntensity = clamp( ply.GAME_flSuppressionWeight, 0, ply:Health() * 10, 0, 1 ) * clamp( ply:GetLackingHealth(), 0, 1 )
		local tCombat, tSearch, tAlert, tHeat, flTopCombatHealth, flTopSearchHealth, flTopAlertHealth, flTopHeatHealth = {}, {}, {}, {}, 0, 0, 0, 0
		for _, ent in pairs( NPC.List ) do
			local d = ent:GetPos():Distance( ply:GetPos() )
			if ply:Visible( ent ) then d = 0 end
			if d > 3000 then continue end
			if IsValid( ent.Enemy ) then
				table.insert( tCombat, ent )
				flTopCombatHealth = flTopCombatHealth + ent:Health() * math.Remap( d, 0, 3000, 1, 0 )
			elseif ent.Schedule && ent.Schedule.m_sName == 'SEARCH_AGGRESSIVE' then
				table.insert( tSearch, ent )
				flTopSearchHealth = flTopSearchHealth + ent:Health() * math.Remap( d, 0, 3000, 1, 0 )
			elseif ent:IsAlert() || ent:IsPatrolling() then
				table.insert( tAlert, ent )
				flTopAlertHealth = flTopAlertHealth + ent:Health() * math.Remap( d, 0, 3000, 1, 0 )
			elseif ent:IsHateDisp( ply ) then
				table.insert( tHeat, ent )
				flTopHeatHealth = flTopHeatHealth + ent:Health() * math.Remap( d, 0, 3000, 1, 0 )
			end
		end
		if !table.IsEmpty( tCombat ) then
			for _, ent in ipairs( tCombat ) do
				local d = ent:GetPos():Distance( ply:GetPos() )
				if ply:Visible( ent ) then d = 0 end
				local f = ent:Health() * math.Remap( d, 0, 3000, 1, 0 )
				ply.GAME_Director_flLastCombat = ply.GAME_Director_flLastCombat + f
				if IsActiveForMusic( ent ) then ply.GAME_Director_flIntensity = clamp( ply.GAME_Director_flIntensity + ( f / flTopCombatHealth ) * ( f / ply:Health() * 4 ), 0, 1 ) end
			end
		end
	end
	local flCombat, flSearch, flAlert, flHeat = ply.GAME_Director_flLastCombat || 0, ply.GAME_Director_flLastSearch || 0, ply.GAME_Director_flLastAlert || 0, ply.GAME_Director_flLastHeat || 0
	if flCombat > 0 then
		if ply.GAME_Director_Music_Combat && CurTime() <= ( ply.GAME_Director_Music_Combat_Next || 0 ) then
			ply.GAME_Director_Music_Combat:UpdateVolumeInternal( 1 )
			ply.GAME_Director_Music_Combat:Play()
		else
			local p = MusicPlayer( ply, table.Random( Director_Music_Combat ) )
			ply.GAME_Director_Music_Combat = p
			ply.GAME_Director_Music_Combat_Next = CurTime() + p:GetLength()
		end
		if ply.GAME_Director_Music_Search then ply.GAME_Director_Music_Search:Stop() end ply.GAME_Director_Music_Search = nil
		if ply.GAME_Director_Music_Alert then ply.GAME_Director_Music_Alert:Stop() end ply.GAME_Director_Music_Alert = nil
		if ply.GAME_Director_Music_Heat then ply.GAME_Director_Music_Heat:Stop() end ply.GAME_Director_Music_Heat = nil
	elseif flSearch > 0 then
		if ply.GAME_Director_Music_Combat then ply.GAME_Director_Music_Combat:Stop() end ply.GAME_Director_Music_Combat = nil
		if ply.GAME_Director_Music_Alert then ply.GAME_Director_Music_Alert:Stop() end ply.GAME_Director_Music_Alert = nil
		if ply.GAME_Director_Music_Heat then ply.GAME_Director_Music_Heat:Stop() end ply.GAME_Director_Music_Heat = nil
	elseif flAlert > 0 then
		if ply.GAME_Director_Music_Combat then ply.GAME_Director_Music_Combat:Stop() end ply.GAME_Director_Music_Combat = nil
		if ply.GAME_Director_Music_Search then ply.GAME_Director_Music_Search:Stop() end ply.GAME_Director_Music_Search = nil
		if ply.GAME_Director_Music_Heat then ply.GAME_Director_Music_Heat:Stop() end ply.GAME_Director_Music_Heat = nil
	elseif flHeat > 0 then
		if ply.GAME_Director_Music_Combat then ply.GAME_Director_Music_Combat:Stop() end ply.GAME_Director_Music_Combat = nil
		if ply.GAME_Director_Music_Search then ply.GAME_Director_Music_Search:Stop() end ply.GAME_Director_Music_Search = nil
		if ply.GAME_Director_Music_Alert then ply.GAME_Director_Music_Alert:Stop() end ply.GAME_Director_Music_Alert = nil
	else
		if ply.GAME_Director_Music_Combat then ply.GAME_Director_Music_Combat:Stop() end ply.GAME_Director_Music_Combat = nil
		if ply.GAME_Director_Music_Search then ply.GAME_Director_Music_Search:Stop() end ply.GAME_Director_Music_Search = nil
		if ply.GAME_Director_Music_Alert then ply.GAME_Director_Music_Alert:Stop() end ply.GAME_Director_Music_Alert = nil
		if ply.GAME_Director_Music_Heat then ply.GAME_Director_Music_Heat:Stop() end ply.GAME_Director_Music_Heat = nil
	end
end

end )

hook.Add( 'PostCleanupMap', 'Director', function()
	for _, ply in ipairs( player.GetAll() ) do
		if ply.GAME_Director_Music_Combat then ply.GAME_Director_Music_Combat:Stop() end ply.GAME_Director_Music_Combat = nil
		if ply.GAME_Director_Music_Search then ply.GAME_Director_Music_Search:Stop() end ply.GAME_Director_Music_Search = nil
		if ply.GAME_Director_Music_Alert then ply.GAME_Director_Music_Alert:Stop() end ply.GAME_Director_Music_Alert = nil
		if ply.GAME_Director_Music_Heat then ply.GAME_Director_Music_Heat:Stop() end ply.GAME_Director_Music_Heat = nil
	end
end )

local TABLE = {
	StartA = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if self.tSounds[ 'StartA' ] && ( !self.bSuffix || self.tSounds[ 'EndBuildUpSuffix' ] ) then
				if RealTime() > self.flSuffixDecisionTime && self.bSuffixGoingUp == nil then
					self.bSuffixGoingUp = flIntensity > .5 && rand( math.Remap( flIntensity, 0, .4, 6, 2 ) ) == 1
				else
					if self.bSuffixGoingUp == false then
						self.flLastSuffixVolume = nil
						self:MoveVolume( 'EndBuildUpSuffix', 0, 7 )
					elseif self.bSuffixGoingUp then
						self.flLastSuffixVolume = 1
						self:MoveVolume( 'EndBuildUpSuffix', 1, 7 )
					else
						self.flLastSuffixVolume = self:MoveVolume( 'EndBuildUpSuffix', clamp( flIntensity > .4 && math.Remap( flIntensity, .4, .8, 0, 1 ) || 0, 0, 1 ), 3 )
					end
				end
			else
				self.bStartedPart = nil
				if self.bSuffix && self.flLastSuffixVolume && self.flLastSuffixVolume == 1 then self.sIndex = rand( 3 ) == 1 && 'EndMagic' || 'End' else self.sIndex = 'StartB' end
				self.flLastSuffixVolume = nil
				self.bSuffixGoingUp = nil
				self.bSuffix = nil
			end
		else
			if rand( 2 ) == 1 then self.sIndex = 'StartB' return end
			self.bStartedPart = true
			self.bSuffix = true
			self:CreateSound( 'StartA', 'MUS_LetsJustGetOutOfHere_StartA', 13.714, 1, true )
			local f = flIntensity > .5 && math.Remap( flIntensity, .5, 1, 0, 1 ) || 0
			self:CreateSound( 'EndBuildUpSuffix', 'MUS_LetsJustGetOutOfHere_EndBuildUpSuffix', 13.69, f, true )
			self.flSuffixDecisionTime = RealTime() + 10.709
			self.flLastSuffixVolume = f
		end
	end,
	StartB = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if self.tSounds[ 'StartB' ] && ( !self.bSuffix || self.tSounds[ 'EndBuildUpSuffix' ] ) then
				if RealTime() > self.flSuffixDecisionTime then
					if self.bSuffixGoingUp == nil then self.bSuffixGoingUp = flIntensity > .4 && rand( math.Remap( flIntensity, 0, .4, 6, 2 ) ) == 1 end
				else
					if self.bSuffixGoingUp == false then
						self.flLastSuffixVolume = nil
						self:MoveVolume( 'EndBuildUpSuffix', 0, 7 )
					elseif self.bSuffixGoingUp then
						self.flLastSuffixVolume = 1
						self:MoveVolume( 'EndBuildUpSuffix', 1, 7 )
					else
						self.flLastSuffixVolume = self:MoveVolume( 'EndBuildUpSuffix', clamp( 0, 1, flIntensity > .4 && math.Remap( flIntensity, .4, .6, 0, 1 ) || 0 ), 3 )
					end
				end
			else
				self.bStartedPart = nil
				if self.bSuffix && self.flLastSuffixVolume && self.flLastSuffixVolume == 1 then self.sIndex = rand( 3 ) == 1 && 'EndMagic' || 'End' else self.sIndex = 'Hits' end
				self.flLastSuffixVolume = nil
				self.bSuffixGoingUp = nil
				self.bSuffix = nil
			end
		else
			self.bStartedPart = true
			self.bSuffix = true
			self:CreateSound( 'StartB', 'MUS_LetsJustGetOutOfHere_StartB', 13.714, 1, true )
			local f = flIntensity > .5 && math.Remap( flIntensity, .5, 1, 0, 1 ) || 0
			self:CreateSound( 'EndBuildUpSuffix', 'MUS_LetsJustGetOutOfHere_EndBuildUpSuffix', 13.69, f, true )
			self.flSuffixDecisionTime = RealTime() + 10.709
			self.flLastSuffixVolume = f
		end
	end,
	Hits = function( self, Owner, flIntensity )
		if !self.iMinHits || !self.iMaxHits then
			self.iMinHits = rand( 0, 1 )
			self.iMaxHits = rand( 1, 8 )
			if self.iMinHits > self.iMaxHits then
				local max, min = self.iMinHits, self.iMaxHits
				self.iMinHits = min
				self.iMaxHits = max
			end
		end
		if self.tSounds[ 'Hits' ] then return end
		if !self.tUseHits then self.tUseHits = { [ 1.715 ] = '1', [ 1.713 ] = '2', [ 1.7151 ] = '3', [ 1.7131 ] = '4' } end
		local i = self.iHits || 0
		if i <= self.iMinHits then
			if table.Count( self.tUseHits ) <= 0 then self.tUseHits = { [ 1.715 ] = '1', [ 1.713 ] = '2', [ 1.7151 ] = '3', [ 1.7131 ] = '4' } end
			local v, k = table.Random( self.tUseHits )
			table.remove( self.tUseHits, k )
			self:CreateSound( 'Hits', 'MUS_LetsJustGetOutOfHere_Hits' .. v, k, 1, true )
			self.iHits = i + 1
		else
			if i > self.iMaxHits || rand( clamp( math.Remap( flIntensity, 0, .4, 2, 6 ), 2, 6 ) ) == 1 then self.iMinHits = nil self.iMaxHits = nil self.iHits = nil self.tUseHits = nil self.sIndex = 'HitBetween' return end
			if table.Count( self.tUseHits ) <= 0 then self.tUseHits = { '1', '2', '3', '4' } end
			local v, k = table.Random( self.tUseHits )
			table.remove( self.tUseHits, k )
			self:CreateSound( 'Hits', 'MUS_LetsJustGetOutOfHere_Hits' .. v, k, 1, true )
			self.iHits = i + 1
		end
	end,
	HitBetween = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if self.tSounds[ 'HitBetween' ] && ( !self.bSuffix || self.tSounds[ 'EndBuildUpSuffix' ] ) then
				if RealTime() > self.flSuffixDecisionTime && self.bSuffixGoingUp == nil then
					self.bSuffixGoingUp = flIntensity > .5 && rand( math.Remap( flIntensity, 0, .4, 6, 2 ) ) == 1
				else
					if self.bSuffixGoingUp == false then
						self.flLastSuffixVolume = nil
						self:MoveVolume( 'EndBuildUpSuffix', 0, 7 )
					elseif self.bSuffixGoingUp then
						self.flLastSuffixVolume = 1
						self:MoveVolume( 'EndBuildUpSuffix', 1, 7 )
					else
						self.flLastSuffixVolume = self:MoveVolume( 'EndBuildUpSuffix', clamp( flIntensity > .4 && math.Remap( flIntensity, .4, .8, 0, 1 ) || 0, 0, 1 ), 3 )
					end
				end
			else
				self.bStartedPart = nil
				if self.bSuffix && self.flLastSuffixVolume && self.flLastSuffixVolume == 1 then self.sIndex = rand( 3 ) == 1 && 'End' || 'EndMagic' else self.sIndex = 'Magic' end
				self.flLastSuffixVolume = nil
				self.bSuffixGoingUp = nil
				self.bSuffix = nil
			end
		else
			if rand( 2 ) == 1 then self.sIndex = 'Magic' return end
			self.bStartedPart = true
			self.bSuffix = true
			self:CreateSound( 'HitBetween', 'MUS_LetsJustGetOutOfHere_HitBetween', 13.707, 1, true )
			local f = flIntensity > .5 && math.Remap( flIntensity, .5, 1, 0, 1 ) || 0
			self:CreateSound( 'EndBuildUpSuffix', 'MUS_LetsJustGetOutOfHere_EndBuildUpSuffix', 13.69, f, true )
			self.flSuffixDecisionTime = RealTime() + 10.709
			self.flLastSuffixVolume = f
		end
	end,
	Magic = function( self, Owner, flIntensity )
		if !self.iMinHits || !self.iMaxHits then
			self.iMinHits = rand( 0, 1 )
			self.iMaxHits = rand( 1, 8 )
			if self.iMinHits > self.iMaxHits then
				local max, min = self.iMinHits, self.iMaxHits
				self.iMinHits = min
				self.iMaxHits = max
			end
		end
		if self.tSounds[ 'Magic' ] then return end
		if !self.tUseHits then self.tUseHits = { [ 1.715 ] = '1', [ 1.713 ] = '2', [ 1.7151 ] = '3', [ 1.7131 ] = '4' } end
		local i = self.iHits || 0
		if i <= self.iMinHits then
			if table.Count( self.tUseHits ) <= 0 then self.tUseHits = { '1', '2', '3', '4' } end
			local v, k = table.Random( self.tUseHits )
			table.remove( self.tUseHits, k )
			self:CreateSound( 'Magic', 'MUS_LetsJustGetOutOfHere_Magic' .. v, k, 1, true )
			self.iHits = i + 1
		else
			if i > self.iMaxHits || rand( clamp( math.Remap( flIntensity, 0, .4, 2, 6 ), 2, 6 ) ) == 1 then self.iMinHits = nil self.iMaxHits = nil self.iHits = nil self.tUseHits = nil self.sIndex = 'EndBuildUp' return end
			if table.Count( self.tUseHits ) <= 0 then self.tUseHits = { '1', '2', '3', '4' } end
			local v, k = table.Random( self.tUseHits )
			table.remove( self.tUseHits, k )
			self:CreateSound( 'Magic', 'MUS_LetsJustGetOutOfHere_Magic' .. v, k, 1, true )
			self.iHits = i + 1
		end
	end,
	EndBuildUp = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if RealTime() > ( self.flRestartTime || 0 ) then
				self.bStartedPart = nil
				self.sIndex = 'End'
			end
		else
			self.bStartedPart = true
			self:CreateSound( 'EndBuildUp', 'MUS_LetsJustGetOutOfHere_EndBuildUp', 13.707, 1 )
			self.flRestartTime = RealTime() + 46.29
		end
	end,
	End = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if RealTime() > ( self.flRestartTime || 0 ) then
				self.bStartedPart = nil
				self.sIndex = 'StartA'
			end
		else
			self.bStartedPart = true
			self:CreateSound( 'End', 'MUS_LetsJustGetOutOfHere_End', 53.652, 1 )
			self.flRestartTime = RealTime() + 46.29
		end
	end,
	EndMagic = function( self, Owner, flIntensity )
		if self.bStartedPart then
			if RealTime() > ( self.flRestartTime || 0 ) then
				self.bStartedPart = nil
				self.sIndex = 'StartA'
			end
		else
			self.bStartedPart = true
			self:CreateSound( 'End', 'MUS_LetsJustGetOutOfHere_End', 53.652, 1 )
			self:CreateSound( 'EndMagic', 'MUS_LetsJustGetOutOfHere_MagicFull', 6.872, 1 )
			self.flRestartTime = RealTime() + 46.29
		end
	end
}

Director_Music_Combat[ 'LetsJustGetOutOfHere' ] = {
	Play = function( self )
		local Owner, flIntensity = self.Owner, self:GetIntensity()
		if !self.sIndex then self.sIndex = table.Random { 'StartA', 'StartB', 'Hits', 'End', 'EndMagic' } end
		TABLE[ self.sIndex ]( self, Owner, flIntensity ) 
	end
}