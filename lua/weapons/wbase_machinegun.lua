//Modified OSIMG parameters. The best way to show what this does is to look at a weapon with those or similar.
SWEP.IgnoreCurShot=no
SWEP.ROFMax=0.033
SWEP.ROFMin=0.33
SWEP.ROFCur=0.33
SWEP.ROFSmallifyPerShot=0.033
SWEP.ROFDontStop=0.22 //For how much we can stop firing until we lose Rate Of Fire?

function SWEP:PrimaryAttack()
	if !self:CanPrimaryAttack() then return end
	self:DoPrimary()
	self:SetNextPrimaryFire(CurTime()+self.ROFCur)
	if !self.IgnoreCurShot then self.ROFCur=math.clamp(self.ROFCur-self.ROFSmallifyPerShot,self.ROFMax,self.ROFMin) end
	self.IgnoreCurShot=!self.IgnoreCurShot
	self:AddThink(function(ent,rm) if CurTime()>(ent:GetNextPrimaryFire()+math.max(ent.ROFDontStop,self.ROFCur+0.01)) then ent.ROFCur=ent.ROFMin ent.IgnoreCurShot=yes rm() end end)
end 