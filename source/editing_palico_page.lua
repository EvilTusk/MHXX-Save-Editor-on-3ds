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
			abilityTree =            { buffer.get(offset + palico.zoneOffset + o*byteNum + 84  , 2 ) },
			skillTree =              { buffer.get(offset + palico.zoneOffset + o*byteNum + 86  , 2 ) },
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
		for i=1,16 do
			if detail.ability[i]==P_ABILITY_NULL then
				for i2=i,16 do
					table.remove(detail.ability,i)
				end
				break
			end
		end
		for i=1,12 do
			if detail.skill[i]==P_SKILL_NULL then
				for i2=i,12 do
					table.remove(detail.skill,i)
				end
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
		for i=1,16 do
			buffer.set(offset + palico.zoneOffset + o*byteNum + 56 + i-1, P_ABILITY_NULL)
		end
		for i=1,12 do
			buffer.set(offset + palico.zoneOffset + o*byteNum + 72 + i-1, P_SKILL_NULL)
		end
		buffer.set(offset + palico.zoneOffset + o*byteNum       , t[1]              )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 36  , detail.lv-1       )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 37  , detail.kind-1     )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 39  , detail.object-1   )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 56  , detail.ability    )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 72  , detail.skill      )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 84  , detail.abilityTree)
		buffer.set(offset + palico.zoneOffset + o*byteNum + 86  , detail.skillTree  )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 156 , t[2]              )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 188 , t[3]              )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 282 , detail.furColor   )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 286 , detail.rEyeColor  )
		buffer.set(offset + palico.zoneOffset + o*byteNum + 290 , detail.lEyeColor  )
		--修改装备的技能
		if detail.kind==1 then
			buffer.set(offset + palico.zoneOffset + o*byteNum + 40 , detail.ability[1])
			for i=2,8 do
				buffer.set(offset + palico.zoneOffset + o*byteNum + 40 + i-1 , 0)
			end
		else
			buffer.set(offset + palico.zoneOffset + o*byteNum + 40     , detail.ability[1])
			buffer.set(offset + palico.zoneOffset + o*byteNum + 40 + 1 , detail.ability[2])
			for i=3,8 do
				buffer.set(offset + palico.zoneOffset + o*byteNum + 40 + i-1 , 0)
			end
		end
		for i=1,8 do
			buffer.set(offset + palico.zoneOffset + o*byteNum + 48 + i-1 , 0)
		end
		local expp = { detail.expp%(16*16), math.floor((detail.expp%(16*16*16*16))/(16*16)), math.floor((detail.expp%(16*16*16*16*16*16))/(16*16*16*16)), math.floor(detail.expp/(16*16*16*16*16*16)) }
		buffer.set(offset + palico.zoneOffset + o*byteNum + 32 , expp)
	end
}

