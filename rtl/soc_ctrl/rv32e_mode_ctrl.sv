// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

module rv32e_mode_ctrl (
  input  logic clk_i,
  input  logic rst_ni,

  input  logic core_rst_ni,
  input  logic rv32e_mode_pending_i,

  output logic rv32e_mode_active_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rv32e_mode_active_o <= 1'b0; // core will default to I-mode on first reset
    end else if (~core_rst_ni) begin
      rv32e_mode_active_o <= rv32e_mode_pending_i;
    end
  end

endmodule