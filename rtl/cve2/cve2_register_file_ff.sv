// Copyright (c) 2025 Eclipse Foundation
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 15/16 32 bit wide registers. Register 0 is fixed to 0 when ZeroHardwired is 1.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module cve2_register_file_ff #(
  parameter int unsigned          DataWidth         = 32,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0,
  parameter logic                 ZeroHardwired     = 1'b1
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,

  // Read port R1
  input  logic [3:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  // Read port R2
  input  logic [3:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,


  // Write port W1
  input  logic [3:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i
);

  localparam int unsigned ADDR_WIDTH = 4;
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg;
  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg_q;
  logic [NUM_WORDS-1:0]                we_a_dec;

  always_comb begin : we_a_decoder
    for (int unsigned i = 0; i < NUM_WORDS; i++) begin
      if (ZeroHardwired && i == 0) begin
        we_a_dec[i] = 1'b0;
      end else begin
        we_a_dec[i] = (waddr_a_i == i[3:0]) ? we_a_i : 1'b0;
      end
    end
  end

  for (genvar i = 0; i < NUM_WORDS; i++) begin
    if (ZeroHardwired && i == 0) begin
      assign rf_reg[i] = WordZeroVal; // no FF for x0
    end else begin
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rf_reg_q[i] <= WordZeroVal;
        end else if (we_a_dec[i]) begin
          rf_reg_q[i] <= wdata_a_i;
        end
      end

      assign rf_reg[i] = rf_reg_q[i];
    end
  end

  assign rdata_a_o = rf_reg[raddr_a_i];
  assign rdata_b_o = rf_reg[raddr_b_i];

  // Signal not used in FF register file
  logic unused_test_en;
  assign unused_test_en = test_en_i;

endmodule