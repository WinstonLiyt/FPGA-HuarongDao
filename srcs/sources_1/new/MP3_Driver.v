`timescale 1ns / 1ps

module MP3_Driver(
    input               R_clk_2M,   // 12.288/6MHZ时钟
    input               I_rst_n,
    input               play,       // 开始播放请求
    input       [1: 0]  mus_id,

    input               DREQ,       // MP3 数据请求线，显示 VS1003是否可以接受数据，高电平可以传输数据
    output reg          XCS,        // 片选输入，低电平有效（SCI 传输读写指令）
    output reg          XDCS,       // 数据片选，字节同步（SDI 传输数据）
    output              SCK,        // SPI总线时钟，12.288MHZ
    output reg          SI,         // 声音传感器有效信号灯（传入mp3）
    output reg          XRESET      // 复位引脚（硬件复位），低电平有效
    );

    parameter   H_RESET         = 4'd0,         // 硬复位
                S_RESET         = 4'd1,         // 软复位
                SET_CLOCKF      = 4'd2,         // 设置时钟寄存器
                SET_BASS        = 4'd3,         // 设置音调寄存器
                SET_VOL         = 4'd4,         // 设置音量
                WAIT            = 4'd5,         // 等待
                PLAY            = 4'd6;         // 播放
    
    reg [3:0]       state       = WAIT;         // 状态
    reg [31:0]      delay       = 32'd0;        // 延时
    reg [31:0]      sci_w       = 32'd0;        // 指令与地址 写
    reg [7:0]       sci_w_cnt   = 8'd32;        // SCI指令地址位数计数
    reg [31:0]      music_data  = 32'd0;        // 音乐数据
    reg [31:0]      sdi_cnt     = 32'd32;       // SDI当前4字节已传送BIT数

    reg [11:0]      addra       = 14'd0;        // ROM中的地址
    wire[31:0]      douta;                      // ROM传出
    wire[31:0]      doutb;
    wire[31:0]      doutc;
    reg [1:0]       pre_id      = 0;
    
    reg             ena         = 0;

    
    assign SCK = (R_clk_2M & ena);
    
    always @(negedge R_clk_2M) begin
        if (!I_rst_n || pre_id != mus_id || !play) begin    // 初始化
            pre_id      <= mus_id;
            XDCS        <= 1'b1;
            ena         <= 0;
            SI          <= 1'b0;
            XCS         <= 1'b1;
            XRESET      <= 1'b1;
            state       <= WAIT;
            addra       <= 14'd0;
            sdi_cnt     <= 32'd32;
            music_data  <= 32'd0;
        end
        else begin
            case (state)
                /*----------------等待---------------*/
                WAIT: begin
                    if (play) begin
                        if (delay > 0)
                            delay   <= delay - 1'b1;
                        else begin                              // 转到硬复位
                            delay   <= 32'd1000;
                            state   <= H_RESET;
                        end
                    end
                    else
                        delay     <= 32'd16700;
                end
                /*-----------------硬复位------------------*/
                H_RESET: begin
                    if (delay > 0)
                        delay     <= delay - 1'b1;
                    else begin
                        XCS         <= 1'b1;                //传输读、写指令
                        XRESET      <= 1'b0;                //硬件复位，低电平有效
                        delay       <= 32'd16700;           //复位后延时一段时间
                        state       <= S_RESET;             //转移到软复位
                        sci_w       <= 32'h02_00_0804;      //软复位指令;使MODE的值为0804;即第2位和第11位置1;软件复位和本地模式
                        sci_w_cnt   <= 8'd32;               //指令、地址、数据总长度
                    end
                end
                /*------------------软复位-----------------*/
                S_RESET: begin
                    if (delay > 0) begin
                        XRESET      <= (delay < 32'd16650);
                        delay       <= delay - 1'b1;
                    end
                    else if (sci_w_cnt == 0) begin          //软复位结束
                        delay       <= 32'd16600;
        
                        state       <= SET_VOL;             //转移到设置VOL
                        sci_w       <= 32'h02_0b_0000;
                        sci_w_cnt   <= 8'd32;
        
                        XCS         <= 1'b1;                //拉高XCS
                        ena         <= 1'b0;                //关闭输入时钟
                        SI          <= 1'b0;
                    end
                    else if (DREQ) begin                    //当DREQ有效时开始软复位；高电平传输数据
                        XCS         <= 1'b0;
                        ena         <= 1'b1;
                        SI          <= sci_w[sci_w_cnt - 1];
                        sci_w_cnt   <= sci_w_cnt - 1'b1;
                    end
                    else begin                              //DREQ无效时继续等待;
                        XCS         <= 1'b1;                //片选SCI 传输读、写指令
                        ena         <= 1'b0;
                        SI          <= 1'b0;
                    end
                end         
    
                /*----------播放音乐----------*/
                PLAY: begin
                    if (delay > 0)
                        delay       <= delay - 1'b1;
                    else if (play) begin
                        XDCS        <= 1'b0;
                        ena         <= 1'b1;
                        if (sdi_cnt == 0) begin             //传输完4字节（32位）
                            XDCS        <= 1'b1;            //拉高XDCS
                            ena         <= 1'b0;
                            SI          <= 1'b0;
                            sdi_cnt     <= 32'd32;
                            if (mus_id == 2'b00)
                                music_data  <= douta;
                            else if (mus_id == 2'b01)
                                music_data  <= doutb;
                            else if (mus_id == 2'b10)
                                music_data  <= doutc;
                            else;
                            addra <= addra + 1'b1;
                        end
                        else begin
                            //当DREQ有效 或当前字节尚未发送完毕 则继续传输
                            if (DREQ || (sdi_cnt != 32 && sdi_cnt != 24 && sdi_cnt != 16 && sdi_cnt != 8)) begin
                                SI      <= music_data[sdi_cnt - 1];
                                sdi_cnt <= sdi_cnt - 1'b1; 
                                ena     <= 1;
                                XDCS    <= 1'b0;
                            end
                            else begin      //DREQ拉低，停止传输
                                ena     <= 1'b0;
                                XDCS    <= 1'b1;
                                SI      <= 1'b0;
                            end
                        end
                    end
                    else begin
                        XCS         <= 1'b1;
                        ena         <= 1'b0;
                        SI          <= 1'b0;
                        // delay     <= 32'd16700;
                    end
                end                             
    
                /*---------------------寄存器配置------------------*/
                default: begin
                    if (delay > 0)
                        delay <= delay - 1'b1;
                    else if (sci_w_cnt == 0) begin          //结束一次SCI写入
                        if (state == SET_CLOCKF) begin
                            delay       <= 32'd11000;       //他是mp3speed
                            state       <= PLAY;
                        end
                        else if (state == SET_BASS) begin
                            delay       <= 32'd2100;
                            sci_w       <= 32'h02_03_7000;  // 7000 = 0111 0000 0000 0000
                            state       <= SET_CLOCKF;      // 设置时钟寄存器
                        end
                        else begin
                            delay       <= 32'd2100;
                            sci_w       <= 32'h02_02_0000;
                            state       <= SET_BASS;        // 设置音调寄存器
                        end
                        sci_w_cnt       <= 8'd32;
                        XCS             <= 1'b1;
                        ena             <= 1'b0;
                        SI              <= 1'b0;
                    end
                    else if (DREQ) begin                    // 写入SCI指令、地址、数据
                        XCS         <= 1'b0;
                        ena         <= 1'b1;
                        SI          <= sci_w[sci_w_cnt - 1];
                        sci_w_cnt   <= sci_w_cnt - 1'b1;
                    end
                    else begin                              // DREQ拉低，等待
                        XCS         <= 1'b1;
                        ena         <= 1'b0;
                        SI          <= 1'b0;
                    end
                end
            endcase
        end
    end


music_light m1 (
  .clka(R_clk_2M),    // input wire clka
  .addra(addra),  // input wire [11: 0] addra
  .douta(douta)  // output wire [31 : 0] douta
);

music_pipa m2 (
  .clka(R_clk_2M),    // input wire clka
  .addra(addra),  // input wire [11 : 0] addra
  .douta(doutb)  // output wire [31 : 0] douta
);

music_fly m3 (
  .clka(R_clk_2M),    // input wire clka
  .addra(addra),  // input wire [11 : 0] addra
  .douta(doutc)  // output wire [31 : 0] douta
);

endmodule

