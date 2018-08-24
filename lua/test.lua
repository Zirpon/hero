-- lua 模式匹配 || lua 5.3 版本的load || 进程的环境变量Env || lua 的全局变量 _G || lua package.config 
-- lua package.path, package.cpath: require搜索路径 loadfile：加载lua文件 loadlib:加载C程序库

local result = {}
local function getenv(name) print("doing getenv") print(name) return assert(os.getenv(name), [[os.getenv() failed: ]] .. name) end
local sep = package.config:sub(1,1)
local current_path = [[.]]..sep

local function include(filename)
    local last_path = current_path 
    local path, name = filename:match([[(.*]]..sep..[[)(.*)$]])--(.*/)(.*)$ 
    if path then  
        if path:sub(1,1) == sep then	-- root  
            current_path = path
        else  
            current_path = current_path .. path  
        end  
    else  
        name = filename  
    end  
    local f = assert(io.open(current_path .. name))  
    local code = assert(f:read [[*a]])
    code = string.gsub(code, [[%$([%w_%d]+)]], getenv)  

    f:close()  
    assert(load(code,[[@]]..filename,[[t]],result))()
    current_path = last_path  
end  

setmetatable(result, { __index = { include = include } })  
local config_name = "./gameSvr.cfg"
include(config_name)  
setmetatable(result, nil)

local rr = {}
load("a=9 bb=10","@none_name",[[t]],rr)()
if rr then
    -- body
    for k,v in pairs(rr) do
        print(k,v)
    end
end

--print( string.gsub("$dd_2, $r_3, $te_2222yyy", [[%$([%w_%d]+)]], "%0 %1" ) )

return result


local tmp = {flag=false}
tmp.flag = {1,35}
tmp.flags = false
local oo = {1,35}
tmp[(oo)] = oo
-- print(type(tmp.flags))
print(tmp[oo])
print(tmp[oo][1])
print(tmp[oo][2])
print(oo)
print(oo[1])
print(oo[2])

local god = {}
god.a = 10
god.b = 3
god.c = 100

print(god[1])
local ggod = {}
for k,v in pairs(god) do
    table.insert(ggod,{kk=k,vv=v})
end

for k,v in pairs(ggod) do
    print(v.kk)
end

table.sort(ggod, function (a,b)  return a.vv > b.vv end )

for k,v in pairs(ggod) do
    print(v.kk)
end

local kkkk = {}
kkkk[100] = {3,1}
kkkk[2] = {3,1}
kkkk[9] = {3,1}

table.remove(kkkk,100)
