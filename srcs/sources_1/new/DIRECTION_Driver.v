`timescale 1ns / 1ps

module DIRECTION_Driver(
    input               I_up,
    input               I_down,
    input               I_left,
    input               I_right,
    input               O_gameover,
    output  reg [2:0]   dir_index
    );
    
    always @ (I_up, I_down, I_left, I_right, O_gameover) begin  //added
        if (!O_gameover) begin
            if (I_up) begin  // 1
                dir_index <= 1;
            end
            else if (I_down) begin  // 2
                dir_index <= 2;
            end
            else if (I_left) begin  // 3
                dir_index <= 3;
            end
            else if (I_right) begin  // 4
                dir_index <= 4;
            end
            else
                dir_index <= 0;
        end
    end

endmodule
