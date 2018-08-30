--[[
   Copyright (C) Soojin Nam

   The red-black tree code is based on the algorithm described in
   the "Introduction to Algorithms" by Cormen, Leiserson and Rivest.
--]]

local type = type
local setmetatable = setmetatable
local insert = table.insert
local co_wrap = coroutine.wrap
local co_yield = coroutine.yield

local RED = 1
local BLACK = 0

local inorder_tree_walk
function inorder_tree_walk (x, Tnil)
   if x ~= Tnil then
      inorder_tree_walk (x.left, Tnil)
      co_yield(x.key)
      inorder_tree_walk (x.right, Tnil)
   end
end

local function tree_minimum (x, Tnil)
   while x.left ~= Tnil do
      x = x.left
   end
   return x
end

local function tree_search (x, k, Tnil)
   while x ~= Tnil and k ~= x.key do
      if k < x.key then
         x = x.left
      else
         x = x.right
      end
   end
   return x
end

local function treeSuccessor( T, x )
    if x.right ~= T.sentinenl then
        return tree_minimum(x.right, T.sentinel)
    end
    local y = x.p
    while y ~= T.sentinel and x == y.right do
        x = y
        y = y.p
    end
    return y
end

--------------------------------------------------------------------------------

local function left_rotate (T, x)
    local y = x.right
    x.right = y.left
    if y.left ~= T.sentinel then
        y.left.p = x
    end
    y.p = x.p 
    if x.p == T.sentinel then
        T.root = y
    elseif x == x.p.left then
        x.p.left = y
    else
        x.p.right = y
    end
    y.left = x
    x.p = y
end

local function right_rotate (T, x)
    local y = x.left
    x.left = y.right
    if y.right ~= T.sentinel then
        y.right.p = x
    end
    y.p = x.p
    if x.p == T.sentinel then
        T.root = y
    elseif x == x.p.right then
        x.p.right = y
    else
        x.p.left = y
    end
    y.right = x
    x.p = y
end

local function rb_insertFixup( T, z )
    while z.p.color == RED do
        if z.p == z.p.p.left then
            y = z.p.p.right
            if y.color == RED then
                z.p.color = BLACK
                y.color = BLACK
                z.p.p.color = RED
                z = z.p.p
            else
                if z == z.p.right then
                    z = z.p
                    left_rotate(T, z)
                end
                z.p.color = BLACK
                z.p.p.color = RED
                right_rotate(T, z.p.p)
            end
        else
            y = z.p.p.left
            if y.color == RED then
                z.p.color = BLACK
                y.color = BLACK
                z.p.p.color = RED
                z = z.p.p
            else
                if z == z.p.left then
                    z = z.p
                    right_rotate(T, z)
                end
                z.p.color = BLACK
                z.p.p.color = RED
                left_rotate(T, z.p.p)
            end
        end
    end
    T.root.color = BLACK
end

local function rb_insert (T, z)
    local y = T.sentinel
    local x = T.root
    while x ~= T.sentinel do
        y = x
        if z.key < x.key then
            x = x.left
        else
            x = x.right
        end
    end
    z.p = y
    if y == T.sentinel then
        T.root = z
    elseif z.key < y.key then
        y.left = z
    else
        y.right = z
    end
    z.left = T.sentinel
    z.right = T.sentinel
    z.color = RED
    rb_insertFixup(T,z)
end

local function rb_deleteFixup( T, x )
    while x ~= T.root and x.color == BLACK do
        local w
        if x == x.p.left then
            w = x.p.right
            if w.color == RED then
                w.color = BLACK
                x.p.color = RED
                left_rotate(T, x.p)
                w = x.p.right
            end
            if w.left.color == BLACK and w.right.color == BLACK then
                w.color = RED
                x = x.p
            else
                if w.right.color == BLACK then
                    w.left.color = BLACK
                    w.color = RED
                    right_rotate(T, w)
                    w = x.p.right
                end
                w.color = x.p.color
                x.p.color = BLACK
                w.right.color = BLACK
                left_rotate(T, x.p)
                x = T.root
            end
        else
            w = x.p.left
            if w.color == RED then
                w.color = BLACK
                x.p.color = RED
                right_rotate(T, x.p)
                w = x.p.left
            end
            if w.right.color == BLACK and w.left.color == BLACK then
                w.color = RED
                x = x.p
            else
                if w.left.color == BLACK then
                    w.right.color = BLACK
                    w.color = RED
                    left_rotate(T, w)
                    w = x.p.left
                end
                w.color = x.p.color
                x.p.color = BLACK
                w.left.color = BLACK
                right_rotate(T, x.p)
                x = T.root
            end
        end
    end
    x.color = BLACK
end

local function rb_delete(T, z)
    local w
    local x = T.sentinel
    local y = T.sentinel
    if z.left == T.sentinel or z.right == T.sentinel then
        y = z
    else
        y = treeSuccessor(T,z)
    end

    if y.left ~= T.sentinel then
        x = y.left
    else
        x = y.right
    end
    x.p = y.p
    if y.p == T.sentinel then
        T.root = x
    else
        if y == y.p.left then
            y.p.left = x
        else
            y.p.right = x
        end
    end

    if y ~= z then
        z.key = y.key
        z.value = y.value
        -- copy y's satellite data into z
    end
   
   if y.color == BLACK then
        rb_deleteFixup(T,x)
   end
end

local function rbtree_node (key, value)
   return { key = key or 0, value = value }
end

--------------------------------------------------------------------------------
-- rbtree module stuffs
--------------------------------------------------------------------------------

local _M = {}

local mt = { __index = _M }

function _M.new ()
   local sentinel = rbtree_node()
   sentinel.color = BLACK
   
   return setmetatable({ root = sentinel, sentinel = sentinel }, mt)
end

function _M.tnode (self, key)
   return rbtree_node(key)
end

function _M.walk (self)
   return co_wrap(function ()
                     inorder_tree_walk(self.root, self.sentinel)
                  end)
end

function _M.insert (self, key, value)
    local key = key
    if type(key) == "number" then
        key = rbtree_node(key, value)
    end
   
   rb_insert(self, key)
end

function _M.delete (self, key)
   local z = tree_search (self.root, key, self.sentinel)
   if z ~= self.sentinel then
        rb_delete(self, z)
   end
end

return _M

