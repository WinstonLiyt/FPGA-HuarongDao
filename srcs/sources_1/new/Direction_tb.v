`timescale 1ns / 1ps

module Direction_tb;
    reg         I_up;
    reg         I_down;
    reg         I_left;
    reg         I_right;
    reg         O_gameover;
    wire  [2:0] dir_index;

    initial begin
        O_gameover = 0;
        I_up = 0; I_down = 0; I_left = 0; I_right = 0;
        I_up = 1;
        # 10 I_up = 0;      I_down = 1;    
        # 10 I_down = 0;    I_right = 1;    
        # 10 I_right = 0;   I_left = 1;   
        # 10 O_gameover = 1;
    end

    DIRECTION_Driver  dir_tb (
    .I_up (I_up),
    .I_down (I_down),
    .I_left (I_left),
    .I_right (I_right),
    .O_gameover (O_gameover),
    .dir_index (dir_index)
    );       

endmodule
