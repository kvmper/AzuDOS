#include "stdint.h"

extern uint8_t cursor_x_pos;
extern uint8_t cursor_y_pos;

uint16_t cursor_pos = 0;

#define VGA_MEM ((volatile uint16_t*)0xB8000)

void kvideo_setup(void) {
    cursor_pos = (80 * cursor_y_pos); // New cursor position
}

// I dont like this, i will replcae it later
void kprint_char(char c, uint8_t color) {
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

void kprint(const char* str, uint8_t color) {
    while (*str != '\0') {
        kprint_char(*str, color);
        str++;
    }
    cursor_y_pos++;
}

void kprint_dec(int dec, uint8_t color) {
    int len = 0; // Length
    char buf[12]; // Max 11 nums + null terminator
    char buf2[12]; // Same as before, but this is the final string reversed
    if (dec == 0) { // All we gotta print is 0, simple
        kprint_char('0', color); // Print 0
        return; // We're done
    } else {
        while (dec > 0) { // Loop while there is anything left
            buf[len++] = (dec % 10) + '0';  // Put the characters in our buffer
                                            // in reversed order
            dec /= 10; // Proceed to next number
        }
    }
    // Reverse string
    int j = 0;
    for (int i = len - 1; i >= 0; i--) { // Basically loops until our length == 0
        buf2[j] = buf[i]; // Okay so, this basically just reverses the string ok?
        kprint_char(buf2[j], color); // Print the current character being pointed at
        j++; // Continue to next charcater
    }
}