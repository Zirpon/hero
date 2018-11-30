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
    for _,node in pairs(importMap) do
        local target = nil
        if newNode[1] <= node[1] and node[1] >= newNode[2] then
            local head = node[1]
            local tail = ((node[2] > newNode[2]) and newNode[2]) or node[2]
            target = {head, tail, 1}

        elseif node[1] <= newNode[1] and newNode[1] >= node[2] then
            local head = newNode[1]
            local tail = ((node[2] > newNode[2]) and newNode[2]) or node[2]
            target = {head, tail, 1}
        end

        if target then
            local increKeys = {}
            local newKeys = {}
            for key,interNode in pairs(intersection) do
                if target[1] <= interNode[1] and interNode[1] >= target[2] then
                    local head = interNode[1]
                    local tail = ((interNode[1] > target[1]) and target[1]) or interNode[1]
                    if head..tail == key then
                        increKeys[key] = true
                    elseif not newKeys[head..tail] then
                        table.insert( newKeys, {head,tail,interNode[3]+1} )
                    end
        
                elseif interNode[1] <= target[1] and target[1] >= interNode[2] then
                    local head = target[1]
                    local tail = ((interNode[2] > target[2]) and target[2]) or interNode[2]
                    if head..tail == key then
                        increKeys[key] = true
                    else
                        table.insert( newKeys, {head,tail,2} )
                    end
                end

            end
        end

    end
    
end
