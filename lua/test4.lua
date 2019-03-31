co = coroutine.create(function (a,b)
   print("before yield")
   coroutine.yield(a + b, a - b)
   print("after yield")
end)
local ret,a,b = coroutine.resume(co, 20, 10)
print(ret, a, b)
ret,a,b = coroutine.resume(co)
print(ret, a, b)

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