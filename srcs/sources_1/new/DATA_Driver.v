`timescale 1ns / 1ps

module DATA_Driver(
    input       [1: 0]  I_new,
    output  reg [3: 0]  tmp_res1,
    output  reg [3: 0]  tmp_res2,
    output  reg [3: 0]  tmp_res3,
    output  reg [3: 0]  tmp_res4,
    output  reg [3: 0]  tmp_res5,
    output  reg [3: 0]  tmp_res6,
    output  reg [3: 0]  tmp_res7,
    output  reg [3: 0]  tmp_res8,
    output  reg [3: 0]  tmp_res9
    );
   
    always @ (I_new[0] or I_new[1]) begin  // 也可以加pin
        if (I_new[0] == 0 && I_new[1] == 0) begin  // case 1
            tmp_res1   <= 4'd1;
            tmp_res2   <= 4'd2;
            tmp_res3   <= 4'd3;
            tmp_res4   <= 4'd4;
            tmp_res5   <= 4'd0;
            tmp_res6   <= 4'd6;
            tmp_res7   <= 4'd7;
            tmp_res8   <= 4'd5;
            tmp_res9   <= 4'd8;
        end
        else if (I_new[0] == 1 && I_new[1] == 0) begin  // case 2
            tmp_res1   <= 4'd0;
            tmp_res2   <= 4'd3;
            tmp_res3   <= 4'd6;
            tmp_res4   <= 4'd2;
            tmp_res5   <= 4'd5;
            tmp_res6   <= 4'd8;
            tmp_res7   <= 4'd1;
            tmp_res8   <= 4'd4;
            tmp_res9   <= 4'd7;
        end
        else if (I_new[0] == 0 && I_new[1] == 1) begin  // case 3
            tmp_res1   <= 4'd7;
            tmp_res2   <= 4'd3;
            tmp_res3   <= 4'd6;
            tmp_res4   <= 4'd2;
            tmp_res5   <= 4'd4;
            tmp_res6   <= 4'd1;
            tmp_res7   <= 4'd5;
            tmp_res8   <= 4'd8;
            tmp_res9   <= 4'd0;
        end
        else begin  // 测试
            tmp_res1   <= 4'd1;
            tmp_res2   <= 4'd2;
            tmp_res3   <= 4'd3;
            tmp_res4   <= 4'd4;
            tmp_res5   <= 4'd5;
            tmp_res6   <= 4'd6;
            tmp_res7   <= 4'd7;
            tmp_res8   <= 4'd0;
            tmp_res9   <= 4'd8;
        end
    end
    
endmodule
