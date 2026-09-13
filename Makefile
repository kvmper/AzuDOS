# Its bad yea ik

AS := nasm

IMG := dist/AzuDOS.img

.PHONY: build src docs clean clean-all

build:
	mkdir -p build dist
	$(AS) -f bin src/boot/boot.asm -o build/boot.bin
	$(AS) -f elf32 src/boot/loader.asm -o build/loader.o
	ld -m elf_i386 -T linker/boot/linker.ld -o build/kernel.elf build/loader.o
	objcopy -O binary build/kernel.elf build/kernel.bin
	cat build/boot.bin build/kernel.bin> $(IMG)
	truncate -s 4096K $(IMG)
docs:

clean:
	rm -rf build dist
clean-all:
	rm -rf build dist docs
run: build
	qemu-system-i386 $(IMG)