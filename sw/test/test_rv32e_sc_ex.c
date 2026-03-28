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

static uint32_t run_alu_benchmark(void) {
    uint32_t cycles, out, s0, tmp;
    uint32_t in0   = 0x12345678u;
    uint32_t in1   = 0x0F0F0F0Fu;
    uint32_t in2   = 3u;
    uint32_t iters = 100;

    asm volatile("csrr  %[cycles], mcycle\n\t"

                 "addi  %[out], x0, 0\n\t"

                 "1:\n\t"
                 // U-type
                 // auipc
                 "lui   %[s0], 0x12345\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 // OP-IMM
                 "addi  %[s0], %[in0], 17\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "slti  %[s0], %[in0], 0\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "sltiu %[s0], %[in0], 1\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "xori  %[s0], %[in0], 0x55\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "ori   %[s0], %[in0], 0xAA\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "andi  %[s0], %[in0], 0xFF\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "slli  %[s0], %[in1], 4\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "srli  %[s0], %[in1], 2\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "srai  %[s0], %[in1], 1\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 // OP
                 "add   %[s0], %[in0], %[in1]\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "sub   %[s0], %[in0], %[in1]\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "sll   %[s0], %[in1], %[in2]\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "slt   %[s0], %[in0], %[in1]\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "sltu  %[s0], %[in0], %[in1]\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "xor   %[s0], %[in0], %[in1]\n\t"
                 "xor   %[out], %[out], %[s0]\n\t"

                 "srl   %[s0], %[in0], %[in2]\n\t"
                 "add   %[out], %[out], %[s0]\n\t"

                 "addi  %[out], %[out], 1\n\t"

                 "addi  %[iters], %[iters], -1\n\t"
                 "bnez  %[iters], 1b\n\t"

                 "csrr  %[tmp], mcycle\n\t"
                 "sub   %[cycles], %[tmp], %[cycles]\n\t"
                 : [cycles] "=&r"(cycles), [out] "=&r"(out), [s0] "=&r"(s0), [tmp] "=&r"(tmp), [iters] "+&r"(iters)
                 : [in0] "r"(in0), [in1] "r"(in1), [in2] "r"(in2));

    printf("result: 0x%x, cycles: 0x%x\n", out, cycles);
    uart_write_flush();

    return out;
}

int main() {
    uart_init();

    // START: This area is executed three times: RV32I, RV32E, reliable RV32E
    uint32_t out = run_alu_benchmark();

    if (out != 0x3F0B9CD4) {
        printf("FAIL: result is incorrect\n");
        uart_write_flush();
        return 1;
    }
    // END: This area is executed three times: RV32I, RV32E, reliable RV32E

    // Switch from RV32I to non-reliable RV32E
    if (core_get_active_isa() == CORE_ISA_RV32I) {
        core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_OFF);
    }

    if (core_get_active_isa() != CORE_ISA_RV32E) {
        printf("FAIL: Core should be in E-mode, but is in I-mode\n");
        uart_write_flush();
        return 1;
    }

    // Switch from RV32E to reliable RV32E
    core_mode_switch(CORE_ISA_RV32E, CORE_RELIABILITY_ON);

    return 0;
}
