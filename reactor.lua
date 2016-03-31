Reactor = { }
Reactor.__index = Reactor

setmetatable(Reactor, {
	__index = Inventory,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Reactor.new(side)
	local reactor = Inventory(side)
	setmetatable(reactor, Reactor)
	reactor.tempLast = nil
	reactor.tempTime = nil
	reactor.tempRate = 0
	reactor.euTime = nil
	reactor.euAvg = 0
	--<I don't even ...>
		reactor.getSizeBroken = reactor.getSize
		reactor.getSize = function()
			return reactor:getSizeBroken() - 4
		end
	--</I don't even ...>
	return reactor
end

function Reactor:getTemp()
	local temp = self.inv.getHeat()
	local time = os.clock()
	if(self.tempTime ~= nil and self.tempLast ~= nil) then
		local dt = time - self.tempTime
		local dT = temp - self.tempLast
		if(dt > 0) then
			if(self.tempRate == nil) then
				self.tempRate =  dT / dt
			else
				self.tempRate = 0.95 * self.tempRate + 0.05 * dT / dt
			end
		end
	end
	self.tempTime = time
	self.tempLast = temp
	return temp
end

function Reactor:getMaxTemp()
	return self.inv.getMaxHeat()
end

function Reactor:getTempTrend()
	return math.floor(self.tempRate * 100 + 0.5) / 100
end

function Reactor:getOutput()
	return self.inv.getEUOutput()
end

function Reactor:getLayout()
	return self.layout
end

function Reactor:setLayout(layout)
	self.layout = layout
end

Layout = { }
Layout.__index = Layout

setmetatable(Layout, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

Layout.max_item_dmg = 8000

Layout.lookup = {
	["S"] = "IC2:reactorUraniumSimple", --Single uranium fuel cell
	["D"] = "IC2:reactorUraniumDual", --Dual uranium fuel cell
	["Q"] = "IC2:reactorUraniumQuad", --Quad uranium fuel cell
	["s"] = "IC2:reactorUraniumSimpledepleted", --Single depleted uranium cell
	["d"] = "IC2:reactorUraniumDualdepleted", --Dual depleted uranium cell
	["q"] = "IC2:reactorUraniumQuaddepleted", --Quad depleted uranium cell
	["1"] = "IC2:reactorCoolantSimple", --10k coolant cell
	["3"] = "IC2:reactorCoolantTriple", --30k coolant cell
	["6"] = "IC2:reactorCoolantSix", --60k coolant cell
	["P"] = "IC2:reactorPlating", --Reactor plating
	["H"] = "IC2:reactorPlatingHeat", --Heat-Capacity reactor plating
	["c"] = "IC2:reactorPlatingExplosive", --Containment reactor plating
	["E"] = "IC2:reactorHeatSwitch", --Heat exchanger
	["R"] = "IC2:reactorHeatSwitchCore", --Reactor heat exchanger
	["C"] = "IC2:reactorHeatSwitchSpread", --Component heat exchanger
	["A"] = "IC2:reactorHeatSwitchDiamond", --Advanced heat exchanger
	["h"] = "IC2:reactorVent", --Heat vent
	["r"] = "IC2:reactorVentCore", --Reactor heat vent
	["o"] = "IC2:reactorVentGold", --Overclocked heat vent
	["v"] = "IC2:reactorVentSpread", --Component heat vent
	["a"] = "IC2:reactorVentDiamond", --Advanced heat vent
	["n"] = "IC2:reactorReflector", --Neutron reflector
	["N"] = "IC2:reactorReflectorThick", --Thick neutron reflector
	["b"] = "IC2:reactorCondensator", --RSH-Condensator
	["B"] = "IC2:reactorCondensatorLap"  --LZH-Condensator
}

Layout.reverseLookup = { }
function Layout.genReverseLookup()
	for k, v in pairs(Layout.lookup) do
		Layout.reverseLookup[v] = k
	end
end
Layout.genReverseLookup()

Layout.dmgLookup = {
	["IC2:reactorUraniumSimple"] = 9998, --Single uranium fuel cell
	["IC2:reactorUraniumDual"] = 9998, --Dual uranium fuel cell
	["IC2:reactorUraniumQuad"] = 9998, --Quad uranium fuel cell
	["IC2:reactorUraniumSimpledepleted"] = nil, --Single depleted uranium cell
	["IC2:reactorUraniumDualdepleted"] = nil, --Dual depleted uranium cell
	["IC2:reactorUraniumQuaddepleted"] = nil, --Quad depleted uranium cell
	["IC2:reactorCoolantSimple"] = 8000, --10k coolant cell
	["IC2:reactorCoolantTriple"] = 8000, --30k coolant cell
	["IC2:reactorCoolantSix"] = 8000, --60k coolant cell
	["IC2:reactorPlating"] = nil, --Reactor plating
	["IC2:reactorPlatingHeat"] = nil, --Heat-Capacity reactor plating
	["IC2:reactorPlatingExplosive"] = nil, --Containment reactor plating
	["IC2:reactorHeatSwitch"] = 8000, --Heat exchanger
	["IC2:reactorHeatSwitchCore"] = 8000, --Reactor heat exchanger
	["IC2:reactorHeatSwitchSpread"] = 8000, --Component heat exchanger
	["IC2:reactorHeatSwitchDiamond"] = 8000, --Advanced heat exchanger
	["IC2:reactorVent"] = 8000, --Heat vent
	["IC2:reactorVentCore"] = 8000, --Reactor heat vent
	["IC2:reactorVentGold"] = 8000, --Overclocked heat vent
	["IC2:reactorVentSpread"] = nil, --Component heat vent
	["IC2:reactorVentDiamond"] = 8000, --Advanced heat vent
	["IC2:reactorReflector"] = 8000, --Neutron reflector
	["IC2:reactorReflectorThick"] = 8000, --Thick neutron reflector
	["IC2:reactorCondensator"] = 8000, --RSH-Condensator
	["IC2:reactorCondensatorLap"] = 8000  --LZH-Condensator
}

Layout.Stack = { }
Layout.Stack.__index = Layout.Stack

setmetatable(Layout.Stack, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Layout.Stack.new(id, qty, dmg, dmgMax)
	local stack = { }
	stack.id = id
	stack.qty = qty
	stack.dmg = dmg
	stack.dmgMax = dmgMax
	stack.char = " "
	return stack
end

function Layout.new(width, height)
	local layout = { }
	setmetatable(layout, Layout)
	layout.layout = { }
	layout.width = width
	layout.height = height
	return layout
end

function Layout.fromFile(fname)
	local layout = Layout(0, 0)
	local flhndl = fs.open(fname, "r")
	if not flhndl then
		error("Can't open '"..tostring(fname).."'")
	end
	local line = flhndl.readLine()
	while line ~= nil  do
		if #line > 0 then
			line = line:gsub("\r", ""):gsub("\n", "")
			local row = { }
			for i = 1, #line, 1 do
				local stack = Layout.Stack()
				stack.char = line:sub(i, i)
				stack.qty = 1
				stack.id = Layout.lookup[stack.char]
				if(stack.id ~= nil) then
					stack.maxDmg = Layout.dmgLookup[stack.id]
				end
				table.insert(row, stack)
			end
			table.insert(layout.layout, row)
			layout.width = math.max(layout.width, #row)
			layout.height = layout.height + 1
		end
		line = flhndl.readLine()
	end
	return layout
end

function Layout.unserialize(str)
	local rep = textutils.unserialize(str)
	local layout = Layout(rep.width, rep.height)
	layout.layout = rep.layout
	return layout
end

function Layout.slotnumToGridSize(slotnum)
	return slotnum / 6, 6
end

function Layout:XYtoPos(x, y)
	return (y - 1) * self.width + x
end

function Layout:posToXY(pos)
	local y = math.ceil(pos / self.width)
	local x = pos - self.width * (y - 1)
	return x, y
end

function Layout:getStack(pos)
	local x, y = self:posToXY(pos)
	return self:getStackAt(x, y)
end

function Layout:getStackAt(x, y)
	return self.layout[y][x]
end

function Layout:serialize()
	local rep = { }
	rep.layout = self.layout
	rep.width = self.width
	rep.height = self.height
	return textutils.serialize(rep)
end

LayoutManager = { }
LayoutManager.__index = LayoutManager

LayoutManager.ERROR_CODES = { }
LayoutManager.ERROR_CODES.CLEAR_FAILED = 1
LayoutManager.ERROR_CODES.ITEM_MISSING = 2
LayoutManager.ERROR_CODES.PULL_FAILED = 3
LayoutManager.ERROR_CODES.INV_NOT_SET = 4

setmetatable(LayoutManager, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function LayoutManager.new(reactor, layout)
	local manager = { }
	setmetatable(manager, LayoutManager)
	manager.reactor = reactor
	manager.layout = layout
	manager.layoutOk = true
	manager.intervalPoll = 10
	return manager
end

function LayoutManager:checkSlot(i)
	local stack = self.reactor:getStack(i)
	local should = self.layout:getStack(i)
	if should.id == nil and stack == nil then
		return true
	end
	if should.id ~= nil and stack ~= nil then
		return should.id == stack.id
	end
	return false
end

function LayoutManager:fixSlot(i)
	local stack = self.reactor:getStack(i)
	if stack ~= nil then
		if not self.reactor:pushStack(self.invDst, i) then
			local err = {
				error='Failed to clear unwanted item',
				code=LayoutManager.ERROR_CODES.CLEAR_FAILED,
				slot=i,
				stack=stack
			}
			return false, err
		end
	end
	local required = self.layout:getStack(i)
	local srcSlot = self.invSrc:findSlot(required.id)
	if srcSlot == nil then
		local err = {
			error='Missing required item',
			code=LayoutManager.ERROR_CODES.ITEM_MISSING,
			slot=i,
			stack=required
		}
		return false, err
	end
	if not self.reactor:pullStack(self.invSrc, srcSlot, 1, i) then
		local err = {
			error='Failed to pull item into reactor',
			code=LayoutManager.ERROR_CODES.PULL_FAILED,
			slot=i,
			srcSlot=srcSlot,
			stack=required
		}
		return false, err
	end
	return true
end

function LayoutManager:run()
	local numSlotsLayout = self.layout.width * self.layout.height
	while true do
		local numSlotsReactor = self.reactor:getSize()
		if numSlotsReactor ~= numSlotsLayout then
			self:execCallback(self.callbackIntegrityFail)
			error("Number of slots in layout doesn't match number of slots in reactor")
		end
		for i = 1, numSlotsLayout, 1 do
			layoutOk = true
			local slotOk = self:checkSlot(i)
			if not slotOk then
				if(self.invSrc == nil or self.invDst == nil) then
					layoutOk = false
					err = {
						error="Source or destination inventory not set. Can't fix layout",
						code=LayoutManager.ERROR_CODES.INV_NOT_SET,
						slot=i
					}
					break
				else
					success, err = self:fixSlot(i)
					if not success then
						layoutOk = false
						break
					end
				end
			end
		end
		self.layoutOk = layoutOk
		if layoutOk then
			self:execCallback(self.callbackOk)
		else
			self:execCallback(self.callbackFail, err)
		end
		sleep(self.intervalPoll)
	end
end

function LayoutManager:execCallback(cb, arg)
	if cb == nil then
		return
	end
	local success, error = pcall(function()
			cb(arg)
		end)
	if not success then
		print("Callback execution failed: '"..error.."'")
	end
end

function LayoutManager:setSrcInv(inv)
	self.invSrc = inv
end

function LayoutManager:setDstInv(inv)
	self.invDst = inv
end

function LayoutManager:setIntegrityFailCallback(cb)
	self.callbackIntegrityFail = cb
end

function LayoutManager:setLayoutFailCallback(cb)
	self.callbackFail = cb
end

function LayoutManager:setLayoutOkCallback(cb)
	self.callbackOk = cb
end

function LayoutManager:setPollInterval(interval)
	self.intervalPoll = interval
end

function LayoutManager:isLayoutOk()
	return self.layoutOk
end
