local Client = { }
Client.__index = Client

setmetatable(Client, {
	__index = PProxy.Client,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Client.new(id, rpc, side)
	local client = PProxy.Client(id, rpc)
	setmetatable(client, Client)
	client.side = side
	return client
end

function Client:getEU()
	return self:callRemote(self.side, 'getEUStored')
end

function Client:getMaxEU()
	return self:callRemote(self.side, 'getEUCapacity')
end

function Client:getFill()
	local eu = self:getEU()
	if not eu then
		return nil
	end
	local max = self:getMaxEU()
	if not eu then
		return nil
	end
	return eu / max
end

local Server = { }
Server.__index = Server

setmetatable(Server, {
	__index = PProxy.Server,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Server.new(rpc)
	local server = PProxy.Server(rpc)
	setmetatable(server, Server)
	return server
end

EUStorage = { Client=Client, Server=Server }
EUStorage.__index = EUStorage

setmetatable(EUStorage, {
	__index = Inventory,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function EUStorage.new(side)
	local storage = Inventory(side)
	setmetatable(storage, EUStorage)
	return storage
end

function EUStorage:getEU()
	return self.inv.getEUStored()
end

function EUStorage:getMaxEU()
	return self.inv.getEUCapacity()
end
