COLOR_HINT_FONT = Color.new(255,255,255)
COLOR_HINT_TITLE = Color.new(255,255,0)
COLOR_HINT_ICON = Color.new(102,204,255)
COLOR_HINT_EXPLAINBOXEDGE = Color.new(255,255,255)
COLOR_HINT_BACKGROUND = Color.new(0,0,0)
COLOR_MARK_FONT = Color.new(255,255,0)

display = {
	mark = { },
	hint = { },
	explain = "",

	getMarkStr = function(o)
		local str = ""
		if o~=nil then
			if o.name~=nil then
				str = "["..o.name.."]"
				if o.nextMark~=nil then
					str = str.." => "..display.getMarkStr(o.nextMark)
				end
			end
		end
		return str
	end,

	refresh = function()
		Screen.waitVblankStart()
		Screen.refresh()
		
		--按优先级排序，最低优先级最先绘制
		--上屏
		if editingComPage.visible then
			editingComPage.display()
		end
		if editingItemPage.visible then
			editingItemPage.display()
		end
		if editingIllusionPage.visible then
			editingIllusionPage.display()
		end
		if editingTalismanPage.visible then
			editingTalismanPage.display()
		end
		if editingPalicoPage.visible then
			editingPalicoPage.display()
		end
		
		if editingMenuPage.visible then
			editingMenuPage.display()
		end
		
		if userSelect.visible then
			userSelect.display()
		end
		if sav.visible then
			sav.display()
		end
		
		if menu.visible then
			menu.display()
		end
		

		if keyboard.visible then
			keyboard.display()
		end
		if colorPicker.visible then
			colorPicker.display()
		end
		
		if messageBox.visible then
			messageBox.display()
		end

		if (not keyboard.visible) and (not colorPicker.visible) then
			--上层标识
			Font.print(theFont,10,10,display.getMarkStr(display.mark),COLOR_MARK_FONT,TOP_SCREEN)

			--下屏
			Screen.fillRect(0,319,0,239,COLOR_HINT_BACKGROUND,BOTTOM_SCREEN)
			Font.print(theFont,95,30, "ＭＨＸＸ存档修改器  ver "..version,COLOR_HINT_TITLE,BOTTOM_SCREEN)
			for i,v in ipairs(display.hint) do
				Font.print(theFont,110,40+20*i, v[1],COLOR_HINT_ICON,BOTTOM_SCREEN)
				Font.print(theFont,150,40+20*i, "：　"..v[2],COLOR_HINT_FONT,BOTTOM_SCREEN)
			end
			Screen.fillRect(18,301,158,202,COLOR_HINT_EXPLAINBOXEDGE,BOTTOM_SCREEN)
			Screen.fillRect(19,300,159,201,COLOR_HINT_BACKGROUND,BOTTOM_SCREEN)
			Font.print(theFont,25,164,"# "..display.explain,COLOR_HINT_FONT,BOTTOM_SCREEN)
			Font.print(theFont,260,220,"by EvilTusk",COLOR_HINT_TITLE,BOTTOM_SCREEN)
		end

		Screen.flip()
	end
}
