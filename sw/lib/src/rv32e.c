// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#include "rv32e.h"
#include "config.h"
#include "util.h"

rv32_mode_t rv32_mode_get_active(void) {
    uint32_t misa   = get_misa();
    uint32_t e_mode = (misa >> 4) & 0x1;
    uint32_t i_mode = (misa >> 8) & 0x1;

    if (e_mode && !i_mode) {
        return RV32_MODE_E;
    }

    if (i_mode && !e_mode) {
        return RV32_MODE_I;
    }

    return RV32_MODE_INVALID;
}

void rv32_core_reset() {
    CLINT_MSIP   = 0x1; // otherwise core will not wake up (stuck at wfi in bootrom)
    CORE_RST_REG = 0x1; // reset the core
}

bool rv32_mode_switch(rv32_mode_t new_mode) {
    if (new_mode != rv32_mode_get_active()) {
        RV32_MODE_REG = new_mode; // core should boot in new mode next
        rv32_core_reset();        // reset needed to apply new mode
    }

    return false;
}
