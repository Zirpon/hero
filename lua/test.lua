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