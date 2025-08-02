////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// SHARED CODE HERE ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
local function _FindNearbyNPCs( ply )
	local t = {}
	local d = sqr( ply.GAME_flTalkDistance || 2000 )
	for _, ent in pairs( NPC.List ) do
		if ent:GetPos():DistToSqr( ply:GetPos() ) > d then continue end
		if ent:Disposition( ply ) != D_LI then continue end
		table.insert( t, ent )
	end
	return t
end

ORDER_NOT_ALL_IGNORE_CHANCE = 3

hook.Add( 'PlayerSay', 'GameImprovements', function( ply, txt )
	if !IsValid( ply ) then return end
	timer.Simple( .1, function()
	if !IsValid( ply ) then return end

	local t = {}
	for w in txt:lower():gsub( '[^a-z ]', '' ):gmatch( '%S+' ) do t[ w ] = true end
	if t[ 'move' ] ||
	   t[ 'moving' ] ||
	   t[ 'back' ] ||
	   t[ 'advance' ] ||
	   t[ 'retreat' ] ||
	   ( t[ 'get' ] ||
		 t[ 'there' ] ||
		 t[ 'in' ] ) then
		if t[ 'back' ] || t[ 'backward' ] || t[ 'retreat' ] then
			if t[ 'everyone' ] then
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMoveBackward && ent:CHAT_CanMoveBackward() then
						ent:CHAT_MoveBackward( ply )
					end
				end
			else
				local n = {}
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMoveBackward && ent:CHAT_CanMoveBackward() then
						table.insert( n, ent )
					end
				end
				for _, ent in ipairs( n ) do
					if rand( ORDER_NOT_ALL_IGNORE_CHANCE ) == 1 then continue end
					ent:CHAT_MoveBackward( ply )
				end
			end
		elseif t[ 'in' ] || t[ 'forward' ] || t[ 'advance' ]  then
			if t[ 'everyone' ] then
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMoveForward && ent:CHAT_CanMoveForward() then
						ent:CHAT_MoveForward( ply )
					end
				end
			else
				local n = {}
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMoveForward && ent:CHAT_CanMoveForward() then
						table.insert( n, ent )
					end
				end
				for _, ent in ipairs( n ) do
					if rand( ORDER_NOT_ALL_IGNORE_CHANCE ) == 1 then continue end
					ent:CHAT_MoveForward( ply )
				end
			end
		else
			if t[ 'everyone' ] then
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMove && ent:CHAT_CanMove() then
						ent:CHAT_Move( ply )
					end
				end
			else
				local n = {}
				for _, ent in ipairs( _FindNearbyNPCs( ply ) ) do
					if ent.CHAT_CanMove && ent:CHAT_CanMove() then
						table.insert( n, ent )
					end
				end
				for _, ent in ipairs( n ) do
					if rand( ORDER_NOT_ALL_IGNORE_CHANCE ) == 1 then continue end
					ent:CHAT_Move( ply )
				end
			end
		end
	end

	end )
end )
hook.Add("PhysgunPickup",'GameImprovements',function() return yes end)
hook.Add("OnPhysgunFreeze",'GameImprovements',function() return yes end)
hook.Add("PlayerDeath",'GameImprovements',function(ply)
	pcall(function()ply:DropWeapon()end)
end)
hook.Add("PlayerDeathSound",'GameImprovements',function() return true end)
hook.Add("PlayerFootstep",'GameImprovements',function(p)return p:Crouching()end)
hook.Add("PlayerCanPickupWeapon",'GameImprovements',function(ply,ent)
	local dirtowep=(ent:GetPos()-ply:EyePos()):GetNormalized():Angle()
	local wants=ply:KeyDown(IN_USE)&&math.abs(math.AngleDifference(dirtowep.p,ply:EyeAngles().p))<=22.5&&math.abs(math.AngleDifference(dirtowep.y,ply:EyeAngles().y))<=22.5
	if wants then timer.Simple(0.1,function() if IsValid(ply)&&IsValid(ent) then ply:SelectWeapon(ent:GetClass()) end end) end
	if CurTime()<(ent.GAME_CreatedTime||999999) then wants=yes end
	return wants
end)
hook.Add("PlayerCanPickupItem",'GameImprovements',function(ply,ent)
	local dirtoitem=(ent:GetPos()-ply:EyePos()):GetNormalized():Angle()
	local wants=ply:KeyDown(IN_USE)&&math.abs(math.AngleDifference(dirtoitem.p,ply:EyeAngles().p))<=22.5&&math.abs(math.AngleDifference(dirtoitem.y,ply:EyeAngles().y))<=22.5
	if CurTime()<(ent.GAME_CreatedTime||999999) then wants=yes end
	return wants
end)
hook.Add( 'PlayerCanSeePlayersChat', 'GameImprovements', function( _, _, ply, talker )
	if !IsValid( talker ) then return true end
	return ply:GetPos():DistToSqr( talker:GetPos() ) < sqr( talker.GAME_flTalkDistance || 2000 )
end )
hook.Add( 'PlayerCanHearPlayersVoice', 'GameImprovements', function( ply, talker )
	local b = ply:GetPos():DistToSqr( talker:GetPos() ) < sqr( talker.GAME_flTalkDistance || 2000 )
	return b, b
end )

