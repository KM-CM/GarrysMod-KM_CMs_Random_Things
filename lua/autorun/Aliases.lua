Yes,YES,yes=true,true,true
No,NO,no=false,false,false
On,ON,on=true,true,true
Off,OFF,off=false,false,false
True,TRUE=true,true
False,FALSE=false,false
None,NONE,none=nil,nil,nil
Nothing,NOTHING,nothing=nil,nil,nil
Void,VOID,void=nil,nil,nil
Nil,NIL=nil,nil
Null,null=NULL,NULL

MENU=MENU_DLL

rand=math.random
table.add=table.Add

ScreenShake,BlastDamage=util.ScreenShake,util.BlastDamage
TraceLine,TraceHull=util.TraceLine,util.TraceHull
Trace,TraceBox=TraceLine,TraceHull
AddClass,AddNPCClass=Add_NPC_Class,Add_NPC_Class
DEFINE_GMBASE=DeriveGamemode
Print,printtable=print,PrintTable

nav=navmesh
base=baseclass
phtool=constraint
perms=permissions
weps,entities=weapons,scripted_ents
sents,sweps=scripted_ents,weps

Ang,Vec=Angle,Vector
AngRand,VecRand=AngleRand,VectorRand
local ent=FindMetaTable("Entity")
function ent:GetAng() return self:GetAngles() end
function ent:SetAng(p) return self:SetAngles(p) end
function ent:GetVec() return self:GetPos() end
function ent:SetVec(p) return self:SetPos(p) end

//AMMO
AMMO={}
AMMO.PULSE="AR2"
AMMO.PISTOL="Pistol"
AMMO.PISTOLHEAVY="357"
AMMO.BULLET="SMG1"
AMMO.PELLET="Buckshot"
AMMO.GRENADE="Grenade"
AMMO.ROCKET="RPG_Round"
AMMO.BOLTS="XBowBolt"
if CLIENT then
	language.Add("AR2_ammo","Pulse Ammo")
	language.Add("Pistol_ammo","Pistol Bullets")
	language.Add("357_ammo","Strong Pistol Bullets")
	language.Add("SMG1_ammo","Assault Rifle Bullets")
	language.Add("Buckshot_ammo","Pellets")
	language.Add("Grenade_ammo","Grenades")
	language.Add("RPG_Round_ammo","Missiles")
	language.Add("XBowBolt_ammo","Crossbow Bolts")
end 