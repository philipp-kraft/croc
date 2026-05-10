// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philipp Kraft <kraftp@ethz.ch>

module user_rom #(
    parameter obi_pkg::obi_cfg_t ObiCfg    = obi_pkg::ObiDefaultConfig,
    parameter type               obi_req_t = logic,
    parameter type               obi_rsp_t = logic
) (
    input logic clk_i,
    input logic rst_ni,

    input  obi_req_t obi_req_i,
    output obi_rsp_t obi_rsp_o
);

  // store info from request
  logic req_d, req_q;
  logic [ObiCfg.IdWidth-1:0] id_d, id_q;
  logic we_d, we_q;
  logic [3:0] word_addr_d, word_addr_q;

  assign req_d         = obi_req_i.req;
  assign id_d          = obi_req_i.a.aid;
  assign we_d          = obi_req_i.a.we;
  assign word_addr_d   = obi_req_i.a.addr[5:2];

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_q <= '0;
      id_q <= '0;
      we_q <= '0;
      word_addr_q <= '0;
    end else begin
      req_q <= req_d;
      id_q <= id_d;
      we_q <= we_d;
      word_addr_q <= word_addr_d;
    end
  end

  logic [ObiCfg.DataWidth-1:0] rsp_data;
  logic obi_err;

  always_comb begin
    rsp_data = '0;
    obi_err  = '0;

    if (req_q) begin
      if (~we_q) begin
        case (word_addr_q) // little endian
          4'd0: rsp_data = 32'h6C696850;  // "Phil"
          4'd1: rsp_data = 32'h20707069;  // "ipp "
          4'd2: rsp_data = 32'h6661724B;  // "Kraf"
          4'd3: rsp_data = 32'h6E612074;  // "t an"
          4'd4: rsp_data = 32'h654A2064;  // "d Je"
          4'd5: rsp_data = 32'h796D6572;  // "remy"
          4'd6: rsp_data = 32'h72654720;  // " Ger"
          4'd7: rsp_data = 32'h72657473;  // "ster"
          4'd8: rsp_data = 32'h00000000;  // "\0"
          default: rsp_data = 32'h00000000;
        endcase
      end else begin
        obi_err = 1'b1;
      end
    end
  end

  assign obi_rsp_o.gnt = obi_req_i.req; // always grant in same cycle

  assign obi_rsp_o.r.rdata      = rsp_data;
  assign obi_rsp_o.r.rid        = id_q;
  assign obi_rsp_o.r.r_optional = '0;
  assign obi_rsp_o.rvalid       = req_q;
  assign obi_rsp_o.r.err        = obi_err;

endmodule
