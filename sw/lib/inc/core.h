// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#pragma once

#include "config.h"
#include <stdbool.h>
#include <stdint.h>

#define CLINT_MSIP                  (*(volatile uint32_t *)(CLINT_BASE_ADDR + 0x0))
#define CORE_RST_REG                (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x18))
#define CORE_MODE_REG               (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x1C))
#define CORE_RST_CAUSE_REG          (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x20))
#define CORE_REL_ERROR_COUNT_REG    (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x24))
#define CORE_REL_ERROR_CAUSE_REG    (*(volatile uint32_t *)(SOCCTRL_BASE_ADDR + 0x28))

#define CORE_RST_CAUSE_SOC          (1 << 0)
#define CORE_RST_CAUSE_SW           (1 << 1)
#define CORE_RST_CAUSE_REL_MISMATCH (1 << 2)
#define CORE_RST_CAUSE_RESERVED     (1 << 3)

#define CORE_REL_ERROR_CAUSE_ID         (1 << 0)
#define CORE_REL_ERROR_CAUSE_FETCH_FIFO (1 << 1)

typedef enum { CORE_ISA_RV32I = 0, CORE_ISA_RV32E = 1, CORE_ISA_INVALID = 3 } core_isa_t;
typedef enum { CORE_RELIABILITY_OFF = 0, CORE_RELIABILITY_ON = 1, CORE_RELIABILITY_INVALID = 3 } core_reliability_t;
typedef uint32_t core_rst_cause_t;

void core_reset(void);

core_reliability_t core_get_active_reliability(void);
core_isa_t core_get_active_isa(void);
bool core_mode_switch(core_isa_t isa, core_reliability_t reliability);

core_rst_cause_t core_get_rst_cause(void);
void core_clear_rst_cause(core_rst_cause_t cause);

uint32_t get_rel_error_count(void);
uint32_t get_rel_error_cause(void);
