// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

import croc_pkg::*;

module core_mode_ctrl (
  input  logic       clk_i,
  input  logic       rst_ni,

  input  logic       core_rst_ni,
  input  core_mode_t core_mode_pending_i,
  output core_mode_t core_mode_active_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      core_mode_active_o <= '{reliable:1'b0, rv32e:1'b0}; // default RV32I and no reliablity mode
    end else if (~core_rst_ni) begin
      core_mode_active_o <= core_mode_pending_i;
    end
  end

endmodule