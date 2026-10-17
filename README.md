# AzuDOS
AzuDOS - a simple, lightweight custom kernel written for x86

## Prerequisites
You must use a Linux operating system. Alternatively, you can use WSL, MSYS2 or Cygwin if you are on Windows.
You will need tools such as `nasm`, `ld`, `objcopy` (which is a part of the `binutils` package), and `make`. You can obtain these tools by downloading them using your package manager.

## Running
You will first need to prepare the build environment by running `make prepare`. You need to run it only once, unless you do `make clean-all`.
After that, you can simply execute `make run` to boot the operating system, or `make` to just build it.