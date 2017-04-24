COLOR_SAV_FONT = Color.new(255,255,255)
COLOR_SAV_SCROLLBAR = Color.new(102,204,255)
COLOR_SAV_SCROLLLINE = Color.new(128,128,128)
COLOR_SAV_BACKGROUND = Color.new(0,0,0)

MAX_RAM_ALLOCATION = 10485760

sav = {
	export = function(path)
		path = path or "/MHXX_sav"
		local inp = io.open("/system",FREAD,6513) -- Hex:1971 = Dec:6513
		if System.doesFileExist(path) then
			System.deleteFile(path)
		end
		local out = io.open(path,FCREATE)
		local size = io.size(inp)
		local index = 0
		while (index+(MAX_RAM_ALLOCATION/2) < size) do
			io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
			index = index + (MAX_RAM_ALLOCATION/2)
		end
		if index < size then
			io.write(out,index,io.read(inp,index,size-index),(size-index))
		end
		io.close(inp)
		io.close(out)
	end,
	
	import = function(path)
		path = path or "/MHXX_sav"
		if not System.doesFileExist(path) then
			return false
		end
		local inp = io.open(path,FREAD)
		local out = io.open("/system",FWRITE,6513) -- Hex:1971 = Dec:6513
		if io.size(inp) <= io.size(out) then
			size = io.size(inp)
			index = 0
			while (index+(MAX_RAM_ALLOCATION/2) < size) do
				io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
				index = index + (MAX_RAM_ALLOCATION/2)
			end
			if index < size then
				io.write(out,index,io.read(inp,index,size-index),(size-index))
			end
		end
		io.close(inp)
		io.close(out)
		return true
	end,
	

	visible = false,

	currentIndex = 1,
	displayIndexFirst = 1,

	backupFileList = {},

	init = function()
		System.createDirectory("/XXBackup")
		local list = System.listDirectory("/XXBackup/")
		sav.backupFileList = {"------创建新的备份------"}
		for i,v in ipairs(list) do
			if string.sub(v.name,-6,-1)==".xxsav" then
				table.insert(sav.backupFileList,string.sub(v.name,1,-7))
			end
		end
	end,

	display = function()
		--上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_SAV_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(sav.currentIndex-sav.displayIndexFirst+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#sav.backupFileList then
				Font.print(theFont,55,15+20*i,sav.backupFileList[sav.displayIndexFirst+i-1],COLOR_SAV_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #sav.backupFileList>10 then
			local barLength = math.floor(10 / #sav.backupFileList*192)
			local barLoc = math.floor((sav.displayIndexFirst-1)/(#sav.backupFileList-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_SAV_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_SAV_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		if sav.currentIndex==1 then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","备份存档"},
				{"B","上一层"}
			}
		else
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"X","删除"},
				{"A","还原存档"},
				{"B","上一层"}
			}
		end
	end,

	padLoop = function()
		sav.init()
		sav.currentIndex = 1
		sav.displayIndexFirst = 1
		sav.visible = true
		menu.visible = false
		display.mark = {name = "备份/还原"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if sav.currentIndex>1 then
					sav.currentIndex = sav.currentIndex-1
				end
				if sav.currentIndex<sav.displayIndexFirst then
					sav.displayIndexFirst = sav.displayIndexFirst-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if sav.currentIndex<#sav.backupFileList then
					sav.currentIndex = sav.currentIndex+1
				end
				if sav.currentIndex>(sav.displayIndexFirst+9) then
					sav.displayIndexFirst = sav.displayIndexFirst+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				sav.currentIndex = sav.currentIndex-10
				sav.displayIndexFirst = sav.displayIndexFirst-10
				if sav.currentIndex<1 then
					sav.currentIndex = 1
				end
				if sav.displayIndexFirst<1 then
					sav.displayIndexFirst = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				sav.currentIndex = sav.currentIndex+10
				sav.displayIndexFirst = sav.displayIndexFirst+10
				if sav.currentIndex>#sav.backupFileList then
					sav.currentIndex = #sav.backupFileList
				end
				if sav.displayIndexFirst>#sav.backupFileList-9 then
					sav.displayIndexFirst = #sav.backupFileList-9
				end
				if sav.displayIndexFirst<1 then
					sav.displayIndexFirst = 1
				end
			end
			if pad.isPress(KEY_X) then
				if sav.currentIndex~=1 then
					if messageBox.show("                    确认要删除该备份吗 ？","确认","取消")=="A" then
						local path = "/XXBackup/"..sav.backupFileList[sav.currentIndex]..".xxsav"
						messageBox.toast("                            删除中 ...")
						if System.doesFileExist(path) then
							System.deleteFile(path)
						end
						messageBox.show("                            删除成功 ！","确认","取消")
						sav.padLoop()
					end
				end
			end
			if pad.isPress(KEY_A) then
				if sav.currentIndex==1 then
					if messageBox.show("                确认创建一个新的备份吗 ？","确认","取消")=="A" then
						messageBox.toast("                            备份中 ...")
						local week,day,month,year = System.getDate()
						local h,m,s = System.getTime()
						local path = "/XXBackup/"..year.."___"..month.."___"..day.."___"..h.."___"..m.."___"..s..".xxsav"
						sav.export(path)
						messageBox.show("                            创建成功 ！","确认","取消")
						sav.padLoop()
					end
				else
					if messageBox.show("                    确认要还原该存档吗 ？","确认","取消")=="A" then
						messageBox.toast("                            还原中 ...")
						local path = "/XXBackup/"..sav.backupFileList[sav.currentIndex]..".xxsav"
						if sav.import(path) then
							messageBox.show("                            还原成功 ！","确认","取消")
						else
							messageBox.show("                            还原失败 ！","确认","取消")
						end
					end
				end
			end
			if pad.isPress(KEY_B) then
				menu.padLoop()
			end
			display.refresh()
		end
	end
}
