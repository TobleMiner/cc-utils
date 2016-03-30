InvSort = { }
InvSort.__index = InvSort

setmetatable(InvSort, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function InvSort.new(inv)
	local invSort = { }
	setmetatable(invSort, InvSort)
	invSort.inv = inv
	invSort.inv:wrap()
	invSort.interval = 30
	invSort.statistics = {
		itemsPos=0,
		itemsNeg=0
	}
	return invSort
end

function InvSort:setPosInv(inv)
	self.posInv = inv
end

function InvSort:setNegInv(inv)
	self.negInv = inv
end

function InvSort:setSorter(sorter)
	self.sorter = sorter
end

function InvSort:setPollInterval(interval)
	self.interval = interval
end

function InvSort:getStats(args)
	return self.statistics
end

function InvSort:run()
	if self.sorter == nil then
		error("sorter must be set")
	end
	if self.negInv == nil then
		error("negInv can not be nil")
	end
	if self.posInv == nil then
		error("posInv can not be nil")
	end
	while true do
		for i = 1, self.inv:getSize(), 1 do
			is = self.inv:getStack(i)
			if is ~= nil then
				keep = self.sorter:grade(is)
				if keep then
					_, qty = self.inv:pushStack(self.posInv, i)
					if(qty ~= nil) then
						self.statistics['itemsPos'] = self.statistics['itemsPos'] + qty
					end
				else
					_,qty = self.inv:pushStack(self.negInv, i)
					if(qty ~= nil) then
						self.statistics['itemsNeg'] = self.statistics['itemsNeg'] + qty
					end
				end
			end
		end
		sleep(self.interval)
	end
end
