#ifndef SERIAL_H
#define SERIAL_H

#include "stdint.h"

#define COM1 0x3F8

int serial_init(uint16_t PORT);
void serial_write(char character, uint16_t PORT);
void serial_print(char* msg, uint16_t PORT);

#endif