`timescale 1ns / 1ps
module data_tb;

    reg     [1: 0]  I_new;
    wire    [3: 0]  tmp_res1;
    wire    [3: 0]  tmp_res2;
    wire    [3: 0]  tmp_res3;
    wire    [3: 0]  tmp_res4;
    wire    [3: 0]  tmp_res5;
    wire    [3: 0]  tmp_res6;
    wire    [3: 0]  tmp_res7;
    wire    [3: 0]  tmp_res8;
    wire    [3: 0]  tmp_res9;

    initial begin
        I_new  = 2'b00;
        # 10 I_new = 2'b01;
        # 10 I_new = 2'b10;
        # 10 I_new = 2'b11;
    end

    DATA_Driver data_driver_tb (
    .I_new (I_new),
    .tmp_res1 (tmp_res1),
    .tmp_res2 (tmp_res2),
    .tmp_res3 (tmp_res3),
    .tmp_res4 (tmp_res4),
    .tmp_res5 (tmp_res5),
    .tmp_res6 (tmp_res6),
    .tmp_res7 (tmp_res7),
    .tmp_res8 (tmp_res8),
    .tmp_res9 (tmp_res9)
    );

endmodule