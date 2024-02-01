`timescale 1ns / 1ps

module Bin2BCD(
    input   [15: 0]     num,
    output  [3: 0]      bcd0,
    output  [3: 0]      bcd1,
    output  [3: 0]      bcd2,
    output  [3: 0]      bcd3
);

    reg [15: 0]  bin;
    reg [15: 0]  res;
    reg [15: 0]  bcd;

    always @ (num) begin
        bin = num[15: 0];
        res = 16'd0;
        repeat (15) begin
            res[0] = bin[15];
            if (res[3:0] > 4)
                res[3:0] = res[3:0] + 4'd3;
            else
                res[3:0] = res[3:0];
            if (res[7:4] > 4)
                res[7:4] = res[7:4] + 4'd3;
            else
                res[7:4] = res[7:4];
            if (res[11:8] > 4)
                res[11:8] = res[11:8] + 4'd3;
            else
                res[11:8] = res[11:8];
            if (res[15:12] > 4)
                res[15:12] = res[15:12] + 4'd3;
            else
                res[15:12] = res[15:12];
            res = res << 1;
            bin = bin << 1;
        end
        res[0] = bin[15];
        bcd = res;
    end
    
    assign bcd0 = bcd[3:0];
    assign bcd1 = bcd[7:4];
    assign bcd2 = bcd[11:8];
    assign bcd3 = bcd[15:12];

endmodule