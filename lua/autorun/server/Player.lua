hook.Add( 'PlayerSpawn', 'Player', function( self )
	self:SetColor( Color( 255, 255, 255 ) )
	self:Extinguish()
end )

VECTOR_HULL_HUMAN_MINS = Vector( -16, -16, 0 )
VECTOR_HULL_HUMAN_MAXS = Vector( 16, 16, 70 )

VECTOR_HULL_HUMAN_DUCK_MINS = Vector( -16, -16, 0 )
VECTOR_HULL_HUMAN_DUCK_MAXS = Vector( 16, 16, 46 )

hook.Add("Think","Player",function()
for _,ply in ipairs(player.GetAll()) do

if ply:GetHull()==vararg(Vector(-16,-16,0),Vector(16,16,72)) then ply:SetHull(Vector(-16,-16,0),Vector(16,16,70)) end
if ply:GetHullDuck()==vararg(Vector(-16,-16,0),Vector(16,16,36)) then ply:SetHullDuck(Vector(-16,-16,0),Vector(16,16,46)) end
if ply:InVehicle() then ply:Give("weapon_empty_hands") end
if ply:GetRunSpeed()==400 then ply:SetRunSpeed(250) end
if ply:GetWalkSpeed()==200 then ply:SetWalkSpeed(150) end
//50 Units vertically. How did I calculate? GetPos'es.
//(Did you really think I am smart enough to find a formula?)
if ply:GetJumpPower()==200 then ply:SetJumpPower(300) end
ply:SetSuppressPickupNotices( true )
ply:SetAllowWeaponsInVehicle( false )
ply:ConCommand( 'fov_desired 99' )

ply:SetSlowWalkSpeed(ply:GetWalkSpeed()*0.5) ply:SetCrouchedWalkSpeed(ply:KeyDown(IN_SPEED)&&1||0.5)

end
end)

concommand.Add("cl_hands",function(ply,cmd,args)

if !IsValid(ply) then return end
ply:Give("weapon_empty_hands")
ply:SelectWeapon("weapon_empty_hands")

end,void,"Selects hands.")

concommand.Add("cl_fists",function(ply,cmd,args)

if !IsValid(ply) then return end
ply:Give("weapon_fists")
ply:SelectWeapon("weapon_fists")

end,void,"Selects fists.")

concommand.Add("cl_select",function(ply,cmd,args)

if !IsValid(ply) then return end
ply:SelectWeapon(tostring(args[1]||void))

end,void,"Selects the told weapon class if the player has it.")