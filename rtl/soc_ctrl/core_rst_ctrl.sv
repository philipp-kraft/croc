// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

module core_rst_ctrl #(
  parameter int unsigned RstCycles = 5
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic testmode_i,
  input  logic core_rst_req_i,

  output logic core_rst_no
);

  localparam int unsigned CntWidth = $clog2(RstCycles + 1);

  logic [CntWidth-1:0] rst_cnt_q, rst_cnt_d;
  logic core_rst_async_n;

  always_comb begin
    rst_cnt_d = rst_cnt_q;

    if (core_rst_req_i && rst_cnt_q == 0) begin // in-progress reset has priority over incoming reset
      rst_cnt_d = RstCycles;
    end else if (rst_cnt_q != 0) begin
      rst_cnt_d = rst_cnt_q - 1'b1;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rst_cnt_q <= '0;
    end else begin
      rst_cnt_q <= rst_cnt_d;
    end
  end

  assign core_rst_async_n = rst_ni && (rst_cnt_q == 0);

  rstgen i_rstgen (
    .clk_i,
    .rst_ni      ( core_rst_async_n ),
    .test_mode_i ( testmode_i       ),
    .rst_no      ( core_rst_no      ),
    .init_no     (                  )
  );

endmodule
