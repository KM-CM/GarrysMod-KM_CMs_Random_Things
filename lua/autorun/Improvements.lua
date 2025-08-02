CPlayer = FindMetaTable( 'Player' ) || {}
CEntity = FindMetaTable( 'Entity' ) || {}
CNPC = FindMetaTable( 'NPC' ) || {}
CNextBot = FindMetaTable( 'NextBot' ) || {}
CWeapon = FindMetaTable( 'Weapon' ) || {}
CVector = FindMetaTable( 'Vector' ) || {}
CAngle = FindMetaTable( 'Angle' ) || {}
CColor = FindMetaTable( 'Color' ) || {}
CConVar = FindMetaTable( 'ConVar' ) || {}
CCVar = FindMetaTable( 'ConVar' ) || {}
CPathFollower = FindMetaTable( 'PathFollower' ) || {}
CNavArea = FindMetaTable( 'CNavArea' ) || {}
CDamageInfo = FindMetaTable( 'CTakeDamageInfo' ) || {}
CEffectData = FindMetaTable( 'CEffectData' ) || {}
CMoveData = FindMetaTable( 'CMoveData' ) || {}
CString = getmetatable( '' ) || {}

function debugoverlay.TraceHull( Data, Time, Col )
	debugoverlay.SweptBox( Data.start, Data.endpos, Data.mins, Data.maxs, Angle( 0, 0, 0 ), Time, Col )
end

function CEntity:CanRegenerate() return CurTime() > ( self.GAME_NextRegen || 0 ) && CurTime() > ( self.GAME_LastTakeDamage || 0 ) + ( self.GAME_RegenDelayFromLastHit || 2 ) end

//Made if You Need `true`/`false` Instead of `true`/`nil`
function BOOL( X ) if X then return true else return false end end

function RegisterMetaTable( Name, Meta ) debug.getregistry()[ Name ] = Meta end
//function RegisterMetaTable( metaName, metaTable ) debug.getregistry()[ metaName ] = metaTable end

function CATEGORIZE( self )
	if !IsValid( self ) then return end
	local t = self.CATEGORIZE
	if !t then return end
	if t.OWNER then
		local owner = self:GetOwner()
		if IsValid( owner ) && owner != self then return CATEGORIZE( owner ) end
	end
	return t
end

/*
Has*Attack Check if The Entity can Perform The Given Attack.
In*Attack Check if The Entity can Perform The Given Attack Now.

InRangeAttack will Return `true` for a Player Holding a Pistol,
and `false` for a Player Holding a Crowbar,
While HasRangeAttack will Return `true` if The Player has a Pistol.
*/

function HasRangeAttack( self )
	if !IsValid( self ) then return end
	if self.HAS_RANGE_ATTACK then return true end
	if self.HAS_NOT_RANGE_ATTACK then return end
	if self.GetCapabilities && Band( self:GetCapabilities(), 417792 ) != 0 || self.CapabilitiesGet && Band( self:CapabilitiesGet(), 417792 ) != 0 then return true end
	if self.GetWeapons then
		for _, wep in ipairs( self:GetWeapons() ) do
			if HasRangeAttack( wep ) then return true end
		end
	elseif self.GetActiveWeapon then
		local wep = self:GetActiveWeapon()
		if IsValid( wep ) && HasRangeAttack( wep ) then return true end
	end
end
setfenv( HasRangeAttack, { IsValid = IsValid, Band = bit.band, ipairs = ipairs, HasRangeAttack = HasRangeAttack } )

function HasMeleeAttack( self )
	if !IsValid( self ) then return end
	if self.HAS_MELEE_ATTACK then return true end
	if self.HAS_NOT_MELEE_ATTACK then return end
	if self.GetCapabilities && Band( self:GetCapabilities(), 1671168 ) != 0 || self.CapabilitiesGet && Band( self:CapabilitiesGet(), 1671168 ) != 0 then return true end
	if self.GetWeapons then
		for _, wep in ipairs( self:GetWeapons() ) do
			if HasMeleeAttack( wep ) then return true end
		end
	elseif self.GetActiveWeapon then
		local wep = self:GetActiveWeapon()
		if IsValid( wep ) && HasMeleeAttack( wep ) then return true end
	end
end
setfenv( HasMeleeAttack, { IsValid = IsValid, Band = bit.band, ipairs = ipairs, HasMeleeAttack = HasMeleeAttack } )

