#include "stdint.h"

extern uint32_t ticks;

int get_uptime(void) { // Uptime in seconds
    return ticks / 100;
}

void sleep(uint32_t ms) {
    uint32_t target_ticks = ticks + (ms / 10); // Tick amount we need to hit before waking up
    while (ticks < target_ticks) {
        asm volatile("hlt"); // Do nothing
    }
}