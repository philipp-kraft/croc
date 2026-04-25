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

#define N 4

static int mat_a[N * N] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
static int mat_b[N * N] = {16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1};
static int mat_c[N * N];
static const int mat_expected[N * N] = {80, 70, 60, 50, 240, 214, 188, 162, 400, 358, 316, 274, 560, 502, 444, 386};

static void matmul(int *a, int *b, int *c, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            int sum = 0;
            for (int k = 0; k < n; k++) {
                sum += a[i * n + k] * b[k * n + j];
            }
            c[i * n + j] = sum;
        }
    }
}

static int verify(int *c, const int *expected, int n) {
    for (int i = 0; i < n * n; i++) {
        if (c[i] != expected[i]) return i + 1;
    }

    return 0;
}

static void clear_mat(int *c, int n) {
    for (int i = 0; i < n * n; i++) {
        c[i] = 0;
    }
}

static int run_matmul_benchmark(void) {
    clear_mat(mat_c, N);

    uint32_t start = get_mcycle();
    matmul(mat_a, mat_b, mat_c, N);
    uint32_t end = get_mcycle();

    int error    = verify(mat_c, mat_expected, N);
    if (error) {
        printf("FAIL: mismatch at index 0x%x\n", error - 1);
        uart_write_flush();
        return error;
    }

    printf("PASS: cycles: 0x%x\n", end - start);
    uart_write_flush();

    return 0;
}

int main() {
    uart_init();

    int error = run_matmul_benchmark();

    if (error) {
        return error;
    }

    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    return 0;
}
