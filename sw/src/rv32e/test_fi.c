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

int main() {
    uart_init();

    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    if (core_get_rst_cause() & CORE_RST_CAUSE_REL_MISMATCH)
    {
        printf("Reboot from REL MISMATCH!\n");

        volatile uint32_t error_cause = get_rel_error_cause();
        volatile uint32_t error_count = get_rel_error_count();

        printf("error_cause=0x%x, error_count=0x%x\n", error_cause, error_count);
        uart_write_flush();

        if (error_count >= 2)
            return 0;
    }
    
    asm volatile (
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        "nop\n\t"
        "addi x5, x5, 1\n\t"
        :
        :
        : "x5"
    );

    return 0;
}
