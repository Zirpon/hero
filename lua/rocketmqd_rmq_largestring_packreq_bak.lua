local skynet = require "skynet"
local cluster = require "skynet.cluster.core"
local rmq = require "rmq.core"

local command = {}
local large_request = {}
local node_session = {}
local wait_resp_thread = {}
local thread_result_data = {}
local start_cache = {}

local function req_data( topic,msg )
	-- body
	rmq.lwrite(topic,msg)
end
local function resp_data( topic,msg )
	-- body
	rmq.lwrite(topic,msg)
end

local function read_response(sock)
	local sz = socket.header(sock:read(2))
	local msg = sock:read(sz)
	return cluster.unpackresponse(msg)	-- session, ok, data, padding
end

local function send_request(source, topic, addr, msg, sz)
	local session = node_session[topic] or 1
	-- msg is a local pointer, cluster.packrequest will free it
	local request, new_session, padding = cluster.packrequest(addr, session, msg, sz)
	node_session[topic] = new_session

	req_data(topic , request)

	if padding then
		-- padding may be a table, to support multi part request
		-- multi part request use low priority socket write
		-- now socket_lwrite returns as socket_write
		for _,v in ipairs(padding) do
			req_data(topic, v)
		end
	end

	local co = coroutine.running()
	wait_resp_thread[session] = co
	skynet.wait(co)

	local data = thread_result_data[co]
	thread_result_data[co] = nil

	return data
end

function command:req(...)
	local ok, msg, sz = pcall(send_request, ...)
	if ok then
		if type(msg) == "table" then
			skynet.ret(cluster.concat(msg))
		else
			skynet.ret(msg)
		end
	else
		skynet.error(msg)
		skynet.response()(false)
	end
end
function command:push(source, topic, addr, msg, sz)

	local logflag = true
	if (topic == "globalDispatchSvr_0_0" and addr == ".dispatch") or (topic == "dispatchSvr_0_0" and addr == ".dispatch") then
		logflag = false
	end

	if logflag then
		skynet.error("rocketmqd command-push start", source, topic, addr, type(msg), sz)
	end

	local session = node_session[topic] or 1
	local request, new_session, padding = cluster.packpush(addr, session, msg, sz)
	if logflag then
		skynet.error("rocketmqd command-push packpush new_session", new_session)
		if type(request) == "string" then
			skynet.error("rocketmqd command-push packpush request", request)
		end
	end

	if padding then	-- is multi push
		node_session[topic] = new_session
	end

	req_data(topic, request)

	if padding and type(padding) == "table" then
		local count = 0
		for k,v in pairs(padding) do
			count = count + 1
			skynet.error("rocketmqd command-push packpush padding key", count, k)
			skynet.error("rocketmqd command-push packpush padding value", count, type(v))
			req_data(topic, v)
		end
	end
end

