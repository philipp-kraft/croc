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

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    asm volatile(
        // x1-x4 would destroy execution
        "li x5,  0x55555555\n"
        "li x6,  0x66666666\n"
        "li x7,  0x77777777\n"
        "li x8,  0x88888888\n"
        "li x9,  0x99999999\n"
        "li x10, 0xAAAAAAAA\n"
        "li x11, 0xBBBBBBBB\n"
        "li x12, 0xCCCCCCCC\n"
        "li x13, 0xDDDDDDDD\n"
        "li x14, 0xEEEEEEEE\n"
        "li x15, 0xFFFFFFFF\n"
        :
        :
        : "x5", "x6", "x7", "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15", "memory");

    uart_write_flush();
    return 0;
}
