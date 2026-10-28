#include "kvideo.h"
#include "serial.h"

int exit_krnl(int code) { // Exit kernel to entry file, and print exit code
    kprint("Kernel exited with code ", 0xF);
    kprint_dec(code, 0xF); // Print code in decimal
    kprint_char('\n', 0); // Create a new line
    // Print message that the kernel exited
    // to the serial port (0x3F8 aka COM1)
    serial_print("Kernel exited, dead", COM1);
    return code; // Exit
}