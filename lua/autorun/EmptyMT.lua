CEmptyMT={}

CEmptyMT.__index=CEmptyMT||function(o) return o||void; end

CEmptyMT.__call=function() return void; end

CEmptyMT.__add=function() return 0; end 
CEmptyMT.__sub=function() return 0; end 
CEmptyMT.__mul=function() return 0; end 
CEmptyMT.__div=function() return 0; end 
CEmptyMT.__unm=function() return 0; end 
CEmptyMT.__mod=function() return 0; end 
CEmptyMT.__pow=function() return 0; end 
CEmptyMT.__idiv=function() return 0; end 

CEmptyMT.__band=function() return 0; end 
CEmptyMT.__bor=function() return 0; end 
CEmptyMT.__bxor=function() return 0; end 
CEmptyMT.__bnot=function() return 0; end 
CEmptyMT.__shl=function() return 0; end 
CEmptyMT.__shr=function() return 0; end

CEmptyMT.__eq=function() return no end
CEmptyMT.__lt=function() return no end
CEmptyMT.__le=function() return no end

CEmptyMT.__concat=function() return ""; end
CEmptyMT.__len=function() return 0; end

function EmptyMT()
	local self=setmetatable({},CEmptyMT)
	return self
end