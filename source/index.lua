romfsPath = "romfs:/"
--romfsPath = "/lpp-3ds/"


theFont = Font.load(romfsPath.."Deng.ttf")
Font.setPixelSizes(theFont,12)


version = "0.4"


COLOR_MAKA = Color.new(0,255,0)


dofile(romfsPath.."pad.lua")
dofile(romfsPath.."sav.lua")
dofile(romfsPath.."buffer.lua")
dofile(romfsPath.."message_box.lua")
dofile(romfsPath.."menu.lua")
dofile(romfsPath.."user_select.lua")
dofile(romfsPath.."editing_menu_page.lua")
dofile(romfsPath.."editing_com_page.lua")
dofile(romfsPath.."editing_item_page.lua")
dofile(romfsPath.."editing_illusion_page.lua")
dofile(romfsPath.."editing_talisman_page.lua")
dofile(romfsPath.."display.lua")


offset = 0

messageBox.toast("                            加载中 ...")
sav.export()
menu.padLoop()

