
romfsPath = "romfs:/"


theFont = Font.load(romfsPath.."Deng.ttf")
Font.setPixelSizes(theFont,12)


version = "1.11"


COLOR_MAKA = Color.new(0,255,0)

dofile(romfsPath.."buffer.lua")
dofile(romfsPath.."color_picker.lua")
dofile(romfsPath.."display.lua")
dofile(romfsPath.."editing_com_page.lua")
dofile(romfsPath.."editing_illusion_page.lua")
dofile(romfsPath.."editing_item_page.lua")
dofile(romfsPath.."editing_menu_page.lua")
dofile(romfsPath.."editing_palico_page.lua")
dofile(romfsPath.."editing_talisman_page.lua")
dofile(romfsPath.."keyboard.lua")
dofile(romfsPath.."libstringUTF8.lua")
dofile(romfsPath.."menu.lua")
dofile(romfsPath.."message_box.lua")
dofile(romfsPath.."pad.lua")
dofile(romfsPath.."sav.lua")
dofile(romfsPath.."skill_list.lua")
dofile(romfsPath.."skill_list_palico.lua")
dofile(romfsPath.."user_select.lua")

System.createDirectory("/XXBackup")
if not System.doesFileExist("/XXBackup/.setting") then
	fs = io.open("/XXBackup/.setting",FCREATE)
	io.write(fs,0,"en",2)
	io.close(fs)
end
fs = io.open("/XXBackup/.setting",FREAD)
lang = io.read(fs,0,2)
if lang~="zh" and lang~="en" then
	io.close(fs)
	io.open("/XXBackup/.setting",FWRITE)
	io.write(fs,0,"en",2)
	lang = "en"
	io.close(fs)
end
io.close(fs)
dofile(romfsPath.."lang_"..lang)


offset = 0

messageBox.toast(TEXT_LOADING)
sav.export()
menu.padLoop()

