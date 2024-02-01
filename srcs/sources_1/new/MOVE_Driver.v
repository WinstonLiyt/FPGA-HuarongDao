`timescale 1ns / 1ps

module MOVE_Driver(
    input               R_clk_2M,
    input               I_reset,
    input               I_up,
    input               I_down,
    input               I_left,
    input               I_right,
    input       [3: 0]  tmp_num_index,
    input       [3: 0]  tmp_res1,
    input       [3: 0]  tmp_res2,
    input       [3: 0]  tmp_res3,
    input       [3: 0]  tmp_res4,
    input       [3: 0]  tmp_res5,
    input       [3: 0]  tmp_res6,
    input       [3: 0]  tmp_res7,
    input       [3: 0]  tmp_res8,
    input       [3: 0]  tmp_res9,
    input       [1: 0]  I_new,
    input               O_gameover,
    output  reg [3: 0]  res1,
    output  reg [3: 0]  res2,
    output  reg [3: 0]  res3,
    output  reg [3: 0]  res4,
    output  reg [3: 0]  res5,
    output  reg [3: 0]  res6,
    output  reg [3: 0]  res7,
    output  reg [3: 0]  res8,
    output  reg [3: 0]  res9,
    output  reg [1: 0]  mus_id,
    output  reg [15: 0] score
    );

    always @(posedge R_clk_2M) begin  // ¢Ù
        if (I_reset) begin
            res1  <=  tmp_res1;
            res2  <=  tmp_res2;
            res3  <=  tmp_res3;
            res4  <=  tmp_res4;
            res5  <=  tmp_res5;
            res6  <=  tmp_res6;
            res7  <=  tmp_res7;
            res8  <=  tmp_res8;
            res9  <=  tmp_res9;
            score   <=  0;
            case ({I_new[0], I_new[1]})
                2'b00: mus_id <= 0;
                2'b10: mus_id <= 1;
                2'b01: mus_id <= 2;
                default: ;
            endcase
        end
        else begin  // ÅĞ¶ÏÄÜ·ñÒÆ¶¯
            if (!O_gameover) begin
                if (tmp_num_index == 1) begin  // 1-¢Ú
                    if (I_right) begin
                        if (res2 == 0) begin  {res1,res2} <= {res2,res1};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res4 == 0) begin  {res1,res4} <= {res4,res1};  score <= score + 1;  end
                    end
                end  // ¢Ú

                else if (tmp_num_index == 2) begin  // 2-¢Ú
                    if (I_right) begin
                        if (res3 == 0) begin  {res2,res3} <= {res3,res2};  score <= score + 1;  end
                    end
                    else if (I_left) begin
                        if (res1 == 0) begin  {res2,res1} <= {res1,res2};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res5 == 0) begin  {res2,res5} <= {res5,res2};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 3) begin  // 3-¢Ú
                    if (I_left) begin
                        if (res2 == 0) begin  {res3,res2} <= {res2,res3};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res6 == 0) begin  {res3,res6} <= {res6,res3};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 4) begin  // 4-¢Ú
                    if (I_up) begin
                        if (res1 == 0) begin  {res4,res1} <= {res1,res4};  score <= score + 1;  end
                    end
                    else if (I_right) begin
                        if (res5 == 0) begin  {res4,res5} <= {res5,res4};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res7 == 0) begin  {res4,res7} <= {res7,res4};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 5) begin  // 5-¢Ú
                    if (I_left) begin
                        if (res4 == 0) begin  {res5,res4} <= {res4,res5};  score <= score + 1;  end
                    end
                    else if (I_right) begin
                        if (res6 == 0) begin  {res5,res6} <= {res6,res5};  score <= score + 1;  end
                    end
                    else if (I_up) begin
                        if (res2 == 0) begin  {res5,res2} <= {res2,res5};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res8 == 0) begin  {res5,res8} <= {res8,res5};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 6) begin  // 6-¢Ú
                    if (I_left) begin
                        if (res5 == 0) begin  {res6,res5} <= {res5,res6};  score <= score + 1;  end
                    end
                    else if (I_up) begin
                        if (res3 == 0) begin  {res6,res3} <= {res3,res6};  score <= score + 1;  end
                    end
                    else if (I_down) begin
                        if (res9 == 0) begin  {res6,res9} <= {res9,res6};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 7) begin  // 7-¢Ú
                    if (I_right) begin
                        if (res8 == 0) begin  {res7,res8} <= {res8,res7};  score <= score + 1;  end
                    end
                    else if (I_up) begin
                        if (res4 == 0) begin  {res7,res4} <= {res4,res7};  score <= score + 1;  end
                    end
                end

                else if (tmp_num_index == 8) begin  // 8-¢Ú
                    if (I_right) begin
                        if (res9 == 0) begin  {res8,res9} <= {res9,res8};  score <= score + 1;  end
                    end
                    else if (I_left) begin
                        if (res7 == 0) begin  {res8,res7} <= {res7,res8};  score <= score + 1;  end
                    end
                    else if (I_up) begin
                        if (res5 == 0) begin  {res8,res5} <= {res5,res8};  score <= score + 1;  end
                    end
                end  // ¢Ú

                else if (tmp_num_index == 9) begin  // 5-¢Ú
                    if (I_left) begin
                        if (res8 == 0) begin  res8 <= res9; res9 <= res8;  score <= score + 1;  end
                    end
                    else if (I_up) begin
                        if (res6 == 0) begin  {res9,res6} <= {res6,res9};  score <= score + 1;  end
                    end
                end
            end
        end
    end  // ¢Ù
endmodule
