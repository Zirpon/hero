local skiplist = require "skiplist"

local MAXN = 10000

-- Floyd's random permutation generator
local function permgen (m, n)
   local s, head = {}
   for j = n-m+1, n do
      local t = math.random(j)
      if not s[t] then
         head = { key = t, next = head }
         s[t] = head
      else
         local curr = { key = j, next = s[t].next }
         s[t].next = curr
         s[j] = curr
      end
   end

   s = {}
   local keys = ""
   while head do
      table.insert(s, head.key)
      keys = keys..head.key.." "
      head = head.next
   end
   --print("ready key:"..keys)
   
   return s
end

function insert(tree, n)
   local arr = permgen(n, MAXN)
   for _, v in ipairs(arr) do
      tree:insert(v)
   end
end

math.randomseed(os.time())
local n = tonumber(arg[1]) or 10
if n > MAXN then n = MAXN end

local list = skiplist.new()
insert(list, n)
--print("OK insert",n)
list:print()
--print(list:max().score)

local s = {}
for v in list:walk() do
   s[#s+1] = v
   --io.write(v, " ")
end
--print("\n")

for i=#s,1,-1 do
    v=s[i]
    print("\nOK delete", v)
    list:remove(v)
    --list:print()
    print(list:max() and list:max().score or 0)
    print(list:len())
end
--[[
for _, v in ipairs(s) do
   print("\nOK delete", v)
   list:remove(v)
   --list:print()
   print(list:max() and list:max().score or 0)
end]]
list:print()
