// Copyright (c) 2025 Eclipse Foundation
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31x 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module cve2_register_file_ff #(
  parameter int unsigned          DataWidth         = 32,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,

  input  logic                 reliable_mode_i,

  // Read port R1
  input  logic [4:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  // Read port R2
  input  logic [4:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,

  // Read mode:
  // 00 -> NORMAL : reads x0-x31
  // 01 -> LOWER  : accept reads only to x0-x15
  // 10 -> UPPER  : remap read x1-x15 to x17-x31
  // 11 -> UNUSED : reserved
  input logic [1:0]            r_mode_i,


  // Write port W1
  input  logic [4:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i,

  // Write mode:
  // 00 -> NORMAL : writes x1-x31
  // 01 -> LOWER  : accept writes only to x1-x15
  // 10 -> UPPER  : remap writes x1-x15 to x17-x31
  // 11 -> MIRROR : write x1-x15 and matching upper x17-x31
  input logic [1:0]            w_mode_i
);

  localparam int unsigned ADDR_WIDTH = 5; // always keep 32 registers
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg;
  logic [NUM_WORDS-1:1][DataWidth-1:0] rf_reg_q;
  logic [NUM_WORDS-1:1]                we_a_dec;

  logic [ADDR_WIDTH-1:0] waddr_upper;
  logic                  waddr_is_nonzero;
  logic                  waddr_is_lower;
  logic                  lower_write_valid;

  logic [ADDR_WIDTH-1:0] raddr_a_resolved;
  logic [ADDR_WIDTH-1:0] raddr_b_resolved;

  assign waddr_upper       = {1'b1, waddr_a_i[ADDR_WIDTH-2:0]};
  assign waddr_is_nonzero  = (waddr_a_i != '0);
  assign waddr_is_lower    = !waddr_a_i[ADDR_WIDTH-1];
  assign lower_write_valid = we_a_i && waddr_is_lower && waddr_is_nonzero;

  always_comb begin : we_a_decoder
    we_a_dec = '0;

    unique case (w_mode_i)
      2'b00: begin // NORMAL
        if (we_a_i && waddr_is_nonzero) begin
          we_a_dec[waddr_a_i] = 1'b1;
        end
      end

      2'b01: begin // LOWER
        if (lower_write_valid) begin
          we_a_dec[waddr_a_i] = 1'b1;
        end
      end

      2'b10: begin // UPPER
        if (lower_write_valid) begin
          we_a_dec[waddr_upper] = 1'b1;
        end
      end
      
      2'b11: begin // MIRROR
        if (lower_write_valid) begin
          we_a_dec[waddr_a_i]   = 1'b1;
          we_a_dec[waddr_upper] = 1'b1;
        end
      end
      default: begin
      end
    endcase
  end

  always_comb begin : read_addr_mux
    raddr_a_resolved = raddr_a_i;
    raddr_b_resolved = raddr_b_i;

    unique case (r_mode_i)
      2'b00: begin // NORMAL
      end

      2'b01: begin // LOWER
        if (raddr_a_i[ADDR_WIDTH-1]) raddr_a_resolved = '0;
        if (raddr_b_i[ADDR_WIDTH-1]) raddr_b_resolved = '0;
      end

      2'b10: begin // UPPER
        if ((raddr_a_i != '0) && !raddr_a_i[ADDR_WIDTH-1]) begin
          raddr_a_resolved = {1'b1, raddr_a_i[ADDR_WIDTH-2:0]};
        end
        if ((raddr_b_i != '0) && !raddr_b_i[ADDR_WIDTH-1]) begin
          raddr_b_resolved = {1'b1, raddr_b_i[ADDR_WIDTH-2:0]};
        end
      end

      2'b11: begin // UNUSED
        raddr_a_resolved = '0;
        raddr_b_resolved = '0;
      end
      default: begin
      end
    endcase
  end

  // No flops for R0 as it's hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_flops
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_reg_q[i] <= WordZeroVal;
      end else if (we_a_dec[i]) begin
        rf_reg_q[i] <= wdata_a_i;
      end
    end
  end

  // R0 is nil
  assign rf_reg[0] = WordZeroVal;

  assign rf_reg[NUM_WORDS-1:1] = rf_reg_q[NUM_WORDS-1:1];

  assign rdata_a_o = rf_reg[raddr_a_resolved];
  assign rdata_b_o = rf_reg[raddr_b_resolved];

  // Signal not used in FF register file
  logic unused_test_en;
  assign unused_test_en = test_en_i;

  // in reliable mode the register file banks should never get out of sync
  `ifndef SYNTHESIS
    always_ff @(posedge clk_i) begin : check_rf_sync
      if (rst_ni && reliable_mode_i == 1'b1) begin
        for (int i = 0; i < 16; i++) begin
          assert (rf_reg[i] == rf_reg[i + 16])
            else $fatal(1, "RF mismatch: x%0d=0x%h x%0d=0x%h", i, rf_reg[i], i + 16, rf_reg[i + 16]);
        end
      end
    end
  `endif

endmodule
