// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#pragma once

#include "config.h"
#include <stdbool.h>
#include <stdint.h>

#define CLINT_MSIP    (*(volatile uint32_t *)(CLINT_BASE_ADDR + 0x0))
#define CORE_RST_REG  (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x18))
#define CORE_MODE_REG (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x1C))

typedef enum { CORE_ISA_RV32I = 0, CORE_ISA_RV32E = 1, CORE_ISA_INVALID = 3 } core_isa_t;
typedef enum { CORE_RELIABILITY_OFF = 0, CORE_RELIABILITY_ON = 1, CORE_RELIABILITY_INVALID = 3 } core_reliability_t;

void core_reset(void);

core_reliability_t core_get_active_reliability(void);
core_isa_t core_get_active_isa(void);
bool core_mode_switch(core_isa_t isa, core_reliability_t reliability);