////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// SERVER CODE HERE ///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
if !SERVER then return end

RunConsoleCommand( 'sv_gravity', '800' )
RunConsoleCommand( 'sv_noclipaccelerate', '15' )
RunConsoleCommand( 'sv_noclipspeed', '15' )
RunConsoleCommand( 'sv_friction', '2' )
ACCELERATION_NORMAL = 2
RunConsoleCommand( 'sv_accelerate', ACCELERATION_NORMAL * math.max( 1, GetConVarNumber 'sv_friction' ) )
RunConsoleCommand( 'sv_airaccelerate', '0' )
RunConsoleCommand( 'physcannon_maxmass', '500' )
RunConsoleCommand( 'sv_alltalk', '1' )
RunConsoleCommand( 'rope_smooth', '1' )
RunConsoleCommand( 'rope_wind_dist', '999999' )
RunConsoleCommand( 'rope_subdiv', '999999' )

RunConsoleCommand( 'sk_helicopter_roundsperburst', '6' )
RunConsoleCommand( 'sk_helicopter_firingcone', '10' )
RunConsoleCommand( 'sk_helicopter_burstcount', '9' )
RunConsoleCommand( 'sk_npc_dmg_helicopter', '30' )
RunConsoleCommand( 'sk_npc_dmg_helicopter_to_plr', '30' )
RunConsoleCommand( 'g_helicopter_idletime', '0' )

physenv.SetPerformanceSettings {
	MaxVelocity = 100000,
	MaxAngularVelocity = 100000
}

hook.Add( 'ShouldCollide', 'GameImprovements', function( A, B )
	if A == B:GetParent() || B == A:GetParent() then return false end
	return true
end )

local ents = ents
local function ClearRelateds( ent )
	//Since an update long ago, string concatenation can be done via +, and is equalent to self/string..tostring(other),
	//But this file was there even longer, and I mean FAR LONGER, and wasnt updated here, but now I did an update. (29.09.2024,V143)
	//(Also adding "||{}" after ents.FindByName is extremely stupid, howd I even think of that??)
	//for _,ent1 in ipairs(ents.FindByName("pt_"+tostring(ent:GetClass())+"_"+tostring(ent:EntIndex()))||{}) do if IsValid(ent1) then ent1:Remove() end end
	//for _,ent1 in ipairs(ents.FindByName("pc_"+tostring(ent:GetClass())+"_"+tostring(ent:EntIndex()))||{}) do if IsValid(ent1) then ent1:Remove() end end
	for _,ent1 in ipairs(ents.FindByName("pt_"+ent:GetClass()+"_"+ent:EntIndex())) do if IsValid(ent1) then ent1:Remove() end end
	for _,ent1 in ipairs(ents.FindByName("pc_"+ent:GetClass()+"_"+ent:EntIndex())) do if IsValid(ent1) then ent1:Remove() end end
end
hook.Add("EntityRemoved",'GameImprovements',function(ent) ClearRelateds(ent) end)

