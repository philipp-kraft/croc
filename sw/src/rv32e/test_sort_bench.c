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

#define N 64

static const int data_init[N] = {42, -7,  13, 0,   -128, 99, 7,   7,   -1, 55,  23,  -42, 100, 1,  -99, 64,
                                 18, -34, 76, 2,   -5,   88, 91,  -73, 6,  14,  -21, 39,  -60, 72, -3,  27,
                                 50, -11, 33, -44, 85,   9,  -90, 12,  67, -2,  41,  -36, 58,  3,  -77, 24,
                                 31, -8,  95, -19, 4,    62, -55, 16,  28, -13, 70,  -25, 11,  47, -66, 20};

static int arr[N];

void insertion_sort(int *a, int n) {
    for (int i = 1; i < n; i++) {
        int key = a[i];
        int j   = i - 1;
        while (j >= 0 && a[j] > key) {
            a[j + 1] = a[j];
            j--;
        }
        a[j + 1] = key;
    }
}

void reset_array(int *dst, const int *src, int n) {
    for (int i = 0; i < n; i++) {
        dst[i] = src[i];
    }
}

int verify_sorted(int *a, int n) {
    for (int i = 1; i < n; i++) {
        if (a[i - 1] > a[i]) return i;
    }
    return 0;
}

static int run_sort_benchmark(void) {
    reset_array(arr, data_init, N);

    uint32_t start = get_mcycle();
    insertion_sort(arr, N);
    uint32_t end = get_mcycle();

    int error    = verify_sorted(arr, N);
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

    int error = run_sort_benchmark();

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
