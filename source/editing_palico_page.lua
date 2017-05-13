COLOR_EDITINGPALICOPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGPALICOPAGE_SCROLLBAR = Color.new(102,204,255)
COLOR_EDITINGPALICOPAGE_SCROLLLINE = Color.new(128,128,128)
COLOR_EDITINGPALICOPAGE_BACKGROUND = Color.new(0,0,0)
COLOR_EDITINGPALICOPAGE_COLORBACKGROUND = Color.new(255,255,255)
COLOR_EDITINGPALICOPAGE_BACKGROUND = Color.new(0,0,0)

palico = {

	zone = {},

	zoneOffset = 146358,
	
	getPalicoZone = function()
		local byteNum = 324
		for i=1,60 do
			palico.zone[i] = {
				name = string.char(buffer.get(offset + palico.zoneOffset + (i-1)*byteNum , 32)),
				lv = buffer.get(offset + palico.zoneOffset + (i-1)*byteNum + 36) + 1
			}
			if string.sub(palico.zone[i].name,1,1)=="\0" then
				palico.zone[i].name = "-----"
				palico.zone[i].lv = "--"
			end
		end
	end,

	getPalicoDetail = function(index)
		local o = index-1
		local byteNum = 324
		local detail = {
			name =        string.char( buffer.get(offset + palico.zoneOffset + o*byteNum       , 32) ),
			lv =                       buffer.get(offset + palico.zoneOffset + o*byteNum + 36) + 1,
			kind =                     buffer.get(offset + palico.zoneOffset + o*byteNum + 37) + 1,
			object =                   buffer.get(offset + palico.zoneOffset + o*byteNum + 39) + 1,
			ability =                { buffer.get(offset + palico.zoneOffset + o*byteNum + 56  , 16) },
			skill =                  { buffer.get(offset + palico.zoneOffset + o*byteNum + 72  , 12) },
			nameGiver =   string.char( buffer.get(offset + palico.zoneOffset + o*byteNum + 156 , 32) ),
			formerOwner = string.char( buffer.get(offset + palico.zoneOffset + o*byteNum + 188 , 32) ),
			furColor =               { buffer.get(offset + palico.zoneOffset + o*byteNum + 282 , 3 ) },
			rEyeColor =              { buffer.get(offset + palico.zoneOffset + o*byteNum + 286 , 3 ) },
			lEyeColor =              { buffer.get(offset + palico.zoneOffset + o*byteNum + 290 , 3 ) }
		}
		for i=1,32 do
			if string.sub(detail.name,i,i)=="\0" then
				detail.name = string.sub(detail.name,1,i-1)
				break
			end
		end
		for i=1,32 do
			if string.sub(detail.nameGiver,i,i)=="\0" then
				detail.nameGiver = string.sub(detail.nameGiver,1,i-1)
				break
			end
		end
		for i=1,32 do
			if string.sub(detail.formerOwner,i,i)=="\0" then
				detail.formerOwner = string.sub(detail.formerOwner,1,i-1)
				break
			end
		end
		local expp = { buffer.get(offset + palico.zoneOffset + o*byteNum + 32 , 4 ) }
		detail.expp = expp[4]*16*16*16*16*16*16 + expp[3]*16*16*16*16 + expp[2]*16*16 + expp[1]
		return detail
	end,

	rewritePalicoDetail = function(index,detail)
		--##
		palico.zone[index].lv = detail.lv
		--##
		local o = index-1
		local byteNum = 324
		local t = { {},{},{} }
		for i=1,32 do
			t[1][i] = string.byte(string.sub(detail.name,        i, i))
			t[2][i] = string.byte(string.sub(detail.nameGiver,   i, i))
			t[3][i] = string.byte(string.sub(detail.formerOwner, i, i))
			buffer.set(offset + palico.zoneOffset + o*byteNum       + i-1, 0)
			buffer.set(offset + palico.zoneOffset + o*byteNum + 156 + i-1, 0)
			buffer.set(offset + palico.zoneOffset + o*byteNum + 188 + i-1, 0)
		end
		buffer.set(offset + palico.zoneOffset + o*byteNum       , t[1]             )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 36  , detail.lv-1      )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 37  , detail.kind-1    )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 39  , detail.object-1  )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 156 , t[2]             )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 188 , t[3]             )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 282 , detail.furColor  )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 286 , detail.rEyeColor )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 290 , detail.lEyeColor )
		local expp = { detail.expp%(16*16), math.floor((detail.expp%(16*16*16*16))/(16*16)), math.floor((detail.expp%(16*16*16*16*16*16))/(16*16*16*16)), math.floor(detail.expp/(16*16*16*16*16*16)) }
		buffer.set(offset + palico.zoneOffset + o*byteNum + 32 , expp)
	end
}

