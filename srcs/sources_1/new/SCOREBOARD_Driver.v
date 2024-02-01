`timescale 1ns / 1ps

module SCOREBOARD_Driver(
    input               R_clk_1000HZ,
    input       [15: 0] score,
    output  reg [7: 0]  O_shift,
    output  reg [6: 0]  O_data
    );

    wire    [3:0]   Data[7:0];
    reg     [3:0]   cnt = 0;  //������
    
    assign Data[4] = 4'd11;
    assign Data[5] = 4'd11;
    assign Data[6] = 4'd11;
    assign Data[7] = 4'd11;
    
    Bin2BCD uut_Bin2bcd(
        .num(score),
        .bcd0(Data[0]),
        .bcd1(Data[1]),
        .bcd2(Data[2]),
        .bcd3(Data[3])
    );

    //Ƭѡ���?
    always @ (posedge R_clk_1000HZ) begin
        if (cnt == 4'd8)
            cnt <= 0;
        else
            cnt <= cnt + 1;
        O_shift <= 8'b1111_1111;
        O_shift[cnt] <= 0;//ѡ��һ������ܽ������
        case (Data[cnt])
            4'b0000: O_data <= 7'b100_0000;  // 0
            4'b0001: O_data <= 7'b111_1001;  // 1
            4'b0010: O_data <= 7'b010_0100;  // 2
            4'b0011: O_data <= 7'b011_0000;  // 3
            4'b0100: O_data <= 7'b001_1001;  // 4
            4'b0101: O_data <= 7'b001_0010;  // 5
            4'b0110: O_data <= 7'b000_0010;  // 6
            4'b0111: O_data <= 7'b111_1000;  // 7
            4'b1000: O_data <= 7'b000_0000;  // 8
            4'b1001: O_data <= 7'b001_0000;  // 9
            default: O_data <= 7'b111_1111;
        endcase
    end
endmodule
