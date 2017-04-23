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

	displayText = {
		"将第①格防具幻化为第②格防具的外形",
		"将第③格防具幻化为第④格防具的外形",
		"将第⑤格防具幻化为第⑥格防具的外形",
		"将第⑦格防具幻化为第⑧格防具的外形",
		"将第⑨格防具幻化为第⑩格防具的外形"
	},
	
	display = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_ILLUSIONPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,85,20+editingIllusionPage.currentIndex*30,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,300,20+editingIllusionPage.currentIndex*30,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,5 do
			Font.print(theFont,105,20+i*30,editingIllusionPage.displayText[i],COLOR_ILLUSIONPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","确定"},
			{"B","上一层"}
		}
	end,
	
	padLoop = function()
		editingIllusionPage.currentIndex = 1
		editingIllusionPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = "幻化"}
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
				if messageBox.show(" 确认"..editingIllusionPage.displayText[editingIllusionPage.currentIndex].." ？","确认","取消")=="A" then
					messageBox.toast("                            幻化中 ...")
					if editingIllusionPage.setIllusion( editingIllusionPage.currentIndex*2 - 1    ,    editingIllusionPage.currentIndex*2 ) then
						messageBox.show("                            幻化成功 ！","确认","取消")
					else
						messageBox.show("                  幻化失败 ，请放好防具 ！","确认","取消")
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
