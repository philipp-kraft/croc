// // Copyright 2026 ETH Zurich and University of Bologna.
// // Licensed under the Apache License, Version 2.0, see LICENSE for details.
// // SPDX-License-Identifier: Apache-2.0
// //
// // Authors:
// // - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "core.h"
#include "util.h"

#define ITERS 128

// CRC32("123456789") = 0xCBF43926
static const uint8_t test_data[9] = {0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39};
#define EXPECTED_CRC 0xCBF43926U

static volatile uint32_t sink;

static uint32_t crc32(const uint8_t *data, int len) {
    uint32_t crc = 0xFFFFFFFFU;
    for (int i = 0; i < len; i++) {
        crc ^= data[i];
        for (int j = 0; j < 8; j++) {
            if (crc & 1U)
                crc = (crc >> 1) ^ 0xEDB88320U;
            else
                crc >>= 1;
        }
    }
    return crc ^ 0xFFFFFFFFU;
}

static int run_crc32_benchmark(void) {
    uint32_t start = get_mcycle();
    for (int i = 0; i < ITERS; i++) sink = crc32(test_data, 9);
    uint32_t end = get_mcycle();

    if (sink != EXPECTED_CRC) {
        printf("FAIL: crc=0x%x expected=0x%x\n", sink, EXPECTED_CRC);
        uart_write_flush();
        return 1;
    }

    printf("PASS: cycles: 0x%x\n", end - start);
    uart_write_flush();
    return 0;
}

int main(void) {
    uart_init();

    int error = run_crc32_benchmark();
    if (error) return error;

    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    return 0;
}
