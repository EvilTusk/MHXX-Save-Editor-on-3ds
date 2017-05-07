romfsPath = "romfs:/"
romfsPath = "/lpp-3ds/"


theFont = Font.load(romfsPath.."Deng.ttf")
Font.setPixelSizes(theFont,12)


version = "0.4"


COLOR_MAKA = Color.new(0,255,0)


for i,v in ipairs(System.listDirectory(romfsPath)) do
	if string.sub(v.name,-4,-1)==".lua" and v.name~="main.lua" and v.name~="index.lua" then
		dofile(romfsPath..v.name)
	end
end

offset = 0

messageBox.toast("                            加载中 ...")
sav.export()
menu.padLoop()
