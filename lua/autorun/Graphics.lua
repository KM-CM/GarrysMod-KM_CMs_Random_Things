///////////// THIS FILE INCLUDES ALMOST ALL CLIENT SCRIPTS, NOT ONLY GRAPHIC-RELATED ONES /////////////

function GetDayNightCycle() return CurTime() % 1000 * .001 end
function GetDNCBrightness( dnc ) dnc = dnc || GetDayNightCycle() return clamp( dnc <= .5 && math.Remap( dnc, 0, .5, -.66, .66 ) || math.Remap( dnc, .5, 1, .66, -.66 ), -.66, 0 ) end
function GetActDNCBrightness( dnc ) return 1 + GetDNCBrightness( dnc ) end
function ColorStabilizeDivider( dnc )
	local x = GetActDNCBrightness( dnc )
	if x < 1 then
		return 1 / math.Remap( x, 1, 0, 1, 100 )
	else
		return x
	end
end

hook.Add( 'AdjustMouseSensitivity', 'Graphics', function() return lmin( LocalPlayer():GetFOV() * .01111111111, 1 ) end )

if SERVER then
	/*////////////////////////////////////////////////////////
	This might look stupid, but it does a very, VERY VERY VERY important thing!
	You see, to get the g_* entity editing to work, you need to cleanup map.
		[ 08.08.2024, 19:02 ]
	////////////////////////////////////////////////////////*/
	hook.Add("Think","Graphics",function() RunConsoleCommand("sv_skyname","painted") if !IsValid(ents.FindByClass("env_skypaint")[1]) then ents.Create("env_skypaint"):Spawn() end end)
	
	_GraphicsMapCleanedUp=_GraphicsMapCleanedUp
	if !_GraphicsMapCleanedUp then timer.Simple(0.1,function()game.CleanUpMap()end) _GraphicsMapCleanedUp=yes end
end

function GetSkyData(dnc)
	dnc=tonumber(dnc)||GetDayNightCycle()
	local tcol,bcol,bias=Vector(0,0,0),Vector(0,0,0),1
	if dnc<0.1||dnc>0.9 then
		//(Mid)Night
		tcol=Vector(0,0,0.1)
		bcol=Vector(0.2,0.1,0.3)
		bias=0.6
	elseif dnc<0.3 then
		//Sunrise
		tcol=Vector(
			dnc<0.15&&math.map(dnc,0.1,0.15,0,0)||math.map(dnc,0.15,0.3,0,0),
			dnc<0.15&&math.map(dnc,0.1,0.15,0,0.4)||math.map(dnc,0.15,0.3,0.4,0.5),
			dnc<0.15&&math.map(dnc,0.1,0.15,0.1,0.6)||math.map(dnc,0.15,0.3,0.6,1)
		)
		bcol=Vector(
			dnc<0.15&&math.map(dnc,0.1,0.15,0.2,1)||math.map(dnc,0.15,0.3,1,0.8),
			dnc<0.15&&math.map(dnc,0.1,0.15,0.1,0.3)||math.map(dnc,0.15,0.3,0.3,0.8),
			dnc<0.15&&math.map(dnc,0.1,0.15,0.3,0)||math.map(dnc,0.15,0.3,0,1)
		)
		bias=math.map(dnc,0.1,0.3,0.6,0.2)
	elseif dnc<0.7 then
		//Day
		tcol=Vector(0,0.5,1)
		bcol=Vector(0.8,0.8,1)
		bias=0.2
	elseif dnc<0.9 then
		//Sunset
		tcol=Vector(
			dnc<0.85&&math.map(dnc,0.7,0.85,0,0)||math.map(dnc,0.85,0.9,0,0),
			dnc<0.85&&math.map(dnc,0.7,0.85,0.5,0.4)||math.map(dnc,0.85,0.9,0.4,0),
			dnc<0.85&&math.map(dnc,0.7,0.85,1,0.6)||math.map(dnc,0.85,0.9,0.6,0.15)
		)
		bcol=Vector(
			dnc<0.85&&math.map(dnc,0.7,0.85,0.8,1)||math.map(dnc,0.85,0.9,1,0.2),
			dnc<0.85&&math.map(dnc,0.7,0.85,0.8,0.3)||math.map(dnc,0.85,0.9,0.3,0.1),
			dnc<0.85&&math.map(dnc,0.7,0.85,0.8,0)||math.map(dnc,0.85,0.9,0,0.3)
		)
		bias=math.map(dnc,0.7,0.9,0.2,0.6)
	end
	return tcol,bcol,bias
