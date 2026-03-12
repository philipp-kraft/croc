// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#include "core.h"
#include "config.h"
#include "util.h"

void core_reset() {
    CLINT_MSIP   = 0x1; // otherwise core will not wake up (stuck at wfi in bootrom)
    CORE_RST_REG = 0x1; // reset the core
}

core_isa_t core_get_active_isa(void) {
    uint32_t misa   = get_misa();
    uint32_t e_mode = (misa >> 4) & 0x1;
    uint32_t i_mode = (misa >> 8) & 0x1;

    if (e_mode && !i_mode) {
        return CORE_ISA_RV32E;
    }

    if (i_mode && !e_mode) {
        return CORE_ISA_RV32I;
    }

    return CORE_ISA_INVALID;
}

static uint32_t core_mode_encode(core_isa_t isa, core_reliability_t reliability) {
    if (isa == CORE_ISA_RV32I && reliability == CORE_RELIABILITY_OFF) return 0x0;
    if (isa == CORE_ISA_RV32E && reliability == CORE_RELIABILITY_OFF) return 0x1;
    if (isa == CORE_ISA_RV32E && reliability == CORE_RELIABILITY_ON) return 0x3;

    return 0x2;
}

bool core_mode_switch(core_isa_t isa, core_reliability_t reliability) {
    uint32_t new_mode = core_mode_encode(isa, reliability);

    if (new_mode == 0x2) {
        return false;
    }

    if ((CORE_MODE_REG & 0x3) != new_mode) {
        CORE_MODE_REG = new_mode;
        core_reset();
    }

    return true;
}
