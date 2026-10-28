#include "io.h" 

int wait_for_keypress(void) {
    for(;;) {
        while (!(inb(0x64) & 0x01)) asm volatile("pause");
        return inb(0x60);
    }
}