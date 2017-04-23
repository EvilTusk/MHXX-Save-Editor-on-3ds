buffer = {
	get = function(index,n)
		n = n or 1
		local fs = io.open("/MHXX_sav",FREAD)
		local str = io.read(fs,index,n)
		io.close(fs)
		return string.byte(str,1,-1)
	end,
	set = function(index,v)
		local fs = io.open("/MHXX_sav",FWRITE)
		if type(v)=="table" then
			io.write(fs,index,string.char(table.unpack(v)),#v)
			io.close(fs)
			return
		end
		io.write(fs,index,string.char(v),1)
		io.close(fs)
	end
}

