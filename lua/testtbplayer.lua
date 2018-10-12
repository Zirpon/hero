local timer = require("Global.apptimer")
local db = require("dbProxySvr.dbconnector")
local dbdef = require("dbProxySvr.dbdef")
local md5 = require("ngx.md5")
local commondef = require("Global.commondef")
local commonfunc = require("Global.common")
local cjson = require "cjson"
local udprak = require "rakclient.core"

MT=MT or {}

MT.skynet = require "skynet"
require "stPreMain"

function MT:Reg()
    GLOG_DEBUG("player BEGIN")
    ProtocolProcessorCommon:regOneService("Query",self.db, self.db.Query)
    ProtocolProcessorCommon:regOneService("QueryMore",self.db, self.db.QueryMore)
    ProtocolProcessorCommon:regOneService("Update",self.db, self.db.Update)
    ProtocolProcessorCommon:regOneService("Insert",self.db, self.db.Insert)
    ProtocolProcessorCommon:regOneService("FindAndModify",self.db, self.db.FindAndModify)
    ProtocolProcessorCommon:regOneService("LoginPlayer",self, self.LoginPlayer)
    ProtocolProcessorCommon:regOneService("CreatePlayer",self, self.CreatePlayer)
    GLOG_DEBUG("player END")
end

function ModuleInit()
    MT.db = db:new()
    MT.db.cdef = dbdef["tb_player"]
    MT.db.c = MT.db:getCollection(MT.db.cdef.tbname)
    
    MT:Reg()

    timer:fork(function()
        for _,k in pairs(MT.db.cdef.__index) do
            MT.db.c:ensureIndex(k)
        end
    end)

    -- timer:sleep(100)
    -- GLOG_DEBUG("CMD")
    -- dumpTable(CMD)
end

--@brief 返回player信息
function FindPlayer(uid, playerId)
    local ok, tblobj, cost
    if not uid or not playerId then
        ok,tblobj = MT.db:QueryMore({},{uid=true,player_id=true,_id=false})
        if ok then
            local fname = "testtbplayer.txt"
            local f = io.open(fname, "a+")
            f:write(cjson.encode(ok))
            f:close()
        end
    else
        local starttime = udprak.raktime()
        ok,tblobj = MT.db:Query({uid = uid, player_id=player_id},{uid=true,player_id=true,_id=false})
        local endtime = udprak.raktime()
        cost = endtime - starttime
    end
    if not ok then
       return nil 
    end
    GLOG_FORWARD("FindPlayer", cost or 0, ok, tblobj)

    return tblobj
end

function InsertPlayer(playerId)
    local col = {}
    col.uid         = Util:UUID()
    col.player_id    = playerId
    col.name  = Util:UUID(16)
    col.level = 1
    col.hero = {["1001"]={skin={},opt=1},["1005"]={skin={},opt=1}}--todo暂时默认

    -- 插入新player
    self.db:Insert(col)
end

--角色登陆
function MT:LoginPlayer(uid,token)

    local ok,resp = netClient:CallLocal(true,"tbaccount","Query",{uid=uid},{token=1,pk=1,token_expire=1,player_id = 1,gm=1})
    if not ok then
        return 1
    end
    if resp.player_id == 0 then
        return 10
    end

    if resp.token == "" or pk == "" then
        return 9
    end

    local now = timer:now()
    if resp.token_expire < now then
        return 9
    end

    local sta = netClient:CallLocal(true, "tbsystemparam","GetValue",commondef.DBSystemParam.server_sta)
    local code = commonfunc:GMHandle(resp.gm,sta)
    if code > 0 then
        return code
    end

    local tokentmp = md5.update(resp.token..resp.pk)
    if string.lower(token) ~= string.lower(tokentmp) then
        return 10031
    end

    ok,resp = self.db:Query({player_id=resp.player_id})
    if not ok then
        return 4
    end
    resp["_id"] = nil

    self.db:Update({uid=uid},{["$set"]={login_date=math.floor(timer:now())}})
    return 0,resp
end

--创建角色
function MT:CreatePlayer(uid, playerName)

    local ok,resp = netClient:CallLocal(true,"tbaccount","Query",{uid=uid},{player_id=1,token=1,token_expire=1,pk=1})
    if not ok then
        return 1
    end

    if resp.player_id > 0 then
        return 10021
    end

    if token == "" then
        return 9
    end

    local now = timer:now()
    if resp.token_expire < now then
        return 9
    end
    local sta = netClient:CallLocal(true, "tbsystemparam","GetValue",commondef.DBSystemParam.server_sta)
    local code = commonfunc:GMHandle(resp.gm,ssta)
    if code > 0 then
        return code
    end

    GLOG_INFO("playername:" .. playerName)
    local rc, rept = self.db:Query({player_name=playerName})
    -- GLOG_INFO("rc:".. tostring(rc))
    -- GLOG_INFO("rept:".. tostring(rept))
    if rept then
        GLOG_ERROR("player created fail [player name has exist]")
        return 10021
    end

    local playerId = netClient:CallLocal(true, "tbsystemparam","GennerateID",commondef.DBSystemParam.player_id)
    if playerId == nil then
        GLOG_ERROR("player created fail [can`t req id]")
        return 10022
    end
    
    --    GLOG_INFO("11111-1")
    local col = {}
    col.uid         = uid
    col.player_id    = playerId
    col.name  = playerName
    col.level = 1
    col.hero = {["1001"]={skin={},opt=1},["1005"]={skin={},opt=1}}--todo暂时默认
    --    GLOG_INFO("11111-2")

    -- 插入新player
    self.db:Insert(col)

    --    GLOG_INFO("11111-3")
    -- 更新accout
    netClient:CallLocal(true,"tbaccount","Update",{uid=uid},{["$set"]={player_id=playerId}})
    --    GLOG_INFO("11111-4")

    return 0, resp.token,playerId
end

MT.skynet.start(function()
    ModuleInit()
    MT.skynet.dispatch("lua", function(session, address, cmd, ...)
        ProtocolProcessorCommon:ServiceDistpatcher(session,address,cmd,...)
    end)
    --FindPlayer()
    local fname = "testtbplayer.txt"
    local tmpf = io.open(fname, "rb")
    local tmpbuf = tmpf:read("*a")
    local tb_tmp = cjson.decode(tmpbuf)
    GLOG_FORWARD("start",#tb_tmp)
    MT.skynet.fork( function ( )
        while true do
            for i=1,#tb_tmp do
                local uid = tb_tmp[i].uid
                local player_id = tb_tmp[i].player_id
                FindPlayer(uid, player_id)
                MT.skynet.sleep(100)
            end
        end        
    end)
end)