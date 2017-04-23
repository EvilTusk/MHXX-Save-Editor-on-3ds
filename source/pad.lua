pad = {
	old = 0,
	current = 0,
	
	reload = function()
		pad.old = pad.current
		pad.current = Controls.read()
	end,

	isPress = function(key)
		return ( Controls.check(pad.current,key) and not Controls.check(pad.old,key) )
	end
}
