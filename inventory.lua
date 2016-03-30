Inventory = { }
Inventory.__index = Inventory

setmetatable(Inventory, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function Inventory.new(side)
	local inv = { }
	setmetatable(inv, Inventory)
	inv.side = side
	inv.invDirections = { }
	return inv
end

function Inventory:wrap()
	self.inv = peripheral.wrap(self.side)
end

function Inventory:getStack(slot)
	return self.inv.getStackInSlot(slot)
end

function Inventory:getAllStacks()
	self.inv.getAllStacks()
end

function Inventory:getSize()
	return self.inv.getInventorySize()
end

function Inventory:findSlot(id, minsize, damage)
	local size = self:getSize()
	for i = 1, size, 1 do
		local stack = self.inv.getStackInSlot(i)
		if(stack ~= nil and id == stack.id and
			(minsize == nil or minsize >= stack.qty) and
			(damage == nil or damage == stack.dmg)) then
			return i
		end
	end
	return nil
end

function Inventory:getMatchingSlots(id, minsize, damage)
	local size = self:getSize()
	local slots = { }
	for i = 1, size, 1 do
		local stack = self.inv.getStackInSlot(i)
		if(stack ~= nil and id == stack.id and
			(minsize == nil or minsize >= stack.qty) and
			(damage == nil or damage == stack.dmg)) then
			table.insert(slots, i)
		end
	end
	return slots
end

function Inventory:pullStack(inv, index, num, targetIndex)
	if self.inv.pullItem(self:getInventoryDirection(inv), index, num, targetIndex) ~= num and num ~=  nil then
		return false
	end
	return true
end

function Inventory:pushStack(inv, index, num, targetIndex)
	local stack = self.inv.getStackInSlot(index)
	if stack == nil then
		return false
	end
	local qty = self.inv.pushItem(self:getInventoryDirection(inv), index, num, targetIndex)
	if (num ~= nil and qty == num) or (num == nil and qty == stack.qty) then
		return true, qty
	end
	return false, qty
end

function Inventory:pushAll(inv)
	local size = self.inv.getInventorySize()
	for i = 1, size, 1 do
		if(not self:pushStack(i, self:getInventoryDirection(inv))) then
			return false
		end
	end
	return true
end

function Inventory:registerInventory(inv, dir)
	self.invDirections[inv] = dir
end

function Inventory:getInventoryDirection(inv)
	local dir = self.invDirections[inv]
	if dir == nil then
		error("Unknown inventory '"..tostring(inv).."'")
	end
	return dir
end

InventoryManager = { }
InventoryManager.__index = InventoryManager

setmetatable(InventoryManager, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function InventoryManager.new(inv)
	local mngr = { }
	setmetatable(mngr, InventoryManager)
	mngr.inv = inv
	mngr.observers = { }
	mngr.intervalPoll = 10
	return mngr
end

function InventoryManager:run()
	while true do
		for _,obsrvr in pairs(self.observers) do
			obsrvr:run(self.inv)
		end
		sleep(self.intervalPoll)
	end
end

function InventoryManager:setPollInterval(interval)
	self.intervalPoll = interval
end

function InventoryManager:addObserver(obsrvr)
	table.insert(self.observers, obsrvr)
end

local SlotObserver = { }
SlotObserver.__index = SlotObserver

setmetatable(SlotObserver , {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function SlotObserver.new(slot)
	local obsrvr = { }
	setmetatable(obsrvr, SlotObserver)
	obsrvr.slot = slot
	return obsrvr
end

function SlotObserver:run(inv)
	local stack = inv:getStack(self.slot)
	self:runSlot(inv, stack)
end

InventoryManager.SlotObserver = SlotObserver

local SlotItemCountObserver = { }
SlotItemCountObserver.__index = SlotItemCountObserver

setmetatable(SlotItemCountObserver , {
	__index = SlotObserver,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function SlotItemCountObserver.new(slot, id, qty, dmg)
	local obsrvr = SlotObserver(slot)
	setmetatable(obsrvr, SlotItemCountObserver)
	obsrvr.qty = qty
	obsrvr.id = id
	obsrvr.dmg = dmg
	return obsrvr
end

function SlotItemCountObserver:runSlot(inv, stack)
	local qty = 0
	if stack ~= nil then
		if stack.id ~= self.id then
			self.callbackItemMissmatch(self, inv, stack)
			return
		end
		if self.dmg ~= nil and stack.dmg ~= self.dmg then
			self.callbackItemMissmatch(self, inv, stack)
			return
		end
		qty = stack.qty
	end
	if qty < self.qty and (self.qtyLast == nil or self.qtyLast >= self.qty) then
		self.callbackUnderflow(self, inv, stack)
	elseif qty == self.qty and (self.qtyLast == nil or self.qtyLast ~= self.qty) then
		self.callbackEqual(self, inv, stack)
	elseif qty > self.qty and (self.qtyLast == nil or self.qtyLast <= self.qty) then
		self.callbackOverflow(self, inv, stack)
	end
	self.qtyLast = qty
end

function SlotItemCountObserver:setOverflowCallback(cb)
	self.callbackOverflow = cb
end

function SlotItemCountObserver:setUnderflowCallback(cb)
	self.callbackUnderflow = cb
end

function SlotItemCountObserver:setEqualCallback(cb)
	self.callbackEqual = cb
end

function SlotItemCountObserver:setItemMissmatchCallback(cb)
	self.callbackItemMissmatch = cb
end

InventoryManager.SlotItemCountObserver = SlotItemCountObserver

local InventoryObserver = { }
InventoryObserver.__index = InventoryObserver

setmetatable(InventoryObserver , {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function InventoryObserver.new()
	local obsrvr = { }
	setmetatable(obsrvr, InventoryObserver)
	return obsrvr
end

InventoryManager.InventoryObserver = InventoryObserver

local InventoryItemCountObserver = { }
InventoryItemCountObserver.__index = InventoryItemCountObserver

setmetatable(InventoryItemCountObserver , {
	__index = InventoryObserver,
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function InventoryItemCountObserver.new(id, qty, dmg)
	local obsrvr = InventoryObserver()
	setmetatable(obsrvr, InventoryItemCountObserver)
	obsrvr.qty = qty
	obsrvr.id = id
	obsrvr.dmg = dmg
	return obsrvr
end

function InventoryItemCountObserver:run(inv)
	local qty = 0
	for i = 1, inv:getSize(), 1 do
		local stack = inv:getStack(i)
		if stack ~= nil then
			if stack.id == self.id and (self.dmg == nil or self.dmg == stack.dmg) then
				qty = qty + stack.qty
			end
		end
	end
	if qty < self.qty and (self.qtyLast == nil or self.qtyLast >= self.qty) then
		self.callbackUnderflow(self, inv, stack)
	elseif qty == self.qty and (self.qtyLast == nil or self.qtyLast ~= self.qty) then
		self.callbackEqual(self, inv, stack)
	elseif qty > self.qty and (self.qtyLast == nil or self.qtyLast <= self.qty) then
		self.callbackOverflow(self, inv, stack)
	end
	self.qtyLast = qty
end

function InventoryItemCountObserver:setOverflowCallback(cb)
	self.callbackOverflow = cb
end

function InventoryItemCountObserver:setUnderflowCallback(cb)
	self.callbackUnderflow = cb
end

function InventoryItemCountObserver:setEqualCallback(cb)
	self.callbackEqual = cb
end

InventoryManager.InventoryItemCountObserver = InventoryItemCountObserver
