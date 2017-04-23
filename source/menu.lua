COLOR_MENU_FONT = Color.new(255,255,255)
COLOR_MENU_BACKGROUND  = Color.new(0,0,0)

menu = {
	visible = false,
	
	currentIndex = 1,
	
	display = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_MENU_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,150,30+menu.currentIndex*40,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,240,30+menu.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,180,70,"进入修改",COLOR_MENU_FONT,TOP_SCREEN)
		Font.print(theFont,180,110,"保存修改",COLOR_MENU_FONT,TOP_SCREEN)
		Font.print(theFont,178,150,"备份/还原",COLOR_MENU_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","进入"},
			{"START","退出"}
		}
	end,
	
	padLoop = function()
		userSelect.visible = false
		sav.visible = false
		menu.visible = true
		display.mark = nil
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if menu.currentIndex>1 then
					menu.currentIndex = menu.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if menu.currentIndex<3 then
					menu.currentIndex = menu.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				if menu.currentIndex==1 then
					userSelect.padLoop()
				end
				if menu.currentIndex==2 then
					if messageBox.show("                            确认保存 ？","确认","取消")=="A" then
						messageBox.toast("                            保存中 ...")
						if sav.import() then
							messageBox.show("                            保存成功 ！","确认","取消")
						else
							messageBox.show("                            保存失败 ！","确认","取消")
						end
					end
				end
				if menu.currentIndex==3 then
					sav.padLoop()
				end
			end
			if pad.isPress(KEY_START) then
				messageBox.toast("                            正在退出 ...")
				System.deleteFile("/MHXX_sav")
				System.exit()
			end
			display.refresh()
		end
	end
}
