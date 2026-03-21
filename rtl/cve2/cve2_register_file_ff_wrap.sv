// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

module cve2_register_file_ff_wrap #(
  parameter int unsigned          DataWidth         = 32,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,

  // Read port R1
  input  logic [4:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  // Read port R2
  input  logic [4:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,

  // Write port W1
  input  logic [4:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i,

  input logic                  reliable_mode_i
);

  logic [DataWidth-1:0] rdata_a_upper, rdata_a_lower;
  logic [DataWidth-1:0] rdata_b_upper, rdata_b_lower;

  logic we_lower, we_upper;

  always_comb begin : we_bank_decoder
    we_upper = 1'b0;
    we_lower = 1'b0;

    if (reliable_mode_i) begin
      if (waddr_a_i != 5'd0) begin // never write to x0 equivalent upper bank register
        // mirror register write
        we_upper = we_a_i;
        we_lower = we_a_i;
      end
    end else begin
      // we to correct bank
      we_upper = we_a_i && (waddr_a_i[4] == 1'b1);
      we_lower = we_a_i && (waddr_a_i[4] == 1'b0);
    end
  end

  assign rdata_a_o = raddr_a_i[4] ? rdata_a_upper : rdata_a_lower;
  assign rdata_b_o = raddr_b_i[4] ? rdata_b_upper : rdata_b_lower;

  cve2_register_file_ff #(
    .DataWidth        (DataWidth),
    .WordZeroVal      (WordZeroVal),
    .ZeroHardwired    (1'b0)
  ) rf_upper_bank_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .test_en_i(test_en_i),

    .raddr_a_i(raddr_a_i[3:0]),
    .rdata_a_o(rdata_a_upper),
    .raddr_b_i(raddr_b_i[3:0]),
    .rdata_b_o(rdata_b_upper),
    .waddr_a_i(waddr_a_i[3:0]),
    .wdata_a_i(wdata_a_i),
    .we_a_i   (we_upper)
  );

  cve2_register_file_ff #(
    .DataWidth        (DataWidth),
    .WordZeroVal      (WordZeroVal),
    .ZeroHardwired    (1'b1)
  ) rf_lower_bank_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .test_en_i(test_en_i),

    .raddr_a_i(raddr_a_i[3:0]),
    .rdata_a_o(rdata_a_lower),
    .raddr_b_i(raddr_b_i[3:0]),
    .rdata_b_o(rdata_b_lower),
    .waddr_a_i(waddr_a_i[3:0]),
    .wdata_a_i(wdata_a_i),
    .we_a_i   (we_lower)
  );

  // in reliable mode the register file banks should never get out of sync
  `ifndef SYNTHESIS
    always_ff @(posedge clk_i) begin : check_rf_sync
      if (rst_ni && reliable_mode_i == 1'b1) begin
        for (int i = 0; i < 16; i++) begin
          assert (rf_lower_bank_i.rf_reg[i] == rf_upper_bank_i.rf_reg[i])
            else $fatal(1, "RF mismatch: x%0d=0x%h x%0d=0x%h", i, rf_lower_bank_i.rf_reg[i], i + 16, rf_upper_bank_i.rf_reg[i]);
        end
      end
    end
  `endif

endmodule