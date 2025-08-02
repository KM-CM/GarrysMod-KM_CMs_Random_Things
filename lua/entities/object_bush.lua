AddCSLuaFile()
DEFINE_BASECLASS( 'base_object' )

ENT.PrintName = '#object_bush'
if CLIENT then language.Add( 'object_bush', 'Bush' ) end

ENT.bDontBreak = True

sound.Add( {
	name = 'object_bush.rattle',
	sound = { 'npc/headcrab_poison/ph_rattle1.wav',
			  'npc/headcrab_poison/ph_rattle2.wav',
			  'npc/headcrab_poison/ph_rattle3.wav' },
	pitch = { 120, 125 },
	level = 70,
	channel = CHAN_AUTO,
} )

function ENT:SetupDataTables()
	self:NetworkVar( 'Float', 0, 'MinSize', { KeyName = 'MaxSize' } )
	self:NetworkVar( 'Float', 1, 'MaxSize', { KeyName = 'MaxSize' } )
	self:NetworkVar( 'Float', 2, 'TrueSize', { KeyName = 'TrueSize' } )
	
	self:NetworkVar( 'Float', 3, 'LifeTime', { KeyName = 'LifeTime' } )
	self:NetworkVar( 'Float', 4, 'BaseLifeTime', { KeyName = 'BaseLifeTime' } )
	
	self:NetworkVar( 'Float', 5, 'ChildCount', { KeyName = 'ChildCount' } )
	self:NetworkVar( 'Float', 6, 'BaseChildCount', { KeyName = 'BaseChildCount' } )
	
	self:NetworkVar( 'Float', 7, 'LivedTime', { KeyName = 'LivedTime' } )
	
	self:NetworkVar( 'Vector', 0, 'NatColor', { KeyName = 'NatColor' } )
	self:NetworkVar( 'Vector', 1, 'ReqColor', { KeyName = 'ReqColor' } )
end

function ENT:Initialize()
	self:SetModel( 'models/object_bush.mdl' )
	self:SetModelScale( .00001 )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_BBOX )
		
		local p = self:GetPhysicsObject()
		if IsValid( p ) then p:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG ) end
		
		self:SetMinSize( 1 )
		self:SetMaxSize( 6 )
		local TrueSize = math.rand( self:GetMinSize(), self:GetMaxSize() )
		self:SetTrueSize( TrueSize )
		
		self:SetBaseLifeTime( 25 )
		local LifeTime = TrueSize * self:GetBaseLifeTime()
		self:SetLifeTime( LifeTime )
		
		self:SetBaseChildCount( 2 )
		local ChildCount = math.Round( TrueSize * self:GetBaseChildCount() )
		self:SetChildCount( ChildCount )
		
		self:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self:RemoveEFlags( EFL_DONTBLOCKLOS )
		
		self:SetTrigger( True )

		if ChildCount > 0 then
			local Start = LifeTime * .5
			local End = LifeTime * .9
			local S = ( End - Start ) / ( ChildCount - 1 )
			local tChildSpawns = {}
			for I = 0, ChildCount - 1 do table.insert( tChildSpawns, Start + ( I * S ) ) end
			self.tChildSpawns = tChildSpawns
			self.iCurChild = 1
		end
		
		local N = Vector( math.rand( 0.5, 1 ), math.rand( 0.5, 1 ), math.rand( 0.5, 1 ) )
		self:SetNatColor( N )
		self:SetReqColor( N )
		self:SetColor( N:ToColor() )
	end
end

if SERVER then
	function ENT:CreateChildBush( Pos, Ang, Par )
		local Bush = ents.Create( 'object_bush' )
		Bush:SetPos( Pos )
		Bush:SetAngles( Ang )
		if IsValid( Par ) then Bush:SetParent( Par ) end
		//TODO: Child Bush's Data is Similar (But Different) to Ours
		Bush:Spawn()
	end

	local _nan = 0 / 0
	function ENT:Think()
		self:SetLivedTime( self:GetLivedTime() + FrameTime() )
		local w = self:WaterLevel()
		if w >= 3 then self:Remove() return end
		local r = w > 0 && self:GetNatColor() || self:GetNatColor() * .75
		self:SetReqColor( r )
		self:SetColor( LerpVector( FrameTime() * .5, self:GetColor():ToVector(), r ):ToColor() )
		local ldt, lft = self:GetLivedTime(), self:GetLifeTime()
		if ldt > lft then self:Remove() return end
		local s = Void
		local hlft = lft * .5
		local bGrowing = ldt <= hlft
		if bGrowing then
			s = ldt / hlft
			s = self:GetTrueSize() * ( s == _nan && .00001 || s )
		else
			s = hlft / ldt
			s = self:GetTrueSize() * ( s == _nan && .00001 || s )
		end
		if s then
			self:SetModelScale( s )
			self:SetCollisionBounds( Vector( -2, -2, 0 ) * s, Vector( 2, 2, 4 ) * s )
		end
		if !bGrowing && self:GetChildCount() > 0 then
			local iCur = self.iCurChild
			local iSpawn = self.tChildSpawns[ iCur ]
			if isnumber( iSpawn ) && ldt > iSpawn then
				//`M` is Squared for Performance Reasons
				local S = self:GetSize() //self:GetModelScale()
				local M, N = S * 10, S * 15
				for I = 1, 33 do
					local c = self:GetCenter()
					local tr = Trace( {
						start = c,
						endpos = c + VectorRand() * N,
						filter = function( ent ) return ent != self && ent:IsEnvironment() end,
						mask = MASK_SOLID
					} )
					if tr.Hit &&
					   !tr.HitSky &&
					   ( !IsValid( tr.Entity ) ||
					   IsValid( tr.Entity ) &&
					   tr.Entity:GetClass() != 'object_bush' ) &&
					   tr.HitPos:Distance( c ) > M then
																							//TODO: Make Them be AlongSide Walls, Ceilings, Etc
						self:CreateChildBush( tr.HitPos, Angle( 0, math.rand( 0, 360 ), 0 ) /*tr.HitNormal:Angle()*/, tr.HitEntity )
						self.iCurChild = iCur + 1
						break
					end
				end
			end
		end
		self:NextThink( CurTime() + .05 )
		return True
	end
	
	function ENT:StartTouch() self:EmitSound( 'object_bush.rattle' ) end
	function ENT:EndTouch() self:EmitSound( 'object_bush.rattle' ) end
end

function ENT:KeyValue( K, V )
	K = string.lower( K )
	if self:SetNetworkKeyValue( K, V ) then return end
end

list.Set( 'SpawnableEntities', 'object_bush', {
	PrintName = '#object_bush',
	ClassName = 'object_bush',
	Category = 'Foilage',
})

scripted_ents.Register( ENT, 'object_bush' )