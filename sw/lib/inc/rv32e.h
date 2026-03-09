// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#pragma once

#include "config.h"
#include <stdbool.h>
#include <stdint.h>

#define CLINT_MSIP (*(volatile uint32_t *)(CLINT_BASE_ADDR + 0x0))
#define CORE_RST_REG (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x14))
#define RV32_MODE_REG (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x18))

typedef enum { RV32_MODE_I = 0, RV32_MODE_E = 1, RV32_MODE_INVALID = 2 } rv32_mode_t;

bool rv32_mode_is_e(void);
bool rv32_mode_is_i(void);
rv32_mode_t rv32_mode_get_active(void);

void rv32_core_reset(void);

bool rv32_mode_switch(rv32_mode_t new_mode);