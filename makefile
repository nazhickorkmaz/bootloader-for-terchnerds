ASM = nasm
QEMU = qemu-system-i386

all: bootloader.img

boot.bin: boot.asm
	$(ASM) -f bin -o $@ $<

stage2.bin: stage2.asm
	$(ASM) -f bin -o $@ $<

bootloader.img: boot.bin stage2.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=boot.bin of=$@ bs=512 count=1 conv=notrunc
	dd if=stage2.bin of=$@ bs=512 seek=1 conv=notrunc

run: bootloader.img
	$(QEMU) -fda $< -boot a

clean:
	rm -f *.bin *.img

.PHONY: all run cleanSetup
or create empty floppy disk
or create empty floppy disk
or create empty hard disk
or create empty hard disk




Disk images are not uploaded to the server
MB
MB

Presets: none, inbrowser, public relay, wisp, fetch 	
B



Setup
or create empty floppy disk
or create empty floppy disk
or create empty hard disk
or create empty hard disk




Disk images are not uploaded to the server
MB
MB

Presets: none, inbrowser, public relay, wisp, fetch 	
B



