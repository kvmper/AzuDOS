// Placeholder, obviously
// Btw i didnt feel like writing the code for printing again so i stole it from a project i made almost 2 years ago

#include "stdint.h"

extern uint8_t cursor_x_pos;
extern uint8_t cursor_y_pos;

uint16_t cursor_pos = 0;

#define VGA_MEM ((volatile uint16_t*)0xB8000)

void printchar(char c, uint8_t color) {
    uint8_t bg = 0x0;
    int i;
    if (c == '\n') {
        cursor_pos += 80 - (cursor_pos % 80);
        return;
    }
    else {
        VGA_MEM[cursor_pos++] = ((bg << 4) | color) << 8 | c;
    }

}

void print(const char* str, uint8_t color) {
    while (*str != '\0') {
        printchar(*str, color);
        str++;
    }
}

int init_main(void) {
    cursor_pos = (80 * cursor_y_pos);
    print("Reached init yippie", 0xB);
    return 0;
}