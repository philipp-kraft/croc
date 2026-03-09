// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "rv32e.h"

static volatile uint32_t illegal_instr;

static inline uint32_t read_mcause(void) {
    uint32_t x;
    asm volatile("csrr %0, mcause" : "=r"(x));
    return x;
}

static inline uint32_t read_mepc(void) {
    uint32_t x;
    asm volatile("csrr %0, mepc" : "=r"(x));
    return x;
}

static inline void write_mepc(uint32_t x) {
    asm volatile("csrw mepc, %0" ::"r"(x));
}

void croc_exception_handler(void) {
    uint32_t mcause = read_mcause();
    uint32_t mepc   = read_mepc();

    if ((mcause & 0x7fffffffU) == 2u) { // illegal instruction
        illegal_instr = 1;
        write_mepc(mepc + 4); // skip illegal instruction
    }
}

int main() {
    uart_init();

    rv32_mode_t mode = rv32_mode_get_active();
    illegal_instr    = 0;

    printf("Executing x20 instruction\n");
    uart_write_flush();
    asm volatile(".word 0x06900A13"); // addi x20, x0, 0x69

    if (mode == RV32_MODE_I) {
        if (illegal_instr) {
            printf("FAIL: illegal instruction in I-mode\n");
            return 1;
        }

        printf("x20 usage works in I-mode\n");
        printf("Switching to E-mode\n");
        uart_write_flush();

        rv32_mode_switch(RV32_MODE_E);
    }

    if (mode == RV32_MODE_E) {
        if (!illegal_instr) {
            printf("FAIL: x20 should trap in E-mode\n");
            return 1;
        }

        printf("PASS: x20 usage illegal in E-mode\n");
        uart_write_flush();
        return 0;
    }

    printf("Invalid mode\n");
    return 1;
}
