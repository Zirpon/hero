local bigTable = {}

--[[
for i=1,1000000 do
    local key = 'dd_big_tableeeeeeeee'..i
    bigTable.key = i
    bigTable[i] = key
end
]]
print("end dddd", #bigTable)
local function ddd(tab)
    
    tab = {c=33}
end

local mk = {c=22}
ddd(mk)
print(mk.c)

local class = {}
function class.new()
    local tmp = {}
    
    return setmetatable(tmp,{__index=class})
end

function class:insert(key, value)
    self[key]= value
    return key
end

local mine = class.new()
mine:insert(3,'ddasgfa')
mine:insert('asdasf',214215)

for i,k in pairs(mine) do
    print("mine:",i,k)
end

local mine2 = class.new()
mine2:insert(4,'ddasgfa')
mine2:insert('asdasf',99)

for i,k in pairs(mine2) do
    print("mine2:",i,k)
end

function mkmk()
    local bb = {}
    bb.a = 44
    return bb
end

local kkk = mkmk()
print(kkk.a)

--[[
local usertable = {}


local meta = {}
meta.n = 0
meta.__newindex = function (t, k, v)
--    print("__newindex", k, v)
    if k == "n" then

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
