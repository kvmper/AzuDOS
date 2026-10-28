AS := nasm
AS_FLAGS := -f elf32 # For now...

# We are now using a cross compilerrrrrr
GCC := i686-elf-gcc
C_FLAGS := -ffreestanding -nostdlib -c -O2 -Iinclude

LD := i686-elf-ld
OBJCOPY := i686-elf-objcopy

IMG := dist/AzuDOS.img

ASM_SRC = $(wildcard src/**/*.asm)
ASM_OBJ = $(patsubst src/%.asm, build/%.o, $(filter-out src/boot/boot.asm src/boot/loader.asm, $(ASM_SRC)))

C_SRC = $(shell find src -name "*.c") # For some reason find works and wildcard doesnt...
C_OBJ = $(patsubst src/%.c, build/%.o, $(C_SRC))

.PHONY: build prepare clean clean-all run run32 docs

build: $(IMG)

$(IMG): build/boot/boot.bin build/boot/loader.o $(ASM_OBJ) $(C_OBJ)
	@$(LD) -m elf_i386 -T linker/boot/linker.ld -o build/kernel.elf build/boot/loader.o $(ASM_OBJ) $(C_OBJ)
	@echo [LD] build/boot/loader.o $(ASM_OBJ) $(C_OBJ)
	@$(OBJCOPY) -O binary build/kernel.elf build/kernel.bin
	@echo [OBJCOPY] build/kernel.elf build/kernel.bin
	@cat build/boot/boot.bin build/kernel.bin > $(IMG)
	@truncate -s 4096K $(IMG)
	@echo Created $(IMG)
	@du -b build/kernel.bin $(IMG)

prepare:
	@mkdir -p build/boot dist/docs qemu-log/
	@echo Created build directories: build dist qemu-log
	@$(AS) -v > /dev/null
	@$(LD) -v > /dev/null
	@$(OBJCOPY) -V > /dev/null
	@$(GCC) --version > /dev/null
	@echo "Crucial tools are installed, you are free to go build AzuDOS!!! :D"
build/%.o: src/%.asm # Assemble all assembly files except the MBR
	@mkdir -p $(dir $@)
	@$(AS) $(AS_FLAGS) $< -o $@
	@echo "[AS] $< $@ ($$(stat --printf="%s" $@) bytes)"
build/boot/boot.bin: src/boot/boot.asm # Assemble MBR
	@$(AS) -f bin $< -o $@
	@echo "[AS] $< $@ ($$(stat --printf="%s" $@) bytes)"
build/%.o: src/%.c # Compile all C files
	@mkdir -p $(dir $@)
	@$(GCC) $(C_FLAGS) $< -o $@
	@echo "[GCC] $< $@ ($$(stat --printf="%s" $@) bytes)"
clean:
	@echo "Removing files: $(strip build/boot/loader.o $(ASM_OBJ) build/boot/boot.bin $(C_OBJ))"
	@rm -rf $(ASM_OBJ) build/boot/loader.o build/boot/boot.bin $(C_OBJ)
	@echo "Cleaning done"
clean-all:
	@echo "Removing directories: build dist qemu-log"
	@rm -rf build dist qemu-log
	@echo "Cleaning done"
run: $(IMG)
	@echo -e "\nAzuDOS 64-bit\n------------------------------"
	qemu-system-x86_64 -cpu host -enable-kvm -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot
run32: $(IMG)
	@echo -e "\nAzuDOS 32-bit\n------------------------------"
	qemu-system-i386 -cpu 486 -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot
run-gdb:
	@echo -e "\nAzuDOS 64-bit GDB\n------------------------------"
	qemu-system-x86_64 -s -S -cpu host -enable-kvm -drive file=$(IMG),format=raw,media=disk -serial stdio -d int,cpu_reset,guest_errors -no-reboot
docs:
	@pandoc docs/main.md -o dist/docs/main.pdf
	@echo -e "Done :>"