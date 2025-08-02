NavMesh = nav

NavMesh.CalcHidingSpots = function( area )
	if !area then return end
	local mins = area:GetCorner( 0 )
	local maxs = area:GetCorner( 2 )
	for X = mins.x, maxs.x, 150 do
		for Y = mins.y, maxs.y, 150 do
			local V = Vector( X, Y, 0 )
			V.z = area:GetZ( V )
			area:AddHidingSpot( V, 8 )
		end
	end
	/*
	for i=0,3 do
		local cor=area:GetCorner(i)
		local ncor=area:GetCorner((i==3&&0||i+1))
		local dist=cor:Distance(ncor)
		for step=1,math.floor(dist/math.clamp(dist*0.3,100,300)) do
			local pos=cor+(ncor-cor):GetNormalized()*(step*math.min(dist*0.5,250))+Vector(0,0,50)
			if (Trace({
				start=pos,
				endpos=pos+Vector(100,0,0),
				mask=MASK_SOLID_BRUSHONLY,
			}).Hit||Trace({
				start=pos,
				endpos=pos+Vector(-100,0,0),
				mask=MASK_SOLID_BRUSHONLY,
			}).Hit||Trace({
				start=pos,
				endpos=pos+Vector(0,100,0),
				mask=MASK_SOLID_BRUSHONLY,
			}).Hit||Trace({
				start=pos,
				endpos=pos+Vector(0,-100,0),
				mask=MASK_SOLID_BRUSHONLY,
			}).Hit) then area:AddHidingSpot(pos+Vector(0,0,-50),1) end
		end
	end
	*/
end

concommand.Add( 'nav_calc_hiding_spots', function( ply, cmd, args ) for _, n in ipairs( navmesh.GetAllNavAreas() ) do navmesh.CalcHidingSpots( n ) end end, nil, "Calculates all hiding spots for the current navigation mesh.", FCVAR_CHEAT )

hook.Add( 'InitPostEntity', 'NavMesh', function()
	timer.Simple( 0, function()
		for _, n in ipairs( navmesh.GetAllNavAreas() ) do navmesh.CalcHidingSpots( n ) end
	end )
end )