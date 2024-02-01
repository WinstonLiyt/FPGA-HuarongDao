`timescale 1ns / 1ps

module scoreboard_tb;
    reg         R_clk_1000HZ = 0;
    reg [15: 0] score;
    wire [7: 0]  O_shift;
    wire [6: 0]  O_data;

    always #10 R_clk_1000HZ = ~R_clk_1000HZ;

    initial begin
        score = 15'd0;
        #20 score = 16'd5;
        #20 score = 16'd60;
        #20 score = 16'd198;
        #20 score = 16'd2378;
    end

    SCOREBOARD_Driver scoreboard_driver_tb(
    .R_clk_1000HZ (R_clk_1000HZ),
    .score (score),
    .O_shift (O_shift),
    .O_data (O_data)
    );
    

endmodule
