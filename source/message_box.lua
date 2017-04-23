--COLOR_MESSAGE_FONT = Color.new(255,255,255)
--COLOR_BOX_EDGE = Color.new(102,204,255)
--COLOR_BOX = Color.new(0,0,0)
COLOR_MESSAGE_FONT = Color.new(0,0,0)
COLOR_BOX_EDGE = Color.new(255,0,0)
COLOR_BOX = Color.new(244,244,244)

messageBox = {
	textBox = "",
	textKeyA = "",
	textKeyB = "",
	
	visible = false,
	
	isUseBottom = true,
	
	display = function()
		----上屏
		--框
		Screen.fillRect(60,339,100,139,COLOR_BOX_EDGE,TOP_SCREEN)
		Screen.fillRect(62,337,102,137,COLOR_BOX,TOP_SCREEN)
		--字
		Font.print(theFont,90,114,messageBox.textBox,COLOR_MESSAGE_FONT,TOP_SCREEN)
		Font.print(theFont,90,114,messageBox.textBox,COLOR_MESSAGE_FONT,TOP_SCREEN) --双重绘制
		
		----下屏
		if isUseBottom then
			display.hint = {
				{"A",messageBox.textKeyA},
				{"B",messageBox.textKeyB}
			}
		else
			display.hint = {}
		end
	end,
	
	show = function(tb,tka,tkb)
		messageBox.textBox = tb
		messageBox.textKeyA = tka
		messageBox.textKeyB = tkb
		isUseBottom = true
		messageBox.visible = true
		while true do
			pad.reload()
			if pad.isPress(KEY_A) then
				messageBox.visible = false
				pad.reload()
				return "A"
			end
			if pad.isPress(KEY_B) then
				messageBox.visible = false
				pad.reload()
				return "B"
			end
			display.refresh()
		end
	end,
	
	toast = function(tb)
		messageBox.textBox = tb
		isUseBottom = false
		messageBox.visible = true
		display.refresh()
		messageBox.visible = false
	end
}