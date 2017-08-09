COLOR_EDITINGMENUPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGMENUPAGE_BACKGROUND = Color.new(0,0,0)

editingMenuPage = {

	visible = false,
	
	currentIndex = 1,
	
	display = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGMENUPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,155,20+editingMenuPage.currentIndex*30,"=>",COLOR_MAKA,TOP_SCREEN)
		--Font.print(theFont,225,20+editingMenuPage.currentIndex*30,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,185,50,TEXT_EDITINGMENUPAGE[1],COLOR_EDITINGMENUPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,185,80,TEXT_EDITINGMENUPAGE[2],COLOR_EDITINGMENUPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,185,110,TEXT_EDITINGMENUPAGE[3],COLOR_EDITINGMENUPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,185,140,TEXT_EDITINGMENUPAGE[4],COLOR_EDITINGMENUPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,185,170,TEXT_EDITINGMENUPAGE[5],COLOR_EDITINGMENUPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓",TEXT_MOVE},
			{"A",TEXT_ENTER},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGMENUPAGE_E
	end,
	
	padLoop = function()
		editingComPage.visible = false
		editingItemPage.visible = false
		editingIllusionPage.visible = false
		editingTalismanPage.visible = false
		editingPalicoPage.visible = false
		editingMenuPage.visible = true
		userSelect.visible = false
		display.mark.nextMark = {name = TEXT_USERSELECT[userSelect.currentIndex]}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingMenuPage.currentIndex>1 then
					editingMenuPage.currentIndex = editingMenuPage.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingMenuPage.currentIndex<5 then
					editingMenuPage.currentIndex = editingMenuPage.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				--综合
				if editingMenuPage.currentIndex==1 then
					editingComPage.padLoop()
				end
				--物品
				if editingMenuPage.currentIndex==2 then
					editingItemPage.padLoop()
				end
				--幻化
				if editingMenuPage.currentIndex==3 then
					editingIllusionPage.padLoop()
				end
				--护石
				if editingMenuPage.currentIndex==4 then
					editingTalismanPage.padLoop()
				end
				--猎猫
				if editingMenuPage.currentIndex==5 then
					editingPalicoPage.padLoop()
				end
			end
			if pad.isPress(KEY_B) then
				userSelect.padLoop()
			end
			display.refresh()
		end
	end
}
