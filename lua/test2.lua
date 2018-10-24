
local oo ={}
oo.k = 10
local t = oo.k
oo.k = 9
oo[10.222]=98
oo[true]=92
oo[false]=93
oo[1]=false
oo[true]=999
for k,v in pairs(oo) do
    print(k,v)
end
print(t)

local ddd = {[222]={id=2,name='22',size={2,4,5,},},}
for k,v in pairs(ddd) do
    if type(v) == "table" then
        for kele,vele in pairs(v) do
            if type(vele) == 'table' then
                for kdd,vdd in pairs(vele) do
                    print(kdd,vdd)
                end
            else
                print(kele,vele)
            end
        end
    else
        print(k,v)
    end
end

--[[
function function_name( a, b )
    a % b == a - math.floor(a/b)*b  
end
]]
function domod( a,b )
    return a - math.floor(a/b)*b
end