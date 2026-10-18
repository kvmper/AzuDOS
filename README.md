# AzuDOS
AzuDOS - a simple and lightweight custom operating system written for x86 architecture

## Prerequisites
You must use a Linux operating system. Alternatively, you can use WSL, MSYS2 or Cygwin if you are on Windows.\
Preferably you need a cross-compiler (`i686-elf-gcc`, `i686-elf-ld`, `i686-elf-objcopy`), `nasm` and `make`. You could try building it without a cross-compiler, but it may not be the best idea and may not even build in the first place unless you add some flags.

Tutorial for setting up the cross-compiler if u don't have it: https://wiki.osdev.org/GCC_Cross-Compiler

You will also need `qemu` or any OS emulator of your choice, however if you want to run the OS by running `make run`, `make run32` or `make run-gdb`, you will need `qemu`.

## Building & running
You will first need to prepare the build environment by running `make prepare`. You need to run it only once, unless you do `make clean-all`.
After that, you can simply execute `make run` (or `make run32` for 32-bit version), to build and boot the operating system. Or you can run `make` to only build it.

## Makefile
`make prepare` - creates build folders and checks if you have all the crucial tools\
`make build` - builds the operating system\
`make clean` - removes assembly and c object files\
`make clean-all` - removes build and dist folders\
`make run` - runs the 64-bit version of AzuDOS\
`make run32` - runs the 32-bit version of AzuDOS\
`make run-gdb` - runs the 64-bit version of AzuDOS however waits for you to attach gdb
