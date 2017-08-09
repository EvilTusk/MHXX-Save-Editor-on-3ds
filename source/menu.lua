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
		Font.print(theFont,150,30+menu.currentIndex*30,"=>",COLOR_MAKA,TOP_SCREEN)
		--Font.print(theFont,240,30+menu.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,170,60,TEXT_MENU[1],COLOR_MENU_FONT,TOP_SCREEN)
		Font.print(theFont,170,90,TEXT_MENU[2],COLOR_MENU_FONT,TOP_SCREEN)
		Font.print(theFont,170,120,TEXT_MENU[3],COLOR_MENU_FONT,TOP_SCREEN)
		Font.print(theFont,170,150,TEXT_MENU[4],COLOR_MENU_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓",TEXT_MOVE},
			{"A",TEXT_ENTER},
			{"START",TEXT_EXIT}
		}
		display.explain = TEXT_MENU_E
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
				if menu.currentIndex<4 then
					menu.currentIndex = menu.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				if menu.currentIndex==1 then
					userSelect.padLoop()
				end
				if menu.currentIndex==2 then
					if messageBox.show(TEXT_MENU_O[1],TEXT_OK,TEXT_CANCEL)=="A" then
						messageBox.toast(TEXT_MENU_O[2])
						if sav.import() then
							messageBox.show(TEXT_MENU_O[3],TEXT_OK,TEXT_CANCEL)
						else
							messageBox.show(TEXT_MENU_O[4],TEXT_OK,TEXT_CANCEL)
						end
					end
				end
				if menu.currentIndex==3 then
					sav.padLoop()
				end
				if menu.currentIndex==4 then
					if lang=="zh" then
						lang = "en"
						dofile(romfsPath.."lang_en")
					else
						lang = "zh"
						dofile(romfsPath.."lang_zh")
					end
					fs = io.open("/XXBackup/.setting",FWRITE)
					io.write(fs,0,lang,2)
					io.close(fs)
					menu.padLoop()
				end
			end
			if pad.isPress(KEY_START) then
				messageBox.toast(TEXT_EXITING)
				System.deleteFile("/MHXX_sav")
				System.exit()
			end
			display.refresh()
		end
	end
}
