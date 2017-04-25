COLOR_EDITINGITEMPAGE_FONT = Color.new(255,255,255)
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
		if editingItemPage.mode==2 then
			editingItemPage.display_fastAdd()
			return
		end
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,155,50+editingItemPage.currentIndex*40,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,230,50+editingItemPage.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,175,90,"选择添加",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,175,130,"快速添加",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","进入"},
			{"B","上一层"}
		}
	end,
	
	padLoop = function()
		editingItemPage.mode = 0
		editingItemPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = "物品"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				editingItemPage.currentIndex = 1
			end
			if pad.isPress(KEY_DDOWN) then
				editingItemPage.currentIndex = 2
			end
			if pad.isPress(KEY_A) then
				if editingItemPage.currentIndex==1 then
					messageBox.show("             对不起 ，暂不支持选择添加 ！","确认","取消")
				end
				if editingItemPage.currentIndex==2 then
					editingItemPage.padLoop_fastAdd()
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,


	fastAddItemList = {
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
		{
			name = "素材玉",
			id = 69
		},
		{
			name = "增殖稿",
			id = 449
		}
	},
	
	currentIndex_fastAdd = 1,
	
	display_fastAdd = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGITEMPAGE_BACKGROUND,TOP_SCREEN)
		--标签
		Font.print(theFont,155,40,"快速添加物品 (+99)",COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		--光标
		if editingItemPage.currentIndex_fastAdd>=1 and editingItemPage.currentIndex_fastAdd<=5 then
			Font.print(theFont,110,50+editingItemPage.currentIndex_fastAdd*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingItemPage.currentIndex_fastAdd>=6 and editingItemPage.currentIndex_fastAdd<=10 then
			Font.print(theFont,210,50+(editingItemPage.currentIndex_fastAdd-5)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		for i=1,5 do
			Font.print(theFont,130,50+i*20,editingItemPage.fastAddItemList[i].name,COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,230,50+i*20,editingItemPage.fastAddItemList[i+5].name,COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","添加"},
			{"B","上一层"}
		}
	end,
	
	padLoop_fastAdd = function()
		editingItemPage.mode = 2
		editingItemPage.currentIndex_fastAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = "快速添加"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingItemPage.currentIndex_fastAdd>1 then
					editingItemPage.currentIndex_fastAdd = editingItemPage.currentIndex_fastAdd-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingItemPage.currentIndex_fastAdd<10 then
					editingItemPage.currentIndex_fastAdd = editingItemPage.currentIndex_fastAdd+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingItemPage.currentIndex_fastAdd>5 then
					editingItemPage.currentIndex_fastAdd = editingItemPage.currentIndex_fastAdd-5
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingItemPage.currentIndex_fastAdd<6 then
					editingItemPage.currentIndex_fastAdd = editingItemPage.currentIndex_fastAdd+5
				end
			end
			if pad.isPress(KEY_A) then
				if messageBox.show("   确认添加99个"..editingItemPage.fastAddItemList[editingItemPage.currentIndex_fastAdd].name.."到你的道具箱吗 ？","确认","取消")=="A" then
					messageBox.toast(   "                            执行中 ...")
					if item.addItemToBox(editingItemPage.fastAddItemList[editingItemPage.currentIndex_fastAdd].id,99) then
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
