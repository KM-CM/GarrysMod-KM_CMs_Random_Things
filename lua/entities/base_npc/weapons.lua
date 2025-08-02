enum("NPC_FIREWEAPON",{
	"EARLY",
	"OK",
	"DOESNTEXIST",
	"NOFUNC",
	"CANT",
	"INDELAY",
})

function ENT:GetAmmoCount(id) return 9999 end
function ENT:RemoveAllAmmo()end
function ENT:RemoveAmmo()end

//ENT.Weapon=void
//For ENT:SetActiveWeapon(weapon), scroll down!
function ENT:GetActiveWeapon() return self.Weapon end
ENT.GetWeapon=ENT.GetActiveWeapon

function ENT:HasWeapon(c) if !isstring(c) then return IsValid(self.Weapon) end return IsValid(self.Weapon)&&self.Weapon:GetClass()==c||!IsValid(self.Weapon) end
function ENT:GetWeapons() return {self:GetActiveWeapon()} end
function ENT:ValidWeapon(wep) return IsValid(wep)&&!wep:IsScripted()&&wep:Clip1()>0 end

ENT.ShootBone="ValveBiped.Weapon_bone"
function ENT:GetShootPos()
	local b=self:LookupBone(tostring(self.ShootBone))
	if b then
		return self:GetBonePosition(b)||self:EyePos()
	else
		return self:EyePos()
	end
end

ENT.flLastPShot=0
ENT.flLastSShot=0
function ENT:FireWeapon(bPrimary,flNonAutoMulM,flNonAutoMulN)
	if !self:CanAttack() then return NPC_FIREWEAPON_EARLY end
	if bPrimary == Void then bPrimary=true end
	if !IsValid(self:GetActiveWeapon()) then return NPC_FIREWEAPON_DOESNTEXIST end
	local wep=self:GetActiveWeapon()
	if !(bPrimary&&wep.NPCShoot_Primary||wep.NPCShoot_Secondary) then return NPC_FIREWEAPON_NOFUNC end
	if !(bPrimary&&wep:CanPrimaryAttack()||wep:CanSecondaryAttack()) then return NPC_FIREWEAPON_CANT end
	flNonAutoMulM = tonumber( flNonAutoMulM ) || 1
	flNonAutoMulN = tonumber( flNonAutoMulN ) || 5
	local d = Void
	if !self:IsWeaponAutomatic( bPrimary ) && self.flLastPShot && self.flLastSShot then
		local t = ( bPrimary && self.flLastPShot || self.flLastSShot )
		d = t + ( ( ( bPrimary && wep:GetNextPrimaryFire() || wep:GetNextSecondaryFire() ) - t ) * math.rand( flNonAutoMulM, flNonAutoMulN ) )
	else
		d = bPrimary && wep:GetNextPrimaryFire() || wep:GetNextSecondaryFire()
	end
	if CurTime() < d then return NPC_FIREWEAPON_INDELAY end
	local v = self:GetAimVector()
	self:SetAimVector( self:AimSpread( v ) )
	if bPrimary then
		wep:NPCShoot_Primary()
		self.flLastPShot=CurTime()
	else
		wep:NPCShoot_Secondary()
		self.flLastSShot=CurTime()
	end
	self:SetAimVector( v )
	return NPC_FIREWEAPON_OK
end

function ENT:IsWeaponAutomatic( bPrimary )
	if bPrimary == Void then bPrimary = True end
	local wep = self.Weapon
	if !IsValid( wep ) then return end
	if bPrimary then
		if istable( wep.Primary ) then return wep.Primary.Automatic end
		return true
	else
		if istable( wep.Secondary ) then return wep.Secondary.Automatic end
		return true
	end
end

function ENT:AimSpread( vec )
	local v = self.VisNight && 0 || math.max( 1 - ColorStabilizeDivider(), 0 )
	return vec:GetSpread( Vector( v, v, v ) ):GetNormalized()
end

ENT.flVolleyShootUntil=0
ENT.flVolleyDontShootUntil=0
function ENT:FireVolley( flVolleyLenMul, flBreakLenMul, ... )
	if bPrimary == Void then bPrimary = True end
	flVolleyLenMul,flBreakLenMul=tonumber(flVolleyLenMul)||1,tonumber(flBreakLenMul)||1
	if CurTime()>self.flVolleyShootUntil then
		if CurTime()>self.flVolleyDontShootUntil then
			self.flVolleyShootUntil=CurTime()+math.rand(unpack(self.VolleyTimes))*flVolleyLenMul
		end
		return
	else self.flVolleyDontShootUntil=CurTime()+math.rand(unpack(self.VolleyBreakTimes))*flBreakLenMul end
	return self:FireWeapon( ... )
end

function ENT:ActWep(act)
	local w=self:GetActiveWeapon()
	if IsValid(w)&&type(w.ActivityTranslateAI)=='table'&&w.ActivityTranslateAI[act] then return w.ActivityTranslateAI[act] end
	return act
