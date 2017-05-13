COLOR_EDITINGITEMPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGITEMPAGE_SCROLLBAR = Color.new(102,204,255)
COLOR_EDITINGITEMPAGE_SCROLLLINE = Color.new(128,128,128)
COLOR_EDITINGITEMPAGE_BACKGROUND = Color.new(0,0,0)

function Dec2Bin(dec,bitNum)
	local Hex2Bin = {
		["0"] = "0000",
		["1"] = "0001",
		["2"] = "0010",
		["3"] = "0011",
		["4"] = "0100",
		["5"] = "0101",
		["6"] = "0110",
		["7"] = "0111",
		["8"] = "1000",
		["9"] = "1001",
		["a"] = "1010",
		["b"] = "1011",
		["c"] = "1100",
		["d"] = "1101",
		["e"] = "1110",
		["f"] = "1111"
	}
	local hex = string.format("%x",dec)
	local bin = ""
	for i=1,string.len(hex) do
		bin = bin..Hex2Bin[string.sub(hex,i,i)]
	end
	if string.len(bin)==bitNum then
		return bin
	end
	if string.len(bin)>bitNum then
		return string.sub(bin,-bitNum,-1)
	end
	if string.len(bin)<bitNum then
		for i=string.len(bin)+1,bitNum do
			bin = "0"..bin
		end
		return bin
	end
end

function Bin2Dec(bin)
	local dec = 0
	for i=1,string.len(bin) do
		dec = dec + ( tonumber(string.sub(bin,-i,-i)) * (2^(i-1)) )
	end
	return dec
end


item = {

	box = {},
	
	boxOffset = 632,

	getEmptySpace = function()
		for i=1,2300 do
			if item.box[i].id==0 or item.box[i].num==0 then
				return i
			end
		end
		return 0
	end,

	getItemBox = function()
		local bytesNum = 5463
		local dataBytes = { buffer.get(offset+item.boxOffset,bytesNum) }
		local dataBin = ""
		for i,v in ipairs(dataBytes) do
			dataBin = Dec2Bin(v,8)..dataBin
		end
		for i=1,2300 do
			item.box[i] = {
				id = Bin2Dec(string.sub(dataBin,-12 + (-19)*(i-1), -1 + (-19)*(i-1))) ,
				num = Bin2Dec(string.sub(dataBin,-19 + (-19)*(i-1), -13 + (-19)*(i-1)))
			}
		end
	end,

	addItemToBox = function(id,num)
		if item.getEmptySpace()==0 then
			return false
		end
		if num>99 then
			local a = item.addItemToBox(id,99)
			local b = item.addItemToBox(id,num-99)
			return ( a and b )
		else
			item.box[item.getEmptySpace()] = {
				id = id,
				num = num
			}
			return true
		end
	end,

	rewriteItemBox = function()
		local dataBin = ""
		for i=1,2300 do
			dataBin = Dec2Bin(item.box[i].num,7)..Dec2Bin(item.box[i].id,12)..dataBin
		end
		dataBin = "0000"..dataBin
		local bytesNum = 5463
		local dataBytes = {}
		for i=1,bytesNum do
			dataBytes[i] = Bin2Dec(string.sub(dataBin,-8 + (-8)*(i-1), -1 + (-8)*(i-1)))
		end
		buffer.set(offset+item.boxOffset,dataBytes)
	end
}

