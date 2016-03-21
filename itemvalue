ItemGrader = { }
ItemGrader.__index = ItemGrader

setmetatable(ItemGrader, {
  __call = function (cls, ...)
    return cls.new(...)
  end
})

function ItemGrader.new()
	local grader = { }
	setmetatable(grader, ItemGrader)
	return grader
end

FunctionListItemGrader = { }
FunctionListItemGrader.__index = FunctionListItemGrader

setmetatable(FunctionListItemGrader, {
	__index = ItemGrader,
	__call = function (cls, ...)
		return FunctionListItemGrader.new(...)
	end
})

function FunctionListItemGrader.new()
	local grader = { }
	setmetatable(grader, FunctionListItemGrader)
	grader:_init()
	return grader
end

function FunctionListItemGrader:_init()
	self.filter = { }
end

function FunctionListItemGrader:addFilter(filterFunc)
	table.insert(self.filter, filterFunc)
end

BlacklistItemGrader = { }
BlacklistItemGrader.__index = BlacklistItemGrader

setmetatable(BlacklistItemGrader, {
	__index = FunctionListItemGrader,
	__call = function (cls, ...)
		return BlacklistItemGrader.new(...)
	end
})

function BlacklistItemGrader.new()
	local grader = FunctionListItemGrader()
	setmetatable(grader, BlacklistItemGrader)
	FunctionListItemGrader._init(grader)
	return grader
end

function BlacklistItemGrader:grade(is)
	for _,f in pairs(self.filter) do
		_, rval = pcall(f, is)
		if not rval then
			return false
		end
	end
	return true
end

WhitelistItemGrader = { }
WhitelistItemGrader.__index = WhitelistItemGrader

setmetatable(WhitelistItemGrader, {
	__index = FunctionListItemGrader,
	__call = function (cls, ...)
		return WhitelistItemGrader.new(...)
	end
})

function WhitelistItemGrader.new()
	local grader = FunctionListItemGrader()
	setmetatable(grader, WhitelistItemGrader)
	FunctionListItemGrader._init(grader)
	return grader
end

function WhitelistItemGrader:grade(is)
	if #self.filter == 0 then
		return false
	end
	for _,f in pairs(self.filter) do
		_, rval = pcall(f, is)
		if not rval then
			return false
		end
	end
	return true
end
