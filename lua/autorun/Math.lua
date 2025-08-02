Math=math
clamp,lmin,lmax,abs=Math.Clamp,Math.min,Math.max,Math.abs

function nums(...) local r={} for _,num in pairs({...}) do if tonumber(num) then table.insert(r,num) end end return r end Math.nums=nums Math.Nums=nums
function average(...) local r=Math.sum(...) return r/#Math.nums(...) end Math.average=average Math.Average=average
function sum(...) local r=0 for _,num in ipairs(Math.nums(...)) do r=r+num end return r end Math.sum=sum Math.Sum=sum
function diff(a,b) return abs(a-b) end Math.diff=diff Math.Diff=diff
function map(n,m1,n1,m2,n2) return (n-m1)/(n1-m1)*(n2-m2)+m2 end Math.map=map Math.Map=map //I need this more than an average programmer needs coffee

//Power stuff, its fun, but boring as HELL to write
//(My eyes bleed looking at the amount of X'es)
function sqr(x) return x*x end Math.sqr=sqr Math.Sqr=sqr
function sqrrt(x) return x^0.5 end Math.sqrt=sqrrt Math.sqrrt=sqrrt Math.SqrRT=sqrrt

function cube(x) return x*x*x end Math.cube=cube Math.Cube=cube
do local p=1/3 function cubert(x) return x^p end Math.cubert=cubert Math.CubeRT=cubert end //Great, now I cant unsee name Cubert in cube root

function quad(x) return x*x*x*x end Math.quad=quad Math.Quad=quad
function quadrt(x) return x^0.25 end Math.quadrt=quadrt Math.QuadRT=quadrt

function quint(x) return x*x*x*x*x end Math.quint=quint Math.Quint=quint
function quintrt(x) return x^0.2 end Math.quintrt=quintrt Math.QuintRT=quintrt

function hex(x) return x*x*x*x*x*x end Math.hex=hex Math.Hex=hex
do local p=1/6 function hexrt(x) return x^p end Math.hexrt=hexrt Math.HexRT=hexrt end

function sept(x) return x*x*x*x*x*x*x end Math.sept=sept Math.Sept=sept
do local p=1/7 function septrt(x) return x^p end Math.septrt=septrt Math.SeptRT=septrt end

function oct(x) return x*x*x*x*x*x*x*x end Math.oct=oct Math.Oct=oct
function octrt(x) return x^0.125 end Math.octrt=octrt Math.OctRT=octrt

function non(x) return x*x*x*x*x*x*x*x*x end Math.non=non Math.Non=non
do local p=1/9 function nonrt(x) return x^p end Math.nonrt=nonrt Math.NonRT=nonrt end

function dec(x) return x*x*x*x*x*x*x*x*x*x end Math.dec=dec Math.Dec=dec //December lol
function decrt(x) return x^0.1 end Math.decrt=decrt Math.DecRT=decrt