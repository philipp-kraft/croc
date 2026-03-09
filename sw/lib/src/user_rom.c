// Copyright 2026 ETH Zurich and University of Bologna.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Philipp Kraft <kraftp@ethz.ch>

#include "user_rom.h"
#include "print.h"

void print_user_rom() {
    volatile const char *user_rom = (volatile const char *)USER_ROM_BASE_ADDR;

    for (int i = 0;; ++i) {
        char c = user_rom[i];

        if (c == '\0') break;

        putchar(c);
    }

    putchar('\n');
}