editingItemPage = {

	visible = false,
	
	mode = 0,
	
	currentIndex = 1,
	
	display = function()
		if editingItemPage.mode==1 then
			editingItemPage.display_medicAdd()
			return
		end
		if editingItemPage.mode==2 then
			editingItemPage.display_longrangeAdd()
			return
		end
		if editingItemPage.mode==3 then
			editingItemPage.display_otherAdd()
			return
		end
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,155,30+editingItemPage.currentIndex*40,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,230,30+editingItemPage.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,180,70,"消耗品",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,175,110,"远程素材",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,175,150,"其他物品",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","进入"},
			{"B","上一层"}
		}
		display.explain = "暂不支持在所有物品的列表随意选择进行添加 。"
	end,
	
	padLoop = function()
		editingItemPage.mode = 0
		editingItemPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = "物品"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingItemPage.currentIndex>1 then
					editingItemPage.currentIndex = editingItemPage.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingItemPage.currentIndex<3 then
					editingItemPage.currentIndex = editingItemPage.currentIndex+1
				end
			end
			if pad.isPress(KEY_A) then
				if editingItemPage.currentIndex==1 then
					editingItemPage.padLoop_medicAdd()
				end
				if editingItemPage.currentIndex==2 then
					editingItemPage.padLoop_longrangeAdd()
				end
				if editingItemPage.currentIndex==3 then
					editingItemPage.padLoop_otherAdd()
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,


	medicAddItemList = {
		{
			name = "鬼人药G",
			id = 18
		},
		{
			name = "硬化药G",
			id = 21
		},
		{
			name = "强走药G",
			id = 16
		},
		{
			name = "怪力之种",
			id = 303
		},
		{
			name = "忍耐之种",
			id = 304
		},
		{
			name = "秘药",
			id = 28
		},
		{
			name = "古代秘药",
			id = 29
		},
		{
			name = "生命大粉尘",
			id = 32
		},
	},
	
	currentIndex_medicAdd = 1,
	displayIndexFirst_medicAdd = 1,
	
	display_medicAdd = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,265,10,"添加消耗品 (+99)",COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingItemPage.currentIndex_medicAdd-editingItemPage.displayIndexFirst_medicAdd+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingItemPage.medicAddItemList then
				Font.print(theFont,55,15+20*i,editingItemPage.medicAddItemList[editingItemPage.displayIndexFirst_medicAdd+i-1].name,COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingItemPage.medicAddItemList>10 then
			local barLength = math.floor(10 / #editingItemPage.medicAddItemList*192)
			local barLoc = math.floor((editingItemPage.displayIndexFirst_medicAdd-1)/(#editingItemPage.medicAddItemList-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGITEMPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGITEMPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"←→","翻页"},
			{"A","添加"},
			{"B","上一层"}
		}
		display.explain = "物品会被添加到你道具箱里最靠前的空位 。"
	end,
	
	padLoop_medicAdd = function()
		editingItemPage.mode = 1
		editingItemPage.currentIndex_medicAdd = 1
		editingItemPage.displayIndexFirst_medicAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = "消耗品"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingItemPage.currentIndex_medicAdd>1 then
					editingItemPage.currentIndex_medicAdd = editingItemPage.currentIndex_medicAdd-1
				end
				if editingItemPage.currentIndex_medicAdd<editingItemPage.displayIndexFirst_medicAdd then
					editingItemPage.displayIndexFirst_medicAdd = editingItemPage.displayIndexFirst_medicAdd-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingItemPage.currentIndex_medicAdd<#editingItemPage.medicAddItemList then
					editingItemPage.currentIndex_medicAdd = editingItemPage.currentIndex_medicAdd+1
				end
				if editingItemPage.currentIndex_medicAdd>(editingItemPage.displayIndexFirst_medicAdd+9) then
					editingItemPage.displayIndexFirst_medicAdd = editingItemPage.displayIndexFirst_medicAdd+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingItemPage.currentIndex_medicAdd = editingItemPage.currentIndex_medicAdd-10
				editingItemPage.displayIndexFirst_medicAdd = editingItemPage.displayIndexFirst_medicAdd-10
				if editingItemPage.currentIndex_medicAdd<1 then
					editingItemPage.currentIndex_medicAdd = 1
				end
				if editingItemPage.displayIndexFirst_medicAdd<1 then
					editingItemPage.displayIndexFirst_medicAdd = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingItemPage.currentIndex_medicAdd = editingItemPage.currentIndex_medicAdd+10
				editingItemPage.displayIndexFirst_medicAdd = editingItemPage.displayIndexFirst_medicAdd+10
				if editingItemPage.currentIndex_medicAdd>#editingItemPage.medicAddItemList then
					editingItemPage.currentIndex_medicAdd = #editingItemPage.medicAddItemList
				end
				if editingItemPage.displayIndexFirst_medicAdd>#editingItemPage.medicAddItemList-9 then
					editingItemPage.displayIndexFirst_medicAdd = #editingItemPage.medicAddItemList-9
				end
				if editingItemPage.displayIndexFirst_medicAdd<1 then
					editingItemPage.displayIndexFirst_medicAdd = 1
				end
			end
			if pad.isPress(KEY_A) then
				if messageBox.show("确认添加99个"..editingItemPage.medicAddItemList[editingItemPage.currentIndex_medicAdd].name.."到你的道具箱吗 ？","确认","取消")=="A" then
					messageBox.toast(   "                            执行中 ...")
					if item.addItemToBox(editingItemPage.medicAddItemList[editingItemPage.currentIndex_medicAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show("                            添加成功 ！","确认","取消")
					else
						messageBox.show("                 添加失败 ，箱子可能已满 ！","确认","取消")
					end
				end
			end
			if pad.isPress(KEY_B) then
				editingItemPage.padLoop()
			end
			display.refresh()
		end
	end,


	longrangeAddItemList = {
		{
			name = "空心果",
			id = 98
		},
		{
			name = "空心骨",
			id = 99
		},
		{
			name = "回复药",
			id = 9
		},
		{
			name = "砥石",
			id = 56
		},
		{
			name = "空瓶",
			id = 207
		},
		{
			name = "药草",
			id = 272
		},
		{
			name = "火药草",
			id = 274
		},
		{
			name = "睡眠草",
			id = 276
		},
		{
			name = "洛阳草之根",
			id = 279
		},
		{
			name = "降霜草",
			id = 281
		},
		{
			name = "硝化菇",
			id = 293
		},
		{
			name = "麻痹菇",
			id = 294
		},
		{
			name = "毒伞菇",
			id = 295
		},
		{
			name = "疲劳伞菇",
			id = 296
		},
		{
			name = "染色果",
			id = 302
		},
		{
			name = "杀龙果",
			id = 306
		},
		{
			name = "爆裂核桃",
			id = 307
		},
		{
			name = "针果",
			id = 308
		},
		{
			name = "贯通果",
			id = 309
		},
		{
			name = "扩散果",
			id = 310
		},
		{
			name = "切味鱼",
			id = 362
		},
		{
			name = "眠鱼",
			id = 364
		},
		{
			name = "针金枪鱼",
			id = 365
		},
		{
			name = "爆裂沙丁鱼",
			id = 367
		},
		{
			name = "扩散凸眼金鱼",
			id = 368
		},
		{
			name = "破裂龙鱼",
			id = 369
		},
		{
			name = "爆裂龙鱼",
			id = 370
		},
		{
			name = "深水沙丁鱼",
			id = 375
		},
		{
			name = "苦虫",
			id = 385
		},
		{
			name = "光虫",
			id = 386
		},
		{
			name = "龙牙",
			id = 432
		},
		{
			name = "龙爪",
			id = 433
		},
		{
			name = "鸟龙种的牙",
			id = 571
		},
		{
			name = "黄速龙的麻痹牙",
			id = 603
		},
		{
			name = "红速龙的毒牙",
			id = 616
		}
	},
	
	currentIndex_longrangeAdd = 1,
	displayIndexFirst_longrangeAdd = 1,
	
	display_longrangeAdd = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,260,10,"添加远程素材 (+99)",COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingItemPage.currentIndex_longrangeAdd-editingItemPage.displayIndexFirst_longrangeAdd+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingItemPage.longrangeAddItemList then
				Font.print(theFont,55,15+20*i,editingItemPage.longrangeAddItemList[editingItemPage.displayIndexFirst_longrangeAdd+i-1].name,COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingItemPage.longrangeAddItemList>10 then
			local barLength = math.floor(10 / #editingItemPage.longrangeAddItemList*192)
			local barLoc = math.floor((editingItemPage.displayIndexFirst_longrangeAdd-1)/(#editingItemPage.longrangeAddItemList-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGITEMPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGITEMPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"←→","翻页"},
			{"A","添加"},
			{"B","上一层"}
		}
		display.explain = "物品会被添加到你道具箱里最靠前的空位 。"
	end,
	
	padLoop_longrangeAdd = function()
		editingItemPage.mode = 2
		editingItemPage.currentIndex_longrangeAdd = 1
		editingItemPage.displayIndexFirst_longrangeAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = "远程素材"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingItemPage.currentIndex_longrangeAdd>1 then
					editingItemPage.currentIndex_longrangeAdd = editingItemPage.currentIndex_longrangeAdd-1
				end
				if editingItemPage.currentIndex_longrangeAdd<editingItemPage.displayIndexFirst_longrangeAdd then
					editingItemPage.displayIndexFirst_longrangeAdd = editingItemPage.displayIndexFirst_longrangeAdd-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingItemPage.currentIndex_longrangeAdd<#editingItemPage.longrangeAddItemList then
					editingItemPage.currentIndex_longrangeAdd = editingItemPage.currentIndex_longrangeAdd+1
				end
				if editingItemPage.currentIndex_longrangeAdd>(editingItemPage.displayIndexFirst_longrangeAdd+9) then
					editingItemPage.displayIndexFirst_longrangeAdd = editingItemPage.displayIndexFirst_longrangeAdd+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingItemPage.currentIndex_longrangeAdd = editingItemPage.currentIndex_longrangeAdd-10
				editingItemPage.displayIndexFirst_longrangeAdd = editingItemPage.displayIndexFirst_longrangeAdd-10
				if editingItemPage.currentIndex_longrangeAdd<1 then
					editingItemPage.currentIndex_longrangeAdd = 1
				end
				if editingItemPage.displayIndexFirst_longrangeAdd<1 then
					editingItemPage.displayIndexFirst_longrangeAdd = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingItemPage.currentIndex_longrangeAdd = editingItemPage.currentIndex_longrangeAdd+10
				editingItemPage.displayIndexFirst_longrangeAdd = editingItemPage.displayIndexFirst_longrangeAdd+10
				if editingItemPage.currentIndex_longrangeAdd>#editingItemPage.longrangeAddItemList then
					editingItemPage.currentIndex_longrangeAdd = #editingItemPage.longrangeAddItemList
				end
				if editingItemPage.displayIndexFirst_longrangeAdd>#editingItemPage.longrangeAddItemList-9 then
					editingItemPage.displayIndexFirst_longrangeAdd = #editingItemPage.longrangeAddItemList-9
				end
				if editingItemPage.displayIndexFirst_longrangeAdd<1 then
					editingItemPage.displayIndexFirst_longrangeAdd = 1
				end
			end
			if pad.isPress(KEY_A) then
				if messageBox.show("确认添加99个"..editingItemPage.longrangeAddItemList[editingItemPage.currentIndex_longrangeAdd].name.."到你的道具箱吗 ？","确认","取消")=="A" then
					messageBox.toast(   "                            执行中 ...")
					if item.addItemToBox(editingItemPage.longrangeAddItemList[editingItemPage.currentIndex_longrangeAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show("                            添加成功 ！","确认","取消")
					else
						messageBox.show("                 添加失败 ，箱子可能已满 ！","确认","取消")
					end
				end
			end
			if pad.isPress(KEY_B) then
				editingItemPage.padLoop()
			end
			display.refresh()
		end
	end,


	otherAddItemList = {
		{
			name = "素材玉",
			id = 69
		},
		{
			name = "增殖稿",
			id = 449
		}
	},
	
	currentIndex_otherAdd = 1,
	displayIndexFirst_otherAdd = 1,
	
	display_otherAdd = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,260,10,"添加其他物品 (+99)",COLOR_MAKA,TOP_SCREEN)
		--光标
		Font.print(theFont,35,15+20*(editingItemPage.currentIndex_otherAdd-editingItemPage.displayIndexFirst_otherAdd+1),"=>",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,10 do
			if i<=#editingItemPage.otherAddItemList then
				Font.print(theFont,55,15+20*i,editingItemPage.otherAddItemList[editingItemPage.displayIndexFirst_otherAdd+i-1].name,COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
			end
		end
		--滑条
		if #editingItemPage.otherAddItemList>10 then
			local barLength = math.floor(10 / #editingItemPage.otherAddItemList*192)
			local barLoc = math.floor((editingItemPage.displayIndexFirst_otherAdd-1)/(#editingItemPage.otherAddItemList-10)*(192-barLength))
			Screen.fillRect(362,362,35,35+192,COLOR_EDITINGITEMPAGE_SCROLLLINE,TOP_SCREEN)
			Screen.fillRect(360,364,35+barLoc,35+barLoc+barLength,COLOR_EDITINGITEMPAGE_SCROLLBAR,TOP_SCREEN)
		end
		
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"←→","翻页"},
			{"A","添加"},
			{"B","上一层"}
		}
		display.explain = "物品会被添加到你道具箱里最靠前的空位 。"
	end,
	
	padLoop_otherAdd = function()
		editingItemPage.mode = 3
		editingItemPage.currentIndex_otherAdd = 1
		editingItemPage.displayIndexFirst_otherAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = "其他物品"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingItemPage.currentIndex_otherAdd>1 then
					editingItemPage.currentIndex_otherAdd = editingItemPage.currentIndex_otherAdd-1
				end
				if editingItemPage.currentIndex_otherAdd<editingItemPage.displayIndexFirst_otherAdd then
					editingItemPage.displayIndexFirst_otherAdd = editingItemPage.displayIndexFirst_otherAdd-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingItemPage.currentIndex_otherAdd<#editingItemPage.otherAddItemList then
					editingItemPage.currentIndex_otherAdd = editingItemPage.currentIndex_otherAdd+1
				end
				if editingItemPage.currentIndex_otherAdd>(editingItemPage.displayIndexFirst_otherAdd+9) then
					editingItemPage.displayIndexFirst_otherAdd = editingItemPage.displayIndexFirst_otherAdd+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				editingItemPage.currentIndex_otherAdd = editingItemPage.currentIndex_otherAdd-10
				editingItemPage.displayIndexFirst_otherAdd = editingItemPage.displayIndexFirst_otherAdd-10
				if editingItemPage.currentIndex_otherAdd<1 then
					editingItemPage.currentIndex_otherAdd = 1
				end
				if editingItemPage.displayIndexFirst_otherAdd<1 then
					editingItemPage.displayIndexFirst_otherAdd = 1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				editingItemPage.currentIndex_otherAdd = editingItemPage.currentIndex_otherAdd+10
				editingItemPage.displayIndexFirst_otherAdd = editingItemPage.displayIndexFirst_otherAdd+10
				if editingItemPage.currentIndex_otherAdd>#editingItemPage.otherAddItemList then
					editingItemPage.currentIndex_otherAdd = #editingItemPage.otherAddItemList
				end
				if editingItemPage.displayIndexFirst_otherAdd>#editingItemPage.otherAddItemList-9 then
					editingItemPage.displayIndexFirst_otherAdd = #editingItemPage.otherAddItemList-9
				end
				if editingItemPage.displayIndexFirst_otherAdd<1 then
					editingItemPage.displayIndexFirst_otherAdd = 1
				end
			end
			if pad.isPress(KEY_A) then
				if messageBox.show("确认添加99个"..editingItemPage.otherAddItemList[editingItemPage.currentIndex_otherAdd].name.."到你的道具箱吗 ？","确认","取消")=="A" then
					messageBox.toast(   "                            执行中 ...")
					if item.addItemToBox(editingItemPage.otherAddItemList[editingItemPage.currentIndex_otherAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show("                            添加成功 ！","确认","取消")
					else
						messageBox.show("                 添加失败 ，箱子可能已满 ！","确认","取消")
					end
				end
			end
			if pad.isPress(KEY_B) then
				editingItemPage.padLoop()
			end
			display.refresh()
		end
	end
}
