--[[
    问题: 现有多个起止时间的活动 求某个同时发生最多活动的时间段
]]

local source = {
    {10,40},
    {0,30},
    {15,60},
    {25,45},
    {30,75},
}

local intersection = {}
local importMap = {}

local function import( newNode )
    local increKeys = {}
    local newKeys = {}
    --print("import newNode:",newNode[1],newNode[2])
    for _,node in pairs(importMap) do
        local target = nil
        if newNode[1] <= node[1] and node[1] <= newNode[2] then
            local head = node[1]
            local tail = ((node[2] > newNode[2]) and newNode[2]) or node[2]
            if head < tail then
                target = {head, tail, 1}
            end
        elseif node[1] <= newNode[1] and newNode[1] <= node[2] then
            local head = newNode[1]
            local tail = ((node[2] > newNode[2]) and newNode[2]) or node[2]
            if head < tail then
                target = {head, tail, 1}
            end
        end

        --print("check node:", node[1],node[2])
        if target then
            --print("target:", target[1],target[2])
            for key,interNode in pairs(intersection) do
                if target[1] <= interNode[1] and interNode[1] <= target[2] then
                    local head = interNode[1]
                    local tail = ((interNode[1] > target[1]) and target[1]) or interNode[1]
                    if intersection[head..tail] then
                        increKeys[key] = true
                        --print("find intersection:", interNode[1], interNode[2], interNode[3])
                    elseif not newKeys[head..tail] and head < tail then
                        newKeys[head..tail] = {head,tail,interNode[3]+1}
                        --table.insert( newKeys, {head,tail,interNode[3]+1} )
                        --print("create intersection:interNode:", interNode[1], interNode[2], interNode[3])
                        --print("create intersection:create:", head, tail, interNode[3]+1)
                    elseif newKeys[head..tail] and newKeys[head..tail][3] < interNode[3]+1 then
                        newKeys[head..tail] = {head,tail,interNode[3]+1}
                        --print("incre create intersection:interNode:", interNode[1], interNode[2], interNode[3])
                        --print("incre create intersection:create:", head, tail, interNode[3]+1)
                    end
                    
                elseif interNode[1] <= target[1] and target[1] <= interNode[2] then
                    local head = target[1]
                    local tail = ((interNode[2] > target[2]) and target[2]) or interNode[2]
                    if intersection[head..tail] then
                        increKeys[key] = true
                        --print("find intersection:", interNode[1], interNode[2], interNode[3])
                    elseif not newKeys[head..tail] and head < tail then
                        newKeys[head..tail] = {head,tail,interNode[3]+1}
                        --table.insert( newKeys, {head,tail,interNode[3]+1} )
                        --print("create intersection:interNode:", interNode[1], interNode[2], interNode[3])
                        --print("create intersection:create:", head, tail, interNode[3]+1)
                    elseif newKeys[head..tail] and newKeys[head..tail][3] < interNode[3]+1 then
                        newKeys[head..tail] = {head,tail,interNode[3]+1}
                        --print("incre create intersection:interNode:", interNode[1], interNode[2], interNode[3])
                        --print("incre create intersection:create:", head, tail, interNode[3]+1)
                    end
                end
            end

            if not intersection[target[1]..target[2]] and (not newKeys[target[1]..target[2]] or newKeys[target[1]..target[2]][3] < target[3] ) then
                newKeys[target[1]..target[2]] = target
                --table.insert( newKeys, target )
            end
        end
    end

    for key,flag in pairs(increKeys) do
        --if flag == true then
            intersection[key][3] = intersection[key][3] + 1
        --end
    end
    for _,newInterNode in pairs(newKeys) do
        intersection[newInterNode[1]..newInterNode[2]] = newInterNode
    end

    table.insert( importMap, newNode )    
end

local function main( t_source)
    for i,node in ipairs(t_source) do
        import(node)
    end

    local sortObj = {}
    for k,v in pairs(intersection) do
        --print("intersection:", k,v[1],v[2],v[3])
        table.insert( sortObj,v )
    end

    table.sort( sortObj, function(a,b) return a[3] > b[3] end )
    
    for k,v in pairs(sortObj) do
        print("sorted:intersection:", k,v[1],v[2],v[3])
    end
end

main(source)