editingPalicoPage = {

	visible = false,
	
	currentIndex = 1,
	displayIndexFirst = 1,
	
	display = function()
		if editingPalicoPage.editing_choosing then
			editingPalicoPage.display_choosing()
			return
		end
		if editingPalicoPage.editing_ability then
			editingPalicoPage.display_ability()
			return
		end
		if editingPalicoPage.editing_skill then
			editingPalicoPage.display_skill()
			return
		end
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
		display.explain = "建议猎人先在外形招募里招募到想要的外观的猎猫 ，\n再进行修改 ，修改时 ，请让猎猫处于完全待机状态 ，不\n能出击 、跟随等 ，请不要修改配信猫 ！避免出现问题 ！"
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
					editingPalicoPage.detail = palico.getPalicoDetail(editingPalicoPage.currentIndex)
					editingPalicoPage.padLoop_editing()
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,


	isKindChanged = false,

	detail = {},

	resetAbilityOfKind = function()
		--技能初始化
		editingPalicoPage.detail.ability = {}
		--固有技能1
		editingPalicoPage.detail.ability[1] = pAbilityO[editingPalicoPage.detail.kind][1]
		--固有技能2-4
		if editingPalicoPage.detail.kind==1 then
			--领袖猫没有第2个固有技能
			--技能2-3固定
			editingPalicoPage.detail.ability[2] = pAbilityS[1]
			editingPalicoPage.detail.ability[3] = pAbilityS[2]
			--3个传授位预留
			editingPalicoPage.detail.ability[4] = 0
			editingPalicoPage.detail.ability[5] = 0
			editingPalicoPage.detail.ability[6] = 0
		else
			--固有技能2
			editingPalicoPage.detail.ability[2] = pAbilityO[editingPalicoPage.detail.kind][2]
			--技能3-4固定
			editingPalicoPage.detail.ability[3] = pAbilityS[1]
			editingPalicoPage.detail.ability[4] = pAbilityS[2]
			--2个传授位预留
			editingPalicoPage.detail.ability[5] = 0
			editingPalicoPage.detail.ability[6] = 0
		end
	end,

	resetSkillOfKind = function()
		--固有技能1-2
		editingPalicoPage.detail.skill[1] = pSkillO[editingPalicoPage.detail.kind][1]
		editingPalicoPage.detail.skill[2] = pSkillO[editingPalicoPage.detail.kind][2]
		--2个传授位清空
		editingPalicoPage.detail.skill[#editingPalicoPage.detail.skill-1] = 0
		editingPalicoPage.detail.skill[#editingPalicoPage.detail.skill  ] = 0
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
	
	display_editing = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,100,15+editingPalicoPage.currentIndex_editing*20,"=>",COLOR_MAKA,TOP_SCREEN)
		if editingPalicoPage.currentIndex_editing==1 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==2 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,272,15+editingPalicoPage.currentIndex_editing*20,">",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==3 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,292,15+editingPalicoPage.currentIndex_editing*20,">",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==4 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==5 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==6 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==7 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==8 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==9 then
			Font.print(theFont,225,15+editingPalicoPage.currentIndex_editing*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		elseif editingPalicoPage.currentIndex_editing==10 then
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
		Font.print(theFont,120,195,"主动技能",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,195,"<……>",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,215,"被动技能",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,215,"<……>",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		--Font.print(theFont,120,195,"被动树表",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		--Font.print(theFont,240,195,editingPalicoPage.detail.skillTree[1]..editingPalicoPage.detail.skillTree[2],COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		--Font.print(theFont,120,215,"主动树表",COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
		--Font.print(theFont,240,215,editingPalicoPage.detail.abilityTree[1]..editingPalicoPage.detail.abilityTree[2],COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
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
		display.explain = "名字修改暂不支持中文 、日文 。修改猎猫类型后请务\n必接着修改主动技能与被动技能 。修改等级暂时只支持\n直接修改99级 。修改完成后需要按Y键保存 。"
	end,

	padLoop_editing = function()
		editingPalicoPage.isKindChanged = false
		editingPalicoPage.editing_ability = false
		editingPalicoPage.editing_skill = false
		editingPalicoPage.editing = true
		display.mark.nextMark.nextMark.nextMark = {name = "详情"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex_editing>1 then
					editingPalicoPage.currentIndex_editing = editingPalicoPage.currentIndex_editing-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex_editing<10 then
					editingPalicoPage.currentIndex_editing = editingPalicoPage.currentIndex_editing+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingPalicoPage.currentIndex_editing==2 then
					if editingPalicoPage.detail.kind>1 then
						editingPalicoPage.isKindChanged = true
						editingPalicoPage.detail.kind = editingPalicoPage.detail.kind-1
						editingPalicoPage.resetAbilityOfKind()
						editingPalicoPage.resetSkillOfKind()
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
						editingPalicoPage.isKindChanged = true
						editingPalicoPage.detail.kind = editingPalicoPage.detail.kind+1
						editingPalicoPage.resetAbilityOfKind()
						editingPalicoPage.resetSkillOfKind()
					end
				end
				if editingPalicoPage.currentIndex_editing==3  then
					if editingPalicoPage.detail.object<6 then
						editingPalicoPage.detail.object = editingPalicoPage.detail.object+1
					end
				end
			end
			if pad.isPress(KEY_Y) then
				if editingPalicoPage.isKindChanged then
					messageBox.show("修改猎猫类型后必须修改主动技能与被动技能 ！","确认","取消")
				elseif messageBox.show("                       确认保存修改吗 ？","确认","取消")=="A" then
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
				if editingPalicoPage.currentIndex_editing==9 then
					editingPalicoPage.padLoop_ability()
				end
				if editingPalicoPage.currentIndex_editing==10 then
					editingPalicoPage.padLoop_skill()
				end
			end
			if pad.isPress(KEY_B) then
				editingPalicoPage.padLoop()
			end
			display.refresh()
		end
	end,


	editing_ability = false,

	currentIndex_ability = 1,
	displayIndexFirst_ability = 1,

	abilityEditing = {},
	abilityPtLast = 0,

	abilityRefresh = function()
		editingPalicoPage.abilityEditing = {}
		for i,v in ipairs(editingPalicoPage.detail.ability) do
			editingPalicoPage.abilityEditing[i] = {}
			editingPalicoPage.abilityEditing[i].id = v
			if v~=0 then
				editingPalicoPage.abilityEditing[i].name = pAbilityAll[v].name
				editingPalicoPage.abilityEditing[i].pt = pAbilityAll[v].pt
			else
				editingPalicoPage.abilityEditing[i].name = "----- 无 -----"
				editingPalicoPage.abilityEditing[i].pt = 0
			end
		end
		--区分技能类型并计算剩余技能点数、添加自由技能预留位
		local ptCount = 0
		if editingPalicoPage.detail.kind==1 then
			--领袖猫
			editingPalicoPage.abilityEditing[1].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[2].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[3].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[1].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[2].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[3].ex = "（不可更改  ）"
			for i=4,#editingPalicoPage.abilityEditing-3 do
				editingPalicoPage.abilityEditing[i].tp = "MOD_DEL"
				editingPalicoPage.abilityEditing[i].ex = "占用点数 ："..editingPalicoPage.abilityEditing[i].pt
				ptCount = ptCount+editingPalicoPage.abilityEditing[i].pt
			end
			table.insert(editingPalicoPage.abilityEditing,#editingPalicoPage.abilityEditing-2,{ name = "##### 添加新的技能 #####", pt = 0, tp = "MOD_ADD", ex = ""})
			editingPalicoPage.abilityPtLast = 9 - ptCount
			for i=#editingPalicoPage.abilityEditing-2,#editingPalicoPage.abilityEditing do
				editingPalicoPage.abilityEditing[i].tp = "MOD_ALL"
				editingPalicoPage.abilityEditing[i].ex = "（传授技能  ）"
			end
		elseif editingPalicoPage.detail.kind==8 then
			--野兽猫
			editingPalicoPage.abilityEditing[1].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[2].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[3].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[4].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[1].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[2].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[3].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[4].ex = "（不可更改  ）"
			for i=5,#editingPalicoPage.abilityEditing-2 do
				editingPalicoPage.abilityEditing[i].tp = "MOD_DEL"
				editingPalicoPage.abilityEditing[i].ex = "占用点数 ："..editingPalicoPage.abilityEditing[i].pt
				ptCount = ptCount+editingPalicoPage.abilityEditing[i].pt
			end
			table.insert(editingPalicoPage.abilityEditing,#editingPalicoPage.abilityEditing-1,{ name = "##### 添加新的技能 #####", pt = 0, tp = "MOD_ADD", ex = ""})
			editingPalicoPage.abilityPtLast = 8 - ptCount
			for i=#editingPalicoPage.abilityEditing-1,#editingPalicoPage.abilityEditing do
				editingPalicoPage.abilityEditing[i].tp = "MOD_ALL"
				editingPalicoPage.abilityEditing[i].ex = "（传授技能  ）"
			end
		else
			--其他猫
			editingPalicoPage.abilityEditing[1].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[2].tp = "MOD_1I2"
			editingPalicoPage.abilityEditing[3].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[4].tp = "NOT_MOD"
			editingPalicoPage.abilityEditing[1].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[2].ex = "（  二选一    ）"
			editingPalicoPage.abilityEditing[3].ex = "（不可更改  ）"
			editingPalicoPage.abilityEditing[4].ex = "（不可更改  ）"
			for i=5,#editingPalicoPage.abilityEditing-2 do
				editingPalicoPage.abilityEditing[i].tp = "MOD_DEL"
				editingPalicoPage.abilityEditing[i].ex = "占用点数 ："..editingPalicoPage.abilityEditing[i].pt
				ptCount = ptCount+editingPalicoPage.abilityEditing[i].pt
			end
			table.insert(editingPalicoPage.abilityEditing,#editingPalicoPage.abilityEditing-1,{ name = "##### 添加新的技能 #####", pt = 0, tp = "MOD_ADD", ex = ""})
			editingPalicoPage.abilityPtLast = 8 - ptCount
			for i=#editingPalicoPage.abilityEditing-1,#editingPalicoPage.abilityEditing do
				editingPalicoPage.abilityEditing[i].tp = "MOD_ALL"
				editingPalicoPage.abilityEditing[i].ex = "（传授技能  ）"
			end
		end
	end,

	display_ability = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,280,10,"剩余点数 ："..editingPalicoPage.abilityPtLast,COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingPalicoPage.currentIndex_ability-editingPalicoPage.displayIndexFirst_ability+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingPalicoPage.abilityEditing then
				Font.print(theFont,55,15+20*i,editingPalicoPage.abilityEditing[editingPalicoPage.displayIndexFirst_ability+i-1].name,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
				Font.print(theFont,280,15+20*i,editingPalicoPage.abilityEditing[editingPalicoPage.displayIndexFirst_ability+i-1].ex,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingPalicoPage.abilityEditing>10 then
			local barLength = math.floor(10 / #editingPalicoPage.abilityEditing*192)
			local barLoc = math.floor((editingPalicoPage.displayIndexFirst_ability-1)/(#editingPalicoPage.abilityEditing-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGPALICOPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGPALICOPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		if editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="NOT_MOD" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_1I2" or editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_ALL" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","修改"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_DEL" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","删除"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_ADD" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","添加"},
				{"B","上一层"}
			}
		end
		display.explain = "注意 ！点数3的技能只能有一个 ，开头技能不能是单\n独的点数2技能 ，领袖猫比其他猫多1点技能点数 ，领袖\n猫必须有一个点数1的技能 。"
	end,

	padLoop_ability = function()
		editingPalicoPage.abilityRefresh()
		editingPalicoPage.editing_choosing = false
		editingPalicoPage.editing_ability = true
		editingPalicoPage.currentIndex_ability = 1
		editingPalicoPage.displayIndexFirst_ability = 1
		display.mark.nextMark.nextMark.nextMark.nextMark = {name = "主动技能"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex_ability>1 then
					editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability-1
				end
				if editingPalicoPage.currentIndex_ability<editingPalicoPage.displayIndexFirst_ability then
					editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex_ability<#editingPalicoPage.abilityEditing then
					editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability+1
				end
				if editingPalicoPage.currentIndex_ability>(editingPalicoPage.displayIndexFirst_ability+9) then
					editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability-10
				editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability-10
				if editingPalicoPage.currentIndex_ability<1 then
					editingPalicoPage.currentIndex_ability = 1
				end
				if editingPalicoPage.displayIndexFirst_ability<1 then
					editingPalicoPage.displayIndexFirst_ability = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability+10
				editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability+10
				if editingPalicoPage.currentIndex_ability>#editingPalicoPage.abilityEditing then
					editingPalicoPage.currentIndex_ability = #editingPalicoPage.abilityEditing
				end
				if editingPalicoPage.displayIndexFirst_ability>#editingPalicoPage.abilityEditing-9 then
					editingPalicoPage.displayIndexFirst_ability = #editingPalicoPage.abilityEditing-9
				end
				if editingPalicoPage.displayIndexFirst_ability<1 then
					editingPalicoPage.displayIndexFirst_ability = 1
				end
			end
			if pad.isPress(KEY_A) then
				--固有2选1技能
				if editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_1I2" then
					local t = {}
					--添加依猎猫类型而定的2选1技能
					local id1 = pAbilityO[editingPalicoPage.detail.kind][2]
					local id2 = pAbilityO[editingPalicoPage.detail.kind][3]
					t[1] = { id = id1, name = pAbilityAll[id1].name, ex = "" }
					t[2] = { id = id2, name = pAbilityAll[id2].name, ex = "" }
					local idGet = editingPalicoPage.getChoose(t)
					if idGet~=0 then
						editingPalicoPage.detail.ability[editingPalicoPage.currentIndex_ability] = idGet
						editingPalicoPage.abilityRefresh()
					end
				--删除自由技能
				elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_DEL" then
					table.remove(editingPalicoPage.detail.ability, editingPalicoPage.currentIndex_ability)
					editingPalicoPage.abilityRefresh()
					--调整显示位置
					editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability-1
					if editingPalicoPage.displayIndexFirst_ability>1 then
						editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability-1
					end
				--添加自由技能
				elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_ADD" then
					local t = {}
					--添加所有自由系技能
					for i,v in ipairs(pAbility) do
						for i2,v2 in ipairs(v) do
							table.insert(t,{ id = v2, name = pAbilityAll[v2].name, ex = "需要点数 ："..pAbilityAll[v2].pt })
						end
					end
					local idGet = editingPalicoPage.getChoose(t)
					if idGet~=0 then
						local isExist = function()
							for i,v in ipairs(editingPalicoPage.detail.ability) do
								if idGet==v then
									return true
								end
							end
							return false
						end
						if not isExist() then
							--自动调整技能位置
							local pt = pAbilityAll[idGet].pt
							if pt==3 then
								if editingPalicoPage.detail.kind==1 then
									table.insert(editingPalicoPage.detail.ability, 4, idGet)
								else
									table.insert(editingPalicoPage.detail.ability, 5, idGet)
								end
							elseif pt==2 then
								if editingPalicoPage.detail.kind==1 then
									for i,v in ipairs(editingPalicoPage.detail.ability) do
										if v==0 then
											table.insert(editingPalicoPage.detail.ability, i, idGet)
											break
										end
										if i>3 and (pAbilityAll[v].pt==1 or pAbilityAll[v].pt==0) then
											table.insert(editingPalicoPage.detail.ability, i, idGet)
											break
										end
									end
								else
									for i,v in ipairs(editingPalicoPage.detail.ability) do
										if v==0 then
											table.insert(editingPalicoPage.detail.ability, i, idGet)
											break
										end
										if i>4 and (pAbilityAll[v].pt==1 or pAbilityAll[v].pt==0) then
											table.insert(editingPalicoPage.detail.ability, i, idGet)
											break
										end
									end
								end
							elseif pt==1 then
								table.insert(editingPalicoPage.detail.ability, editingPalicoPage.currentIndex_ability, idGet)
							end
							editingPalicoPage.abilityRefresh()
							--调整显示位置
							editingPalicoPage.currentIndex_ability = editingPalicoPage.currentIndex_ability+1
							if editingPalicoPage.currentIndex_ability>(editingPalicoPage.displayIndexFirst_ability+9) then
								editingPalicoPage.displayIndexFirst_ability = editingPalicoPage.displayIndexFirst_ability+1
							end
						else
							messageBox.show("                        该技能已存在 ！","确认","取消")
						end
					end
				--传授技能
				elseif editingPalicoPage.abilityEditing[editingPalicoPage.currentIndex_ability].tp=="MOD_ALL" then
					local t = {}
					--添加空选项
					table.insert(t,{ id = -1, name = "----- 无 -----", ex = "" })
					--添加所有自由系技能
					for i,v in ipairs(pAbility) do
						for i2,v2 in ipairs(v) do
							table.insert(t,{ id = v2, name = pAbilityAll[v2].name, ex = "" })
						end
					end
					--添加所有类型（除了领袖和野兽）的猫的固有2选1技能
					for i,v in ipairs(pAbilityO) do
						if i~=1 and i~=8 then
							local isExist = function()
								for i2,v2 in ipairs(t) do
									if v[2]==v2.id then
										return true
									end
								end
								return false
							end
							if not isExist() then
								table.insert(t,{ id = v[2], name = pAbilityAll[v[2]].name, ex = "" })
							end
							local isExist = function()
								for i2,v2 in ipairs(t) do
									if v[3]==v2.id then
										return true
									end
								end
								return false
							end
							if not isExist() then
								table.insert(t,{ id = v[3], name = pAbilityAll[v[3]].name, ex = "" })
							end
						end
					end
					local idGet = editingPalicoPage.getChoose(t)
					if idGet==-1 then
						editingPalicoPage.detail.ability[editingPalicoPage.currentIndex_ability-1] = 0
						editingPalicoPage.abilityRefresh()
					elseif idGet~=0 then
						local isExist = function()
							for i,v in ipairs(editingPalicoPage.detail.ability) do
								if idGet==v then
									return true
								end
							end
							return false
						end
						if not isExist() then
							editingPalicoPage.detail.ability[editingPalicoPage.currentIndex_ability-1] = idGet
							editingPalicoPage.abilityRefresh()
						else
							messageBox.show("                        该技能已存在 ！","确认","取消")
						end
					end
				end
			end
			if pad.isPress(KEY_B) then
				if editingPalicoPage.abilityPtLast~=0 then
					if messageBox.show("        剩余技能点数不为0 ！确认返回 ？","确认","取消")=="A" then
						editingPalicoPage.padLoop_editing()
					end
				elseif editingPalicoPage.detail.kind==1 then
					local isHaveOnePtAbility = function()
						for i,v in ipairs(editingPalicoPage.abilityEditing) do
							if v.tp=="MOD_DEL" and v.pt==1 then
								return true
							end
						end
						return false
					end
					if isHaveOnePtAbility() then
						local ptTree = {}
						for i,v in ipairs(editingPalicoPage.abilityEditing) do
							if v.tp=="MOD_DEL" then
								table.insert(ptTree, v.pt)
							end
						end
						table.remove(ptTree)
						local threePtAbilityCount = 0
						local twoPtAbilityCount = 0
						for i,v in ipairs(ptTree) do
							if v==3 then
								threePtAbilityCount = threePtAbilityCount+1
							elseif v==2 then
								twoPtAbilityCount = twoPtAbilityCount+1
							end
						end
						if threePtAbilityCount>1 then
							if messageBox.show("      点数3的技能只能有一个 ！确认返回 ？","确认","取消")=="A" then
								editingPalicoPage.padLoop_editing()
							end
						elseif threePtAbilityCount==0 and twoPtAbilityCount==1 then
							if messageBox.show("开头技能不能是单独的点数2技能 ！确认返回 ？","确认","取消")=="A" then
								editingPalicoPage.padLoop_editing()
							end
						else
							--完全合法通道
							local abilityTree = pAbilityTree[table.concat(ptTree,nil)]
							abilityTree[2] = abilityTree[2]+1 --领袖猫补正
							editingPalicoPage.detail.abilityTree = abilityTree
							editingPalicoPage.padLoop_editing()
						end
					else
						if messageBox.show(" 领袖猫必须有一个点数1的技能 ！确认返回 ？","确认","取消")=="A" then
							editingPalicoPage.padLoop_editing()
						end
					end
				else
					local ptTree = {}
					for i,v in ipairs(editingPalicoPage.abilityEditing) do
						if v.tp=="MOD_DEL" then
							table.insert(ptTree, v.pt)
						end
					end
					local threePtAbilityCount = 0
					local twoPtAbilityCount = 0
					for i,v in ipairs(ptTree) do
						if v==3 then
							threePtAbilityCount = threePtAbilityCount+1
						elseif v==2 then
							twoPtAbilityCount = twoPtAbilityCount+1
						end
					end
					if threePtAbilityCount>1 then
						if messageBox.show("      点数3的技能只能有一个 ！确认返回 ？","确认","取消")=="A" then
							editingPalicoPage.padLoop_editing()
						end
					elseif threePtAbilityCount==0 and twoPtAbilityCount==1 then
						if messageBox.show("开头技能不能是单独的点数2技能 ！确认返回 ？","确认","取消")=="A" then
							editingPalicoPage.padLoop_editing()
						end
					else
						--完全合法通道
						local abilityTree = pAbilityTree[table.concat(ptTree,nil)]
						editingPalicoPage.detail.abilityTree = abilityTree
						editingPalicoPage.padLoop_editing()
					end
				end
			end
			display.refresh()
		end
	end,


	editing_skill = false,

	currentIndex_skill = 1,
	displayIndexFirst_skill = 1,

	skillEditing = {},
	skillPtLast = 0,

	skillRefresh = function()
		editingPalicoPage.skillEditing = {}
		for i,v in ipairs(editingPalicoPage.detail.skill) do
			editingPalicoPage.skillEditing[i] = {}
			editingPalicoPage.skillEditing[i].id = v
			if v~=0 then
				editingPalicoPage.skillEditing[i].name = pSkillAll[v].name
				editingPalicoPage.skillEditing[i].pt = pSkillAll[v].pt
			else
				editingPalicoPage.skillEditing[i].name = "----- 无 -----"
				editingPalicoPage.skillEditing[i].pt = 0
			end
		end
		--区分技能类型并计算剩余技能点数、添加自由技能预留位
		local ptCount = 0
		editingPalicoPage.skillEditing[1].tp = "NOT_MOD"
		editingPalicoPage.skillEditing[2].tp = "NOT_MOD"
		editingPalicoPage.skillEditing[1].ex = "（不可更改  ）"
		editingPalicoPage.skillEditing[2].ex = "（不可更改  ）"
		for i=3,#editingPalicoPage.skillEditing-2 do
			editingPalicoPage.skillEditing[i].tp = "MOD_DEL"
			editingPalicoPage.skillEditing[i].ex = "占用点数 ："..editingPalicoPage.skillEditing[i].pt
			ptCount = ptCount+editingPalicoPage.skillEditing[i].pt
		end
		table.insert(editingPalicoPage.skillEditing,#editingPalicoPage.skillEditing-1,{ name = "##### 添加新的技能 #####", pt = 0, tp = "MOD_ADD", ex = ""})
		editingPalicoPage.skillPtLast = 8 - ptCount
		for i=#editingPalicoPage.skillEditing-1,#editingPalicoPage.skillEditing do
			editingPalicoPage.skillEditing[i].tp = "MOD_ALL"
			editingPalicoPage.skillEditing[i].ex = "（传授技能  ）"
		end
	end,

	display_skill = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,280,10,"剩余点数 ："..editingPalicoPage.skillPtLast,COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingPalicoPage.currentIndex_skill-editingPalicoPage.displayIndexFirst_skill+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingPalicoPage.skillEditing then
				Font.print(theFont,55,15+20*i,editingPalicoPage.skillEditing[editingPalicoPage.displayIndexFirst_skill+i-1].name,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
				Font.print(theFont,280,15+20*i,editingPalicoPage.skillEditing[editingPalicoPage.displayIndexFirst_skill+i-1].ex,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingPalicoPage.skillEditing>10 then
			local barLength = math.floor(10 / #editingPalicoPage.skillEditing*192)
			local barLoc = math.floor((editingPalicoPage.displayIndexFirst_skill-1)/(#editingPalicoPage.skillEditing-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGPALICOPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGPALICOPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		if editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="NOT_MOD" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_ALL" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","修改"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_DEL" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","删除"},
				{"B","上一层"}
			}
		elseif editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_ADD" then
			display.hint = {
				{"↑↓","移动光标"},
				{"←→","翻页"},
				{"A","添加"},
				{"B","上一层"}
			}
		end
		display.explain = "注意 ！点数3的技能只能有一个 ，开头技能不能是单\n独的点数2技能 。领袖猫没有特殊的被动技能规则 。"
	end,

	padLoop_skill = function()
		editingPalicoPage.skillRefresh()
		editingPalicoPage.editing_choosing = false
		editingPalicoPage.editing_skill = true
		editingPalicoPage.currentIndex_skill = 1
		editingPalicoPage.displayIndexFirst_skill = 1
		display.mark.nextMark.nextMark.nextMark.nextMark = {name = "被动技能"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex_skill>1 then
					editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill-1
				end
				if editingPalicoPage.currentIndex_skill<editingPalicoPage.displayIndexFirst_skill then
					editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex_skill<#editingPalicoPage.skillEditing then
					editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill+1
				end
				if editingPalicoPage.currentIndex_skill>(editingPalicoPage.displayIndexFirst_skill+9) then
					editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill-10
				editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill-10
				if editingPalicoPage.currentIndex_skill<1 then
					editingPalicoPage.currentIndex_skill = 1
				end
				if editingPalicoPage.displayIndexFirst_skill<1 then
					editingPalicoPage.displayIndexFirst_skill = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill+10
				editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill+10
				if editingPalicoPage.currentIndex_skill>#editingPalicoPage.skillEditing then
					editingPalicoPage.currentIndex_skill = #editingPalicoPage.skillEditing
				end
				if editingPalicoPage.displayIndexFirst_skill>#editingPalicoPage.skillEditing-9 then
					editingPalicoPage.displayIndexFirst_skill = #editingPalicoPage.skillEditing-9
				end
				if editingPalicoPage.displayIndexFirst_skill<1 then
					editingPalicoPage.displayIndexFirst_skill = 1
				end
			end
			if pad.isPress(KEY_A) then
				--删除自由技能
				if editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_DEL" then
					table.remove(editingPalicoPage.detail.skill, editingPalicoPage.currentIndex_skill)
					editingPalicoPage.skillRefresh()
					--调整显示位置
					editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill-1
					if editingPalicoPage.displayIndexFirst_skill>1 then
						editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill-1
					end
				--添加自由技能
				elseif editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_ADD" then
					local t = {}
					--添加所有自由系技能
					for i,v in ipairs(pSkill) do
						for i2,v2 in ipairs(v) do
							table.insert(t,{ id = v2, name = pSkillAll[v2].name, ex = "需要点数 ："..pSkillAll[v2].pt })
						end
					end
					local idGet = editingPalicoPage.getChoose(t)
					if idGet~=0 then
						local isExist = function()
							for i,v in ipairs(editingPalicoPage.detail.skill) do
								if idGet==v then
									return true
								end
							end
							return false
						end
						if not isExist() then
							--自动调整技能位置
							local pt = pSkillAll[idGet].pt
							if pt==3 then
								table.insert(editingPalicoPage.detail.skill, 3, idGet)
							elseif pt==2 then
								for i,v in ipairs(editingPalicoPage.detail.skill) do
									if v==0 then
										table.insert(editingPalicoPage.detail.skill, i, idGet)
										break
									end
									if i>2 and (pSkillAll[v].pt==1 or pSkillAll[v].pt==0) then
										table.insert(editingPalicoPage.detail.skill, i, idGet)
										break
									end
								end
							elseif pt==1 then
								table.insert(editingPalicoPage.detail.skill, editingPalicoPage.currentIndex_skill, idGet)
							end
							editingPalicoPage.skillRefresh()
							--调整显示位置
							editingPalicoPage.currentIndex_skill = editingPalicoPage.currentIndex_skill+1
							if editingPalicoPage.currentIndex_skill>(editingPalicoPage.displayIndexFirst_skill+9) then
								editingPalicoPage.displayIndexFirst_skill = editingPalicoPage.displayIndexFirst_skill+1
							end
						else
							messageBox.show("                        该技能已存在 ！","确认","取消")
						end
					end
				--传授技能
				elseif editingPalicoPage.skillEditing[editingPalicoPage.currentIndex_skill].tp=="MOD_ALL" then
					local t = {}
					--添加空选项
					table.insert(t,{ id = -1, name = "----- 无 -----", ex = "" })
					--添加所有自由系技能
					for i,v in ipairs(pSkill) do
						for i2,v2 in ipairs(v) do
							table.insert(t,{ id = v2, name = pSkillAll[v2].name, ex = "" })
						end
					end
					--添加所有类型的猫的固有技能
					for i,v in ipairs(pSkillO) do
						table.insert(t,{ id = v[1], name = pSkillAll[v[1]].name, ex = "" })
						table.insert(t,{ id = v[2], name = pSkillAll[v[2]].name, ex = "" })
					end
					--添加所有配信技能
					for i,v in ipairs(pSkillD) do
						table.insert(t,{ id = v, name = pSkillAll[v].name, ex = "" })
					end
					local idGet = editingPalicoPage.getChoose(t)
					if idGet==-1 then
						editingPalicoPage.detail.skill[editingPalicoPage.currentIndex_skill-1] = 0
						editingPalicoPage.skillRefresh()
					elseif idGet~=0 then
						local isExist = function()
							for i,v in ipairs(editingPalicoPage.detail.skill) do
								if idGet==v then
									return true
								end
							end
							return false
						end
						if not isExist() then
							editingPalicoPage.detail.skill[editingPalicoPage.currentIndex_skill-1] = idGet
							editingPalicoPage.skillRefresh()
						else
							messageBox.show("                        该技能已存在 ！","确认","取消")
						end
					end
				end
			end
			if pad.isPress(KEY_B) then
				if editingPalicoPage.skillPtLast~=0 then
					if messageBox.show("        剩余技能点数不为0 ！确认返回 ？","确认","取消")=="A" then
						editingPalicoPage.padLoop_editing()
					end
				else
					local ptTree = {}
					for i,v in ipairs(editingPalicoPage.skillEditing) do
						if v.tp=="MOD_DEL" then
							table.insert(ptTree, v.pt)
						end
					end
					local threePtAbilityCount = 0
					local twoPtAbilityCount = 0
					for i,v in ipairs(ptTree) do
						if v==3 then
							threePtAbilityCount = threePtAbilityCount+1
						elseif v==2 then
							twoPtAbilityCount = twoPtAbilityCount+1
						end
					end
					if threePtAbilityCount>1 then
						if messageBox.show("      点数3的技能只能有一个 ！确认返回 ？","确认","取消")=="A" then
							editingPalicoPage.padLoop_editing()
						end
					elseif threePtAbilityCount==0 and twoPtAbilityCount==1 then
						if messageBox.show("开头技能不能是单独的点数2技能 ！确认返回 ？","确认","取消")=="A" then
							editingPalicoPage.padLoop_editing()
						end
					else
						--完全合法通道
						local skillTree = pSkillTree[table.concat(ptTree,nil)]
						editingPalicoPage.detail.skillTree = skillTree
						editingPalicoPage.padLoop_editing()
					end
				end
			end
			display.refresh()
		end
	end,


	editing_choosing = false,

	chooseBox = {},

	currentIndex_choosing = 1,
	displayIndexFirst_choosing = 1,

	display_choosing = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGPALICOPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingPalicoPage.currentIndex_choosing-editingPalicoPage.displayIndexFirst_choosing+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingPalicoPage.chooseBox then
				Font.print(theFont,55,15+20*i,editingPalicoPage.chooseBox[editingPalicoPage.displayIndexFirst_choosing+i-1].name,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
				Font.print(theFont,280,15+20*i,editingPalicoPage.chooseBox[editingPalicoPage.displayIndexFirst_choosing+i-1].ex,COLOR_EDITINGPALICOPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingPalicoPage.chooseBox>10 then
			local barLength = math.floor(10 / #editingPalicoPage.chooseBox*192)
			local barLoc = math.floor((editingPalicoPage.displayIndexFirst_choosing-1)/(#editingPalicoPage.chooseBox-10)*(192-barLength))
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

	getChoose = function(list)
		editingPalicoPage.chooseBox = list
		editingPalicoPage.editing_choosing = true
		editingPalicoPage.currentIndex_choosing = 1
		editingPalicoPage.displayIndexFirst_choosing = 1
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingPalicoPage.currentIndex_choosing>1 then
					editingPalicoPage.currentIndex_choosing = editingPalicoPage.currentIndex_choosing-1
				end
				if editingPalicoPage.currentIndex_choosing<editingPalicoPage.displayIndexFirst_choosing then
					editingPalicoPage.displayIndexFirst_choosing = editingPalicoPage.displayIndexFirst_choosing-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingPalicoPage.currentIndex_choosing<#editingPalicoPage.chooseBox then
					editingPalicoPage.currentIndex_choosing = editingPalicoPage.currentIndex_choosing+1
				end
				if editingPalicoPage.currentIndex_choosing>(editingPalicoPage.displayIndexFirst_choosing+9) then
					editingPalicoPage.displayIndexFirst_choosing = editingPalicoPage.displayIndexFirst_choosing+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingPalicoPage.currentIndex_choosing = editingPalicoPage.currentIndex_choosing-10
				editingPalicoPage.displayIndexFirst_choosing = editingPalicoPage.displayIndexFirst_choosing-10
				if editingPalicoPage.currentIndex_choosing<1 then
					editingPalicoPage.currentIndex_choosing = 1
				end
				if editingPalicoPage.displayIndexFirst_choosing<1 then
					editingPalicoPage.displayIndexFirst_choosing = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingPalicoPage.currentIndex_choosing = editingPalicoPage.currentIndex_choosing+10
				editingPalicoPage.displayIndexFirst_choosing = editingPalicoPage.displayIndexFirst_choosing+10
				if editingPalicoPage.currentIndex_choosing>#editingPalicoPage.chooseBox then
					editingPalicoPage.currentIndex_choosing = #editingPalicoPage.chooseBox
				end
				if editingPalicoPage.displayIndexFirst_choosing>#editingPalicoPage.chooseBox-9 then
					editingPalicoPage.displayIndexFirst_choosing = #editingPalicoPage.chooseBox-9
				end
				if editingPalicoPage.displayIndexFirst_choosing<1 then
					editingPalicoPage.displayIndexFirst_choosing = 1
				end
			end
			if pad.isPress(KEY_A) then
				pad.reload()
				editingPalicoPage.editing_choosing = false
				return editingPalicoPage.chooseBox[editingPalicoPage.currentIndex_choosing].id
			end
			if pad.isPress(KEY_B) then
				pad.reload()
				editingPalicoPage.editing_choosing = false
				return 0
			end
			display.refresh()
		end
	end
}
