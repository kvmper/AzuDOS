#include "io.h"

int serial_init(uint16_t PORT) {
   outb(PORT + 1, 0x00);    // Disable all interrupts
   outb(PORT + 3, 0x80);    // Enable DLAB (set baud rate divisor)
   outb(PORT + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
   outb(PORT + 1, 0x00);    //                  (hi byte)
   outb(PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
   outb(PORT + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
   outb(PORT + 4, 0x0B);    // IRQs enabled, RTS/DSR set
   outb(PORT + 4, 0x1E);    // Set in loopback mode, test the serial chip
   outb(PORT + 0, 0xAE);    // Test serial chip (send byte 0xAE and check if serial returns same byte)

   // Check if serial is faulty (i.e: not same byte as sent)
   if(inb(PORT + 0) != 0xAE) {
      return 1;
   }

   // If serial is not faulty set it in normal operation mode
   // (not-loopback with IRQs enabled and OUT#1 and OUT#2 bits enabled)
   outb(PORT + 4, 0x0F);
   return 0;
}

int is_transmit_empty(uint16_t PORT) {
   return inb(PORT + 5) & 0x20; // Is our port empty?
}

void serial_write(char character, uint16_t PORT) {
    while (is_transmit_empty(PORT) == 0); // Check if port empty
    // If port is empty, write the character to the port
    outb(PORT, character);
}

void serial_print(char* msg, uint16_t PORT) {
    while (*msg != '\0') { // While we didnt hit a null terminator
        serial_write(*msg, PORT); // Write character till we printed the string
        msg++; // Continue to the next character
    }
    serial_write('\n', PORT); // Create a new line
}
