COLOR_EDITINGCOMPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGCOMPAGE_BACKGROUND = Color.new(0,0,0)
editingComPage = {

	visible = false,
	
	mode = 0,
	
	currentIndex = 1,
	
	getHunterName = function()
		local name = string.char(buffer.get(offset+146301,32))
		for i=1,32 do
			if string.sub(name,i,i)=="\0" then
				name = string.sub(name,1,i-1)
				break
			end
		end
		return name
	end,

	setHunterName = function(o)
		if subStringGetTotalIndex(o)>10 then
			o = subStringUTF8(o,1,10)
		end
		local t = {}
		for i=1,32 do
			t[i] = string.byte(string.sub(o,i,i))
			buffer.set(offset + i - 1 , 0)
			buffer.set(offset + i - 1 + 146301 , 0)
		end
		buffer.set(offset , t)
		buffer.set(offset + 146301 , t)
	end,
	
	getMoney = function()
		local a = buffer.get(offset+10258)
		local b = buffer.get(offset+10257)
		local c = buffer.get(offset+10256)
		local d = buffer.get(offset+10255)
		return a*16*16*16*16*16*16 + b*16*16*16*16 + c*16*16 + d
	end,
	
	setMoney = function(o)
		local a = math.floor(o/(16*16*16*16*16*16))
		local b = math.floor(o/(16*16*16*16)) % (16*16)
		local c = math.floor(o/(16*16)) % (16*16)
		local d = math.floor(o) % (16*16)
		buffer.set(offset+39,a)
		buffer.set(offset+38,b)
		buffer.set(offset+37,c)
		buffer.set(offset+36,d)
		buffer.set(offset+10258,a)
		buffer.set(offset+10257,b)
		buffer.set(offset+10256,c)
		buffer.set(offset+10255,d)
	end,
	
	getHR = function()
		local a = buffer.get(offset + 10254)
		local b = buffer.get(offset + 10253)
		local c = buffer.get(offset + 10252)
		local d = buffer.get(offset + 10251)
		local e = buffer.get(offset + 40)
		local f = buffer.get(offset + 41)
		local currentHRpts = (a*16*16*16*16*16*16 + b*16*16*16*16 + c*16*16 + d)
		if currentHRpts<=29420 then
			return e + f*16*16
		end
		local hrpts = 29420
		for i=13,999 do
			hrpts = hrpts+math.min((i-9)*70+1000 , 4010) + math.floor((i-2)/100) * 70
			if hrpts>currentHRpts then
				currentHRpts = i-1
				break
			end
		end
		return currentHRpts
	end,
	
	setHR = function(o)
		if tonumber(o)>=13 then
			buffer.set(offset+40,math.floor(o%(16*16)))
			buffer.set(offset+41,math.floor(o/(16*16)))
		end
		local hrpts = 29420
		local i = 13
		while i<=tonumber(o) do
			hrpts = hrpts + math.min((i-9) * 70 + 1000, 4010) + math.floor((i-2)/100) * 70
			i=i+1
		end
		buffer.set(offset+10251 , math.floor(hrpts) % (16*16) )
		buffer.set(offset+10252 , math.floor(hrpts/(16*16)) % (16*16) )
		buffer.set(offset+10253 , math.floor(hrpts/(16*16*16*16)) % (16*16) )
		buffer.set(offset+10254 , math.floor(hrpts/(16*16*16*16*16*16)) )
	end,
	
	getAP = function()
		local a = buffer.get(offset + 10266)
		local b = buffer.get(offset + 10265)
		local c = buffer.get(offset + 10264)
		local d = buffer.get(offset + 10263)
		return a*16*16*16*16*16*16 + b*16*16*16*16 + c*16*16 + d
	end,
	
	setAP = function(o)
		local a = math.floor(o/(16*16*16*16*16*16))
		local b = math.floor(o/(16*16*16*16)) % (16*16)
		local c = math.floor(o/(16*16)) % (16*16)
		local d = math.floor(o) % (16*16)
		buffer.set(offset+10266,a)
		buffer.set(offset+10265,b)
		buffer.set(offset+10264,c)
		buffer.set(offset+10263,d)
	end,
	
	getSex = function()
		return buffer.get(offset + 146251)
	end,
	
	setSex = function(o)
		buffer.set(offset+580,o)
		buffer.set(offset+146251,o)
	end,
	
	getGender = function()
		if editingComPage.getSex()==1 then
			return TEXT_EDITINGCOMPAGE_SEXEDIT[2]
		end
		return TEXT_EDITINGCOMPAGE_SEXEDIT[1]
	end,
	
	getVoice = function()
		return buffer.get(offset + 146248)
	end,
	
	setVoice = function(o)
		buffer.set(offset+577,o)
		buffer.set(offset+146248,o)
	end,
	
	getFace = function()
		return buffer.get(offset + 146254) + 1
	end,
	
	setFace = function(o)
		buffer.set(offset+583,o-1)
		buffer.set(offset+146254,o-1)
		buffer.set(offset+815580,o-1)
	end,

	toDisplay = {},
	toDisplayRefresh = function()
		editingComPage.toDisplay = {
			hunterName = editingComPage.getHunterName(),
			gender = editingComPage.getGender(),
			voice = editingComPage.getVoice(),
			face = editingComPage.getFace(),
			money = editingComPage.getMoney(),
			ap = editingComPage.getAP(),
			hr = editingComPage.getHR()
		}
	end,
	
	display = function()
		if editingComPage.mode==1 then
			editingComPage.display_nameEdit()
			return
		end
		if editingComPage.mode==2 then
			editingComPage.display_sexEdit()
			return
		end
		if editingComPage.mode==3 then
			editingComPage.display_voiceEdit()
			return
		end
		if editingComPage.mode==4 then
			editingComPage.display_faceEdit()
			return
		end
		if editingComPage.mode==5 then
			editingComPage.display_moneyEdit()
			return
		end
		if editingComPage.mode==6 then
			editingComPage.display_apEdit()
			return
		end
		if editingComPage.mode==7 then
			editingComPage.display_hrEdit()
			return
		end
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,100,45+editingComPage.currentIndex*20,"=>",COLOR_MAKA,TOP_SCREEN)
		if editingComPage.currentIndex==3 or editingComPage.currentIndex==4 then
			Font.print(theFont,225,45+editingComPage.currentIndex*20,"<",COLOR_MAKA,TOP_SCREEN)
			Font.print(theFont,260,45+editingComPage.currentIndex*20,">",COLOR_MAKA,TOP_SCREEN)
		else
			Font.print(theFont,225,45+editingComPage.currentIndex*20,"(A)",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		Font.print(theFont,120,65,TEXT_EDITINGCOMPAGE[1],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,65,editingComPage.toDisplay.hunterName,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,85,TEXT_EDITINGCOMPAGE[2],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,85,editingComPage.toDisplay.gender,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,105,TEXT_EDITINGCOMPAGE[3],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,105,editingComPage.toDisplay.voice,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,125,TEXT_EDITINGCOMPAGE[4],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,125,editingComPage.toDisplay.face,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,145,TEXT_EDITINGCOMPAGE[5],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,145,editingComPage.toDisplay.money,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,165,TEXT_EDITINGCOMPAGE[6],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,165,editingComPage.toDisplay.ap,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,185,TEXT_EDITINGCOMPAGE[7],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,185,editingComPage.toDisplay.hr,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		----下屏
		if editingComPage.currentIndex==3 or editingComPage.currentIndex==4 then
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"←→",TEXT_MODIFY},
				{"B",TEXT_RETURN}
			}
		else
			display.hint = {
				{"↑↓",TEXT_MOVE},
				{"A",TEXT_MODIFY},
				{"B",TEXT_RETURN}
			}
		end
		display.explain = TEXT_EDITINGCOMPAGE_E
	end,
	
	padLoop = function()
		editingComPage.mode = 0
		editingComPage.toDisplayRefresh()
		editingComPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = TEXT_EDITINGCOMPAGE_M}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentIndex>1 then
					editingComPage.currentIndex = editingComPage.currentIndex-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentIndex<7 then
					editingComPage.currentIndex = editingComPage.currentIndex+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex==3 then
					if editingComPage.toDisplay.voice>1 then
						editingComPage.toDisplay.voice = editingComPage.toDisplay.voice-1
						editingComPage.setVoice(editingComPage.toDisplay.voice)
					end
				end
				if editingComPage.currentIndex==4 then
					if editingComPage.toDisplay.face>1 then
						editingComPage.toDisplay.face = editingComPage.toDisplay.face-1
						editingComPage.setVoice(editingComPage.toDisplay.face)
					end
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex==3 then
					if editingComPage.toDisplay.voice<20 then
						editingComPage.toDisplay.voice = editingComPage.toDisplay.voice+1
						editingComPage.setVoice(editingComPage.toDisplay.voice)
					end
				end
				if editingComPage.currentIndex==4 then
					if editingComPage.toDisplay.face<18 then
						editingComPage.toDisplay.face = editingComPage.toDisplay.face+1
						editingComPage.setVoice(editingComPage.toDisplay.face)
					end
				end
			end
			if pad.isPress(KEY_A) then
				--名字
				if editingComPage.currentIndex==1 then
					local str = keyboard.get(TEXT_EDITINGCOMPAGE_O[1],editingComPage.getHunterName(),10)
					if str~="" then
						if messageBox.show(TEXT_EDITINGCOMPAGE_O[2]..str..TEXT_EDITINGCOMPAGE_O[3],TEXT_OK,TEXT_CANCEL)=="A" then
							editingComPage.setHunterName(str)
							editingComPage.toDisplayRefresh()
						end
					end
				end
				--性别
				if editingComPage.currentIndex==2 then
					editingComPage.padLoop_sexEdit()
				end
				--所持金
				if editingComPage.currentIndex==5 then
					local money = keyboard.get(TEXT_EDITINGCOMPAGE_O[4],editingComPage.toDisplay.money,7,ONLY_NUMBER)
					if money~="" then
						editingComPage.setMoney(money)
						editingComPage.toDisplayRefresh()
					end
				end
				--龙历院点数
				if editingComPage.currentIndex==6 then
					local ap = keyboard.get(TEXT_EDITINGCOMPAGE_O[5],editingComPage.toDisplay.ap,7,ONLY_NUMBER)
					if ap~="" then
						editingComPage.setAP(ap)
						editingComPage.toDisplayRefresh()
					end
				end
				--HR
				if editingComPage.currentIndex==7 then
					local hr = keyboard.get(TEXT_EDITINGCOMPAGE_O[6],editingComPage.toDisplay.hr,3,ONLY_NUMBER)
					if hr~="" then
						if hr==999 then
							hr = 998
						end
						editingComPage.setHR(hr)
						editingComPage.toDisplayRefresh()
					end
				end
			end
			if pad.isPress(KEY_B) then
				editingMenuPage.padLoop()
			end
			display.refresh()
		end
	end,

	
	currentIndex_sexEdit = 0,
	
	display_sexEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,170,50+editingComPage.currentIndex_sexEdit*20,"=>",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,210,50+editingComPage.currentIndex_sexEdit*20,"<=",COLOR_MAKA,TOP_SCREEN)
		--字
		Font.print(theFont,190,70,TEXT_EDITINGCOMPAGE_SEXEDIT[1],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,190,90,TEXT_EDITINGCOMPAGE_SEXEDIT[2],COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓",TEXT_MOVE},
			{"A",TEXT_MODIFY},
			{"B",TEXT_RETURN}
		}
		display.explain = TEXT_EDITINGCOMPAGE_SEXEDIT_E
	end,
	
	padLoop_sexEdit = function()
		editingComPage.mode = 2
		editingComPage.currentIndex_sexEdit = editingComPage.getSex()+1
		display.mark.nextMark.nextMark.nextMark = {name = TEXT_EDITINGCOMPAGE_SEXEDIT_M}
		display.refresh()
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				editingComPage.currentIndex_sexEdit = 1
				display.refresh()
			end
			if pad.isPress(KEY_DDOWN) then
				editingComPage.currentIndex_sexEdit = 2
				display.refresh()
			end
			if pad.isPress(KEY_A) then
				editingComPage.setSex(editingComPage.currentIndex_sexEdit-1)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
		end
	end
}
