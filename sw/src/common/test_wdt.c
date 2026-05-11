#include <stdint.h>
#include "config.h"

// Define Watchdog memory-mapped registers
#define WDT_BASE        0x20001000
#define WDT_EN          (*(volatile uint32_t*)(WDT_BASE + 0x00))
#define WDT_FEED        (*(volatile uint32_t*)(WDT_BASE + 0x04))
#define WDT_TIMEOUT_VAL (*(volatile uint32_t*)(WDT_BASE + 0x08))

// Define SoC Control registers
#define SOC_CTRL_BASE   0x03000000
#define CORE_RST_CAUSE  (*(volatile uint32_t*)(SOC_CTRL_BASE + 0x20))

#define UART_BASE       0x03002000
#define UART_TX         (*(volatile uint32_t*)(UART_BASE + 0x00))

void print_char(char c) {
    UART_TX = c;
}

int main() {
    // if cpu boots, check why
    if (CORE_RST_CAUSE & 0x08) {
        print_char('R'); // Rebooted successfully from wdt
        print_char('\n'); // flush UART monitor line buffer
        return 0;
    }

    print_char('S'); // S = Start

    // 2. Configure the Watchdog
    WDT_TIMEOUT_VAL = 50000; // 50,000 clock cycles timeout
    WDT_EN = 1;              // Turn it on

    print_char('A'); // A = Alive

    // 3. reset counter
    for (int i = 0; i < 3; i++) {
        for (volatile int delay = 0; delay < 10000; delay++); 
        WDT_FEED = 0xFEEDC0DE; // Reset the counter
        print_char('F'); 
    }

    // test get stuck
    print_char('S'); // S = Stuck
    while(1) {
    }

    return 0;
}