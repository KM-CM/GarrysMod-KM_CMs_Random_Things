/*////////////////////////////////////////////////////////
Here's an Example of The Globals This Adds:
enum( 'ENUM', {
	'NOTHING', //ENUM_NOTHING, -1
	'EMPTY', //ENUM_EMPTY, 0
	'THING1', //ENUM_THING1, 1
	'THING2', //ENUM_THING2, 2
	[...]
} )
For Consistency, Keep Enums Caps.
////////////////////////////////////////////////////////*/

function enum(pr,...)
	for i,n in ipairs(type(...)=='table'&&...||{...}) do
		i=i-2
		_G[pr+"_"+n]=i
		_G[pr+"i"]=i
	end
end
function enum0(pr,...)
	for i,n in ipairs(type(...)=='table'&&...||{...}) do
		i=i-1
		_G[pr+"_"+n]=i
		_G[pr+"i"]=i
	end
end
function enumex(nm) return isnumber(_G[nm]+"i") end
Enum,Enum0,EnumExists=enum,enum0,enumex