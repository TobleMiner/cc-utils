local Client = { }
Client.__index = Client

setmetatable(Client, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Client.new(id, rpc)
	local client = { }
	setmetatable(client, Client)
	client.rpc = rpc
	client.id = id
	return client
end

function Client:safeRPC(action, args)
	local success, data = self.rpc:callRemote(self.id, action, args)
	if not success then
		print(data)
		return nil
	end
	return data
end

function Client:callRemote(side, func, ...)
	local args = { side, func, {...} }
	local success, data = self.rpc:callRemote(self.id, 'peripheral.call', args)
	if not success then
		print("Remote peripheral didn't answer")
		return nil
	end
	if data.success then
		return data.data
	else
		print(data.error)
	end
end

local Server = { }
Server.__index = Server

setmetatable(Server, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Server.new(rpc)
	local server = { }
	setmetatable(server, Server)
	server.rpc = rpc
	server.sides = {['bottom']=true, ['top']=true, ['front']=true, ['back']=true, ['left']=true, ['right']=true}
	server.rpc:registerProcedure('peripheral.call', function(side, func, args)
			if server.sides[side] then
				local realArgs = args or { }
				return peripheral.call(side, func, unpack(realArgs))
			else
				return nil
			end
		end)
	return server
end

PProxy = { Client=Client, Server=Server }
