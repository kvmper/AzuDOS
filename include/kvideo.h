#ifndef KVIDEO_H
#define KVIDEO_H

#include "stdint.h"

extern uint8_t cursor_x_pos;
extern uint8_t cursor_y_pos;
extern uint16_t cursor_pos;

void kvideo_setup(void);
void kprint_char(char c, uint8_t color);
void kprint(const char* str, uint8_t color);
void kprint_dec(int dec, uint8_t color);
void kvideo_clear(uint8_t color);

#endif