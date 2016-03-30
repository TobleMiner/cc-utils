RednetRpc = { }
RednetRpc.__index = RednetRpc

setmetatable(RednetRpc,
	{
		__call = function (cls, ...)
			return cls.new(...)
		end
	})

function RednetRpc.new(modemSide)
	if modemSide ~= nil and not rednet.isOpen(modemSide) then
		rednet.open(modemSide)
	end
	local rednet = { }
	setmetatable(rednet, RednetRpc)
	rednet.functions = { }
	return rednet
end

function RednetRpc.getID(len)
	local len = len or 10
	local chars = 'abcdefghijklmopqrstuvwxyz1234567890'
	local str = ''
	for i = 1, len, 1 do
		local j = math.random(#chars)
		local c = chars:sub(j,j)
		str = str..c
	end
	return str
end

function RednetRpc:processResponse(response)
	local data = textutils.unserialize(response)
	return data
end

function RednetRpc:callRemote(id, action, args)
	local rpcid = RednetRpc.getID()
	local call = { action=action, rpcid=rpcid, args=args }
	rednet.send(id, textutils.serialize(call), 'rpc')
	local tries = 10
	while true do
		tries = tries - 1
		rid, msg = rednet.receive('rpc_'..rpcid, 3)
		if rid == nil or tries == 0 then
			return false
		end
		if(rid == id) then
			break
		end
	end
	local success, data = pcall(function()
			return self:processResponse(msg)
		end)
	return success, data
end

function RednetRpc:registerProcedure(name, func)
	self.functions[name] = func
end

function RednetRpc:execRPC(msg)
	local data = textutils.unserialize(msg)
	local funcname = data['action']
	local rpcid = data['rpcid']
	local func = self.functions[funcname]
	if func == nil then
		error("Unknown RPC '"..tostring(funcname).."'")
	end
	local args = data['args']
	if not args then
		args = { }
	end
	local success, retval = pcall(function()
			return func(unpack(args))
		end)
	if not success then
		error('RPC failed: '..retval)
	end
	return rpcid, retval
end

function RednetRpc:listen()
	while true do
		local sender, msg = rednet.receive('rpc')
		local success, rpcid, data = pcall(function()
				return self:execRPC(msg)
			end)
		local retval = { success=success }
		if success then
			retval['data'] = data
		else
			retval['error'] = rpcid
			print('RPC failed: '..rpcid)
		end
		if rpcid then
			rednet.send(sender, textutils.serialize(retval), 'rpc_'..rpcid)
		end
	end
end
