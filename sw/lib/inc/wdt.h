// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Jeremy Gerster <jgerster@ethz.ch>

#pragma once

#include <stdint.h>
#include "config.h"

// Register offsets
#define WDT_EN_REG_OFFSET          0x00
#define WDT_FEED_REG_OFFSET        0x04
#define WDT_TIMEOUT_VAL_REG_OFFSET 0x08

// Magic value the FEED register accepts to reload counter
#define WDT_FEED_MAGIC             0xFEEDC0DE

#define WDT_REG(off)               (*(volatile uint32_t *)(USER_WDT_BASE_ADDR + (off)))

static inline void wdt_set_timeout(uint32_t cycles) {
    WDT_REG(WDT_TIMEOUT_VAL_REG_OFFSET) = cycles;
}

static inline void wdt_enable(void) {
    WDT_REG(WDT_EN_REG_OFFSET) = 1;
}

static inline void wdt_disable(void) {
    WDT_REG(WDT_EN_REG_OFFSET) = 0;
}

static inline void wdt_feed(void) {
    WDT_REG(WDT_FEED_REG_OFFSET) = WDT_FEED_MAGIC;
}

static inline uint32_t wdt_get_count(void) {
    return WDT_REG(WDT_FEED_REG_OFFSET);
}
