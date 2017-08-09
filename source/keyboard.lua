COLOR_TYPING_FONT = Color.new(255,255,255)
COLOR_TYPING_BACKGROUND = Color.new(0,0,0)
COLOR_TYPING_UNDETLINE = Color.new(128,128,128)

ALL_SUPPORT = 0
ONLY_NUMBER = 1

keyboard = {
	displayText = "",
	title = "",
	maxLength = 0,

	timer = nil,
	typingMakaVisible = true,

	visible = false,

	display = function()
		--背景
		Screen.fillRect(0,399,0,239,COLOR_TYPING_BACKGROUND,TOP_SCREEN)
		--标题
		Font.print(theFont,45,30,keyboard.title,COLOR_MAKA,TOP_SCREEN)
		--字数提示
		Font.print(theFont,270,30,TEXT_KEYBOARD[1]..(keyboard.maxLength-subStringGetTotalIndex(keyboard.displayText)),COLOR_MAKA,TOP_SCREEN)
		--文本
		local str = keyboard.displayText
		if keyboard.typingMakaVisible then
			str = str.." |"
		end
		Font.print(theFont,50,50,str,COLOR_TYPING_FONT,TOP_SCREEN)
		--下划线
		Screen.fillRect(45,354,65,66,COLOR_TYPING_UNDETLINE,TOP_SCREEN)
	end,

	get = function(title,initText,maxLength,mode)
		mode = mode or ALL_SUPPORT
		keyboard.visible = true
		Keyboard.setText(initText)
		keyboard.displayText = initText
		keyboard.title = title
		keyboard.maxLength = maxLength
		keyboard.typingMakaVisible = true
		keyboard.timer = Timer.new()
		while true do
			local kbState = Keyboard.getState()
			if kbState ~= FINISHED then
				Keyboard.show()
				if kbState ~= NOT_PRESSED then
					if kbState == PRESSED then
						keyboard.displayText = Keyboard.getInput()
						keyboard.displayText = subStringUTF8(tostring(keyboard.displayText),1,maxLength)
						Keyboard.setText(keyboard.displayText)
						if mode == ONLY_NUMBER then
							local len = string.len(keyboard.displayText)
							if len ~= 0 then
								local b = string.byte(string.sub(keyboard.displayText,-1,-1))
								if b < 48 or b > 57 then
									if len > 1 then
										keyboard.displayText = string.sub(keyboard.displayText,1,-2)
									else
										keyboard.displayText = ""
									end
									Keyboard.setText(keyboard.displayText)
								end
							end
						end
					end
					if kbState == CLEANED then
						keyboard.visible = false
						Keyboard.clear()
						Timer.destroy(keyboard.timer)
						pad.reload()
						return ""
					end
				end
			else
				keyboard.visible = false
				Keyboard.clear()
				Timer.destroy(keyboard.timer)
				pad.reload()
				return keyboard.displayText
			end
			display.refresh()
			if Timer.getTime(keyboard.timer) >= 500 then
				keyboard.typingMakaVisible = not keyboard.typingMakaVisible
				Timer.reset(keyboard.timer)
			end
		end
	end
}
