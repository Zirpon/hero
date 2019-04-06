----------------------------------------------------------------------------------
-- 协程
--[[
co = coroutine.create(function (a,b)
   print("before yield")
   coroutine.yield(a + b, a - b)
   print("after yield")
end)
local ret,a,b = coroutine.resume(co, 20, 10)
print(ret, a, b)
ret,a,b = coroutine.resume(co)
print(ret, a, b)
]]

----------------------------------------------------------------------------------
-- 环境 _G
--[[
print("++++++++++++++++++")
local declaredNames = {}

function declare (name, initval)
    rawset(_G, name, initval)
    declaredNames[name] = true
end

setmetatable(_G, {
    __newindex = function (t, n, v)
        if not declaredNames[n] then
            print("attempt to write to undeclared var. "..n, 2)
        else
            rawset(t, n, v) -- do the actual set
        end
    end,
    __index = function (_, n)
        if not declaredNames[n] then
            print("attempt to read undeclared var. "..n, 2)
        else
            return nil
        end
    end,
})

a=3
declare 'a'
a = 2
print(a)
print(_G['a'])
]]
----------------------------------------------------------------------------------
--[[
print("++++++++++++++++++")

Account = {
    balance = 9,
}

function Account:withdraw (v)
    self.balance = self.balance - v
end

function Account:deposit (v)
    print("ddds", self.balance)
    self.balance = self.balance + v
end

function Account:new (o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = function (t,k)
        return self[k]
    end
    print("ddds oo", o.balance)
    print("ddd self", self.balance)
    print("ddds o", o.balance)
    return o
end

a = Account:new()
print(a.balance)
a:deposit(100)
print(a.balance)


b = Account:new()
print(b.balance)
print(a.balance)
]]
----------------------------------------------------------------------------------
-- weak table 
--[[
print("++++++++++++++++++")

a = {}
b = {}
setmetatable(a, b)
b.__mode = "k" -- now 'a' has weak keys
key = {} -- creates first key
a[{key}] = 1
key = {} -- creates second key
a[key] = 2
key = nil
collectgarbage() -- forces a garbage collection cycle
for k, v in pairs(a) do print(v) end
]]
----------------------------------------------------------------------------------
-- table 
print("++++++++++++++++++")

a = {1, 2, key = '1234321', nil, 15, 'sagewqgag', nil}

for k,v in pairs(a) do
    print(k,v)
end

for k,v in ipairs(a) do
    print('kdkdk:',k,v)
end

print('len:',#a)

dd = debug.getinfo( print )

for k,v in pairs(dd) do
    print(k,v)
end