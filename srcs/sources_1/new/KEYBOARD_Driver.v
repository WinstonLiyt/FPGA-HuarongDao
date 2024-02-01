`timescale 1ns / 1ps

module KEYBOARD_Driver(
    input                   I_clk_100M,     // 系统时钟
    input                   I_rst_n,		// 系统复位，低有效
    input                   ps2_clk,	    // PS2键盘时钟输入
    input                   ps2_data,	    // PS2键盘数据输入
    output  reg   [7:0]     key_ascii,		// 按键键值对应的ASCII编码
    output  reg             num_state
);

    reg		ps2_clk_r0  = 1'b1, ps2_clk_r1  = 1'b1; 
    reg		ps2_data_r0 = 1'b1, ps2_data_r1 = 1'b1;
    
    initial  num_state <= 0;

    //  对键盘时钟数据信号进行延时锁存
    always @ (posedge I_clk_100M or negedge I_rst_n)  begin
        if (!I_rst_n) begin
            ps2_clk_r0  <= 1'b1;
            ps2_clk_r1  <= 1'b1;
            ps2_data_r0 <= 1'b1;
            ps2_data_r1 <= 1'b1;
        end 
        else begin
            ps2_clk_r0  <= ps2_clk;         // PS2键盘时钟输入
            ps2_clk_r1  <= ps2_clk_r0;
            ps2_data_r0 <= ps2_data;
            ps2_data_r1 <= ps2_data_r0;     // PS2键盘时钟输入
        end
    end
     
    // 键盘时钟信号下降沿检测
    wire	  key_clk_neg = ps2_clk_r1 & (~ps2_clk_r0); 
     
    reg				[3:0]	cnt; 
    reg				[7:0]	temp_data;
     
    //根据键盘的时钟信号的下降沿读取数据
    always @ (posedge I_clk_100M or negedge I_rst_n) begin
        if (!I_rst_n) begin
            cnt     <= 4'd0;
            temp_data <= 8'd0;
        end 
        else if (key_clk_neg) begin 
            if (cnt >= 4'd10) cnt <= 4'd0;
            else cnt <= cnt + 1'b1;
            case (cnt)
                4'd0: ;  // 起始位
                4'd1: temp_data[0] <= ps2_data_r1;
                4'd2: temp_data[1] <= ps2_data_r1;
                4'd3: temp_data[2] <= ps2_data_r1;
                4'd4: temp_data[3] <= ps2_data_r1;
                4'd5: temp_data[4] <= ps2_data_r1;
                4'd6: temp_data[5] <= ps2_data_r1;
                4'd7: temp_data[6] <= ps2_data_r1;
                4'd8: temp_data[7] <= ps2_data_r1;
                4'd9: ;	 // 校验位
                4'd10:;	 // 结束位
                default: ;
            endcase
        end
    end
     
    reg		    key_break = 1'b0;
    reg         key_state = 1'b0;
    reg [7:0]	key_byte  = 1'b0;

    // 根据通码和断码判定按键的当前是按下还是松开，松开是0
    always @ (posedge I_clk_100M or negedge I_rst_n) begin 
        if (!I_rst_n) begin
            key_break   <= 1'b0;
            key_state   <= 1'b0;
            key_byte    <= 1'b0;
        end 
        else if (cnt == 4'd10 && key_clk_neg) begin 
            if (temp_data == 8'hf0)  	// 收到断码（8'hf0）：按键松开，下一个数据为断码，设置断码标示为1
                key_break   <= 1'b1;    // 不能赋值，现在是断码
            else if (!key_break) begin 	// 断码标示 0：当前数据为按下数据，输出键值，并设置按下标示为 1
                key_state   <= 1'b1;
                key_byte    <= temp_data; 
            end 
            else begin	// 断码标示 1:当前数据为松开数据，断码标示和按下标示清零
                key_state   <= 1'b0;
                key_break   <= 1'b0;
            end
        end
    end
    
    reg num_state2 = 1'b0;
  
    // 将键盘返回的有效键值转换为按键字母对应的ASCII码
    always @ (key_state) begin  // 一有新的就会读入
        if (num_state2 == 1'b0) begin   // !num_state 这个一加就只输出8了; 啥都不输出了
            case (key_byte)    //translate key_byte to key_ascii
                8'h16:  begin key_ascii <= 8'h31;   end  //1
                8'h1E:  begin key_ascii <= 8'h32;   end  //2       
                8'h26:  begin key_ascii <= 8'h33;   end  //3
                8'h25:  begin key_ascii <= 8'h34;   end  //4
                8'h2E:  begin key_ascii <= 8'h35;   end  //5
                8'h36:  begin key_ascii <= 8'h36;   end  //6
                8'h3D:  begin key_ascii <= 8'h37;   end  //7
                8'h3E:  begin key_ascii <= 8'h38;   end  //8            
                default:  key_ascii <= 0;   // 保持原状
            endcase
        end
    end
 
endmodule