// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Jeremy Gerster <jgerster@ethz.ch>

package wdt_pkg;

  // Needs to be at least 4 bits to cover offset 0x08.
  localparam int unsigned IntAddrWidth = 4;

  parameter logic [IntAddrWidth-1:0] WDT_EN_OFFSET          = 4'h0;
  parameter logic [IntAddrWidth-1:0] WDT_FEED_OFFSET        = 4'h4;
  parameter logic [IntAddrWidth-1:0] WDT_TIMEOUT_VAL_OFFSET = 4'h8;

endpackage
