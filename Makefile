AS := nasm

IMG := dist/AzuDOS.img

.PHONY: build src docs clean clean-all

build:
	mkdir -p build dist
	nasm -f bin src/boot/boot.asm -o build/boot.bin
	nasm -f bin src/boot/loader.asm -o build/loader.bin
	cat build/boot.bin build/loader.bin > $(IMG)
	truncate -s 10400K $(IMG)
docs:

clean:
	rm -rf build dist
clean-all:
	rm -rf build dist docs
run: build
	qemu-system-i386 $(IMG)