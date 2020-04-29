/*
 * ws2812_out.sv
 *
 *  Created on: 2020-04-06 23:09
 *      Author: Jack Chen <redchenjs@live.com>
 */

module ws2812_out(
    input logic clk_in,
    input logic rst_n_in,

    input logic bit_rdy_in,
    input logic bit_data_in,

    input logic [7:0] t1_h_cnt_in,
    input logic [7:0] t1_l_cnt_in,
    input logic [7:0] t0_h_cnt_in,
    input logic [7:0] t0_l_cnt_in,

    output logic bit_done_out,
    output logic ws2812_data_out
);

logic bit_bsy;
logic [8:0] bit_cnt;
logic [7:0] cnt_done;

always_ff @(posedge clk_in or negedge rst_n_in)
begin
    if (!rst_n_in) begin
        bit_bsy <= 1'b0;
        bit_cnt <= 9'h000;
        cnt_done <= 8'h00;

        bit_done_out <= 1'b0;
        ws2812_data_out <= 1'b0;
    end else begin
        bit_bsy <= bit_bsy ? (bit_cnt[8:1] != cnt_done) : bit_rdy_in;
        bit_cnt <= bit_bsy ? bit_cnt + 1'b1 : 9'h000;
        cnt_done <= bit_data_in ? (t1_h_cnt_in + t1_l_cnt_in)
                                : (t0_h_cnt_in + t0_l_cnt_in);

        bit_done_out <= bit_bsy & (bit_cnt[8:1] == cnt_done);
        ws2812_data_out <= bit_bsy & ((bit_data_in & (bit_cnt[8:1] < t1_h_cnt_in))
                                   | (~bit_data_in & (bit_cnt[8:1] < t0_h_cnt_in)));
    end
end

endmodule
