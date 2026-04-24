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

    core_rst_cause_t cause = core_get_rst_cause();
    core_clear_rst_cause(CORE_RST_CAUSE_SOC);

    if (cause & CORE_RST_CAUSE_SOC) printf("SOC reset cause\n");
    if (cause & CORE_RST_CAUSE_SW) printf("SW reset cause\n");
    if (cause & CORE_RST_CAUSE_REL_MISMATCH) {
        printf("rel mismatch reset\n");
        return 0;
    }

    uart_write_flush();

    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    if (!(cause & CORE_RST_CAUSE_SW)) {
        printf("FAIL: Expected software reset after mode switch\n");
        uart_write_flush();
        return 2;
    }

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    return 0;
}
