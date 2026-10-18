# AzuDOS
AzuDOS - a simple, lightweight custom kernel written for x86 architecture

## Prerequisites
You must use a Linux operating system. Alternatively, you can use WSL, MSYS2 or Cygwin if you are on Windows.  
You will need tools such as `nasm`, `ld`, `objcopy` (`ld` and `objcopy` are a part of the `binutils` package), and `make` to build the system.  
You will also need `qemu` or any OS emulator of your choice, however if you want to run the OS by running `make run` (or `make run32` for the 32-bit version) you will need `qemu`.  
You can obtain these tools by downloading them using your package manager. Or you can build these tools, and that would require you to change AS, LD and OBJCOPY constants in the Makefile.

## Building & running
You will first need to prepare the build environment by running `make prepare`. You need to run it only once, unless you do `make clean-all`.
After that, you can simply execute `make run` (or `make run32` for 32-bit version), to build and boot the operating system. Or you can run `make` to only build it.
