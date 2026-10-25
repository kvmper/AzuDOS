#include "include/kvideo.h"
#include "include/exit.h"
#include "include/string.h"
#include "include/io.h"

extern int init(void); // Wheres init??

// Main entry point
int main(void) {
    int code; // Exit code received from init
    if ((code = init())) {
        /*  If init returns a non-zero value (error)
            then exit the kernel (back to entry.asm) */
        return exit_krnl(code); // Exit with code received from init
    }
    // Not an error, exit and halt forever
    return exit_krnl(0); // Exit with code 0 (success!)
}

int init(void) {
    kvideo_setup();
    kprint("Reached init yippie :)\n", 0xB);
    kprint("Exiting...          :(\n", 0xD);
    for (int i = 0; i < 3; i++) outb(0x3F8, 'H');   // Print 3 H's to uninitialized serial port
                                                    // Prolly will crash on real computers
                                                    // since we didnt initialize it yet
    uint64_t funny = 0/0; // For funsies
    return 0;
}