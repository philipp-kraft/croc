// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "rv32e.h"

static volatile uint32_t cnt = 0;
static volatile rv32_mode_t expected_mode = RV32_MODE_INVALID;

static rv32_mode_t rv32_mode_toggle(rv32_mode_t mode) {
    if (mode == RV32_MODE_E) return RV32_MODE_I;
    if (mode == RV32_MODE_I) return RV32_MODE_E;

    return RV32_MODE_INVALID;
}

int main(void) {
    uart_init();

    rv32_mode_t active_mode = rv32_mode_get_active();

    if (active_mode == RV32_MODE_INVALID) {
        printf("FAIL: invalid active mode\n");
        uart_write_flush();
        return 1;
    }

    if (cnt > 0 && active_mode != expected_mode) {
        printf("FAIL: expected mode %x, got %x\n", expected_mode, active_mode);
        uart_write_flush();
        return 1;
    }

    if (cnt == 10) {
        printf("PASS: switched modes 10 times\n");
        uart_write_flush();
        return 0;
    }

    cnt += 1;
    expected_mode = rv32_mode_toggle(active_mode);
    rv32_mode_switch(expected_mode);

    return 1;
}