AS := nasm

IMG := dist/AzuDOS.img

.PHONY: build src docs clean clean-all

build:
	mkdir -p build 
	nasm -f bin src/boot/boot.asm -o build/boot.bin
docs:

clean:
	rm -rf build
clean-all:
	rm -rf build dist docs
run: build
	qemu-system-i386 build/boot.bin