end

if !CLIENT then return end

local tBlockedHUD = {
	[ 'CHudHealth' ] = true,
	[ 'CHudBattery' ] = true,
	[ 'CHudAmmo' ] = true,
	[ 'CHudSecondaryAmmo' ] = true,
	[ 'CHudVehicle' ] = true,
	[ 'CHudCrosshair' ] = true,
	[ 'CHudPoisonDamageIndicator' ] = true,
	[ 'CHudTrain' ] = true,
	[ 'CHUDQuickInfo' ] = true,
	[ 'CHudSuitPower' ] = true,
	[ 'CHudCloseCaption' ] = true,
	[ 'CHudDamageIndicator' ]  =  true //VALVe's Version of The Red Screen
}
hook.Add( 'HUDShouldDraw', 'Graphics', function( Name ) local ply = LocalPlayer() return IsValid( ply ) && ply:Alive() && !tBlockedHUD[ Name ] end )
hook.Add( 'HUDPaint', 'Graphics', function()
	for i = 2, 0, -.1 do surface.DrawCircle( ScrW() * .5, ScrH() *.5, i, 255, 255, 255, 255 ) end
	surface.DrawCircle( ScrW() * .5, ScrH() * .5, 2, 0, 0, 0, 255 )
end )

DOF_Ents = {}
DOF_Made = DOF_Made
DOF_Start, DOF_Kill = void, void
local function DOF_Stop()
	for _,e in pairs( DOF_Ents ) do if IsValid( e ) then e:Remove() end end
	DOFModeHack( false )
	DOF_Made = nil
end
local function DOF()
	if DOF_Made then return end
	DOF_Stop()
	for i = 0, 5 do
		local ed = EffectData()
		ed:SetScale( i )
		util.Effect( 'DOFNode' , ed )
	end
	DOFModeHack( true )
	DOF_Made = true
end

local function FOG(self,s)
	/*
	//Maybe I'll do this someday.
	//The very extremely ass hard thing is,
	//We need to account for the current environment.
	//If he's standing in a closed spot,
	//That doesnt see any sky, like a tunnel,
	//Then the fog should change to the light color.
	//Which's hard to do and smoothly change,
	//Meaning this is a To-Do thatll never get done.
	render.FogMode(MATERIAL_FOG_NONE)
	*/
	
	if !isvector(self.GAME_Lighting)||!istable(self.GAME_SkyData) then return end
	
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)

	local c=(self.GAME_Lighting||Vector(0,0,0)):Clamp(0,1)
	local t=util.IsSkyboxVisibleFromPoint(EyePos())&&LerpVector(.5,c,LerpVector(.5,self.GAME_SkyData.Top,self.GAME_SkyData.Bot)*.5)||c

	local r=LerpVector(FrameTime()*.5,self.GAME_FogCol||Vector(0,0,0),t*.5)
	self.GAME_FogCol=r
	local b=r:Sum()*.33
	render.FogEnd(math.Remap(b,0,1,1000,4000))
	render.FogMaxDensity(math.Remap(b,0,1,.6,.2))
	render.FogColor(r.x*255,r.y*255,r.z*255)
end
hook.Add("SetupWorldFog","Graphics",function() FOG(LocalPlayer(),1) return true end)
hook.Add("SetupSkyboxFog","Graphics",function(s) FOG(LocalPlayer(),s) return true end)

