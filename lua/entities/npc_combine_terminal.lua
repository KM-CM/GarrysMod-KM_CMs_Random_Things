AddCSLuaFile()
DEFINE_BASECLASS 'base_npc'

ENT.Name = 'Combine Terminal'

ENT.VisNight = true

ENT.bUseFindLookAng = false
ENT.bNoPhysics = false
ENT.bFlying = true

ENT.bCantStackUp = true

function ENT:OnDeath( d ) self:DeathMessage( d ) self:Remove() end

/*
`rand( self.Terminal:GetChangeChance() ) == 1`
The Code Above Explains Everything. When You want to Do an Action, It.
If The Result is `true`, Do It, Else, Dont Do Anything.
Used so That, for Example, Lights Dont Turn on Immideatly All at Once.
*/
function ENT:GetChangeChance() return 250 * FrameTime() end

ENT.sLightOrders = 'OFF'
//ENT.bSirens = false
//ENT.bWeakSirens = false
ENT.flNextScan = 0

ENT.tConnections = {}

ENT.iClass = CLASS_COMBINE

function ENT:Init()
	self:SetModel( 'models/props_combine/combine_interface001.mdl' )
	self:SetHealth( 500 )
	self:SetMaxHealth( 500 )
	self:SetBloodColor( BLOOD_COLOR_MECH )
end

local npc_combine_terminal_scan_dist = CreateConVar(
	'npc_combine_terminal_scan_dist',
	4000,
	FCVAR_NEVER_AS_STRING+
	FCVAR_CHEAT+
	FCVAR_NOTIFY+
	FCVAR_SERVER_CAN_EXECUTE,
	"How Far can an `npc_combine_terminal` Scan?"
)
function ENT:_Scan()
	if CurTime() <= self.flNextScan then return end
	for _, ent in ipairs( self.tConnections ) do if IsValid( ent ) then ent.Terminal = nil end end
	local t, n = {}, npc_combine_terminal_scan_dist:GetFloat()
	self.flAllySearchDist = n
	for _, ent in ipairs( self:HaveAllies() ) do
		//Why would a Terminal Handle Something That isnt Handled by a Terminal?
		if !ent.bCombineTerminal || IsValid( ent.Terminal ) && ent.Terminal != self then continue end
		local d = ent:GetPos():Distance( self:GetPos() )
		if d > n then continue end
		table.insert( t, { ent, d } )
	end
	local c = {}
	self.tConnections = c
	for _, d in ipairs( t ) do
		local ent = d[ 1 ]
		table.insert( c, ent )
		ent.Terminal = self
	end
	self.flNextScan = CurTime() + math.rand( .33, .66 )
end

function ENT:ForceTick() self:_Scan() end

function ENT:CombatBehaviour()
	self.bSirens = true
	self.bWeakSirens = true
	self.sLightOrders = self.bAllyVisNight && 'COMBAT' || 'COMBAT_BRIGHT'
end
function ENT:AlertBehaviour()
	self.bSirens = nil
	self.bWeakSirens = true
	self.sLightOrders = self.bAllyVisNight && 'ALERT' || 'ALERT_BRIGHT'
end
function ENT:PatrolBehaviour()
	self.bSirens = nil
	self.bWeakSirens = true
	self.sLightOrders = self.bAllyVisNight && 'ALERT' || 'ALERT_BRIGHT'
end
function ENT:IdleBehaviour()
	self.bSirens = nil
	self.bWeakSirens = nil
	self.sLightOrders = self.bAllyVisNight && 'OFF' || 'ON'
end

//Keep The Terminal in The `SpawnableEntities` List, Not in The `NPC` List
list.Set( 'SpawnableEntities', 'npc_combine_terminal', {
	PrintName = '#npc_combine_terminal',
	ClassName = 'npc_combine_terminal',
	Category = 'Combine'
} )

ENT.Class = 'npc_combine_terminal' NPC.Register( ENT )
