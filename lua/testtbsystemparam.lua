MT= MT or {}
MT.skynet = require "skynet"
local timer = require("Global.apptimer")
local db = require("dbProxySvr.dbconnector")
local dbdef = require("dbProxySvr.dbdef")
local commondef = require("Global.commondef")
local udprak = require "rakclient.core"

require "stPreMain"

function MT:Reg()
    ProtocolProcessorCommon:regOneService("Query",self.db, self.db.Query)
    ProtocolProcessorCommon:regOneService("QueryMore",self.db, self.db.QueryMore)
    ProtocolProcessorCommon:regOneService("Update",self.db, self.db.Update)
    ProtocolProcessorCommon:regOneService("Insert",self.db, self.db.Insert)
    ProtocolProcessorCommon:regOneService("FindAndModify",self.db, self.db.FindAndModify)

    ProtocolProcessorCommon:regOneService("GennerateID",self, self.GennerateID)
    ProtocolProcessorCommon:regOneService("SetValue",self, self.SetValue)
    ProtocolProcessorCommon:regOneService("GetValue",self, self.GetValue)
end

function ModuleInit()
        MT.db = db:new()
        MT.db.cdef = dbdef["tb_system_param"]
        MT.db.c = MT.db:getCollection(MT.db.cdef.tbname)

        MT:Reg()

        timer:fork(function()
        for _,k in pairs(MT.db.cdef.__index) do
            MT.db.c:ensureIndex(k)
        end
        
        for i, k in pairs(commondef.DBSystemParam) do
            if k > 0 then
                local ret = MT.db:Query({id=k})
                if not ret then
                    MT.db:FindAndModify({id=k},{["$set"]={id=k,name=i,value=1}},true)
                end
            end
        end 
    end)
end

function MT:GennerateID(id)
    local src_id = 0
    local ret = self.db:FindAndModify({id=id},{["$inc"]={value=1}})
    ret = ret.value

    if not ret then
        return;
    else
        src_id = ret.value
    end
	
    local nodeid = self.skynet.getenv("node_id")
	
    if id == commondef.DBSystemParam.player_id then
            src_id = (0xFF00000000 & (nodeid << 32)) + src_id
    elseif id == commondef.DBSystemParam.player_id then
            src_id = (0xFF00000000 & (nodeid << 32)) + src_id
    elseif  id == commondef.DBSystemParam.item_id then
            
    end
--    GLOG_INFO("XX4:" .. src_id)

    return src_id, 0
end

function MT:SetValue( id,value )
    -- body
    self.db:FindAndModify({id=id},{["$set"]={value=value}})
end

function MT:GetValue( id )
    -- body
    local ok,ret = self.db:Query({id=id},{value=1})
    if ok then
        return ret.value
    end
    return nil
end

MT.skynet.start(function()
    ModuleInit()
    MT.skynet.dispatch("lua", function(session, address, cmd, ...)
        ProtocolProcessorCommon:ServiceDistpatcher(session,address,cmd,...)
    end)

    MT.skynet.fork(function ( )
        --for i=1,1 do
        while true do
            local id = Util:UUID()
            local starttime = udprak.raktime()
            --MT.db:Insert({id=id, name="test", value=0})
            MT:GetValue(commondef.DBSystemParam.player_id)
            local endtime = udprak.raktime()
            cost = endtime - starttime
            --GLOG_FORWARD("SetValue:", cost or 0, id)
            GLOG_FORWARD("GetValue:", cost or 0, commondef.DBSystemParam.player_id)
            MT.skynet.sleep(100)
        end        
    end)
end)