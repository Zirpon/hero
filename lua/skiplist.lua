--[[
    based on the redis source code t_zset.c skiplist
]]

local co_wrap = coroutine.wrap
local co_yield = coroutine.yield
local ZSKIPLIST_MAXLEVEL = 32
local ZSKIPLIST_P = 0.25

local function zslCreate(  )
    local zsl = {level = 1, length = 0, header = {}, tail = false}
    zsl.header.level = {}
    zsl.header.score = 0
    zsl.header.value = nil
    zsl.header.backward = false
    for i = 1, ZSKIPLIST_MAXLEVEL do
        zsl.header.level[i] = {span = 0, forward = false}
    end
    return zsl
end

local function zslRandomLevel( )
    math.randomseed(os.time())
    local stand = math.floor(ZSKIPLIST_P * 0xFFFF)
    local level = 1
    while (math.random(0xFFFF) < stand) and (level < ZSKIPLIST_MAXLEVEL) do
        level = level + 1
    end
    return level
end

local function zslInsert(zsl, score, value)
    local rank = {}
    local update = {}
    local x = zsl.header
    for i = zsl.level, 1, -1 do
        rank[i] = ((i == zsl.level) and 0) or rank[i+1]
        while x.level[i] and x.level[i].forward and (x.level[i].forward.score < score or
            (x.level[i].forward.score == score and x.level[i].forward.value ~= value))
        do
            rank[i] = rank[i] + x.level[i].span
            x = x.level[i].forward
        end
        update[i] = x
    end

    local level = zslRandomLevel()
    if level > zsl.level then
        for i = zsl.level + 1, level do
            rank[i] = 0
            update[i] = zsl.header
            update[i].level = update[i].level or {}
            update[i].level[i] = {span = zsl.length, forward = false}
            --print("zslInsert addlevel", i, update[i].score, update[i].level[i].span)
        end
        zsl.level = level
    end

    local node = {}
    node.score = score
    node.value = value
    node.level = {}
    --node.backward = nil
    for i = 1, level do
        node.level[i] = {}
        node.level[i].forward = update[i].level[i].forward
        update[i].level[i].forward = node

        node.level[i].span = update[i].level[i].span - (rank[1] - rank[i])
        update[i].level[i].span = rank[1] - rank[i] + 1
        --print("zslInsert level add node", i, node.score, node.level[i], node.level[i].span)
        --print("zslInsert level add node update", i, update[i].score, update[i].level[i].span)
    end

    if level < zsl.level then
        for i = level, zsl.level do
            update[i].level[i].span = update[i].level[i].span + 1
        end
    end

    node.backward = ((update[1] ~= zsl.header) and update[1]) or false
    if node.level[1].forward then
        node.level[1].forward.backward = node
    else
        zsl.tail = node
    end
    zsl.length = zsl.length + 1
    return node
end

local function zslDeleteNode( zsl, x, update )
    for i = 1, zsl.level do
        if update[i].level[i].forward == x then
            update[i].level[i].span = update[i].level[i].span + x.level[i].span - 1
            update[i].level[i].forward = x.level[i].forward
        else
            update[i].level[i].span = update[i].level[i].span - 1 
        end
    end

    if x.level[1].forward then
        x.level[1].forward.backward = x.backward
    else
        zsl.tail = x.backward
    end

    while zsl.level > 1 and zsl.header.level[zsl.level].forward == false do
        zsl.level = zsl.level - 1
    end
    zsl.length = zsl.length - 1
end

local function zslDelete( zsl, score, value )
    local x = zsl.header
    local update = {}
    for i = zsl.level, 1, -1 do
        -- 如果值相同多个 找到新插入的
        while x.level[i].forward and (x.level[i].forward.score < score or
            (x.level[i].forward.score == score and x.level[i].forward.value ~= value))
        do
            x = x.level[i].forward
        end
        update[i] = x
    end

    x = x.level[1].forward
    if x and score == x.score then
        zslDeleteNode(zsl, x, update)
        return true, x
    end

    return false
end

local function zslGetLastNode( zsl )
    local x = zsl.header
    for i = zsl.level, 1, -1 do
        while x.level[i].forward do
            x = x.level[i].forward
        end
    end
    if x == zsl.header then
        return nil
    end
    return x
end

local function zslFormat( zsl )
    local cutting = "++++++++++++++++++++++++++++++++++++++++ "..zsl.level.."\n"
    local szFormat = cutting
    for i = zsl.level, 1, -1 do
        szFormat = szFormat.."level_"..i..":"..zsl.header.score

        for ispan = 1, zsl.header.level[i].span do
            szFormat = szFormat.." * "
        end

        local x = zsl.header.level[1]
        while x.forward do
            if x.forward.level[i] then
                szFormat = szFormat..x.forward.score.." "
                --[[
                for ispan = 1, x.forward.level[i].span do
                    szFormat = szFormat.." - "
                end]]
            else
                szFormat = szFormat.." * "
            end
            x = x.forward.level[1]
        end
        szFormat = szFormat.."\n"
    end
    local szFormat = szFormat..cutting
    return szFormat
end

local function inorder_list_walk( zsl )
    local x = zsl.header.level[1]
    while x.forward do
        co_yield(x.forward.score)
        x = x.forward.level[1]
    end
end

--------------------------------------------------------------------------------

local _INTERFACE = {}

function _INTERFACE.new()
    local skiplist = zslCreate()
    return setmetatable(skiplist, {__index=_INTERFACE})
end

function _INTERFACE:insert(key, value)
    if type(key) == "number" then
        zslInsert(self, key, value)
    end
end

function _INTERFACE:remove( key, value )
    zslDelete(self, key, value)
end

function _INTERFACE:print( )
    local log = zslFormat(self)
    print(log)
end

function _INTERFACE:walk( )
    return co_wrap(function () inorder_list_walk(self) end)
end

function _INTERFACE:max( )
    return zslGetLastNode(self)
end

function _INTERFACE:len( )
    return self.length
end

return _INTERFACE
