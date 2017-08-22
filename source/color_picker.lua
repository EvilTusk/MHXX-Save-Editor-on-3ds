COLOR_COLORPICKER_FONT = Color.new(255,255,255)
COLOR_COLORPICKER_BACKGROUND = Color.new(0,0,0)
COLOR_COLORPICKER_COLORBACKGROUND = Color.new(255,255,255)


colorPicker = {

	visible = false,

	title = "",

	beforeColor = {},
	currentColor = {},
	bright = 128,
	colorLoc = { x=8, y=28 },

	deckLoc = { x=8, y=28 },
	brightLoc = { x=8, y=186 },

	inited = false,

	display = function()
		colorPicker.displayInit()
		Screen.fillRect(0,399,0,239,COLOR_COLORPICKER_BACKGROUND,TOP_SCREEN)
		Font.print(theFont,50,50,colorPicker.title,COLOR_COLORPICKER_FONT,TOP_SCREEN)
		Font.print(theFont,130,90,TEXT_COLORPICKER[1],COLOR_COLORPICKER_FONT,TOP_SCREEN)
		Screen.fillRect(239,271,84,116,COLOR_COLORPICKER_COLORBACKGROUND,TOP_SCREEN)
		Screen.fillRect(240,270,85,115,Color.new(table.unpack(colorPicker.beforeColor)),TOP_SCREEN)
		Font.print(theFont,130,130,TEXT_COLORPICKER[2],COLOR_COLORPICKER_FONT,TOP_SCREEN)
		Screen.fillRect(239,271,124,156,COLOR_COLORPICKER_COLORBACKGROUND,TOP_SCREEN)
		Screen.fillRect(240,270,125,155,Color.new(table.unpack(colorPicker.currentColor)),TOP_SCREEN)
		Screen.fillRect(colorPicker.colorLoc.x  ,colorPicker.colorLoc.x  ,colorPicker.colorLoc.y-6,colorPicker.colorLoc.y-3,Color.new(0,0,0),BOTTOM_SCREEN)
		Screen.fillRect(colorPicker.colorLoc.x  ,colorPicker.colorLoc.x  ,colorPicker.colorLoc.y+3,colorPicker.colorLoc.y+6,Color.new(0,0,0),BOTTOM_SCREEN)
		Screen.fillRect(colorPicker.colorLoc.x-6,colorPicker.colorLoc.x-3,colorPicker.colorLoc.y  ,colorPicker.colorLoc.y  ,Color.new(0,0,0),BOTTOM_SCREEN)
		Screen.fillRect(colorPicker.colorLoc.x+3,colorPicker.colorLoc.x+6,colorPicker.colorLoc.y  ,colorPicker.colorLoc.y  ,Color.new(0,0,0),BOTTOM_SCREEN)
		Screen.fillRect(colorPicker.brightLoc.x+colorPicker.bright,colorPicker.brightLoc.x+colorPicker.bright,colorPicker.brightLoc.y+20+1,colorPicker.brightLoc.y+20+6,Color.new(0,0,0),BOTTOM_SCREEN)
	end,
	
	displayInit = function()
		local bmp = Screen.loadImage(romfsPath.."color_picker_"..lang..".bmp")
		Screen.drawImage(0,0,bmp,BOTTOM_SCREEN)
		Screen.freeImage(bmp)
		--[[Screen.fillRect(0,319,0,239,Color.new(170,170,200),BOTTOM_SCREEN)
		Screen.fillRect(0,399,0,239,Color.new(0,0,0),TOP_SCREEN)
		Font.print(theFont,colorPicker.deckLoc.x,colorPicker.deckLoc.y-18,"Color plate :",Color.new(0,0,0),BOTTOM_SCREEN)
		Font.print(theFont,colorPicker.deckLoc.x,colorPicker.deckLoc.y-18,"Color plate :",Color.new(0,0,0),BOTTOM_SCREEN)
		for y=0,128 do
			for x=0,51 do
				local a = 255-y                                        --255
				local b = x*5+math.floor((128-x*5)*(y/128))            --x*5
				local c = y                                            --0
				local d = 255-x*5+math.floor((128-(255-x*5))*(y/128))  --255-x*5
				local fx = colorPicker.deckLoc.x+x
				local fy = colorPicker.deckLoc.y+y
				Screen.drawPixel(fx    ,fy,Color.new(a,b,c),BOTTOM_SCREEN)--R.G+
				Screen.drawPixel(fx+51 ,fy,Color.new(d,a,c),BOTTOM_SCREEN)--R-G.
				Screen.drawPixel(fx+102,fy,Color.new(c,a,b),BOTTOM_SCREEN)--G.B+
				Screen.drawPixel(fx+153,fy,Color.new(c,d,a),BOTTOM_SCREEN)--G-B.
				Screen.drawPixel(fx+204,fy,Color.new(b,c,a),BOTTOM_SCREEN)--B.R+
				Screen.drawPixel(fx+255,fy,Color.new(a,c,d),BOTTOM_SCREEN)--B-R.
			end
		end

		Font.print(theFont,colorPicker.brightLoc.x,colorPicker.brightLoc.y-18,"Brightness :",Color.new(0,0,0),BOTTOM_SCREEN)
		Font.print(theFont,colorPicker.brightLoc.x,colorPicker.brightLoc.y-18,"Brightness :",Color.new(0,0,0),BOTTOM_SCREEN)
		for x=0,255 do
			Screen.fillRect(colorPicker.brightLoc.x+x,colorPicker.brightLoc.x+x,colorPicker.brightLoc.y,colorPicker.brightLoc.y+20,Color.new(x,x,x),BOTTOM_SCREEN)
		end
		
		Font.print(theFont,200,220,"A : OK",Color.new(255,0,0),BOTTOM_SCREEN)
		Font.print(theFont,200,220,"A : OK",Color.new(255,0,0),BOTTOM_SCREEN)
		Font.print(theFont,260,220,"B : Cancel",Color.new(255,0,0),BOTTOM_SCREEN)
		Font.print(theFont,260,220,"B : Cancel",Color.new(255,0,0),BOTTOM_SCREEN)
		System.takeScreenshot("/file.bmp",false)]]
	end,
	
	show = function(title,iR,iG,iB)
		colorPicker.title = title
		colorPicker.beforeColor  = { iR, iG, iB }
		colorPicker.currentColor = { iR, iG, iB }
		colorPicker.visible = true
		while true do
			pad.reload()
			local x,y = Controls.readTouch()
			if x~=0 and y~=0 then
				if x>=colorPicker.deckLoc.x and x<=colorPicker.deckLoc.x+306 and y>=colorPicker.deckLoc.y and y<=colorPicker.deckLoc.y+128 then
					colorPicker.colorLoc.x = x
					colorPicker.colorLoc.y = y
					local bmp = Graphics.loadImage(romfsPath.."color_picker_"..lang..".bmp")
					local p = Graphics.getPixel(colorPicker.colorLoc.x,colorPicker.colorLoc.y,bmp)
					local r,g,b
					if colorPicker.bright>=128 then
						l = colorPicker.bright-128
						r = Color.getR(p)+math.floor((255-Color.getR(p))*(l/128))
						g = Color.getG(p)+math.floor((255-Color.getG(p))*(l/128))
						b = Color.getB(p)+math.floor((255-Color.getB(p))*(l/128))
					end
					if colorPicker.bright<=127 then
						l = 127-colorPicker.bright
						r = Color.getR(p)-math.floor((Color.getR(p))*(l/128))
						g = Color.getG(p)-math.floor((Color.getG(p))*(l/128))
						b = Color.getB(p)-math.floor((Color.getB(p))*(l/128))
					end
					Graphics.freeImage(bmp)
					colorPicker.currentColor = { r, g, b }
				end
				if x>=colorPicker.brightLoc.x and x<=colorPicker.brightLoc.x+255 and y>=colorPicker.brightLoc.y and y<=colorPicker.brightLoc.y+20 then
					colorPicker.bright = x-colorPicker.brightLoc.x
					local bmp = Graphics.loadImage(romfsPath.."color_picker_"..lang..".bmp")
					local p = Graphics.getPixel(colorPicker.colorLoc.x,colorPicker.colorLoc.y,bmp)
					local r,g,b
					if colorPicker.bright>=128 then
						l = colorPicker.bright-128
						r = Color.getR(p)+math.floor((255-Color.getR(p))*(l/128))
						g = Color.getG(p)+math.floor((255-Color.getG(p))*(l/128))
						b = Color.getB(p)+math.floor((255-Color.getB(p))*(l/128))
					end
					if colorPicker.bright<=127 then
						l = 127-colorPicker.bright
						r = Color.getR(p)-math.floor((Color.getR(p))*(l/128))
						g = Color.getG(p)-math.floor((Color.getG(p))*(l/128))
						b = Color.getB(p)-math.floor((Color.getB(p))*(l/128))
					end
					Graphics.freeImage(bmp)
					colorPicker.currentColor = { r, g, b }
				end
			end
			if pad.isPress(KEY_A) then
				colorPicker.visible = false
				pad.reload()
				return true,colorPicker.currentColor[1],colorPicker.currentColor[2],colorPicker.currentColor[3]
			end
			if pad.isPress(KEY_B) then
				colorPicker.visible = false
				pad.reload()
				return false
			end
			display.refresh()
		end
	end
}