end

function ENT:HasWeaponAmmo() return true end
//function ENT:HasWeaponAmmo() return Either(IsValid(self.Weapon)&&self.Weapon.HasAmmo,pcall_ret(function()return self.Weapon:HasAmmo()end)==yes,no) end

/*////////////////////////////////////////////////////////
Void ENT:Give(String WeaponClass)

1/String WeaponClass: The weapon class to give us.

Spawns a weapon and gives it to us.
Use the raw code from the func if you want to have a return.

DEFAULT:NONE
RETURNS:[[
	Weapon OurWeapon, :: The weapon we got. Can be nothing if class is invalid, or any other reason.
]]
////////////////////////////////////////////////////////*/
function ENT:Give( Class ) return pcall_ret( function() local wep = ents.Create( tostring( Class ) ) wep:Spawn() self:SetActiveWeapon( wep ) return wep end ) end
function ENT:DefaultWeapon( Class ) if !IsValid( self.Weapon ) then self:Give( Class ) end end

/*////////////////////////////////////////////////////////
Weapon ENT:SetActiveWeapon(Weapon NewWeapon)

1/Weapon NewWeapon: The weapon to pickup.

Drops the current weapon,
Sets up the physobj and flags of the weapon,
Removes velocity and correctly parents it,
Then, if clip1 or clip2 values are illogical, sets them to 1.
In simple words: Picks it up.

RETURN: Weapon NewWeapon - The Weapon We Got.
////////////////////////////////////////////////////////*/
function ENT:SetActiveWeapon(wep)
	if wep==self.Weapon||!IsValid(wep)||IsValid(wep)&&!wep:IsScripted() then return self.Weapon end
	if self:HasWeapon() then self:DropWeapon() end
	wep:SetPos(self:GetPos())
	wep:SetAng(self:GetAng())
	wep:SetVelocity(vector_origin)
	wep:SetParent(self)
	wep:SetOwner(self)
	wep:RemoveSolidFlags(FSOLID_TRIGGER)
	wep:PhysicsDestroy()
	wep:SetMoveType(MOVETYPE_NONE)
	wep:AddEffects(EF_BONEMERGE)
	wep:AddSolidFlags(FSOLID_NOT_SOLID)
	wep:SetLocalPos(vector_origin)
	wep:SetLocalAngles(angle_zero)
	wep:SetTransmitWithParent(yes)
	if wep:Clip1()<0 then wep:SetClip1(1) end
	if wep:Clip2()<0 then wep:SetClip2(1) end
	self.Weapon=wep
	pcall(function()wep:OwnerChanged()end)
	pcall(function()wep:Equip(self)end)
	return wep
end
ENT.SetWeapon=ENT.SetActiveWeapon

/*////////////////////////////////////////////////////////
Weapon ENT:DropWeapon()

Drop the current weapon.
Unchecks the weapon,
Makes it solid,
And activates its PhysObj.

Returns: Weapon DroppedWeapon - The Weapon We Dropped.
////////////////////////////////////////////////////////*/
function ENT:DropWeapon()
	local wep=self:GetActiveWeapon()
	if !IsValid(wep) then return NULL end
	self.Weapon=NULL
	wep:SetParent()
	wep:RemoveEffects(EF_BONEMERGE)
	wep:RemoveSolidFlags(FSOLID_NOT_SOLID)
	wep:CollisionRulesChanged()
	wep:SetOwner(NULL)
	wep:SetMoveType(MOVETYPE_VPHYSICS)
	if !wep:PhysicsInit(SOLID_VPHYSICS) then
		wep:SetSolid(SOLID_OBB)
	else
		wep:SetMoveType(MOVETYPE_VPHYSICS)
		wep:PhysWake()
	end
	local sf=wep:GetSolidFlags()
	wep:SetSolidFlags(bit.bor(sf,FSOLID_TRIGGER))
	wep:SetTransmitWithParent(no)
	pcall(function()wep:OwnerChanged()end)
	pcall(function()wep:OnDrop()end)
	wep:SetPos(self:GetShootPos())
	wep:SetAngles(self:GetAngles())
	local phys=wep:GetPhysicsObject()
	if IsValid(phys) then phys:AddVelocity(self.loco:GetVelocity()) else wep:SetVelocity(self.loco:GetVelocity()) end
	return wep
end

/*////////////////////////////////////////////////////////
Boolean ENT:CanAttack()

Can we attack right now?
////////////////////////////////////////////////////////*/
function ENT:CanAttack()
	return self:Disposition( TraceBox( {
		start = self:GetShootPos(),
		endpos = self:GetShootPos() + self:GetAimVector() * 999999,
		filter = self:AllRelatedEntities(),
		mask = MASK_SOLID_AND_NPCS,
		mins = Vector(-15,-15,-15),
		maxs = Vector(15,15,15),
	} ).Entity ) != D_LI
end
