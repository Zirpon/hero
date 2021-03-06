local rbtree = require "rbtree"

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
   while head do
      table.insert(s, head.key)
      head = head.next
   end
   
   return s
end


function merge (t1, t2)
   local walk1, walk2 = t1:walk(), t2:walk()
   local v1, v2 = walk1(), walk2()

   while v1 or v2 do
      if v1 and (not v2 or v1 < v2) then
         io.write(v1, " "); v1 = walk1()
      else
         io.write(v2, " "); v2 = walk2()
      end
   end
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

local tree = rbtree.new()
insert(tree, n)
print("OK insert")

local s = {}
for v in tree:walk() do
   s[#s+1] = v
   io.write(v, " ")
end
print("\n")

for _, v in ipairs(s) do
   print("OK delete", v)
   tree:delete(v)
end

print()

local tree1, tree2 = rbtree.new(), rbtree.new()

insert(tree1, n)
insert(tree2, n)

print("tree1")
for v in tree1:walk() do
   s[#s+1] = v
   io.write(v, " ")
end

print("\ntree2")
for v in tree2:walk() do
   s[#s+1] = v
   io.write(v, " ")
end

print("\nmerge")

merge(tree1, tree2)

print()

