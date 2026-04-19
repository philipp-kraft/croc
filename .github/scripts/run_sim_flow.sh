#!/bin/bash
# Copyright (c) 2026 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>
#
# Two-phase Verilator simulation flow:
#   Phase 1 (default): Build software, build Verilator model, run helloworld
#   Phase 2 (iDMA on): Enable iDMA, build Verilator model, run all unit tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CROC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$CROC_ROOT"

echo "============================================="
echo "Phase 1: default config — helloworld"
echo "============================================="

# ensure default config (iDMA off)
"$SCRIPT_DIR/set_croc_config.sh"

# build software for both ISAs
make -C sw all

# build verilator simulation and run helloworld
cd verilator
./run_verilator.sh --build
./run_verilator.sh --run ../sw/bin/rv32i/src/common/helloworld.hex
grep -q "\[UART\] Hello World from Croc!" croc.log || exit 1

./run_verilator.sh --run ../sw/bin/rv32i/src/common/print_config.hex
"$SCRIPT_DIR/check_sim.sh" croc.log

cd "$CROC_ROOT"

echo ""
echo "============================================="
echo "Phase 2: iDMA enabled — unit tests"
echo "============================================="

# enable iDMA
"$SCRIPT_DIR/set_croc_config.sh" iDMAEnable=1

# rebuild Verilator model with iDMA enabled
cd verilator
./run_verilator.sh --build

# run RV32I common tests
"$SCRIPT_DIR/run_tests.sh" \
    --hexdir ../sw/bin/rv32i/src/common \
    --label rv32i-common

# run RV32I ISA tests
"$SCRIPT_DIR/run_tests.sh" \
    --hexdir ../sw/bin/rv32i/src/isa \
    --label rv32i-isa \
    --filter '*'

# run RV32E common tests
"$SCRIPT_DIR/run_tests.sh" \
    --hexdir ../sw/bin/rv32e/src/common \
    --label rv32e-common

# run RV32E specific tests
"$SCRIPT_DIR/run_tests.sh" \
    --hexdir ../sw/bin/rv32e/src/rv32e \
    --label rv32e-specific

# run RV32E ISA tests with reliablity on
"$SCRIPT_DIR/run_tests.sh" \
    --hexdir ../sw/bin/rv32e/src/isa \
    --label rv32e-isa \
    --filter '*'

cd "$CROC_ROOT"

# restore defaults
"$SCRIPT_DIR/set_croc_config.sh"

echo ""
echo "============================================="
echo " Simulation completed"
echo "============================================="
