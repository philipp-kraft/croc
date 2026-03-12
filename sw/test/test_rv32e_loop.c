// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "core.h"

static volatile uint32_t cnt = 0;
static volatile core_isa_t expected_mode;

static core_isa_t core_mode_toggle(core_isa_t isa) {
    if (isa == CORE_ISA_RV32E) return CORE_ISA_RV32I;
    if (isa == CORE_ISA_RV32I) return CORE_ISA_RV32E;
}

int main(void) {
    uart_init();

    core_isa_t active_isa = core_get_active_isa();

    if (cnt > 0 && active_isa != expected_mode) {
        printf("FAIL: expected mode %x, got %x\n", expected_mode, active_isa);
        printf("\n");
        uart_write_flush();
        return 1;
    }

    if (cnt == 11) {
        printf("PASS: switched modes 11 times\n");
        uart_write_flush();
        return 0;
    }

    cnt += 1;
    expected_mode = core_mode_toggle(active_isa);

    core_reliability_t rel;
    if (expected_mode == CORE_ISA_RV32E)
        rel = CORE_RELIABILITY_ON;
    else
        rel = CORE_RELIABILITY_OFF;

    core_mode_switch(expected_mode, rel);

    return 1;
}
