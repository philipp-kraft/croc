// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "util.h"

int main() {
    uart_init();

    // read misa
    uint32_t misa = get_misa();
    printf("misa=0x%x | E=%x I=%x\n", misa, (misa >> 4) & 1, (misa >> 8) & 1);

    uart_write_flush();
    return 0;
}
