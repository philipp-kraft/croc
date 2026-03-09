// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

#include "uart.h"
#include "print.h"
#include "util.h"
#include "user_rom.h"

int main() {
    uart_init();

    print_user_rom();

    uart_write_flush();
    return 0;
}
