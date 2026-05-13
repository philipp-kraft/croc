// Copyright 2025 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

package soc_ctrl_regs_pkg;

  // Internal address width. 6 bits covers offsets 0x00-0x3F (word-aligned registers).
  localparam int unsigned IntAddrWidth = 6;

  // Register offsets
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_BOOTADDR_OFFSET         = 6'h00;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_FETCHEN_OFFSET          = 6'h04;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_CORESTATUS_OFFSET       = 6'h08;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_BOOTMODE_OFFSET         = 6'h0c;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_SRAM_DLY_OFFSET         = 6'h10;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_INFO_OFFSET             = 6'h14;

  parameter logic [IntAddrWidth-1:0] SOC_CTRL_CORE_RST_REQ_OFFSET     = 6'h18;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_CORE_MODE_OFFSET        = 6'h1c;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_CORE_RST_CAUSE_OFFSET   = 6'h20;
  parameter logic [IntAddrWidth-1:0] SOC_CTRL_REL_ERROR_COUNT_OFFSET  = 6'h24;

endpackage
