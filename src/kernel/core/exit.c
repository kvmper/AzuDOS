#include "include/kvideo.h"

int exit_krnl(int code) { // Exit kernel to entry file, and print exit code
    kprint("Kernel exited with code ", 0xF);
    kprint_dec(code, 0xF); // Print code in decimal
    kprint_char('\n', 0); // Create a new line
    return code; // Exit
}