local function recv(opt,fromtopic,msg)
	skynet.error("recv start", opt, fromtopic)
	if opt == 0x00 then--req
		local sz
		local addr, session, msg, padding, is_push, paddingIndex = cluster.unpackrequest(msg)

		local totalLen = 0
		local part = 0
		if type(msg) == "number" then
			part = math.floor((msg - 1) / 0x8000 + 1)
			totalLen = msg
			skynet.error("rocketmqd recv unpackrequest totalLen", part, addr, session, msg, padding, is_push)
		elseif type(msg) == "string" then
			skynet.error("rocketmqd recv unpackrequest", addr, session, string.len(msg), padding, is_push, paddingIndex)
		end

		if padding then
			local requests = large_request[fromtopic]
			if requests == nil then
				requests = {}
				large_request[fromtopic] = requests
			end
			local req = requests[session] or { addr = addr , is_push = is_push , part = part, len = totalLen  }
			req.addr = (addr and addr) or req.addr
			req.is_push = (is_push and is_push) or req.is_push
			req.part = (part ~= 0 and part) or req.part
			req.len = (totalLen ~= 0 and totalLen) or req.len

			requests[session] = req
			if totalLen == 0 and paddingIndex then
				table.insert(req, {msg,paddingIndex})
			end

			if #req > 0 then
				skynet.error("rocketmqd recv large_request params", req[#requests[session]][2], #requests[session], 
					requests[session].part, requests[session].addr, requests[session].is_push, requests[session].len)
			end

			if #req == req.part and #req > 0 then
				requests[session] = nil
				table.sort(req, function ( a, b ) return a[2] < b[2] end)
				local reqtmp = {}
				table.insert(reqtmp, req.len)
				for i,v in ipairs(req) do
					skynet.error("rocketmqd recv package sort", v[2])
					table.insert(reqtmp, v[1])
				end
				
				msg,sz = cluster.concat(reqtmp)
				addr = req.addr
				is_push = req.is_push
				skynet.error("rocketmqd recv package done", sz, addr, is_push, type(msg))
			else
				return
			end
		else
			local requests = large_request[fromtopic]
			if requests then
				local req = requests[session]
				if req then
					table.insert(req, {msg,paddingIndex})
					if #req == req.part and #req > 0 then
						requests[session] = nil
						table.sort(req, function ( a, b ) return a[2] < b[2] end)
						local reqtmp = {}
						table.insert(reqtmp, req.len)
						for i,v in ipairs(req) do
							skynet.error("rocketmqd recv package sort", v[2])
							table.insert(reqtmp, v[1])
						end

						msg,sz = cluster.concat(reqtmp)
						addr = req.addr
						is_push = req.is_push
						skynet.error("rocketmqd recv package done", sz, #req, req.part, addr, is_push, type(msg))
					else
						if #req > 0 then
							skynet.error("rocketmqd recv package unorder", req[#requests[session]][2], #requests[session], 
								requests[session].part, requests[session].addr, requests[session].is_push, requests[session].len)
						end
						return
					end
				end
			end
			if not msg then
				skynet.error("rocketmqd recv package error")
				local response = cluster.packresponse(session, false, "Invalid large req")
				resp_data(fromtopic,response)--todo
				return
			end
		end
		local ok, response
		if addr == 0 then
			local name = skynet.unpack(msg, sz)
			local addr = register_name[name]
			if addr then
				ok = true
				msg, sz = skynet.pack(addr)
			else
				ok = false
				msg = "name not found"
			end
		elseif is_push then

			local strMethod,cmd,handle,ret,playerid,strMethod2,fid,buf = skynet.unpack(msg, sz)
			if strMethod2 == "finishBattle" then
				skynet.error("rocketmqd recv buf,fid", fid)
			end

			if skynet.rawsend(addr, "lua", msg, sz) == nil then
				--
				table.insert(start_cache,{addr,msg,sz})--retry latter
				skynet.error("rocketmqd recv call func handler error", addr)
			elseif start_cache then
				skynet.error("rocketmqd recv call func handler success", addr, #start_cache)
				for i=1,#start_cache do
					skynet.rawsend(start_cache[i][1], "lua", start_cache[i][2], start_cache[i][3])
				end
				start_cache = nil
			end
			return	-- no response
		else
			ok , msg, sz = pcall(skynet.rawcall, addr, "lua", msg, sz)
			if not ok then
				table.insert(start_cache,{addr,msg,sz})--retry latter
			elseif start_cache then
				for i=1,#start_cache do
					pcall(skynet.rawcall,start_cache[i][1], "lua", start_cache[i][2], start_cache[i][3])
				end
				start_cache = nil				
			end
		end
		if ok then
			response = cluster.packresponse(session, true, msg, sz)
			if type(response) == "table" then
				for _, v in ipairs(response) do
					resp_data(fromtopic,v)--todo
				end
			else
				resp_data(fromtopic,response)--todo
			end
		else
			response = cluster.packresponse(session, false, msg)
			resp_data(fromtopic,response)--todo
		end
	elseif opt == 0x01 then--resp
		local _,session,result_ok,result_data,padding = pcall(cluster.unpackresponse,msg)	-- session, ok, data, padding
		if result_ok and session then
			local co = wait_resp_thread[session]
			if co then
				if padding and result_ok then
					local result = thread_result_data[co] or {}
					thread_result_data[co] = result
					table.insert(result, result_data)
				else
					wait_resp_thread[session] = nil
					if result_ok and thread_result_data[co] then
						table.insert(thread_result_data[co], result_data)
					else
						thread_result_data[co] = result_data
					end
					skynet.wakeup(co)					
				end
			else
				skynet.error("roketmq: unknown session :", session)
			end
		end
	end
end

skynet.register_protocol {
	name = "roketmq",
	id = skynet.PTYPE_ROCKETMQ,	-- PTYPE_ROCKETMQ = 99
	unpack = function ( msg, sz )
		skynet.error("rocketmqd unpackmsg ", type(msg), sz)
		return rmq.unpack(msg,sz)
	end,
	dispatch = function (_, _, opt, topic, msg)
		skynet.error("rocketmqd rocketmq-protocol dispatch", opt, topic)
		recv(opt,topic,msg)
	end
}

skynet.start(function()
	rmq.bind(skynet.self())
	skynet.dispatch("lua", function(session , source, cmd, ...)
		--skynet.error("rocketmqd lua-protocol dispatch", session, source, cmd)
		local f = assert(command[cmd])
		--skynet.error("rocketmqd("..skynet.self()..")".." cmd="..cmd)
		f(command,source, ...)
	end)
end)
