/*
 * layer_out.sv
 *
 *  Created on: 2020-04-06 23:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

module layer_out(
    input logic clk_in,
    input logic rst_n_in,

    input logic frame_rdy_in,

    input logic wr_en_in,
    input logic [5:0] wr_addr_in,
    input logic [7:0] wr_data_in,
    input logic [4:0] byte_en_in,

    output logic ws2812_data_out
);

logic [7:0] rst_cnt;

logic [7:0] t1_h_cnt;
logic [7:0] t1_l_cnt;
logic [7:0] t0_h_cnt;
logic [7:0] t0_l_cnt;

logic bit_rdy, bit_data, bit_done;

wire reg_wr_en = byte_en_in[4] & wr_en_in;

ws2812_ctl ws2812_ctl(
    .clk_in(clk_in),
    .rst_n_in(rst_n_in),

    .bit_done_in(bit_done),
    .frame_rdy_in(frame_rdy_in),

    .wr_en_in(wr_en_in),
    .wr_addr_in(wr_addr_in),
    .wr_data_in(wr_data_in),
    .byte_en_in(byte_en_in[3:0]),

    .rst_cnt_in(rst_cnt),

    .bit_rdy_out(bit_rdy),
    .bit_data_out(bit_data)
);

ws2812_out ws2812_out(
    .clk_in(clk_in),
    .rst_n_in(rst_n_in),

    .bit_rdy_in(bit_rdy),
    .bit_data_in(bit_data),

    .t1_h_cnt_in(t1_h_cnt),
    .t1_l_cnt_in(t1_l_cnt),
    .t0_h_cnt_in(t0_h_cnt),
    .t0_l_cnt_in(t0_l_cnt),

    .bit_done_out(bit_done),
    .ws2812_data_out(ws2812_data_out)
);

always_ff @(posedge clk_in)
begin
    case ({reg_wr_en, wr_addr_in[2:0]})
        4'h8 + 4'h0:
            rst_cnt <= wr_data_in;
        4'h8 + 4'h1:
            t1_h_cnt <= wr_data_in;
        4'h8 + 4'h2:
            t1_l_cnt <= wr_data_in;
        4'h8 + 4'h3:
            t0_h_cnt <= wr_data_in;
        4'h8 + 4'h4:
            t0_l_cnt <= wr_data_in;
    endcase
end

endmodule
