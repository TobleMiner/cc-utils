BCable = { }
BCable.__index = BCable

setmetatable(BCable, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function BCable.new(side)
	local cable = { }
	setmetatable(cable, BCable)
	cable.side = side
	return cable
end

function BCable:setColor(color)
	local out = redstone.getBundledOutput(self.side)
	out = bit.bor(out, color)
	redstone.setBundledOutput(self.side, out)
end

function BCable:clearColor(color)
	local out = redstone.getBundledOutput(self.side)
	out = bit.band(out, color)
	redstone.setBundledOutput(self.side, out)
end

function BCable:off()
	redstone.setBundledOutput(self.side, 0)
end

function BCable:on()
	redstone.setBundledOutput(self.side, 65535)
end

Cable = { }
Cable.__index = Cable

setmetatable(Cable, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Cable.new(bundle, color)
	local cable = { }
	setmetatable(cable, Cable)
	cable.bundle = bundle
	cable.color = color
	return cable
end

function Cable:on()
	self.bundle:setColor(self.color)
end

function Cable:off()
	self.bundle:clearColor(self.color)
end
