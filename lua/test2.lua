local oo ={}
oo.k = 10
local t = oo.k
oo.k = 9
print(t)

function function_name( a, b )
    a % b == a - math.floor(a/b)*b  
end

function domod( a,b )
    return a - math.floor(a/b)*b
end