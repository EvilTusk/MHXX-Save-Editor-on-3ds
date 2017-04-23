COLOR_USERSELECT_EXIST = Color.new(255,255,255)
COLOR_USERSELECT_NULL  = Color.new(255,0,0)
COLOR_USERSELECT_BACKGROUND  = Color.new(0,0,0)

userSelect = {
	visible = false,
	
	userOffset = {0,0,0},
	
	userExist = {false,false,false},
	
	currentIndex = 1,

	
	init = function()
		userSelect.userOffset[1] = buffer.get(18)*16*16*16*16 + buffer.get(17)*16*16 + buffer.get(16)
		userSelect.userOffset[2] = buffer.get(22)*16*16*16*16 + buffer.get(21)*16*16 + buffer.get(20)
		userSelect.userOffset[3] = buffer.get(26)*16*16*16*16 + buffer.get(25)*16*16 + buffer.get(24)
		if buffer.get(4)==1 then
			userSelect.userExist[1] = true
		end
		if buffer.get(5)==1 then
			userSelect.userExist[2] = true
		end
		if buffer.get(6)==1 then
			userSelect.userExist[3] = true
		end
	end,

	
	userStr = {
		"存档一",
		"存档二",
		"存档三"
	},
	
	display = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_USERSELECT_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,150,30+userSelect.currentIndex*40,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,230,30+userSelect.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,3 do
			if userSelect.userExist[i] then
				Font.print(theFont,180,30+40*i,userSelect.userStr[i],COLOR_USERSELECT_EXIST,TOP_SCREEN)
			else
				Font.print(theFont,180,30+40*i,userSelect.userStr[i],COLOR_USERSELECT_NULL,TOP_SCREEN)
			end
		end
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","进入"},
			{"B","上一层"}
		}
	end,
	
	padLoop = function()
		userSelect.init()
		editingMenuPage.visible = false
		userSelect.visible = true
		menu.visible = false
		display.mark = {name = "修改"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if userSelect.currentIndex>1 then
					userSelect.currentIndex = userSelect.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if userSelect.currentIndex<3 then
					userSelect.currentIndex = userSelect.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				if userSelect.userExist[userSelect.currentIndex] then
					messageBox.toast("                            读取中 ...")
					offset = userSelect.userOffset[userSelect.currentIndex]
					item.getItemBox()
					editingMenuPage.padLoop()
				else
					messageBox.show("                  该位置没有检测到存档 ！","确认","取消")
				end
			end
			if pad.isPress(KEY_B) then
				menu.padLoop()
			end
			display.refresh()
		end
	end
}