function DispatchRangeAttackInfo( vStart, vEnd, Owner, flDamage )
	if IsValid( Owner ) then
		for _, ent in ipairs( ents.FindAlongRay( vStart, vEnd, Vector( -1024, -1024, -1024 ), Vector( 1024, 1024, 1024 ) ) ) do
			if ent == Owner || ent.Disposition && ent:Disposition( Owner ) == D_LI then continue end
			local w = ent.GAME_flSuppressionWeight
			if w then ent.GAME_flSuppressionWeight = w + flDamage end
		end
	else
		for _, ent in ipairs( ents.FindAlongRay( vStart, vEnd, Vector( -1024, -1024, -1024 ), Vector( 1024, 1024, 1024 ) ) ) do
			local w = ent.GAME_flSuppressionWeight
			if w then ent.GAME_flSuppressionWeight = w + flDamage end
		end
	end
end
hook.Add( 'EntityFireBullets', 'GameImprovements', function( ent, data )
	local main = IsValid( data.Attacker ) && data.Attacker || ent
	data.Tracer=math.clamp(data.Tracer||1,0,1)
	if !IsValid(data.Attacker) then data.Attacker=void end
	local at=data.AmmoType
	if data.AmmoType!=""&&data.Damage==0 then data.Damage=game.GetAmmoPlayerDamage(game.GetAmmoID(data.AmmoType)) end
	//We use "ent" instead of "data" because of engine limitations....
	if !ent.ShootColor then ent.ShootColor = '255 25 0 750' end
	local col = ent.ShootColor
	if !ent.DisableFlash then
		for i = 1, data.Num do
			local dir = data.Dir:GetSpread( data.Spread )
			local pt=ents.Create( 'env_projectedtexture' )
			pt:SetPos( data.Src )
			pt:SetAngles( dir:Angle() )
			pt:SetKeyValue( 'lightfov', '110' )
			pt:SetKeyValue( 'lightcolor', col )
			pt:SetKeyValue( 'spritedisabled', '1' )
			pt:SetKeyValue( 'distance', '150' )
			pt:Input( 'SpotlightTexture', _, _, 'effects/flashlight/soft' )
			pt:Spawn()
			timer.Simple( tonumber( ent.MFlashTime ) || .05, function() if IsValid( pt ) then pt:Remove() end end )
		end
		local ed = EffectData()
		ed:SetEntity( ent )
		ed:SetAttachment( 1 )
		ed:SetFlags( ent.MFlashFlags || 1 )
		util.Effect( ent.MFlash || 'MuzzleFlash', ed )
	end
	if !ent.DisableRecoil then pcall( function()
		main:DoRecoilEffect( tonumber( ent.RecoilStrength ) || clamp( data.Damage * data.Num * .25, 1, 33 ) )
	end ) end
	local OldCallBack = data.Callback || function() return { effects = true, damage = true } end
	data.Callback = function( self, tr, dmg )
		local t = OldCallBack( self, tr, dmg )
		if tr.Hit then DispatchRangeAttackInfo( tr.StartPos, tr.HitPos, main, data.Damage ) end
		//if tr.Hit && IsValid( tr.Entity ) && !tr.Entity:IsEnvironment() then t.effects = false end
		return t
	end
	return true
end )

