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

#define ITERS 4096

static volatile unsigned int sink;

static void alu_benchmark(void) {
    int x = 0x12345678;
    int y = 0xdeadbeef;

    for (int i = 0; i < ITERS; i++) {
        x = x + y;
        y = x ^ y;
        x = x + (y << 1);
        y = y - (x >> 2);
        x = x ^ (y << 3);
        y = y + x;
        x = x - y;
        y = y ^ x;
    }

    sink = x + y;
}

static int run_alu_benchmark(void) {
    uint32_t start = get_mcycle();
    alu_benchmark();
    uint32_t end = get_mcycle();

    if (sink == 0xE679961C) {
        printf("PASS: cycles: 0x%x\n", end - start);
        uart_write_flush();
        return 0;
    }

    return 2;
}

int main() {
    uart_init();

    int error = run_alu_benchmark();
    if (error) {
        return error;
    }

    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    return 0;
}
