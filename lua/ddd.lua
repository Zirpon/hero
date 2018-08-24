local bigTable = {}


for i=1,1000000 do
    local key = 'dd_big_tableeeeeeeee'..i
    bigTable.key = i
    bigTable[i] = key
end

print("end dddd", #bigTable)

--[[
local usertable = {}


local meta = {}
meta.n = 0
meta.__newindex = function (t, k, v)
--    print("__newindex", k, v)
    if k == "n" then
        return nil
    end
    if not v then
        meta.n = (meta.n < 1 and 0) or (meta.n-1)
    else
        meta.n = meta.n + 1
    end

    t[k] = v
end
meta.__index = function(t,k)    
--    print("__index", k)
    if k == "n" then
        return meta.n
    else
        return t[k]
    end
end

setmetatable(usertable, meta)
usertable.name = "kawaii"
print(usertable.n) 
print(#usertable)
for i,v in pairs(usertable) do
    print(i,v)
end
usertable.name = nil
print(usertable.n) 
usertable.n = 90
print(usertable.n)
]]