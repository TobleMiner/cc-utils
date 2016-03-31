ReactorControl = { }
ReactorControl.__index = ReactorControl

setmetatable(ReactorControl, {
	__call = function (cls, ...)
		return cls.new(...)
	end
})

function ReactorControl.new(reactor)
	local ctl = { }
	setmetatable(ctl, ReactorControl)
	ctl.reactor = reactor
	ctl.intervalPoll = 10
	return ctl
end

function ReactorControl:setLayoutManager(mngr)
	self.layoutmanager = mngr
	self.layoutmanager:setLayoutFailCallback(function(err)
			print(err.error)
			self:update()
		end)
	self.layoutmanager:setLayoutOkCallback(function()
			self:update()
		end)
end

function ReactorControl:setRedstoneConnection(cable)
	self.cable = cable
end

function ReactorControl:setEnergyStorage(storage)
	self.storage = storage
end

function ReactorControl:start()
	local threads = { }
	if self.layoutmanager then
		table.insert(threads, function()
			self.layoutmanager:run()
		end)
	end
	table.insert(threads, function()
			self:run()
		end)
	parallel.waitForAny(unpack(threads))
end

function ReactorControl:update()
	if self.cable then
		local fill = 0
		if self.storage then
			fill = self.storage:getFill()
			print('EU storage charge: '..tostring(fill))
		end
		local layoutOk = true
		if self.layoutmanager then
			layoutOk = self.layoutmanager:isLayoutOk()
			print('Layout ok: '..tostring(layoutOk))
		end
		if layoutOk and fill < 0.75 then
			self.cable:on()
		else
			self.cable:off()
		end
	end
end

function ReactorControl:run()
	while true do
		self:update()
		sleep(self.intervalPoll)
	end
end