function InRangeAttack( self )
	if !IsValid( self ) then return end
	if self.IN_RANGE_ATTACK then return true end
	if self.IN_NOT_RANGE_ATTACK then return end
	if self.GetCapabilities && Band( self:GetCapabilities(), 417792 ) != 0 || self.CapabilitiesGet && Band( self:CapabilitiesGet(), 417792 ) != 0 then return true end
	if self.GetActiveWeapon then
		local wep = self:GetActiveWeapon()
		if IsValid( wep ) && InRangeAttack( wep ) then return true end
	end
end
setfenv( InRangeAttack, { IsValid = IsValid, Band = bit.band, ipairs = ipairs, InRangeAttack = InRangeAttack } )

function InMeleeAttack( self )
	if !IsValid( self ) then return end
	if self.IN_MELEE_ATTACK then return true end
	if self.IN_NOT_MELEE_ATTACK then return end
	if self.GetCapabilities && Band( self:GetCapabilities(), 1671168 ) != 0 || self.CapabilitiesGet && Band( self:CapabilitiesGet(), 1671168 ) != 0 then return true end
	if self.GetActiveWeapon then
		local wep = self:GetActiveWeapon()
		if IsValid( wep ) && InMeleeAttack( wep ) then return true end
	end
end
setfenv( InMeleeAttack, { IsValid = IsValid, Band = bit.band, ipairs = ipairs, InMeleeAttack = InMeleeAttack } )

