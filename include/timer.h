#ifndef TIMER_H
#define TIMER_H

#include "stdint.h"

int get_uptime(void);
void sleep(uint32_t ms);

#endif