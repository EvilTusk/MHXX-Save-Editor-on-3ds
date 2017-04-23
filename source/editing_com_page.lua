COLOR_EDITINGCOMPAGE_FONT = Color.new(255,255,255)
COLOR_EDITINGCOMPAGE_BACKGROUND = Color.new(0,0,0)
editingComPage = {

	visible = false,
	
	mode = 0,
	
	currentIndex = 1,
	
	getHunterName = function()
		local name = string.char(buffer.get(offset+146301,32))
		return name
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
		if o>=13 then
			buffer.set(offset+40,math.floor(o%(16*16)))
			buffer.set(offset+41,math.floor(o/(16*16)))
		end
		local hrpts = 29420
		local i = 13
		while i<=o do
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
			return "女"
		end
		return "男"
	end,
	
	getVoice = function()
		return buffer.get(offset + 146248)
	end,
	
	setVoice = function(o)
		buffer.set(offset+577,o)
		buffer.set(offset+146248,o)
	end,
	
	getFace = function()
		return buffer.get(offset + 146254)
	end,
	
	setFace = function(o)
		buffer.set(offset+583,o)
		buffer.set(offset+146254,o)
		buffer.set(offset+815580,o)
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
		--字
		Font.print(theFont,120,65,"名字",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,65,editingComPage.toDisplay.hunterName,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,85,"性别",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,85,editingComPage.toDisplay.gender,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,105,"声音",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,105,editingComPage.toDisplay.voice,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,125,"脸型",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,125,editingComPage.toDisplay.face,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,145,"所持金",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,145,editingComPage.toDisplay.money,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,165,"龙历院点数",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,165,editingComPage.toDisplay.ap,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,120,185," ＨＲ ",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,240,185,editingComPage.toDisplay.hr,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop = function()
		editingComPage.mode = 0
		editingComPage.toDisplayRefresh()
		editingComPage.visible = true
		editingMenuPage.visible = false
		display.mark.nextMark.nextMark = {name = "综合"}
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
			if pad.isPress(KEY_A) then
				--名字
				if editingComPage.currentIndex==1 then
					messageBox.show("             对不起 ，暂不支持修改名字 ！","确认","取消")
				end
				--性别
				if editingComPage.currentIndex==2 then
					editingComPage.padLoop_sexEdit()
				end
				--声音
				if editingComPage.currentIndex==3 then
					editingComPage.padLoop_voiceEdit()
				end
				--脸型
				if editingComPage.currentIndex==4 then
					editingComPage.padLoop_faceEdit()
				end
				--所持金
				if editingComPage.currentIndex==5 then
					editingComPage.padLoop_moneyEdit()
				end
				--龙历院点数
				if editingComPage.currentIndex==6 then
					editingComPage.padLoop_apEdit()
				end
				--HR
				if editingComPage.currentIndex==7 then
					editingComPage.padLoop_hrEdit()
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
		Font.print(theFont,190,70,"男",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		Font.print(theFont,190,90,"女",COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_sexEdit = function()
		editingComPage.mode = 2
		editingComPage.currentIndex_sexEdit = editingComPage.getSex()+1
		display.mark.nextMark.nextMark.nextMark = {name = "性别"}
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
	end,


	currentIndex_voiceEdit = 0,
	
	display_voiceEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		if editingComPage.currentIndex_voiceEdit>=1 and editingComPage.currentIndex_voiceEdit<=5 then
			Font.print(theFont,120,50+editingComPage.currentIndex_voiceEdit*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingComPage.currentIndex_voiceEdit>=6 and editingComPage.currentIndex_voiceEdit<=10 then
			Font.print(theFont,160,50+(editingComPage.currentIndex_voiceEdit-5)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingComPage.currentIndex_voiceEdit>=11 and editingComPage.currentIndex_voiceEdit<=15 then
			Font.print(theFont,200,50+(editingComPage.currentIndex_voiceEdit-10)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingComPage.currentIndex_voiceEdit>=16 and editingComPage.currentIndex_voiceEdit<=20 then
			Font.print(theFont,240,50+(editingComPage.currentIndex_voiceEdit-15)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		for i=1,5 do
			Font.print(theFont,140,50+i*20,i,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,180,50+i*20,i+5,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,220,50+i*20,i+10,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,260,50+i*20,i+15,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"↑↓","移动光标"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_voiceEdit = function()
		editingComPage.mode = 3
		editingComPage.currentIndex_voiceEdit = editingComPage.getVoice()
		display.mark.nextMark.nextMark.nextMark = {name = "声音"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentIndex_voiceEdit>1 then
					editingComPage.currentIndex_voiceEdit = editingComPage.currentIndex_voiceEdit-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentIndex_voiceEdit<20 then
					editingComPage.currentIndex_voiceEdit = editingComPage.currentIndex_voiceEdit+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex_voiceEdit>5 then
					editingComPage.currentIndex_voiceEdit = editingComPage.currentIndex_voiceEdit-5
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex_voiceEdit<16 then
					editingComPage.currentIndex_voiceEdit = editingComPage.currentIndex_voiceEdit+5
				end
			end
			if pad.isPress(KEY_A) then
				editingComPage.setVoice(editingComPage.currentIndex_voiceEdit)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
			display.refresh()
		end
	end,
	

	currentIndex_faceEdit = 0,
	
	display_faceEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		if editingComPage.currentIndex_faceEdit>=1 and editingComPage.currentIndex_faceEdit<=6 then
			Font.print(theFont,130,50+editingComPage.currentIndex_faceEdit*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingComPage.currentIndex_faceEdit>=7 and editingComPage.currentIndex_faceEdit<=12 then
			Font.print(theFont,170,50+(editingComPage.currentIndex_faceEdit-6)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		if editingComPage.currentIndex_faceEdit>=13 and editingComPage.currentIndex_faceEdit<=18 then
			Font.print(theFont,210,50+(editingComPage.currentIndex_faceEdit-12)*20,"=>",COLOR_MAKA,TOP_SCREEN)
		end
		--字
		for i=1,6 do
			Font.print(theFont,150,50+i*20,i,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,190,50+i*20,i+6,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
			Font.print(theFont,230,50+i*20,i+12,COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		--背景
		display.hint = {
			{"↑↓","移动光标"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_faceEdit = function()
		editingComPage.mode = 4
		editingComPage.currentIndex_faceEdit = editingComPage.getFace()
		display.mark.nextMark.nextMark.nextMark = {name = "脸型"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentIndex_faceEdit>1 then
					editingComPage.currentIndex_faceEdit = editingComPage.currentIndex_faceEdit-1
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentIndex_faceEdit<18 then
					editingComPage.currentIndex_faceEdit = editingComPage.currentIndex_faceEdit+1
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex_faceEdit>6 then
					editingComPage.currentIndex_faceEdit = editingComPage.currentIndex_faceEdit-6
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex_faceEdit<13 then
					editingComPage.currentIndex_faceEdit = editingComPage.currentIndex_faceEdit+6
				end
			end
			if pad.isPress(KEY_A) then
				editingComPage.setFace(editingComPage.currentIndex_faceEdit-1)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
			display.refresh()
		end
	end,


	currentIndex_moneyEdit = 0,
	
	currentMoney = 0,
	
	display_moneyEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,120+editingComPage.currentIndex_moneyEdit*20,70,"∧",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,120+editingComPage.currentIndex_moneyEdit*20,130,"∨",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,7 do
			Font.print(theFont,120+i*20,100,math.floor((editingComPage.currentMoney)%(10^(8-i))/(10^(7-i))),COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"←→","移动光标"},
			{"↑↓","更改数值"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_moneyEdit = function()
		editingComPage.mode = 5
		editingComPage.currentIndex_moneyEdit = 1
		editingComPage.currentMoney = editingComPage.getMoney()
		display.mark.nextMark.nextMark.nextMark = {name = "所持金"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentMoney + 10^(7-editingComPage.currentIndex_moneyEdit) < 9999999 then
					editingComPage.currentMoney = editingComPage.currentMoney + 10^(7-editingComPage.currentIndex_moneyEdit)
				end
				display.refresh()
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentMoney > 10^(7-editingComPage.currentIndex_moneyEdit) then
					editingComPage.currentMoney = editingComPage.currentMoney - 10^(7-editingComPage.currentIndex_moneyEdit)
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex_moneyEdit>1 then
					editingComPage.currentIndex_moneyEdit = editingComPage.currentIndex_moneyEdit-1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex_moneyEdit<7 then
					editingComPage.currentIndex_moneyEdit = editingComPage.currentIndex_moneyEdit+1
				end
			end
			if pad.isPress(KEY_A) then
				editingComPage.setMoney(editingComPage.currentMoney)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
			display.refresh()
		end
	end,


	currentIndex_apEdit = 0,
	
	currentAP = 0,
	
	display_apEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,120+editingComPage.currentIndex_apEdit*20,70,"∧",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,120+editingComPage.currentIndex_apEdit*20,130,"∨",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,7 do
			Font.print(theFont,120+i*20,100,math.floor((editingComPage.currentAP)%(10^(8-i))/(10^(7-i))),COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"←→","移动光标"},
			{"↑↓","更改数值"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_apEdit = function()
		editingComPage.mode = 6
		editingComPage.currentIndex_apEdit = 1
		editingComPage.currentAP = editingComPage.getAP()
		display.mark.nextMark.nextMark.nextMark = {name = "龙历院点数"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentAP + 10^(7-editingComPage.currentIndex_apEdit) < 9999999 then
					editingComPage.currentAP = editingComPage.currentAP + 10^(7-editingComPage.currentIndex_apEdit)
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentAP > 10^(7-editingComPage.currentIndex_apEdit) then
					editingComPage.currentAP = editingComPage.currentAP - 10^(7-editingComPage.currentIndex_apEdit)
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex_apEdit>1 then
					editingComPage.currentIndex_apEdit = editingComPage.currentIndex_apEdit-1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex_apEdit<7 then
					editingComPage.currentIndex_apEdit = editingComPage.currentIndex_apEdit+1
				end
			end
			if pad.isPress(KEY_A) then
				editingComPage.setAP(editingComPage.currentAP)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
			display.refresh()
		end
	end,


	currentIndex_hrEdit = 0,
	
	currentHR = 0,
	
	display_hrEdit = function()
		----上屏
		--背景
		Screen.fillRect(0,399,0,239,COLOR_EDITINGCOMPAGE_BACKGROUND,TOP_SCREEN)
		--光标
		Font.print(theFont,160+editingComPage.currentIndex_hrEdit*20,70,"∧",COLOR_MAKA,TOP_SCREEN)
		Font.print(theFont,160+editingComPage.currentIndex_hrEdit*20,130,"∨",COLOR_MAKA,TOP_SCREEN)
		--字
		for i=1,3 do
			Font.print(theFont,160+i*20,100,math.floor((editingComPage.currentHR)%(10^(4-i))/(10^(3-i))),COLOR_EDITINGCOMPAGE_FONT,TOP_SCREEN)
		end
		----下屏
		display.hint = {
			{"←→","移动光标"},
			{"↑↓","更改数值"},
			{"A","确认修改"},
			{"B","上一层"}
		}
	end,
	
	padLoop_hrEdit = function()
		editingComPage.mode = 7
		editingComPage.currentIndex_hrEdit = 1
		editingComPage.currentHR = editingComPage.getHR()
		display.mark.nextMark.nextMark.nextMark = {name = "HR"}
		while true do
			pad.reload()
			if pad.isPress(KEY_DUP) then
				if editingComPage.currentHR + 10^(3-editingComPage.currentIndex_hrEdit) < 999 then
					editingComPage.currentHR = editingComPage.currentHR + 10^(3-editingComPage.currentIndex_hrEdit)
				end
			end
			if pad.isPress(KEY_DDOWN) then
				if editingComPage.currentHR > 10^(3-editingComPage.currentIndex_hrEdit) then
					editingComPage.currentHR = editingComPage.currentHR - 10^(3-editingComPage.currentIndex_hrEdit)
				end
			end
			if pad.isPress(KEY_DLEFT) then
				if editingComPage.currentIndex_hrEdit>1 then
					editingComPage.currentIndex_hrEdit = editingComPage.currentIndex_hrEdit-1
				end
			end
			if pad.isPress(KEY_DRIGHT) then
				if editingComPage.currentIndex_hrEdit<3 then
					editingComPage.currentIndex_hrEdit = editingComPage.currentIndex_hrEdit+1
				end
			end
			if pad.isPress(KEY_A) then
				editingComPage.setHR(editingComPage.currentHR)
				editingComPage.padLoop()
			end
			if pad.isPress(KEY_B) then
				editingComPage.padLoop()
			end
			display.refresh()
		end
	end
}