function GetFlameStopChance( self ) return math.max( 1000, #GetVelocity( self ) * 100 ) end

function CAngle:Length() return abs( self.p ) + abs( self.y ) + abs( self.r ) end
function CAngle:__len() return abs( self.p ) + abs( self.y ) + abs( self.r ) end

function CVector:Distance2D( Other ) return Vector( self.x, self.y, 0 ):Distance( Vector( Other.x, Other.y, 0 ) ) end
function CVector:Distance2DSqr( Other ) return Vector( self.x, self.y, 0 ):DistToSqr( Vector( Other.x, Other.y, 0 ) ) end

function SimpleDuplicator_Copy( ent )
	return {
		Class = ent:GetClass(),
		Pos = ent:GetPos(),
		Angles = ent:GetAngles(),
		Model = ent:GetModel(),
		Skin = ent:GetSkin(),
		Weapon = ( ent.GetActiveWeapon && IsValid( ent:GetActiveWeapon() ) ) && ent:GetActiveWeapon():GetClass() 
	}
end
function SimpleDuplicator_Paste( Data )
	local ent = ents.Create( Data.Class )
	ent:SetPos( Data.Pos )
	ent:SetAngles( Data.Angles )
	ent:SetModel( Data.Model )
	ent:SetSkin( Data.Skin || 0 )
	if Data.Weapon then ent:Give( Data.Weapon ) end
	return ent
end

function IsInCone(p,s,d,v,h) local dr=(p-s):GetNormalized():Angle() return math.abs(math.AngleDifference(d:Angle().p,dr.p))<=v&&math.abs(math.AngleDifference(d:Angle().y,dr.y))<=h end

function CalcAcceleration( vDesired, vCurrent, flAcceleration )
	local v = vDesired - vCurrent
	return v:GetNormalized() * math.min( v:Length(), flAcceleration )
end

function CVector:Clamp(M,N) return V(C(self.x,M,N),C(self.y,M,N),C(self.z,M,N)) end
setfenv(CVector.Clamp,{V=Vector,C=math.Clamp})

function DBToDistance(iDB) return math.map(iDB,60,150,886,19626) end
function DBToDistanceSqr(iDB) return math.map(iDB,60,150,784996,385179876) end

function CEntity:GetRandomPoint() return self:GetPos()+self:GetForward()*rand(self:OBBMins().x,self:OBBMaxs().x)+self:GetRight()*rand(self:OBBMins().y,self:OBBMaxs().y)+self:GetUp()*rand(self:OBBMins().z,self:OBBMaxs().z) end

function CAngle:GetSnap(d,t) return Angle(math.ApproachAngle(self.p,t.p,d),math.ApproachAngle(self.y,t.y,d),math.ApproachAngle(self.r,t.r,d)) end

function CPlayer:GetShootPos() return self:GetBonePosition(self:LookupBone(self.ShootBone||'ValveBiped.Bip01_R_Hand')) end

function CEntity:GetBackward() return -self:GetForward() end
function CEntity:GetLeft() return -self:GetRight() end
CEntity.GetFor=CEntity.GetForward
CEntity.GetBack=CEntity.GetBackward
CEntity.GetRightward=CEntity.GetRight
CEntity.GetLeftward=CEntity.GetLeft

function CVector:DotFlat( Other ) return self[ 1 ] * Other[ 1 ] + self[ 2 ] * Other[ 2 ] end

function table.IntChoices(self,X)
	local R,M={},#self
	X=math.min(X,M)
	local S={}
	for i=1,M do S[i]=i end
	for i=M,2,-1 do
		local j=math.random(i)
		S[i],S[j]=S[j],S[i]
	end
	for i=1,X do table.insert(R,self[S[i]]) end
	return R
end

if SERVER then
	Add_NPC_Class( 'CLASS_HUMAN' )
	function CPlayer:SetNPCClass( i ) self.iClass = i end
	function CPlayer:GetNPCClass() return self.iClass || CLASS_HUMAN end
	setfenv( CPlayer.GetNPCClass, { CLASS_HUMAN = CLASS_HUMAN } )
	CPlayer.Classify = CPlayer.GetNPCClass
end

function CEntity:GetGeneralHealth()
	local h = self:Health()
	if self.InVehicle && self:InVehicle() then h = h + self:GetVehicle():Health() end
	local own = self:GetOwner()
	if IsValid( own)  then h = h + own:GetGeneralHealth() end
	return h
end

sv_gravity = GetConVar 'sv_gravity'
function CalcThrow( vStart, vTarget, flSpeed )
	local v = vTarget - vStart
	local t = #v / flSpeed
	v = v * ( 1 / t )
	v.z = v.z + sv_gravity:GetFloat() * t * .5
	return v
end

function CEntity:GetSize() return #self:OBBMins() + #self:OBBMaxs() end
/*function CEntity:GetSize()
	local m,n=self:OBBMins(),self:OBBMaxs()
	m.x=abs(m.x) m.y=abs(m.y) m.z=abs(m.z)
	n.x=abs(m.x) n.y=abs(m.y) n.z=abs(m.z)
	return #(m+n)
end*/

function CEntity:DoRecoilEffect( f )
	local p = math.rand( 0, 1 )
	local r = 1 - p
	if BoolRand() then f = -f end
	local v = Angle( f * p, 0, -f * r )
	self:ViewPunch( v ) timer.Simple( .033, function() self:ViewPunch( -v ) end )
end

function IOEntity( ent ) return ent:GetForIO() end
IOEnt = IOEntity
function CEntity:GetForIO()
	if !self:HasTargetName() then
		local n=self:GetClass() .. '_'.. self:EntIndex()
		self:SetTargetName( n )
		return n
	end
	return self:GetTargetName()
end

function CEntity:SetTargetName( n ) self:SetKeyValue( 'targetname', n ) end
function CEntity:GetTargetName() return self:GetKeyValue( 'targetname' ) end
function CEntity:HasTargetName() return #tostring( self:GetKeyValue( 'targetname' ) || '' ) > 0 end

function GetShootPos( ent )
	if !IsValid( ent ) then return end
	local v = ent:EyePos()
	pcall( function() v = ent:GetShootPos() end )
	return v
end

function GetAimVector( ent )
	if !IsValid( ent ) then return end
	local v = ent:GetForward()
	pcall( function() v = ent:GetAimVector() end )
	return v
end

function GetOwner(ent) return IsValid(ent:GetOwner())&&GetOwner(ent:GetOwner())||ent end
function GetParent(ent) return IsValid(ent:GetParent())&&GetParent(ent:GetParent())||ent end

function SetEnemy(ent,tar)pcall(function()ent:SetEnemy(tar)end)end
function GetEnemy( ent ) local r = Void pcall( function() r = ent:GetEnemy() end ) return r end

function SetWeapon(ent,tar)pcall(function()ent:SetActiveWeapon(tar)end)end
function GetWeapon(ent) local r=void pcall(function()r=ent:GetActiveWeapon()end) return r end
function GetWeaponClass(ent) local w=GetWeapon(ent) return IsValid(w)&&w:GetClass()||'' end

function CEntity:GetLackingHealth() return clamp(math.map(self:Health(),0,self:GetMaxHealth(),1,0),0,1) end

function string.separate(s,c)
	local ret={}
	for i=1,#s,c do table.insert(ret,s:sub(i,i+c-1)) end
	return ret
end

function CreateID(isnumber,maxlength)
	if !maxlength then maxlength=tonumber(maxlength)||20 end
	if isnumber then
		local id=''
		for i=1,maxlength do id=id+table.Random({'0','1','2','3','4','5','6','7','8','9',}) end
		return tonumber(id)
	else
		local id=''
		for i=1,maxlength do id=id+table.Random({
			'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
			'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
			'0','1','2','3','4','5','6','7','8','9',
		}) end
		return id
	end
end
function CreateIDCheap(isnumber,maxlength)
	if !maxlength then maxlength=tonumber(maxlength)||1000 end
	local id=tostring(rand(-maxlength/2,maxlength/2))
	if isnumber then return tonumber(id) end
	return id
end

function CWeapon:SetNextFire(t) self:SetNextPrimaryFire(t) self:SetNextSecondaryFire(t) end

function CPlayer:GetOldAimVector() return ply:EyeAngles():Forward() end

local cgroups={
	[0]='COLLISION_GROUP_NONE',
	[1]='COLLISION_GROUP_DEBRIS',
	[2]='COLLISION_GROUP_DEBRIS_TRIGGER',
	[3]='COLLISION_GROUP_INTERACTIVE_DEBRIS',
	[4]='COLLISION_GROUP_INTERACTIVE',
	[5]='COLLISION_GROUP_PLAYER',
	[6]='COLLISION_GROUP_BREAKABLE_GLASS',
	[7]='COLLISION_GROUP_VEHICLE',
	[8]='COLLISION_GROUP_PLAYER_MOVEMENT',
	[9]='COLLISION_GROUP_NPC',
	[10]='COLLISION_GROUP_IN_VEHICLE',
	[11]='COLLISION_GROUP_WEAPON',
	[12]='COLLISION_GROUP_VEHICLE_CLIP',
	[13]='COLLISION_GROUP_PROJECTILE',
	[14]='COLLISION_GROUP_DOOR_BLOCKER',
	[15]='COLLISION_GROUP_PASSABLE_DOOR',
	[16]='COLLISION_GROUP_DISSOLVING',
	[17]='COLLISION_GROUP_PUSHAWAY',
	[18]='COLLISION_GROUP_NPC_ACTOR',
	[19]='COLLISION_GROUP_NPC_SCRIPTED',
	[20]='COLLISION_GROUP_WORLD',
}
function CEntity:GetCollisionGroupStr() return cgroups[self:GetCollisionGroup()]||'CUSTOM' end

local ts=GetConVar('host_timescale')
function game.GetActTimeScale() return game.GetTimeScale()*ts:GetFloat() end

//Door Classes For Entities
engine.DoorClasses={}
function engine.AddDoorClass(c) engine.DoorClasses[c]=yes end
engine.AddDoorClass('prop_door_rotating')
engine.AddDoorClass('func_door_rotating')
function engine.IsDoor(c) return !engine.DoorClasses[c] end

//CanPenetrateArmor(dmginfo)
function CanPenetrateArmor(d) return d:IsDamageType(DMG_BLAST+DMG_CRUSH+DMG_BLUNT) end

//Angle:Difference(Angle Other)
function CAngle:Difference(ang) return Angle(math.AngleDifference(self.p,ang.p),math.AngleDifference(self.y,ang.y),math.AngleDifference(self.r,ang.r)) end

//Entity:IsEnvironment()
function CEntity:IsEnvironment() return !(self:IsPlayer()||self:IsNPC()||self:IsNextBot()) end

//Entity:SeqAct(name)
function CEntity:SeqAct(n) return self:GetSequenceActivity(self:LookupSequence(n)) end

function table.randk(t)
	local k={}
	for v,_ in pairs(t) do table.insert(k,v) end
	return table.Random(k)
end

//inrange(num,min,max)
function inrange(n,mn,mx)
	if n<=0&&mn<=0&&mx<=0 then n,mn,mx=math.abs(n),math.abs(mn),math.abs(mx) end
	return n>=mn&&n<=mx
end

function CEntity:GodEnable() self.GAME_God=yes end
function CEntity:GodDisable() self.GAME_God=no end
function CEntity:GodToggle() self.GAME_God=!self.GAME_God end

function CEntity:GetCenter() return self:GetPos() + self:OBBCenter() end
function CEntity:MaxHealth() return self:GetMaxHealth()!=1&&self:GetMaxHealth()||self.GAME_StartHealth end

function ToRGB(r,g,b)
	if type(r)=='table' then r,g,b=unpack(r) end
	local max=math.max(r,g,b)
	local scale_factor=(255/max)
	local scaled={}
	for _,num in ipairs({r,g,b}) do table.insert(scaled,num*scale_factor) end
	return scaled
end
torgb=ToRGB

//CMoveData:AddVelocity(vec)
function CMoveData:AddVelocity(x) self:SetVelocity((self:GetVelocity()+x)) end

//String+String,String*Number,-String,String <(=) String.
//Others are just returning self.
function CString:__add(x) return self..tostring(x||void); end
function CString:__mul(x)
	local ret=''
	for i=1,tonumber(x||void)||1 do ret=ret..self end
	return ret
end
function CString:__lt(x) return pcall_ret(function() return (#self<#x); end)||no end
function CString:__tostring() return self end
function CString:__unm()
	local ret=''
	for i=1,#self do
		local char=self:sub(i,i)
		ret=char..ret
	end
	return ret
end

//Ret(...): Where normally Lua doesnt allow,like {[1]=yes,[2]=yes}[1],you can do ret({[1]=yes,[2]=yes})[1] instead.
function Ret(...) return ... end
This,this,Vararg,vararg,Tuple,tuple,ret=Ret,Ret,Ret,Ret,Ret,Ret,Ret

function CColor:__div(n) return Color(self.r/n,self.g/n,self.b/n) end

//For SPECIAL CASES ONLY.
function CCVar:GetNum(d) return tonumber(self:GetString())||d end
function CCVar:GetNumber(d) return tonumber(self:GetString())||d end

AXIS_PITCH=1
AXIS_P=1
AXIS_YAW=2
AXIS_Y=2
AXIS_ROLL=3
AXIS_R=3
function CAngle:RemoveAxis(n)
	if n==AXIS_PITCH then self.p=0 end
	if n==AXIS_YAW then self.y=0 end
	if n==AXIS_ROLL then self.r=0 end
	return self
end

//string.f(...) - Python-like F-String!
function string.f(...)
	local result=''
	for _,thing in ipairs({...}) do result=(result+tostring(thing||void)); end
	return result
end

//sv_infinite_ammo is back!
if SERVER then
local sv_infinite_ammo=CreateConVar('sv_infinite_ammo',0,bit.bor(FCVAR_NEVER_AS_STRING,FCVAR_CHEAT,FCVAR_NOTIFY,FCVAR_SERVER_CAN_EXECUTE),'Should ammo be infinite?')
hook.Add('Think','sv_infinite_ammo',function() for _,ent in ipairs(ents.GetAll()) do if ent:IsWeapon() then if sv_infinite_ammo:GetInt()==1 then ent:SetClip1(99999) elseif ent:Clip1()==99999 then ent:SetClip1(1) end end end end)
end

function table.tohasvalue(tbl)
	local newtbl={}
	for _,v in ipairs(tbl) do newtbl[v]=yes end
	return newtbl
end
function table.fromhasvalue(tbl)
	local newtbl={}
	for v,_ in ipairs(tbl) do table.insert(newtbl,v) end
	return newtbl
end

function pixels(h,n) return ((h&&ScrW()||ScrH())*n/(h&&1920||1080)); end

function CEntity:CanIgnite() return ((self:GetClass()!='predicted_viewmodel')&&(CurTime()>(self.GAME_FireImmunity||0))&&(!self:IsWeapon()||(self:IsWeapon()&&!IsValid(self:GetOwner())))&&!self.GAME_DontIgnite&&(self:WaterLevel()<=2)); end

function Code(...)
	local r=''
	for _,o in ipairs(type(...)=='table'&&...||{...}) do
		local n=o
		if n==';' then n=';' else n=tocode(o) end
		r=r+n
	end
	return r
end
function tocode(o)
	if o==void then return 'void' end
	if o==null then return 'null' end
	if o==no then return 'no' end
	if o==yes then return 'yes' end
	if type(o)=='number' then return tostring(o) end
	if type(o)=='string' then return o end
	return (o.__tocode&&tostring(o:__tocode()||void))||no
end
function CEntity:__tocode() return 'Entity('+tostring(self:EntIndex())+')'; end
function CVector:__tocode() return 'Vector('+tostring(self.x)+','+tostring(self.y)+','+tostring(self.z)+')'; end
function CAngle:__tocode() return 'Angle('+tostring(self.p)+','+tostring(self.y)+','+tostring(self.r)+')'; end
function CColor:__tocode() return 'Color('+tostring(self.r)+','+tostring(self.g)+','+tostring(self.b)+','+tostring(self.a)+')'; end

function KillServer() for _,ply in ipairs(player.GetAll()) do ply:ConCommand('disconnect') end end

function pcall_ret(f) return select(2,pcall(function()return f()end)) end

//Vector:Sum()
//Returns: Sum of X,Y and Z of the vector.
function CVector:Sum() return (self.x+self.y+self.z); end

//Entity:GetHealth()=Entity:Health()
function CEntity:GetHealth() return self:Health(); end

//IsInCone( vTarget, vStart, vDirection, flVertical, flHorizontal )
local function IsInCone(p,s,d,v,h) local dr=(p-s):GetNormalized():Angle() return math.abs(math.AngleDifference(d:Angle().p,dr.p))<=v&&math.abs(math.AngleDifference(d:Angle().y,dr.y))<=h end

//GetVelocity(ent),SetVelocity(ent,velocity)
//Set custom handlers via ENT:__GetVelocity__(),ENT:__SetVelocity__(velocity),ENT:__AddVelocity__ocity__(velocity).
function GetVelocity(ent)
	if ent.__GetVelocity__ then return ent:__GetVelocity__() end
	if ent:IsNextBot() then return ent.loco:GetVelocity() else
		if IsValid(ent:GetPhysicsObject()) then return ent:GetPhysicsObject():GetVelocity()
		else return ent:GetVelocity() end
	end
end
function SetVelocity(ent,v)
	if ent.__SetVelocity__ then return ent:__SetVelocity__(v) end
	if ent:IsNextBot() then return ent.loco:SetVelocity(v) else
		if ent:IsPlayer() then ent:SetVelocity((v-ent:GetVelocity()))
		elseif IsValid(ent:GetPhysicsObject()) then return ent:GetPhysicsObject():SetVelocity(v)
		else return ent:SetVelocity(v) end
	end
end
function AddVelocity(ent,v)
	if ent.__AddVelocity__ then return ent:__AddVelocity__(v) end
	if ent:IsNextBot() then return ent.loco:SetVelocity((ent.loco:GetVelocity()+v)) else
		if ent:IsPlayer() then ent:SetVelocity(v)
		elseif IsValid(ent:GetPhysicsObject()) then return ent:GetPhysicsObject():AddVelocity(v)
		else return ent:SetVelocity((ent:GetVelocity()+v)) end
	end
end

function CEntity:Kill(dmg) self:SetHealth(0) self:TakeDamageInfo(dmg||DamageInfo()) end

local cdev=GetConVar('developer')
hook.Add('Think','Improvements',function() if cdev:GetInt()>1 then RunConsoleCommand('developer',1) end end)

function CVector:GetFlat() return Vector(self.x,self.y,0) end
function CVector:Flat() self.z=0 end

if SERVER then function navmesh.GetClosestPos(p)
	local ret=p
	local area=navmesh.GetNearestNavArea(p)
	if area then ret=area:GetClosestPointOnArea(p) end
	return ret
end navmesh.GetClosestPoint=navmesh.GetClosestPos end

function CEntity:AddThink(func)
if type(func)!='function' then return end
local ent=self
local id=CreateID()
hook.Add('Think',id,function()
	local function RmThisThink() hook.Remove('Think',id) end
	if !IsValid(ent) then RmThisThink() return end
	func(ent,RmThisThink)
end)
end

hook.Add('EntityKeyValue','Improvements',function(ent,k,v)
	if !ent.DATA_KeyValues then ent.DATA_KeyValues={} end
	ent.DATA_KeyValues[string.lower(tostring(k||void))]=tostring(v||void) //Do !lower the value!
end)

SetGlobalBool('LE_Exists',no)
hook.Add('EntityKeyValue','Improvements',function(ent,k,v)
	if ent:GetClass()=='light_environment' then
		SetGlobalBool('LE_Exists',yes)
		if k=='_light' then
			local components={}
			for value in tostring(v):gmatch('%S+') do
				table.insert(components,(tonumber(value)||255)*2)
			end
			//'Just in case!'
			table.insert(components,255*2)
			table.insert(components,255*2)
			table.insert(components,255*2)
			LE_Light=Color(components[1],components[2],components[3])
			SetGlobalVector('LE_Light',LE_Light:ToVector())
		elseif k=='_ambient' then
			local components={}
			for value in tostring(v):gmatch('%S+') do
				table.insert(components,(tonumber(value)||255)*2)
			end
			//'Just in case!'
			table.insert(components,255*2)
			table.insert(components,255*2)
			table.insert(components,255*2)
			LE_ALight=Color(components[1],components[2],components[3])
			SetGlobalVector('LE_ALight',LE_ALight:ToVector())
		end
		LE_Ang=ent:GetAngles()
		SetGlobalAngle('LE_Ang',LE_Ang)
		LE_Pos=ent:GetPos()
		SetGlobalVector('LE_Pos',LE_Pos)
	end
end)

list.Set('SpawnableEntities','item_item_crate',{
	PrintName='Ammo Crate',
	ClassName='item_item_crate',
	Category='Ammo Crates',
	AdminOnly=no,
	KeyValues={CrateType=0,ItemClass='item_dynamic_resupply',ItemCount=2},
})

local atcts={
	[0]='item_ammo_pistol',
	[1]='item_ammo_smg1',
	[2]='item_ammo_ar2',
	[3]='item_rpg_round',
	[4]='item_box_buckshot',
	[5]='weapon_frag',
	[8]='item_ammo_ar2_altfire',
	[9]='item_ammo_smg1_grenade',
}
for at,ats in ipairs(atcts) do list.Set('SpawnableEntities','item_ammo_crate_'+ats,{
	PrintName='['+ats+'] Ammo Crate',
	ClassName='item_ammo_crate',
	Category='Ammo Crates',
	AdminOnly=no,
	KeyValues={AmmoType=at},
}) end

if IsMounted('hl1') then
	list.Set('NPC','monster_apache',{
		Name='AH-64 Apache',
		Class='monster_apache',
		Category='Half-Life: Source',
		AdminOnly=no
	})
	list.Set('NPC','monster_osprey',{
		Name='Osprey',
		Class='monster_osprey',
		Category='Half-Life: Source',
		AdminOnly=no
	})
	list.Set('NPC','monster_ichthyosaur',{
		Name='Ichthyosaur',
		Class='monster_ichthyosaur',
		Category='Half-Life: Source',
		AdminOnly=no
	})
end

list.Set('Vehicles','airboat_gun',{
	Name='Airboat [Gun]',
	Class='prop_vehicle_airboat',
	Model='models/airboat.mdl',
	Category='Half-Life 2',
	KeyValues={
		vehiclescript='scripts/vehicles/airboat.txt',
		EnableGun=1
	},
	AdminOnly=no
})
list.Set('Vehicles','jeep_gun',{
	Name='Jeep [Gun]',
	Class='prop_vehicle_jeep_old',
	Model='models/buggy.mdl',
	Category='Half-Life 2',
	KeyValues={
		vehiclescript='scripts/vehicles/jeep_test.txt',
		EnableGun=1,
		EnableRadar=1
	},
	AdminOnly=no
})
list.Set('Vehicles','combine_apc',{
	Name='Combine APC',
	Class='prop_vehicle_jeep',
	Model='models/combine_apc.mdl',
	Category='Half-Life 2',
	KeyValues={ vehiclescript='scripts/vehicles/combine_apc_new.txt' },
	AdminOnly=no
})

function table.KeyByValue(t,vl) for k,v in pairs(t) do if v==vl then return k end end end

function CEntity:AllRelatedEntities(s)
	if !IsValid(self) then return {} end
	local result={}
	if !s then table.insert(result,self) end
	if self.GetVehicle&&IsValid(self:GetVehicle()) then table.insert(result,self:GetVehicle()) end
	if self.GetViewEntity&&IsValid(self:GetViewEntity()) then table.insert(result,self:GetViewEntity()) end
	if self.GetActiveWeapon&&IsValid(self:GetActiveWeapon()) then table.insert(result,self:GetActiveWeapon()) end
	if self.GetWeapons&&type(self:GetWeapons())=='table' then
		for _,wep in ipairs(self:GetWeapons()||{}) do
			if IsValid(wep) then table.insert(result,wep) end
		end
	end
	if IsValid(self:GetParent()) then table.insert(result,self:GetParent()) end
	if IsValid(self:GetOwner()) then table.insert(result,self:GetParent()) end
	return result
end
function CEntity:GetCurSequenceName() return self:GetSequenceList()[self:GetSequence()||0] end
function CEntity:GetKeyValue(k) return self:GetKeyValues()[tostring(k||void)] end
function CEntity:SetKeyValues(data) for k,v in pairs(data) do self:SetKeyValue(tostring(k||void),tostring(v||void)) end end
function CEntity:SetSpawnFlags(flags) self:SetKeyValue('spawnflags',tonumber(flags)||0) end
function CEntity:AddSpawnFlags(flags) self:SetKeyValue('spawnflags',bit.bor(self:GetSpawnFlags(),tonumber(flags)||0)) end
function CEntity:Input(input,activator,caller,data) self:Fire(tostring(input),(data||''),0,(activator||NULL),(caller||NULL)) end
function CEntity:EyePos()
	local v=pcall_ret(function()return self:GetEyePos()end)
	if isvector(v) then return v end
	return self:GetPos()+self:OBBCenter()
end
function CEntity:DoNothing() end
function CEntity:IsBreakable()
	if self.bCanBreak then return true end
	if self.bDontBreak then return false end
	local c=self:GetClass()
	if c=='prop_ragdoll' then return false end
	local b=c:match('prop_*')||c:match('object_*')||c:match('item_*')
	if b then return true end
	if c:match('func_*') then return !self:GetNoDraw() end
	return false
end

function string.gmatch_tbl(d,p)
	local m=string.gmatch(tostring(d||void),tostring(p||void))
	local returnvalue={}
	for word in m do table.insert(returnvalue,m) end
	return returnvalue
end

/*////////////////////////////////////////////////////////
Table FindSpots( Vector Position, Float Radius, Float Down, Float Up, Boolean Underwater )

1/Vector Position: Around where to search for spots?
2/Float Radius: Max flat dist from a nav area to Position to consider a spot valid.
3/Float Down: Ditto, except for spots upper than Position.
3/Float Up: Ditto, except for spots lower than Position.
3/Boolean Underwater: Should we consider underwater spots valid?

Finds Spots for Dynamic Cover that You Must Filter by LOS or LOF.

WARNING: DO NOT USE THESE FOR FINDING PLACES NEAR COVER, THIS IS MADE FOR FINDING DYNAMIC COVER!
WARNING: ALWAYS, AND I MEAN ALWAYS FILTER THESE SPOTS, OR ELSE YOU WILL GET IMPROPER POSITIONS!

RETURNS: Table Spots - Found
////////////////////////////////////////////////////////*/
function FindSpots(pos,radius,stepdown,stepup,uw)
	if !navmesh||navmesh.GetNavAreaCount()<=0 then return {} end
	local r={}
	for _,area in ipairs(navmesh.Find(pos,radius,stepdown,stepup)) do
		if !uw&&!area:IsUnderwater()||uw then
			table.insert(r,area:GetCenter())
			for _,v in ipairs(area:GetHidingSpots()) do table.insert(r,v) end
			for _,v in ipairs(area:GetExposedSpots()) do table.insert(r,v) end
		end
	end
	return r
end

function BoolRand() return R(1,2)==1 end
setfenv(BoolRand,{R=math.random})

function CVector:__len() return self:Length() end
function CVector:AddSpread(vec)
	self:Normalize()
	self.y=self.y+math.rand(-(vec.x/2),(vec.x/2))
	self.z=self.z+math.rand(-(vec.y/2),(vec.y/2))
	self:Normalize()
end
function CVector:GetSpread(vec)
	local ret=self:GetNormalized()
	ret.y=ret.y+math.rand(-(vec.x/2),(vec.x/2))
	ret.z=ret.z+math.rand(-(vec.y/2),(vec.y/2))
	return ret:GetNormalized()
end

function bit.has(o,f) return bit.band(o,f)==f end
hook.Add('OnEntityCreated','Improvements',function(ent) if ent:IsNextBot() then ent:AddFlags(FL_OBJECT) end end)