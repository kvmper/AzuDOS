AS := nasm
AS_FLAGS := -f elf32 # For now...
IMG := dist/AzuDOS.img

ASM_SRC = $(wildcard src/**/*.asm)
ASM_OBJ = $(patsubst src/%.asm, build/%.o, $(filter-out src/boot/boot.asm src/boot/loader.asm, $(ASM_SRC)))

.PHONY: build src docs clean clean-all

build: clean prepare build/boot.bin build/boot/loader.o $(ASM_OBJ)
	@ld -m elf_i386 -T linker/boot/linker.ld -o build/kernel.elf build/boot/loader.o $(ASM_OBJ)
	@echo [LD] build/boot/loader.o $(ASM_OBJ)
	@objcopy -O binary build/kernel.elf build/kernel.bin
	@echo [OBJCOPY] build/kernel.elf build/kernel.bin
	@cat build/boot.bin build/kernel.bin > $(IMG)
	@truncate -s 4096K $(IMG)
	@echo Created $(IMG)

prepare:
	@mkdir -p build dist
	@echo Created build directories
build/%.o: src/%.asm
	@mkdir -p $(dir $@)
	@$(AS) $(AS_FLAGS) $< -o $@
	@echo [AS] $< $@
build/boot.bin: src/boot/boot.asm
	@$(AS) -f bin $< -o $@
	@echo [AS] $< $@
clean:
	@rm -rf build dist
	@echo Removed build directories
run: $(IMG)
	@echo -e "\nAzuDOS 64-bit\n------------------------------"
	qemu-system-x86_64 -cpu host -enable-kvm -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot
run32: $(IMG)
	@echo -e "\nAzuDOS 32-bit\n------------------------------"
	qemu-system-i386 -cpu 486 -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot