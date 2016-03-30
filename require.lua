_G['require'] = function(fname)
	local f = loadfile(fname)
	if not f then
		error("Can't open '"..tostring(fname).."'")
	end
	f()
end
