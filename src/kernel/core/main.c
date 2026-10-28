#include "kvideo.h"
#include "exit.h"
#include "string.h"
#include "io.h"
#include "serial.h"
#include "timer.h"
#include "keyboard.h"

extern int init(void); // Wheres init??
extern void pit_init(void);

// Main entry point
int main(void) {
    int code; // Exit code received from init
    if ((code = init())) {
        /*  If init returns a non-zero value (error)
            then exit the kernel (back to entry.asm) */
        serial_print("Kernel encountered an error", COM1);
        return exit_krnl(code); // Exit with code received from init
    }
    // Not an error, exit and halt forever
    serial_print("Exit with code 0", COM1);
    return exit_krnl(0); // Exit with code 0 (success!)
}

int init(void) {
    kvideo_setup(); // Setup video, set cursor positions etc
    kprint("Reached init yippie :)\n", 0xB);
    serial_init(COM1); // Initialize serial port (COM1)
    pit_init();
    // For testing purposes, most code here will be deleted in the next version
    for (int i = 1; i < 6; i++) {
        sleep(200);
        kprint_dec(i, 0xF);
        for (int j = 0; j < 3; j++) {
            kprint_char('.', 0xF);
            sleep(200);
        }
    }
    kprint_char('\n',0);
    int hellolen = strlen("hello");
    kprint("Hello has ", 0x0F);
    kprint_dec(hellolen, 0xA);
    kprint(" letters!\nPress any key to exit...\n", 0x0F);
    int scancode = wait_for_keypress();
    kprint("Pressed scancode: ", 0x0F);
    kprint_dec(scancode, 0x0F);
    kprint("\nExiting...          :(\n", 0xD);
    int uptime;
    while (uptime < 15) {
        uptime = get_uptime();
        sleep(1000);
        kvideo_clear(0x10);
        kprint("Uptime: ", 0xF);
        kprint_dec(uptime, 0xF);
        kprint_char('\n', 0);
    }
    return 0; // Exit successfully
}