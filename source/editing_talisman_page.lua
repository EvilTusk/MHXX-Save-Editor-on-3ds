COLOR_EDITINGTALISMANPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGTALISMANPAGE_SCROLLBAR = Color.new(102,204,255)
COLOR_EDITINGTALISMANPAGE_SCROLLLINE = Color.new(128,128,128)
COLOR_EDITINGTALISMANPAGE_BACKGROUND = Color.new(0,0,0)

MAX_RAM_ALLOCATION = 10485760


editingTalismanPage = {

	equipmentBoxOffset = 25326,

	getEmptySpace = function(emptySpaceInEquipBoxOffset)
		emptySpaceInEquipBoxOffset = emptySpaceInEquipBoxOffset or 0
		for i=0,35 do
			if buffer.get(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceInEquipBoxOffset + i) ~= 0 then
				emptySpaceInEquipBoxOffset = emptySpaceInEquipBoxOffset + 36
				return editingTalismanPage.getEmptySpace(emptySpaceInEquipBoxOffset)
			end
		end
		return emptySpaceInEquipBoxOffset
	end,
	
	addTalisman = function(typeCode, sk1Code, sk2Code, sk1Num, sk2Num, slot)
		local emptySpaceOffset = editingTalismanPage.getEmptySpace()
		if emptySpaceOffset >= 72000 then
			return false
		end
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset      , 6 )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 2  , typeCode )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 12 , sk1Code )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 13 , sk2Code )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 14 , sk1Num )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 15 , sk2Num )
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 16 , slot )
		if typeCode == 1 then
			buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 18 , 97 )
		elseif typeCode >= 2 and typeCode <= 4  then
			buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 18 , 98 )
		elseif typeCode >= 5 and typeCode <= 7  then
			buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 18 , 99 )
		elseif typeCode >= 8 and typeCode <= 10 then
			buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 18 , 100 )
		end
		buffer.set(offset + editingTalismanPage.equipmentBoxOffset + emptySpaceOffset + 19 , 1 )
		return true
	end,

	visible = false,

	currentIndex = 1,

	rareText = {},

	currentSetting = {
		rare = 1,
		sk_id = { 0,0 },
		sk_pt = { 0,0 },
		slot = 0,
	},

	mode = 0,

	display = function()
		if editingTalismanPage.mode==1 then
			editingTalismanPage.display_chooseSkill()
			return
		end
		--上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGTALISMANPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,60,10+40*editingTalismanPage.currentIndex,"=>",COLOR_MAKA,TOP_SCREEN)
		--左右标
		if editingTalismanPage.currentIndex==1 then
			Font.print(theFont,220,50,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,325,50,">",COLOR_MAKA,TOP_SCREEN)
		end
		if editingTalismanPage.currentIndex==2 then
			Font.print(theFont,275,90,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,315,90,">",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,145,90,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingTalismanPage.currentIndex==3 then
			Font.print(theFont,275,130,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,315,130,">",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,145,130,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingTalismanPage.currentIndex==4 then
			Font.print(theFont,275,170,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,315,170,">",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		Font.print(theFont,80,50,TEXT_EDITINGTALISMANPAGE[1],COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,50,editingTalismanPage.rareText[editingTalismanPage.currentSetting.rare],COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)

		Font.print(theFont,80,90,TEXT_EDITINGTALISMANPAGE[2],COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,160,90,skillList[editingTalismanPage.currentSetting.sk_id[1]+1].name,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		local str1 = editingTalismanPage.currentSetting.sk_pt[1]
		if str1>=0 then
			str1 = "+"..str1
		end
		Font.print(theFont,290,90,str1,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		
		Font.print(theFont,80,130,TEXT_EDITINGTALISMANPAGE[3],COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,160,130,skillList[editingTalismanPage.currentSetting.sk_id[2]+1].name,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		local str2 = editingTalismanPage.currentSetting.sk_pt[2]
		if str2>=0 then
			str2 = "+"..str2
		end
		Font.print(theFont,290,130,str2,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		
		Font.print(theFont,80,170,TEXT_EDITINGTALISMANPAGE[4],COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,295,170,editingTalismanPage.currentSetting.slot,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
		
		----下屏
		if editingTalismanPage.currentIndex==1 then
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_EDITINGTALISMANPAGE[5]},
				{"Y",TEXT_EDITINGTALISMANPAGE[9]},
				{"B",TEXT_RETURN}
			}
		end
		if editingTalismanPage.currentIndex==2 or editingTalismanPage.currentIndex==3 then
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_EDITINGTALISMANPAGE[6]},
				{"A",TEXT_EDITINGTALISMANPAGE[8]},
				{"Y",TEXT_EDITINGTALISMANPAGE[9]},
				{"B",TEXT_RETURN}
			}
		end
		if editingTalismanPage.currentIndex==4 then
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_EDITINGTALISMANPAGE[7]},
				{"Y",TEXT_EDITINGTALISMANPAGE[9]},
				{"B",TEXT_RETURN}
			}
		end
		display.explain = TEXT_EDITINGTALISMANPAGE_E
	end,

	padLoop = function()
		editingTalismanPage.mode = 0
		editingTalismanPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = TEXT_EDITINGTALISMANPAGE_M}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingTalismanPage.currentIndex>1 then
					editingTalismanPage.currentIndex = editingTalismanPage.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingTalismanPage.currentIndex<4 then
					editingTalismanPage.currentIndex = editingTalismanPage.currentIndex+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingTalismanPage.currentIndex==1 then
					if editingTalismanPage.currentSetting.rare>1 then
						editingTalismanPage.currentSetting.rare = editingTalismanPage.currentSetting.rare-1
					end
				end
				if editingTalismanPage.currentIndex==2 then
					if editingTalismanPage.currentSetting.sk_pt[1]>-10 then
						editingTalismanPage.currentSetting.sk_pt[1] = editingTalismanPage.currentSetting.sk_pt[1]-1
					end
				end
				if editingTalismanPage.currentIndex==3 then
					if editingTalismanPage.currentSetting.sk_pt[2]>-10 then
						editingTalismanPage.currentSetting.sk_pt[2] = editingTalismanPage.currentSetting.sk_pt[2]-1
					end
				end
				if editingTalismanPage.currentIndex==4 then
					if editingTalismanPage.currentSetting.slot>0 then
						editingTalismanPage.currentSetting.slot = editingTalismanPage.currentSetting.slot-1
					end
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingTalismanPage.currentIndex==1 then
					if editingTalismanPage.currentSetting.rare<10 then
						editingTalismanPage.currentSetting.rare = editingTalismanPage.currentSetting.rare+1
					end
				end
				if editingTalismanPage.currentIndex==2 then
					if editingTalismanPage.currentSetting.sk_pt[1]<14 then
						editingTalismanPage.currentSetting.sk_pt[1] = editingTalismanPage.currentSetting.sk_pt[1]+1
					end
				end
				if editingTalismanPage.currentIndex==3 then
					if editingTalismanPage.currentSetting.sk_pt[2]<14 then
						editingTalismanPage.currentSetting.sk_pt[2] = editingTalismanPage.currentSetting.sk_pt[2]+1
					end
				end
				if editingTalismanPage.currentIndex==4 then
					if editingTalismanPage.currentSetting.slot<3 then
						editingTalismanPage.currentSetting.slot = editingTalismanPage.currentSetting.slot+1
					end
				end
			end
			if pad.isPress(KEY_Y) then
				if editingTalismanPage.currentSetting.sk_id[1]==0 then
					messageBox.show(TEXT_EDITINGTALISMANPAGE_O[1],TEXT_OK,TEXT_CANCEL)
				else
					if editingTalismanPage.currentSetting.sk_pt[1]==0 then
						messageBox.show(TEXT_EDITINGTALISMANPAGE_O[2],TEXT_OK,TEXT_CANCEL)
					else
						if messageBox.show(TEXT_EDITINGTALISMANPAGE_O[3],TEXT_OK,TEXT_CANCEL)=="A" then
							messageBox.toast(TEXT_EDITINGTALISMANPAGE_O[4])
							if editingTalismanPage.addTalisman( editingTalismanPage.currentSetting.rare, editingTalismanPage.currentSetting.sk_id[1], editingTalismanPage.currentSetting.sk_id[2], editingTalismanPage.currentSetting.sk_pt[1], editingTalismanPage.currentSetting.sk_pt[2], editingTalismanPage.currentSetting.slot ) then
								messageBox.show(TEXT_EDITINGTALISMANPAGE_O[5],TEXT_OK,TEXT_CANCEL)
							else
								messageBox.show(TEXT_EDITINGTALISMANPAGE_O[6],TEXT_OK,TEXT_CANCEL)
							end
						end
					end
				end
			end
			if pad.isPress(KEY_A) then
				if editingTalismanPage.currentIndex==2 or editingTalismanPage.currentIndex==3 then
					editingTalismanPage.padLoop_chooseSkill()
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,


	limitsText1 = {
		"R①",
		"R②",
		"R③",
		"R④",
		"R⑤",
		"R⑥",
		"R⑦",
		"R⑧",
		"R⑨",
		"R⑩"
	},

	limitsText2 = {},

	currentEditingLoc_chooseSkill = 1,
	currentIndex_chooseSkill = 1,
	displayIndexFirst_chooseSkill = 1,

	display_chooseSkill = function()
		--上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGTALISMANPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingTalismanPage.currentIndex_chooseSkill-editingTalismanPage.displayIndexFirst_chooseSkill+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		--极限值标题
		Font.print(theFont,260,10,editingTalismanPage.limitsText1[editingTalismanPage.currentSetting.rare].."-"..editingTalismanPage.limitsText2[editingTalismanPage.currentEditingLoc_chooseSkill].."-"..TEXT_EDITINGTALISMANPAGE_CHOOSESKILL[1],COLOR_MAKA,TOP_SCREEN)
		for i=1,10 do
			if i<=#skillList then
				--技能名
				Font.print(theFont,55,15+20*i,skillList[editingTalismanPage.displayIndexFirst_chooseSkill+i-1].name,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
				--极限值
				local rank = 0
				if editingTalismanPage.currentSetting.rare==1 then
					rank = 1
				end
				if editingTalismanPage.currentSetting.rare>=2 and editingTalismanPage.currentSetting.rare<=4 then
					rank = 2
				end
				if editingTalismanPage.currentSetting.rare>=5 and editingTalismanPage.currentSetting.rare<=7 then
					rank = 3
				end
				if editingTalismanPage.currentSetting.rare>=8 and editingTalismanPage.currentSetting.rare<=10 then
					rank = 4
				end
				local str = skillList[editingTalismanPage.displayIndexFirst_chooseSkill+i-1].limits[editingTalismanPage.currentEditingLoc_chooseSkill][rank]
				if str=="" then
					str = "---------"
				end
				Font.print(theFont,280,15+20*i,str,COLOR_EDITINGTALISMANPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #skillList>10 then
			local barLength = math.floor(10 / #skillList*192)
			local barLoc = math.floor((editingTalismanPage.displayIndexFirst_chooseSkill-1)/(#skillList-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGTALISMANPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGTALISMANPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		if editingTalismanPage.currentIndex_chooseSkill==1 then
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_PAGETURN},
				{"A",TEXT_EDITINGTALISMANPAGE_CHOOSESKILL[2]},
				{"B",TEXT_RETURN}
			}
		else
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_PAGETURN},
				{"A",TEXT_EDITINGTALISMANPAGE_CHOOSESKILL[2]},
				{"B",TEXT_RETURN}
			}
		end
	end,

	padLoop_chooseSkill = function()
		editingTalismanPage.mode = 1
		editingTalismanPage.currentEditingLoc_chooseSkill = editingTalismanPage.currentIndex-1
		editingTalismanPage.currentIndex_chooseSkill = editingTalismanPage.currentSetting.sk_id[editingTalismanPage.currentEditingLoc_chooseSkill] + 1
		editingTalismanPage.displayIndexFirst_chooseSkill = editingTalismanPage.currentSetting.sk_id[editingTalismanPage.currentEditingLoc_chooseSkill] + 1 - 4
		if editingTalismanPage.displayIndexFirst_chooseSkill<1 then
			editingTalismanPage.displayIndexFirst_chooseSkill = 1
		end
		if editingTalismanPage.displayIndexFirst_chooseSkill>#skillList-9 then
			editingTalismanPage.displayIndexFirst_chooseSkill = #skillList-9
		end
		display.mark.nextMark.nextMark.nextMark = {name = TEXT_EDITINGTALISMANPAGE_CHOOSESKILL_M}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingTalismanPage.currentIndex_chooseSkill>1 then
					editingTalismanPage.currentIndex_chooseSkill = editingTalismanPage.currentIndex_chooseSkill-1
				end
				if editingTalismanPage.currentIndex_chooseSkill<editingTalismanPage.displayIndexFirst_chooseSkill then
					editingTalismanPage.displayIndexFirst_chooseSkill = editingTalismanPage.displayIndexFirst_chooseSkill-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingTalismanPage.currentIndex_chooseSkill<#skillList then
					editingTalismanPage.currentIndex_chooseSkill = editingTalismanPage.currentIndex_chooseSkill+1
				end
				if editingTalismanPage.currentIndex_chooseSkill>(editingTalismanPage.displayIndexFirst_chooseSkill+9) then
					editingTalismanPage.displayIndexFirst_chooseSkill = editingTalismanPage.displayIndexFirst_chooseSkill+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingTalismanPage.currentIndex_chooseSkill = editingTalismanPage.currentIndex_chooseSkill-10
				editingTalismanPage.displayIndexFirst_chooseSkill = editingTalismanPage.displayIndexFirst_chooseSkill-10
				if editingTalismanPage.currentIndex_chooseSkill<1 then
					editingTalismanPage.currentIndex_chooseSkill = 1
				end
				if editingTalismanPage.displayIndexFirst_chooseSkill<1 then
					editingTalismanPage.displayIndexFirst_chooseSkill = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingTalismanPage.currentIndex_chooseSkill = editingTalismanPage.currentIndex_chooseSkill+10
				editingTalismanPage.displayIndexFirst_chooseSkill = editingTalismanPage.displayIndexFirst_chooseSkill+10
				if editingTalismanPage.currentIndex_chooseSkill>#skillList then
					editingTalismanPage.currentIndex_chooseSkill = #skillList
				end
				if editingTalismanPage.displayIndexFirst_chooseSkill>#skillList-9 then
					editingTalismanPage.displayIndexFirst_chooseSkill = #skillList-9
				end
				if editingTalismanPage.displayIndexFirst_chooseSkill<1 then
					editingTalismanPage.displayIndexFirst_chooseSkill = 1
				end
			end
			if pad.isPress(KEY_A) then
				editingTalismanPage.currentSetting.sk_id[editingTalismanPage.currentEditingLoc_chooseSkill] = editingTalismanPage.currentIndex_chooseSkill - 1
				editingTalismanPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingTalismanPage.padLoop()
			end
			display.refresh()
		end
	end
}
