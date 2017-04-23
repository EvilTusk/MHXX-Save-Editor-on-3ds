3dstool -cvtf romfs romfs.bin --romfs-dir source
DEL "MHXX Save Editor.cia"
makerom -f cia -o "MHXX Save Editor.cia" -elf lpp-3ds.elf -rsf cia_workaround.rsf -icon icon.bin -banner banner.bin -exefslogo -target t -romfs romfs.bin
DEL romfs.bin
@ECHO "MHXX Save Editor.cia" built complete.
@pause