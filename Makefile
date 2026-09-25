# Its bad yea ik

AS := nasm

IMG := dist/AzuDOS.img

.PHONY: build src docs clean clean-all

build:
	mkdir -p build dist
	$(AS) -f bin src/boot/boot.asm -o build/boot.bin
	$(AS) -f elf64 src/boot/loader.asm -o build/loader.o
	ld -m elf_x86_64 -T linker/boot/linker.ld -o build/kernel.elf build/loader.o
	objcopy -O binary build/kernel.elf build/kernel.bin
	cat build/boot.bin build/kernel.bin> $(IMG)
	truncate -s 4096K $(IMG)
clean:
	rm -rf build dist
run: build
	qemu-system-x86_64 -cpu host -enable-kvm -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot