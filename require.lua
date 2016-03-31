_G['require'] = function(fname)
	local f = assert(loadfile(fname))
	f()
end
