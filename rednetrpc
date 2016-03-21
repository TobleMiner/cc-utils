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

function RednetRpc:processResponse(response)
	local data = textutils.unserialize(response)
	return data
end

function RednetRpc:callRemote(id, action, args)
	local call = { action=action, args=args }
	rednet.send(id, textutils.serialize(call))
	local tries = 10
	while true do
		tries = tries - 1
		rid, msg = rednet.receive(3)
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
	local func = self.functions[funcname]
	if func == nil then
		error("Unknown RPC '"..tostring(funcname).."'")
	end
	local args = data['args']
	if args == nil then
		args = { }
	end
	local success, retval = pcall(function()
			return func(unpack(args))
		end)
	if not success then
		error('RPC failed: '..retval)
	end
	return retval
end

function RednetRpc:listen()
	while true do
		local _, sender, msg = os.pullEvent('rednet_message')
		local success, data = pcall(function()
				return self:execRPC(msg)
			end)
		local retval = { success=success }
		if success then
			retval['data'] = data
		else
			retval['error'] = data
			print('RPC failed: '..data)
		end
		rednet.send(sender, textutils.serialize(retval))
	end
end