editingPalicoPage = {

	visible = false,
	
	currentIndex = 1,
	displayIndexFirst = 1,
	
	display = function()
		if editingPalicoPage.editing then
			editingPalicoPage.display_editing()
			return
		end
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,300,10,"LV",COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingPalicoPage.currentIndex-editingPalicoPage.displayIndexFirst+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#palico.zone then
				Font.print(theFont,55,15+20*i,palico.zone[editingPalicoPage.displayIndexFirst+i-1].name,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
				Font.print(theFont,300,15+20*i,palico.zone[editingPalicoPage.displayIndexFirst+i-1].lv,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #palico.zone>10 then
			local barLength = math.floor(10 / #palico.zone*192)
			local barLoc = math.floor((editingPalicoPage.displayIndexFirst-1)/(#palico.zone-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGPALICOPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGPALICOPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"←→","翻页"},
			{"A","选择"},
			{"B","上一层"}
		}
	end,
	
	padLoop = function()
		editingPalicoPage.editing = false
		editingPalicoPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = "猎猫"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex>1 then
					editingPalicoPage.currentIndex = editingPalicoPage.currentIndex-1
				end
				if editingPalicoPage.currentIndex<editingPalicoPage.displayIndexFirst then
					editingPalicoPage.displayIndexFirst = editingPalicoPage.displayIndexFirst-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex<#palico.zone then
					editingPalicoPage.currentIndex = editingPalicoPage.currentIndex+1
				end
				if editingPalicoPage.currentIndex>(editingPalicoPage.displayIndexFirst+9) then
					editingPalicoPage.displayIndexFirst = editingPalicoPage.displayIndexFirst+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingPalicoPage.currentIndex = editingPalicoPage.currentIndex-10
				editingPalicoPage.displayIndexFirst = editingPalicoPage.displayIndexFirst-10
				if editingPalicoPage.currentIndex<1 then
					editingPalicoPage.currentIndex = 1
				end
				if editingPalicoPage.displayIndexFirst<1 then
					editingPalicoPage.displayIndexFirst = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingPalicoPage.currentIndex = editingPalicoPage.currentIndex+10
				editingPalicoPage.displayIndexFirst = editingPalicoPage.displayIndexFirst+10
				if editingPalicoPage.currentIndex>#palico.zone then
					editingPalicoPage.currentIndex = #palico.zone
				end
				if editingPalicoPage.displayIndexFirst>#palico.zone-9 then
					editingPalicoPage.displayIndexFirst = #palico.zone-9
				end
				if editingPalicoPage.displayIndexFirst<1 then
					editingPalicoPage.displayIndexFirst = 1
				end
			end
			if pad.isPress(KEY_A) then
				if palico.zone[editingPalicoPage.currentIndex].name~="-----" then
					editingPalicoPage.padLoop_editing()
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,


	editing = false,
	currentIndex_editing = 1,

	kindText = {
		"领袖",
		"奋斗",
		"防御",
		"辅助",
		"回复",
		"爆弹",
		"收集",
		"野兽"
	},

	objectText = {
		"无指定",
		"只打小型",
		"小型优先",
		"平衡",
		"大型优先",
		"只打大型"
	},

	detail = {},
	
	display_editing = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,100,15+editingPalicoPage.currentIndex_editing*20,"=>",COLOR_MAKA,TOP_SCREEN)
		if editingPalicoPage.currentIndex_editing==1 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==2 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,272,15+editingPalicoPage.currentIndex_editing*20,">",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==3 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,292,15+editingPalicoPage.currentIndex_editing*20,">",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==4 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==5 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==6 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==7 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		if editingPalicoPage.currentIndex_editing==8 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		Font.print(theFont,120,35,"等级",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,35,editingPalicoPage.detail.lv,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,55,"猎猫类型",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,55,editingPalicoPage.kindText[editingPalicoPage.detail.kind],COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,75,"攻击倾向",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,75,editingPalicoPage.objectText[editingPalicoPage.detail.object],COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,95,"命名者",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,95,editingPalicoPage.detail.nameGiver,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,115,"前主人",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,115,editingPalicoPage.detail.formerOwner,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,135,"毛皮色",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		local furColor = Color.new(table.unpack(editingPalicoPage.detail.furColor))
		Screen.fillRect(239,271,134,146,COLOR_EDITINGPALICOPAGE_COLORBACKGROUND,TOP_SCREEN)
		Screen.fillRect(240,270,135,145,furColor,TOP_SCREEN)
		Font.print(theFont,120,155,"右眼色",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		local rEyeColor = Color.new(table.unpack(editingPalicoPage.detail.rEyeColor))
		Screen.fillRect(239,271,154,166,COLOR_EDITINGPALICOPAGE_COLORBACKGROUND,TOP_SCREEN)
		Screen.fillRect(240,270,155,165,rEyeColor,TOP_SCREEN)
		Font.print(theFont,120,175,"左眼色",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		local lEyeColor = Color.new(table.unpack(editingPalicoPage.detail.lEyeColor))
		Screen.fillRect(239,271,174,186,COLOR_EDITINGPALICOPAGE_COLORBACKGROUND,TOP_SCREEN)
		Screen.fillRect(240,270,175,185,lEyeColor,TOP_SCREEN)
		--Font.print(theFont,120,195,"经验",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		--Font.print(theFont,240,195,editingPalicoPage.detail.expp,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		----下屏
		if editingPalicoPage.currentIndex_editing==1 then
			display.hint = {
				{"↑↓","移动光标"},
				{"A","修改为99级"},
				{"Y","保存修改"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.currentIndex_editing==2 or editingPalicoPage.currentIndex_editing==3 then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","更改"},
				{"Y","保存修改"},
				{"B","上一层"}
			}
		else
			display.hint = {
				{"↑↓","移动光标"},
				{"A","修改"},
				{"Y","保存修改"},
				{"B","上一层"}
			}
		end
	end,

	padLoop_editing = function()
		editingPalicoPage.currentIndex_editing = 1
		editingPalicoPage.detail = palico.getPalicoDetail(editingPalicoPage.currentIndex)
		editingPalicoPage.editing = true
		display.mark.nextMark.nextMark.nextMark = {name = editingPalicoPage.detail.name}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex_editing>1 then
					editingPalicoPage.currentIndex_editing = editingPalicoPage.currentIndex_editing-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex_editing<8 then
					editingPalicoPage.currentIndex_editing = editingPalicoPage.currentIndex_editing+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingPalicoPage.currentIndex_editing==2 then
					if editingPalicoPage.detail.kind>1 then
						editingPalicoPage.detail.kind = editingPalicoPage.detail.kind-1
					end
				end
				if editingPalicoPage.currentIndex_editing==3  then
					if editingPalicoPage.detail.object>1 then
						editingPalicoPage.detail.object = editingPalicoPage.detail.object-1
					end
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingPalicoPage.currentIndex_editing==2 then
					if editingPalicoPage.detail.kind<8 then
						editingPalicoPage.detail.kind = editingPalicoPage.detail.kind+1
					end
				end
				if editingPalicoPage.currentIndex_editing==3  then
					if editingPalicoPage.detail.object<6 then
						editingPalicoPage.detail.object = editingPalicoPage.detail.object+1
					end
				end
			end
			if pad.isPress(KEY_Y) then
				if messageBox.show("                       确认保存修改吗 ？","确认","取消")=="A" then
					messageBox.toast("                              保存中 ...")
					palico.rewritePalicoDetail(editingPalicoPage.currentIndex,editingPalicoPage.detail)
				end
			end
			if pad.isPress(KEY_A) then
				if editingPalicoPage.currentIndex_editing==1 then
					if messageBox.show("                  确认修改等级为99吗 ？","确认","取消")=="A" then
						editingPalicoPage.detail.lv = 99
						editingPalicoPage.detail.expp = 950215
					end
				end
				if editingPalicoPage.currentIndex_editing==4 then
					local str = keyboard.get("请修改命名者名字 ：",editingPalicoPage.detail.nameGiver,10)
					if str~="" then
						editingPalicoPage.detail.nameGiver = str
					end
				end
				if editingPalicoPage.currentIndex_editing==5 then
					local str = keyboard.get("请修改前主人名字 ：",editingPalicoPage.detail.formerOwner,10)
					if str~="" then
						editingPalicoPage.detail.formerOwner = str
					end
				end
				if editingPalicoPage.currentIndex_editing==6 then
					editingPalicoPage.visible = false
					local isChanged,r,g,b = colorPicker.show("请调整毛皮颜色 ：",table.unpack(editingPalicoPage.detail.furColor))
					if isChanged then
						editingPalicoPage.detail.furColor = { r,g,b }
					end
					editingPalicoPage.visible = true
				end
				if editingPalicoPage.currentIndex_editing==7 then
					editingPalicoPage.visible = false
					local isChanged,r,g,b = colorPicker.show("请调整左眼颜色 ：",table.unpack(editingPalicoPage.detail.rEyeColor))
					if isChanged then
						editingPalicoPage.detail.rEyeColor = { r,g,b }
					end
					editingPalicoPage.visible = true
				end
				if editingPalicoPage.currentIndex_editing==8 then
					editingPalicoPage.visible = false
					local isChanged,r,g,b = colorPicker.show("请调整右眼颜色 ：",table.unpack(editingPalicoPage.detail.lEyeColor))
					if isChanged then
						editingPalicoPage.detail.lEyeColor = { r,g,b }
					end
					editingPalicoPage.visible = true
				end
			end
			if pad.isPress(KEY_B) then
				editingPalicoPage.padLoop()
			end
			display.refresh()
		end
	end
}