if _Graphics_BloomRemade then
	_RAW_DrawBloom=_RAW_DrawBloom||DrawBloom
	function DrawBloom(UNUSED_Darken,Mul,SizeX,SizeY,Passes,ColMul,Red,Green,Blue)
		local flDiv=ColorStabilizeDivider()
		_RAW_DrawBloom(
			0,
			(tonumber(Mul)||0)/flDiv,
			tonumber(SizeX)||5,
			tonumber(SizeY)||5,
			tonumber(Passes)||5,
			(tonumber(ColMul)||1)/flDiv,
			(tonumber(Red)||1)/flDiv,
			(tonumber(Green)||1)/flDiv,
			(tonumber(Blue)||1)/flDiv
		)
	end
	_Graphics_BloomRemade=True
end

hook.Add( 'RenderScreenspaceEffects', 'Graphics', function()
	local ply=LocalPlayer()
	if !IsValid( ply ) || !ply:Alive() then DrawColorModify( { [ '$pp_colour_contrast' ] = 0 } ) return end

	local dnc=GetDayNightCycle()

	local tDrawColorModify = {
		[ '$pp_colour_addr' ] = 0,
		[ '$pp_colour_addg' ] = 0,
		[ '$pp_colour_addb' ] = 0,
		[ '$pp_colour_brightness' ] = GetDNCBrightness(),
		[ '$pp_colour_contrast' ] = 1,
		[ '$pp_colour_colour' ] = 1.4,
		[ '$pp_colour_mulr' ] = 0,
		[ '$pp_colour_mulg' ] = 0,
		[ '$pp_colour_mulb' ] = 0,
	}

	local flDeath = ply:GetLackingHealth()
	if flDeath > 0 then
		/*
		tDrawColorModify[ '$pp_colour_addr' ] = flDeath
		tDrawColorModify[ '$pp_colour_mulr' ] = flDeath
		*/
		DrawBokehDOF( flDeath * 5, 0, 0 )
		local X = 1 - flDeath
		tDrawColorModify[ '$pp_colour_colour' ] = tDrawColorModify[ '$pp_colour_colour' ] * X
		tDrawColorModify[ '$pp_colour_addr' ] = flDeath * X
		tDrawColorModify[ '$pp_colour_mulr' ] = flDeath * X
	end

	DrawColorModify( tDrawColorModify )

	local tr=Trace({
		start=ply:EyePos(),
		endpos=ply:EyePos()+ply:GetAimVector()*500,
		filter=ply:AllRelatedEntities(),
		mask=MASK_VISIBLE, //NOT MASK_BLOCK_LOS!!!
	})
	local lt=(render.ComputeLighting(ply:EyePos(),ply:GetAimVector()*tr.HitPos:Distance(ply:EyePos()))+render.ComputeDynamicLighting(ply:EyePos(),ply:GetAimVector()*tr.HitPos:Distance(ply:EyePos())))*0.0001025641025641/(tr.HitPos:Distance(ply:EyePos())*0.002)
	ply.GAME_Lighting=lt
	local act=#lt
	ply.GAME_PrpEyeLight=math.Approach(ply.GAME_PrpEyeLight||0,act,.03)
	//We can only change focus under 7000 units, everything farther should be atleast a little blurry
	//(Excluding the times when were using a scope of a sniper or any other zoom thing)
	local md=7000*(99/ply:GetFOV())
	local d=Trace({
		start=EyePos(),
		endpos=EyePos()+EyeVector()*md,
		mask=MASK_VISIBLE_AND_NPCS, //We MUST properly focus on NPCs
		filter=ply:AllRelatedEntities(), //Ignore our weapon, vehicle, etc
	}).HitPos:Distance(EyePos())*1.1
	if (ply.GAME_PrpEyeDist||0)<d then
		ply.GAME_PrpEyeDist=lmin((ply.GAME_PrpEyeDist||0)+(d-(ply.GAME_PrpEyeDist||0))*0.1,d)
	else
		ply.GAME_PrpEyeDist=lmax((ply.GAME_PrpEyeDist||0)-((ply.GAME_PrpEyeDist||0)*0.2),d)
	end
	ply.GAME_PrpEyeDist=clamp(ply.GAME_PrpEyeDist,250,md)
	//Actual Work of Eyes' Adjustment
	local bl=clamp(math.map(ply.GAME_PrpEyeLight,0,1,1.5,1.1),1.1,1.5)
	DrawBloom(0,bl,10,10,10,bl,bl,bl,bl)
	DOF()
	
	//We NEED that here!
	local tcol,bcol,bias=GetSkyData()
	ply.GAME_SkyData={Top=tcol,Bot=bcol,Bias=bias}
	
	//Sky Stuff - The Best + The Hardest!
	if !IsValid( g_SkyPaint ) then return end
	
	g_SkyPaint:SetDrawStars( true )
	g_SkyPaint:SetTopColor( tcol )
	g_SkyPaint:SetBottomColor( bcol )
	g_SkyPaint:SetFadeBias( bias )
	
	g_SkyPaint:SetDuskIntensity(0)
	g_SkyPaint:SetDuskScale(0)
	
	g_SkyPaint:SetStarLayers(3)
	g_SkyPaint:SetStarFade(1.5)
	g_SkyPaint:SetStarSpeed(0.05)
	g_SkyPaint:SetStarScale(3)
	g_SkyPaint:SetStarTexture((dnc<0.05||dnc>0.95)&&"skybox/starfield"||"skybox/clouds")
	
	g_SkyPaint:SetSunSize(0.02)
	g_SkyPaint:SetSunNormal(Vector(dnc<0.5&&math.map(dnc,0,0.5,1,0)||math.map(dnc,0.5,1,0,-1),0,dnc<0.5&&math.map(dnc,0,0.5,-1,1)||math.map(dnc,0.5,1,1,-1)))
	g_SkyPaint:SetSunColor(Vector(1,0.75,0.25))
end )
hook.Add("CalcView","Graphics",function(ply,pos,angles,fov,znear,zfar)
	if ply:InVehicle() then return end
	local ent=IsValid(ply:GetRagdollEntity())&&ply:GetRagdollEntity()||(IsValid(ply:GetViewEntity())&&ply:GetViewEntity()!=ply)&&ply:GetViewEntity()||ply
	local hbone={
		pos=select(1,ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1")||-1))||ent:GetPos(),
		ang=select(2,ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1")||-1))||angles,
	}
	local nw=angles
	if hbone.ang then
		nw=hbone.ang:Right():Angle()
		nw:Normalize()
		nw.p=math.clamp(math.map(nw.p,-4,35,-40,40)-30,-80,80)
		hbone.ang=nw
	end
	local t = table.tohasvalue( ply:AllRelatedEntities() )
	local tr = Trace {
		start=hbone.pos,
		endpos=hbone.pos+hbone.ang:Forward()*8+hbone.ang:Up()*2,
		filter=function(ent) return !t[ent]&&!ent:GetCollisionGroup()==COLLISION_GROUP_WORLD end,
		mask=MASK_VISIBLE_AND_NPCS,
	}
	local returndata={
		origin=(IsValid(ply:GetRagdollEntity())||pos:DistToSqr(tr.HitPos)<=10000||tp!=-1)&&tr.HitPos||pos,
		angles=IsValid(ply:GetViewEntity())&&ply:GetViewEntity()!=ply&&ply:GetViewEntity():GetAngles()||IsValid(ply:GetRagdollEntity())&&hbone.ang||tp==-1&&angles,
		fov=math.Clamp(fov,0,179),
		drawviewer=!(IsValid(ply:GetActiveWeapon())&&ply:GetActiveWeapon():GetClass()=='gmod_camera'),
		znear=1,
		zfar=1e10
	}
	if tr.Hit then returndata.origin=returndata.origin+(tr.HitNormal*5) end
	return returndata
end)
hook.Add("CalcVehicleView","Graphics",function(veh,ply,data)
	local hbone={
		pos=select(1,ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1")))||ply:GetPos(),
		ang=(select(2,ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1")))||data.angles):RemoveAxis(AXIS_ROLL),
	}
	hbone.ang:Normalize()
	data.angles:Normalize()
	return {
		origin=hbone.pos+hbone.ang:Forward()*4+hbone.ang:Up()*-6,
		angles=IsValid(ply:GetViewEntity())&&ply:GetViewEntity()!=ply&&ply:GetViewEntity():GetAngles()||data.angles,
		fov=math.min(data.fov,179),
		drawviewer=yes,
		znear=1,
		zfar=1e10
	}
end)
