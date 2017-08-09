COLOR_ILLUSIONPAGE_FONT = Color.new(255,255,255)
COLOR_ILLUSIONPAGE_BACKGROUND = Color.new(0,0,0)

editingIllusionPage = {

	visible = false,
	
	currentIndex = 1,


	equipmentBoxOffset = 25326,

	setIllusion = function(objIndex,aprIndex)
		local equipment1Type = buffer.get(offset + editingIllusionPage.equipmentBoxOffset + 36*(objIndex-1)) % 32
		local equipment2Type = buffer.get(offset + editingIllusionPage.equipmentBoxOffset + 36*(aprIndex-1)) % 32
		if equipment1Type<0 then
			equipment1Type = equipment1Type+32
		end
		if equipment2Type<0 then
			equipment2Type = equipment2Type+32
		end
		if equipment1Type < 1 or equipment1Type > 5 or equipment2Type < 1 or equipment2Type > 5 then
			return false
		else
			buffer.set(  offset + editingIllusionPage.equipmentBoxOffset + 36*(objIndex-1) + 4    ,    buffer.get(offset + editingIllusionPage.equipmentBoxOffset + 36*(aprIndex-1) + 2)  )
			buffer.set(  offset + editingIllusionPage.equipmentBoxOffset + 36*(objIndex-1) + 5    ,    buffer.get(offset + editingIllusionPage.equipmentBoxOffset + 36*(aprIndex-1) + 3)  )
			return true
		end
	end,

	display = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_ILLUSIONPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,85,20+editingIllusionPage.currentIndex*30,"=>",COLOR_MAKA,TOP_SCREEN)
		--Font.print(theFont,300,20+editingIllusionPage.currentIndex*30,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,5 do
			Font.print(theFont,105,20+i*30,TEXT_EDITINGILLUSIONPAGE[i],COLOR_ILLUSIONPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"↑↓",TEXT_MOVE},
			{"A",TEXT_OK},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGILLUSIONPAGE_E
	end,
	
	padLoop = function()
		editingIllusionPage.currentIndex = 1
		editingIllusionPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = TEXT_EDITINGILLUSIONPAGE_M}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingIllusionPage.currentIndex>1 then
					editingIllusionPage.currentIndex = editingIllusionPage.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingIllusionPage.currentIndex<5 then
					editingIllusionPage.currentIndex = editingIllusionPage.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				if messageBox.show(TEXT_EDITINGILLUSIONPAGE_O[1]..TEXT_EDITINGILLUSIONPAGE[editingIllusionPage.currentIndex]..TEXT_EDITINGILLUSIONPAGE_O[2],TEXT_OK,TEXT_CANCEL)=="A" then
					messageBox.toast(TEXT_EDITINGILLUSIONPAGE_O[3])
					if editingIllusionPage.setIllusion( editingIllusionPage.currentIndex*2 - 1    ,    editingIllusionPage.currentIndex*2 ) then
						messageBox.show(TEXT_EDITINGILLUSIONPAGE_O[4],TEXT_OK,TEXT_CANCEL)
					else
						messageBox.show(TEXT_EDITINGILLUSIONPAGE_O[5],TEXT_OK,TEXT_CANCEL)
					end
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end
}
