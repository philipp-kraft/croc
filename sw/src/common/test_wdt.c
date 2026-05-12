// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Jeremy Gerster <jgerster@ethz.ch>

#include "util.h"
#include "uart.h"
#include "print.h"
#include "core.h"
#include "wdt.h"

#define WDT_EXPECT_MAGIC 0xC0DEBEEFu
static volatile uint32_t expect_wdt_reboot;

static int test_register_rw(void) {
    wdt_set_timeout(0xDEADBEEF);
    CHECK_ASSERT(11, WDT_REG(WDT_TIMEOUT_VAL_REG_OFFSET) == 0xDEADBEEF);
    wdt_disable();
    CHECK_ASSERT(12, (WDT_REG(WDT_EN_REG_OFFSET) & 1u) == 0u);
    return 0;
}

static int test_feed(void) {
    wdt_set_timeout(50000);
    wdt_enable();
    for (int i = 0; i < 10; i++) {
        for (volatile int d = 0; d < 1000; d++)
            ;
        wdt_feed();
    }
    wdt_disable();
    return 0;
}

static int test_disable(void) {
    wdt_set_timeout(2000);
    wdt_enable();
    wdt_disable();
    for (volatile int d = 0; d < 5000; d++)
        ;
    return 0;
}

static int test_count_decrements(void) {
    wdt_set_timeout(100000);
    wdt_enable();
    uint32_t a = wdt_get_count();
    for (volatile int d = 0; d < 200; d++)
        ;
    uint32_t b = wdt_get_count();
    wdt_disable();
    CHECK_ASSERT(41, b < a);
    return 0;
}

static int test_bad_feed(void) {
    wdt_set_timeout(100000);
    wdt_enable();
    for (volatile int d = 0; d < 200; d++)
        ;
    uint32_t before              = wdt_get_count();
    WDT_REG(WDT_FEED_REG_OFFSET) = 0xDEADBEEF;
    uint32_t after               = wdt_get_count();
    wdt_disable();
    // slack for cycles between the two reads
    CHECK_ASSERT(51, after <= before + 50);
    return 0;
}

int main(void) {
    uart_init();

    core_rst_cause_t cause = core_get_rst_cause();
    core_clear_rst_cause(CORE_RST_CAUSE_SOC | CORE_RST_CAUSE_WDT);

    if (cause & CORE_RST_CAUSE_WDT) {
        wdt_disable();
        printf("rebooted via WDT (cause=0x%x marker=0x%x)\n", cause, expect_wdt_reboot);
        uart_write_flush();
        CHECK_ASSERT(91, expect_wdt_reboot == WDT_EXPECT_MAGIC);
        return 0;
    }

    expect_wdt_reboot = 0;
    printf("WDT test start (cause=0x%x)\n", cause);

    CHECK_CALL(test_register_rw());
    CHECK_CALL(test_feed());
    CHECK_CALL(test_disable());
    CHECK_CALL(test_count_decrements());
    CHECK_CALL(test_bad_feed());

    expect_wdt_reboot = WDT_EXPECT_MAGIC;
    printf("Arming WDT, expecting reset...\n");
    uart_write_flush();

    wdt_set_timeout(50000);
    wdt_enable();
    while (1)
        ;
}
