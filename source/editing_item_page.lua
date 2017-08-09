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
		--Font.print(theFont,230,30+editingItemPage.currentIndex*40,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,175,70,TEXT_EDITINGITEMPAGE[1],COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,175,110,TEXT_EDITINGITEMPAGE[2],COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,175,150,TEXT_EDITINGITEMPAGE[3],COLOR_EDITINGITEMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓",TEXT_MOVE},
			{"A",TEXT_ENTER},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGITEMPAGE_E
	end,
	
	padLoop = function()
		editingItemPage.mode = 0
		editingItemPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = TEXT_EDITINGITEMPAGE_M}
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
			id = 18
		},
		{
			id = 21
		},
		{
			id = 16
		},
		{
			id = 303
		},
		{
			id = 304
		},
		{
			id = 28
		},
		{
			id = 29
		},
		{
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
		Font.print(theFont,265,10,TEXT_EDITINGITEMPAGE_MEDICADD[1],COLOR_MAKA,TOP_SCREEN)
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
			{"↑↓",TEXT_MOVE},
			{"←→",TEXT_PAGETURN},
			{"A",TEXT_ADD},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGITEMPAGE_ALLADD_E
	end,
	
	padLoop_medicAdd = function()
		editingItemPage.mode = 1
		editingItemPage.currentIndex_medicAdd = 1
		editingItemPage.displayIndexFirst_medicAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = TEXT_EDITINGITEMPAGE_MEDICADD_M}
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
				if messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[1]..editingItemPage.medicAddItemList[editingItemPage.currentIndex_medicAdd].name..TEXT_EDITINGITEMPAGE_ALLADD_O[2],TEXT_OK,TEXT_CANCEL)=="A" then
					messageBox.toast(TEXT_EDITINGITEMPAGE_ALLADD_O[3])
					if item.addItemToBox(editingItemPage.medicAddItemList[editingItemPage.currentIndex_medicAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[4],TEXT_OK,TEXT_CANCEL)
					else
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[5],TEXT_OK,TEXT_CANCEL)
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
			id = 98
		},
		{
			id = 99
		},
		{
			id = 9
		},
		{
			id = 56
		},
		{
			id = 207
		},
		{
			id = 272
		},
		{
			id = 274
		},
		{
			id = 276
		},
		{
			id = 279
		},
		{
			id = 281
		},
		{
			id = 293
		},
		{
			id = 294
		},
		{
			id = 295
		},
		{
			id = 296
		},
		{
			id = 302
		},
		{
			id = 306
		},
		{
			id = 307
		},
		{
			id = 308
		},
		{
			id = 309
		},
		{
			id = 310
		},
		{
			id = 362
		},
		{
			id = 364
		},
		{
			id = 365
		},
		{
			id = 367
		},
		{
			id = 368
		},
		{
			id = 369
		},
		{
			id = 370
		},
		{
			id = 375
		},
		{
			id = 385
		},
		{
			id = 386
		},
		{
			id = 432
		},
		{
			id = 433
		},
		{
			id = 571
		},
		{
			id = 603
		},
		{
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
		Font.print(theFont,260,10,TEXT_EDITINGITEMPAGE_LONGRANGEADD[1],COLOR_MAKA,TOP_SCREEN)
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
			{"↑↓",TEXT_MOVE},
			{"←→",TEXT_PAGETURN},
			{"A",TEXT_ADD},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGITEMPAGE_ALLADD_E
	end,
	
	padLoop_longrangeAdd = function()
		editingItemPage.mode = 2
		editingItemPage.currentIndex_longrangeAdd = 1
		editingItemPage.displayIndexFirst_longrangeAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = TEXT_EDITINGITEMPAGE_LONGRANGEADD_M}
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
				if messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[1]..editingItemPage.longrangeAddItemList[editingItemPage.currentIndex_longrangeAdd].name..TEXT_EDITINGITEMPAGE_ALLADD_O[2],TEXT_OK,TEXT_CANCEL)=="A" then
					messageBox.toast(TEXT_EDITINGITEMPAGE_ALLADD_O[3])
					if item.addItemToBox(editingItemPage.longrangeAddItemList[editingItemPage.currentIndex_longrangeAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[4],TEXT_OK,TEXT_CANCEL)
					else
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[5],TEXT_OK,TEXT_CANCEL)
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
			id = 69
		},
		{
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
		Font.print(theFont,260,10,TEXT_EDITINGITEMPAGE_OTHERADD[1],COLOR_MAKA,TOP_SCREEN)
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
			{"↑↓",TEXT_MOVE},
			{"←→",TEXT_PAGETURN},
			{"A",TEXT_ADD},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGITEMPAGE_ALLADD_E
	end,
	
	padLoop_otherAdd = function()
		editingItemPage.mode = 3
		editingItemPage.currentIndex_otherAdd = 1
		editingItemPage.displayIndexFirst_otherAdd = 1
		display.mark.nextMark.nextMark.nextMark = {name = TEXT_EDITINGITEMPAGE_OTHERADD_M}
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
				if messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[1]..editingItemPage.otherAddItemList[editingItemPage.currentIndex_otherAdd].name..TEXT_EDITINGITEMPAGE_ALLADD_O[2],TEXT_OK,TEXT_CANCEL)=="A" then
					messageBox.toast(TEXT_EDITINGITEMPAGE_ALLADD_O[3])
					if item.addItemToBox(editingItemPage.otherAddItemList[editingItemPage.currentIndex_otherAdd].id,99) then
						item.rewriteItemBox()
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[4],TEXT_OK,TEXT_CANCEL)
					else
						messageBox.show(TEXT_EDITINGITEMPAGE_ALLADD_O[5],TEXT_OK,TEXT_CANCEL)
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