ENT_BREAKFX={}
function ENT_BREAKFX_DEFAULT(self,dmg)
	if !self.OBBMins || !self.OBBMaxs || !self.GetModelScale ||
	   !self:OBBMins() || !self:OBBMaxs() || !self:GetModelScale() then self:Remove() return end
	if self:IsVehicle()&&self:GetClass()!="prop_vehicle_prisoner_pod" then
		local ec=rand(2,4)
		for i=1,ec do
			local e=ents.Create("env_explosion")
			local maxs=self:OBBMaxs()
			local mins=self:OBBMins()
			e:SetPos(self:GetRandomPoint())
			e:SetKeyValue("magnitude",tostring(self:GetSize()/ec))
			e:Spawn()
			e:Fire("Explode")
		end
	else
		local c=rand(3,6)
		for i=1,c do
			local prop=ents.Create("prop_physics")
			prop:SetModel(table.Random(self:GetMaterialType()==MAT_WOOD&&{
				"models/props_debris/wood_chunk04a.mdl",
				"models/props_debris/wood_chunk04b.mdl",
				"models/props_debris/wood_chunk04c.mdl",
				"models/props_debris/wood_chunk04d.mdl",
				"models/props_debris/wood_chunk04e.mdl",
				"models/props_debris/wood_chunk04f.mdl",
			}||{
				"models/props_lab/filecabinet02.mdl",
				"models/props_c17/oildrum001.mdl",
				"models/props_junk/metal_paintcan001a.mdl",
			}))
			prop:SetAngles(AngleRand())
			prop:SetPos(self:GetRandomPoint())
			prop:SetOwner(self)
			prop:SetMaterial(#self:GetMaterial()>0&&self:GetMaterial()||table.Random(self:GetMaterials()))
			prop:SetModelScale((self:GetSize()*self:GetModelScale()/(prop:GetSize()*c)))
			prop:SetColor(self:GetColor())
			prop.bDontBreak=yes
			prop:Spawn()
			prop:Activate()
			prop:GetPhysicsObject():AddVelocity((GetVelocity(self)+dmg:GetDamageForce():GetSpread(Vector(0.5,0.5,0.5))*dmg:GetDamageForce():Length()))
			timer.Simple(math.rand(2,4),function() if IsValid(prop) then prop:Remove() end end)
		end
	end
	self:Remove()
end

DMG_BLUNT, DMG_HIT = DMG_CLUB, DMG_CLUB
DMG_BURN, DMG_SLOWBURN = 268435464, 268435464 //When an entity burns, DMG_BURN/DMG_SLOWBURN doesnt work!

hook.Add( 'OnNPCKilled', 'GameImprovements', function( self, attacker, inflictor )
	self.DEAD_ATTACKER = attacker
	self.DEAD_INFLICTOR = inflictor
	ClearRelateds( self )
end )

hook.Add( 'CreateEntityRagdoll', 'GameImprovements', function( self, rag )
	if self:IsOnFire() then rag:Ignite( 5 ) end
	rag.DEAD = true
	rag.DEAD_INFLICTOR = self.DEAD_INFLICTOR
	local at = self.DEAD_ATTACKER
	rag.DEAD_ATTACKER = at
	if IsValid( at ) then
		if at.Classify then
			rag.DEAD_DISCOVERED_CLASS = { [ at:Classify() ] = true }
			rag.DEAD_ATTACKER_CLASS = at:Classify()
		end
		rag.DEAD_DISCOVERED_ENTITY = { [ at ] = true }
	end
	rag.DEAD_HEALTH = abs( self:GetMaxHealth() )
end )

DAMAGE_MULTIPLIER_MIN, DAMAGE_MULTIPLIER_MAX = 4, 5

hook.Add( 'EntityTakeDamage', 'GameImprovements', function( ent, dmg )
	local r = pcall_ret( function() return dmg:GetAttacker():OnHurtSomething( ent, dmg ) end)
	if r == true then return true end
	if ent.GAME_God then return true end
	dmg:ScaleDamage( math.rand( DAMAGE_MULTIPLIER_MIN, DAMAGE_MULTIPLIER_MAX ) )
	if dmg:GetDamagePosition() == Vector( 0, 0, 0 ) then dmg:SetDamagePosition( IsValid( dmg:GetAttacker() ) && dmg:GetAttacker():GetCenter() || ( ent:GetPos() + ent:OBBCenter() ) ) end
	if CurTime() < ( ent.GAME_FireImmunity || 0 ) && dmg:IsDamageType( DMG_BURN ) then ent:Extinguish() return true end
	if dmg:IsDamageType( DMG_BLAST ) then ent:Ignite( 5 ) end
	if ent:IsPlayer() && !ent:HasGodMode() then
		ent:ViewPunch( AngleRand() * dmg:GetDamage() * .0001 )
		local l = math.min( 5, dmg:GetDamage() * .01 )
		ent:ScreenFade( SCREENFADE.IN, ent.HurtColor || Color( 255, 0, 0, 255 ), l * 2, l )
	end
	ent.GAME_LastTakeDamage = CurTime()
	ent.GAME_LastDamageInfo = dmg
	local d = dmg:GetDamage()
	for _, Other in pairs( NPC.List ) do
		if Other:Disposition( ent ) == D_LI && Other:CanSee( ent ) then
			Other.flEnemyDamage = Other.flEnemyDamage + d
		end
	end
	if ent:IsBreakable() && !ent.GAME_Dead then
		if pcall_ret( function() return ent:Damaged( dmg ) end ) == true then return true end
		ent:SetHealth( ent:Health() - dmg:GetDamage() )
		if ent:Health() <= 0 then
			if ent:GetClass() != 'prop_physics' || ( ent.OBBMins && ent.OBBMaxs && ent.GetModelScale && ent:GetSize() > 64 ) then
				local f = ent.GAME_BreakFX
				if !isfunction( f ) then f=ENT_BREAKFX[ ent:GetModel() ] end
				if !isfunction( f ) then f=ENT_BREAKFX_DEFAULT end
				local s, e = pcall( function() f( ent, dmg ) end )
				if !s then print( "Error in ", tostring( ent ), "'s break function!:\n" + e ) end
			else ent:Remove() end
			//OLD! Was used when the explode/crush was same for everything and did this automatically.
			//ent:Remove()
			//return
			ent.GAME_Dead = true
		end
	end
end )

hook.Add("PlayerSwitchFlashlight",'GameImprovements',function(ply,IsOn)
	if !IsValid(ply:GetWeapon("weapon_flashlight")) then return no end
	ply:EmitSound(IsOn&&"player.flashlight.on"||"player.flashlight.off")
	if !IsValid(ply.GAME_Flashlight) then
		//Goals to make it not only realistic, but also as uncomfortable(in a creepy way, not battery way) as possible.
		local pt=ents.Create("env_projectedtexture")
		pt:SetParent(ply)
		pt:SetKeyValue("lightfov","60")
		pt:SetKeyValue("lightcolor","255 255 255 500")
		pt:SetKeyValue("NearZ","1")
		pt:SetKeyValue("FarZ","1500")
		pt:Input("SpotlightTexture",void,void,"effects/flashlight001")
		pt:Spawn()
		ply.GAME_Flashlight=pt
	else ply.GAME_Flashlight:Remove() end
	return no
end)

ENT_CLASSMODS={
	["func_button"]=function(ent) if !(ent:HasSpawnFlags(512)&&ent:HasSpawnFlags(1024)) then ent:AddSpawnFlags(bit.bor(512,1024)) end end,
	["func_rot_button"]=function(ent) if !(ent:HasSpawnFlags(512)&&ent:HasSpawnFlags(1024)) then ent:AddSpawnFlags(bit.bor(512,1024)) end end,
	["env_fire_trail"]=function(ent)
		ent.GAME_DontIgnite=yes
		ent:Extinguish()
		if CurTime()>(ent.GAME_FireSpreadCheck||0) then for _,ent1 in ipairs(ents.GetAll()) do
			if ent1:GetPos():DistToSqr(ent:GetPos())<10000&&ent1:CanIgnite() then
				ent1:Ignite(5)
			end
		end ent.GAME_FireSpreadCheck=CurTime()+math.rand(0.2,0.4) end
		if ent:WaterLevel()!=0 then ent:Remove() end
	end,
	["env_flare"]=function(ent)
		ent.GAME_DontIgnite=yes
		ent:Extinguish()
		if CurTime()>(ent.GAME_FireSpreadCheck||0) then for _,ent1 in ipairs(ents.GetAll()) do
			if ent1:GetPos():DistToSqr(ent:GetPos())<10000&&ent1:CanIgnite() then
				ent1:Ignite(5)
			end
		end ent.GAME_FireSpreadCheck=CurTime()+math.rand(0.2,0.4) end
		if ent:WaterLevel()!=0 then ent:Remove() end
	end,
	["bullseye_strider_focus"]=function(ent) ent:AddFlags(FL_NOTARGET) end
}
local navmesh = navmesh
hook.Add( 'Think', 'GameImprovements', function()
	local all = ents.GetAll()
	if navmesh.IsGenerating() then
		for _,ent in ipairs( all ) do if !ent:IsPlayer() then pcall( function() ent:Remove() end ) end end
		return //Dont Forget to STOP!
	end
	//Wind & Graphics stuff. See Graphics.lua.
	local fnd=ents.FindByClass("env_tonemap_controller")
	if !IsValid(fnd[1]) then ents.Create("env_tonemap_controller"):Spawn() end
	for _,ent in ipairs(fnd) do
		//DISABLED! As I said, see Graphics.lua for a better version of HDR.
		ent:Fire("SetBloomScale","0")
		ent:Fire("SetTonemapRate","1")
		ent:Fire("SetAutoExposureMin","1")
		ent:Fire("SetAutoExposureMax","1")
	end
	local fnd=ents.FindByClass("env_wind")
	if !IsValid(fnd[1]) then fnd[ 1 ] = ents.Create("env_wind") fnd[ 1 ]:Spawn() end
	if IsValid(fnd[2]) then fnd[2]:Remove() end
	for _,ent in ipairs(fnd) do
		if !ent.GAME_Strength||rand(500)==1 then ent.GAME_Strength=rand(10,100) end
		if !ent.GAME_Dir||rand(100)==1 then ent.GAME_Dir=rand(0,360) end
		ent:Fire("SetWindDir",tostring(ent.GAME_Dir))
		
		for _,ent1 in ipairs(ents.FindByClass("env_smokestack")) do
			ent1:SetKeyValue("WindAngle","0 "+ent.GAME_Dir+" 0")
			ent1:SetKeyValue("WindSpeed",ent.GAME_Strength)
		end
		
		if rand(75)==1 then
			Entity(0):EmitSound(Sound("ambient/wind/wind_med"+rand(1,2)+".wav"),0,100,ent.GAME_Strength*.0025,CHAN_STATIC)
		end if ent.GAME_Strength>50&&rand(75)==1 then
			Entity(0):EmitSound(Sound("ambient/wind/windgust.wav"),0,100,ent.GAME_Strength*.005,CHAN_STATIC)
		end
		ent:SetKeyValue("minwind",tostring(ent.GAME_Strength*.25))
		ent:SetKeyValue("maxwind",tostring(ent.GAME_Strength*.25))
		
		ent:SetKeyValue("mingust","0")
		ent:SetKeyValue("maxgust","0")
		ent:SetKeyValue("mingustdelay","999999")
		ent:SetKeyValue("maxgustdelay","999999")
		ent:SetKeyValue("gustduration","0")
	end
	////////////////////////
	for _,ent in ipairs(all) do
		local hp,mhp,cl=ent:Health(),ent:GetMaxHealth(),ent:GetClass()
		if hp<mhp&&hp>0&&ent:CanRegenerate() then
			ent:SetHealth(lmin(hp+(ent.GAME_RegenStrength||ent:GetMaxHealth()*0.01),mhp))
			ent.GAME_NextRegen=CurTime()+(ent.GAME_RegenRate||0.25)
		end
		
		ent:SetPersistent(ent:MapCreationID()==-1&&(ent:IsWeapon()&&!IsValid(ent:GetOwner())||!ent:IsWeapon()))

		if ent.DEAD_DISCOVERED_ENTITY then
			local t = {}
			for Other in pairs( ent.DEAD_DISCOVERED_ENTITY ) do
				if IsValid( Other ) then t[ Other ] = true end
			end
			ent.DEAD_DISCOVERED_ENTITY = t
		end
		
		//Vehicle stuff.
		if ent:IsVehicle() then
			if !ent.MaxPower then ent.MaxPower=240 end
			if !ent.Power then ent.Power=ent.MaxPower end
			if IsValid(ent:GetDriver()) then
				if ent:IsEngineStarted() then
					if !IsValid(ent.GAME_FuelPercentSprite) then
						local spr=ents.Create("env_sprite")
						spr:SetKeyValue("model","sprites/glow1.spr")
						spr:SetKeyValue("rendermode","9")
						local power=(ent.Power||240)/(ent.MaxPower||240)
						local r,g,b
						if power<=0.5 then
							r=255
							g=math.map(power,0,0.5,0,255)
							b=0
						else
							r=math.map(power,0.5,1,255,0)
							g=255
							b=0
						end
						spr:Fire("ColorRedValue",r)
						spr:Fire("ColorGreenValue",g)
						spr:Fire("ColorBlueValue",b)
						spr:SetKeyValue("scale",tostring((power+0.0000000001)/2))
						spr:SetPos((ent:GetPassengerSeatPoint(1)+ent:GetForward()*10+ent:GetUp()*50))
						spr:SetParent(ent) spr:SetOwner(ent)
						spr:Spawn()
						ent.GAME_FuelPercentSprite=spr
					else
						local spr=ent.GAME_FuelPercentSprite
						local power=(ent.Power||240)/(ent.MaxPower||240)
						local r,g,b
						if power<=0.5 then
							r=255
							g=math.map(power,0,0.5,0,255)
							b=0
						else
							r=math.map(power,0.5,1,255,0)
							g=255
							b=0
						end
						spr:Fire("ColorRedValue",r)
						spr:Fire("ColorGreenValue",g)
						spr:Fire("ColorBlueValue",b)
						spr:SetKeyValue("scale",tostring((power+0.0000000001)/2))
					end
					if ent:GetThrottle()==0 then
						ent.Power=(ent.Power||240)-(ent.IdlePowerConsumption||0.0066)
					else
						ent.Power=(ent.Power||240)-(ent.ActivePowerConsumption||0.033)
					end
					if (ent.Power||240)<=0 then ent:StartEngine(no) end
				else if ent.AllowIdleRegen then ent.Power=math.min(ent.Power||240+(ent.PowerRegen||0.025),ent.MaxPower||240) end end
			else
				ent.Power=math.min(ent.Power+(ent.PowerRegen||0.015),ent.MaxPower||240)
				if IsValid(ent.GAME_FuelPercentSprite) then ent.GAME_FuelPercentSprite:Remove() end
				if (ent.Power||240)<1 then ent:StartEngine(no) end
				if !ent.GAME_WheelSmokes then ent.GAME_WheelSmokes={} end
				for i=0,ent:GetWheelCount()-1 do
					local wheel=ent:GetWheel(i)
					wheel:EnableCollisions(yes)
					local vel=wheel:GetVelocity()
					local lvel=vel:Length()
					if lvel<100 then
						if IsValid(ent.GAME_WheelSmokes[i]) then
							local smoke=ent.GAME_WheelSmokes[i]
							smoke:Fire("TurnOff")
							timer.Simple(2.5,function() if IsValid(smoke) then smoke:Remove() end end)
						end
					end
				end
			end
		elseif ent:IsPlayer() then
			if !ent.GAME_FLPower then ent.GAME_FLPower=100 end
			if IsValid(ent.GAME_Flashlight) then
				ent.GAME_Flashlight:SetKeyValue("lightcolor","255 255 255 "..ent.GAME_FLPower*5)//+(ent.GAME_FLPower/100)*255) :: This is old TwT
				ent.GAME_FLPower=ent.GAME_FLPower-FrameTime()
				if ent.GAME_FLPower<=0||!ent:Alive()||!IsValid(ent:GetWeapon("weapon_flashlight")) then ent.GAME_Flashlight:Remove() end
				ent.GAME_Flashlight:SetPos(ent:GetShootPos())
				ent.GAME_Flashlight:SetAngles(ent:GetAimVector():Angle())
			else ent.GAME_FLPower=math.min((ent.GAME_FLPower||100)+FrameTime()*5,100) end
		end
		if !ent.GAME_PhysColHook then
			ent:AddCallback( 'PhysicsCollide', function( self, Data )
				local Other = Data.HitEntity
				if !IsValid( Other ) then return end
				if CurTime() > ( Other.GAME_FireImmunity || 0 ) && self:IsOnFire() then
					Other:Ignite( 1e8 )
				elseif CurTime() > ( self.GAME_FireImmunity || 0 ) && Other:IsOnFire() then
					self:Ignite( 1e8 )
				end
			end )
			ent.GAME_PhysColHook = True
		end
		if ent:CanIgnite() && rand( ent:GetSize() * 10 ) != 1 then
			if ent:IsOnFire() then
				ent:Ignite( 1e8 )
				if rand(lmax(20000/ent:GetSize(),50))==1 then
					local p=ents.Create("prop_physics")
					p:SetPos(ent:GetRandomPoint())
					p:SetCollisionGroup(COLLISION_GROUP_WORLD)
					p:SetModel("models/combine_helicopter/helicopter_bomb01.mdl")
					p:SetNoDraw(yes)
					p.bDontBreak=yes
					p.GAME_DontIgnite = true
					p:Spawn()
					p:GodEnable()
					local f=ents.Create("env_fire_trail")
					f:SetPos(p:GetPos())
					f:SetParent(p)
					f:Spawn()
					f.GAME_DontIgnite = true
					p:GetPhysicsObject():AddVelocity((VectorRand()*ent:GetSize()*rand(1,6)))
					p:AddThink(function(self) if rand(GetFlameStopChance(self)*FrameTime())==1||self:WaterLevel()!=0 then self:Remove() end end)
					p:EmitSound("fire.igniteshort")
				end
			elseif IsValid( ent.GAME_FireSmoke ) then ent.GAME_FireSmoke:Remove() end
		else
			ent:Extinguish()
			if IsValid( ent.GAME_FireSmoke ) then ent.GAME_FireSmoke:Remove() end
		end
		if ENT_CLASSMODS[ cl ] then pcall( function() ENT_CLASSMODS[ cl ]( ent ) end ) end
	end
end)

/*////////////////////////////////////////////////////////
Void GM:EntityEmitSound( Table Data )

Allows NPCs to Hear Sounds.

Force-Sets an Appropriate Decibel Volume.
////////////////////////////////////////////////////////*/
ALLOWED_DECIBEL_VOLUMES = { 0, 20, 25, 30, 35, 40, 45, 50, 55, 60, 60, 65, 70, 75, 80, 85, 90, 95, 100, 105, 110, 120, 130, 140, 150 }
hook.Add( 'EntityEmitSound', 'GameImprovements', function( data, _Comp )
	if _Comp then return end
	hook.Run( 'EntityEmitSound', data, true )
	//CreateSound Doesnt Call This. Nor Do We Need It After I Implemented The Flag Below.
	//if data.SoundName:match( 'dmusic/.*$' ) then return true end
	if data.Entity.bNextSoundUnHearable then data.Entity.bNextSoundUnHearable = nil return true end
	local ns, nsd = void, math.huge
	for _, snd in ipairs( ALLOWED_DECIBEL_VOLUMES ) do if math.abs( snd - data.SoundLevel ) < nsd then ns, nsd = snd, math.abs( snd - data.SoundLevel ) end end
	if ns then data.SoundLevel = ns end
	data.Pitch = data.Pitch * game.GetActTimeScale()
	if data.Entity:GetClass() != 'worldspawn' then
		local tent,oent = GetOwner( data.Entity ), data.Entity
		if !IsValid( tent ) || !IsValid( oent ) then return true end
		local d = DBToDistance( data.SoundLevel )
		for _, ent in ipairs( ents.GetAll() ) do
			if ent != oent && ent != tent && ent:GetPos():Distance( tent:GetPos() ) < d * ( ent.GAME_HearDistMul || 1 ) then
				pcall( function() ent:OnHeardSomething( tent, data ) end )
			end
		end
	end
	return true
end)

ENT_FORCEBREAKHEALTH={ prop_door_rotating = 50 }
ENT_REMOVECLASS={
	env_fog_controller = true,
	gmod_hands = true
}
hook.Add("OnEntityCreated",'GameImprovements',function(ent)timer.Simple(0.1,function()pcall(function()
	if ent:IsNextBot()&&navmesh.GetNavAreaCount()<1 then ent:Remove() return end
	if ENT_REMOVECLASS [ent:GetClass() ] then ent:Remove() return end
	if ent:IsBreakable()&&ent:OBBMaxs()&&ent:GetModelScale() then
		local v = ENT_FORCEBREAKHEALTH[ ent:GetClass() ]
		if isnumber( v ) then
			ent:SetMaxHealth( v )
			ent:SetHealth( v )
		else
			ent:SetMaxHealth(((ent:OBBMaxs():Length()+ent:OBBMins():Length())*ent:GetModelScale()*20))
			ent:SetHealth(((ent:OBBMaxs():Length()+ent:OBBMins():Length())*ent:GetModelScale()*20))
		end
	end
	if ent:GetMaxHealth()!=0 then ent.GAME_StartHealth=ent:GetMaxHealth() else ent.GAME_StartHealth=ent:Health() ent:SetMaxHealth(ent:Health()) end //Use VERY rarely,usually Entity:GetMaxHealth() is MUCH better!
	ent.GAME_CreatedTime=CurTime()
	ent.GAME_LastTakeDamage=0
	ent.GAME_LastBullet=0
	ent.GAME_LastDamageInfo=nil
end)end)end)