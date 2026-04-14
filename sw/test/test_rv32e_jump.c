// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "core.h"
#include "util.h"

static inline uint32_t run_jalr_benchmark(void) {
    uint32_t cycles, tmp;
    uint32_t iters = 100;

    asm volatile("la    t0, 2f\n\t"
                 "csrr  %[cycles], mcycle\n\t"
                 "1:\n\t"
                 "jalr  x1, t0, 0\n\t"
                 "2:\n\t"
                 "addi  %[iters], %[iters], -1\n\t"
                 "bnez  %[iters], 1b\n\t"
                 "csrr  %[tmp], mcycle\n\t"
                 "sub   %[cycles], %[tmp], %[cycles]\n\t"
                 : [cycles] "=&r"(cycles), [tmp] "=&r"(tmp), [iters] "+&r"(iters)
                 :
                 : "t0", "x1");

    printf("cycles: 0x%x\n", cycles);
    uart_write_flush();

    return cycles;
}

int main() {
    uart_init();

    // START: This area is executed three times: RV32I, RV32E, reliable RV32E
    uint32_t out = run_jalr_benchmark();
    // END: This area is executed three times: RV32I, RV32E, reliable RV32E

    // Switch from RV32I to non-reliable RV32E
    if (core_get_active_isa() == CORE_ISA_RV32I) {
        core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_OFF);
    }

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    // Switch from RV32E to reliable RV32E
    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    return 0;
}
