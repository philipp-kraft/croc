// Copyright 2026 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Jeremy Gerster <jgerster@ethz.ch>

`include "common_cells/registers.svh"

module wdt #(
  parameter type obi_req_t = logic,
  parameter type obi_rsp_t = logic
) (
  input  logic             clk_i,
  input  logic             rst_ni,
  input  obi_req_t         obi_req_i,
  output obi_rsp_t         obi_rsp_o,
  
  output logic             wdt_rst_req_o
);

  import wdt_pkg::*;

  logic [31:0] timeout_val_d, timeout_val_q;
  logic        en_d,          en_q;
  logic [31:0] cnt_d,         cnt_q;

  logic req_q, we_q;
  logic [$bits(obi_req_i.a.aid)-1:0] id_q;
  logic [IntAddrWidth-1:2]           addr_q;

  `FF(req_q,  obi_req_i.req,                      '0, clk_i, rst_ni)
  `FF(we_q,   obi_req_i.a.we,                     '0, clk_i, rst_ni)
  `FF(id_q,   obi_req_i.a.aid,                    '0, clk_i, rst_ni)
  `FF(addr_q, obi_req_i.a.addr[IntAddrWidth-1:2], '0, clk_i, rst_ni)

  `FF(timeout_val_q, timeout_val_d, '0, clk_i, rst_ni)
  `FF(en_q,          en_d,          '0, clk_i, rst_ni)
  `FF(cnt_q,         cnt_d,         '0, clk_i, rst_ni)

  always_comb begin : logic_and_writes
    timeout_val_d = timeout_val_q;
    en_d          = en_q;
    cnt_d         = cnt_q;
    wdt_rst_req_o = 1'b0;

    if (en_q) begin
      if (cnt_q == 0) begin
        wdt_rst_req_o = 1'b1;
        cnt_d = timeout_val_q;
      end else begin
        cnt_d = cnt_q - 1;
      end
    end

    if (obi_req_i.req && obi_req_i.a.we) begin
      unique case ({obi_req_i.a.addr[IntAddrWidth-1:2], 2'b00})
        WDT_EN_OFFSET: begin
          en_d = obi_req_i.a.wdata[0];
          // Load counter on enable rising edge so WDT doesn't fire immediately
          if (obi_req_i.a.wdata[0] && !en_q) cnt_d = timeout_val_q;
        end
        WDT_TIMEOUT_VAL_OFFSET: timeout_val_d = obi_req_i.a.wdata;
        WDT_FEED_OFFSET: begin
          if (obi_req_i.a.wdata == 32'hFEEDC0DE) cnt_d = timeout_val_q;
        end
        default: ;
      endcase
    end
  end

  always_comb begin : obi_response
    obi_rsp_o        = '0;
    obi_rsp_o.gnt    = 1'b1;
    obi_rsp_o.rvalid = req_q;
    obi_rsp_o.r.rid  = id_q;

    if (req_q) begin
      if (!we_q) begin
        unique case ({addr_q, 2'b00})
          WDT_EN_OFFSET:          obi_rsp_o.r.rdata = {31'b0, en_q};
          WDT_TIMEOUT_VAL_OFFSET: obi_rsp_o.r.rdata = timeout_val_q;
          WDT_FEED_OFFSET:        obi_rsp_o.r.rdata = cnt_q;
          default: begin
            obi_rsp_o.r.rdata = 32'hBADCAB1E;
            obi_rsp_o.r.err   = 1'b1;
          end
        endcase
      end else begin
        unique case ({addr_q, 2'b00})
          WDT_EN_OFFSET, WDT_TIMEOUT_VAL_OFFSET, WDT_FEED_OFFSET: ;
          default: obi_rsp_o.r.err = 1'b1;
        endcase
      end
    end
  end

endmodule
