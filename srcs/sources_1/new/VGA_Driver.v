`timescale 1ns / 1ps

module VGA_Driver(
    input                   R_clk_25M,      // 25mhz
    input                   R_clk_2M,
    input                   I_rst_n, 	    // 系统复位

    input                   I_up,
    input                   I_down,
    input                   I_left,
    input                   I_right,
    input                   I_reset,
    output  reg [3: 0]      O_red, 	        // VGA红色分量
    output  reg [3: 0]      O_green, 	    // VGA绿色分量
    output  reg [3: 0]      O_blue, 	    // VGA蓝色分量
    output                  O_hs, 	        // VGA行同步信号
    output                  O_vs,      	    // VGA场同步信号
    output  reg             O_gameover,
    
    input       [7: 0]      key_ascii,
    input                   num_state,
    output      [15: 0]     score,
    input       [1: 0]      I_new,
    output      [1: 0]      music_id
    );
    
    // 分辨率为640*480时行时序各个参数定义
    parameter       H_SYNC_PULSE        =   96, 
                    H_BACK_PORCH        =   48,
                    H_ACTIVE_TIME       =   640,
                    H_FRONT_PORCH       =   16,
                    H_LINE_PERIOD       =   800;
    
    // 分辨率为640*480时场时序各个参数定义               
    parameter       V_SYNC_PULSE        =   2, 
                    V_BACK_PORCH        =   33,
                    V_ACTIVE_TIME       =   480,
                    V_FRONT_PORCH       =   10,
                    V_FRAME_PERIOD      =   525;
    
    // 行列时序计数器
    reg [11:0]      h_cnt;          // 行
    reg [11:0]      v_cnt;          // 列
    
    wire            active_flag;    // 激活标志，当这个信号为1时RGB的数据可以显示在屏幕上
    
    // 内边框坐标
    parameter       B_X1    = 140,
                    B_X2    = 500,
                    B_Y1    = 60,
                    B_Y2    = 420;
    // 外边框坐标
    parameter       B_X_MIN     = 135,
                    B_X_MAX     = 505,
                    B_Y_MIN     = 55,
                    B_Y_MAX     = 425;
    
    parameter       CELL        = 112;  // 边框大小
    
    // Gameover图像信息
    parameter       C_IMAGE_WIDTH       = 120,
                    C_IMAGE_HEIGHT      = 120,
                    C_IMAGE_PIX_NUM     = 120 * 120;
    reg [13:0]      R_rom_addr = 14'b0; // ROM的地址
    wire[11:0]      W_rom_data;         // ROM中存储的数据
    
    // 文字：数字华容道
    parameter       CHAR_W      = 12'd64,   // 字符宽度
                    CHAR_H      = 12'd336;  // 字符深度
    parameter       CHAR_B_H    = H_SYNC_PULSE + H_BACK_PORCH + 30,
                    CHAR_B_V    = V_SYNC_PULSE + V_BACK_PORCH + 65;
    wire[11:0]      char_x;     // 字符横坐标
    wire[11:0]      char_y;     // 字符纵坐标
    
    // 文字：移动的数字是
    parameter       CHAR_W1     = 12'd72,
                    CHAR_H1     = 12'd50;
    parameter       CHAR_B_H1   = H_SYNC_PULSE + H_BACK_PORCH + 515,
                    CHAR_B_V1   = V_SYNC_PULSE + V_BACK_PORCH + 75;
    wire    [11:0]  char_x1;
    wire    [11:0]  char_y1;
    
    // 文字：移动的方位是
    parameter       CHAR_W2     = 12'd72,
                    CHAR_H2     = 12'd50;
    parameter       CHAR_B_H2   = H_SYNC_PULSE + H_BACK_PORCH + 515,
                    CHAR_B_V2   = V_SYNC_PULSE + V_BACK_PORCH + 190;
    wire    [11:0]  char_x2;
    wire    [11:0]  char_y2;
    
    // 文字：具体数字是
    parameter       CHAR_W3     = 12'd16,
                    CHAR_H3     = 12'd32;
    parameter       CHAR_B_H3   = H_SYNC_PULSE + H_BACK_PORCH + 605,
                    CHAR_B_V3   = V_SYNC_PULSE + V_BACK_PORCH + 80;
    wire    [11:0]  char_x3;
    wire    [11:0]  char_y3;
    
    // 数字：华容道数字
    parameter       NUM_X       = 48,
                    NUM_Y       = 40;
    parameter       CHAR_B_H_1  = H_SYNC_PULSE + H_BACK_PORCH + NUM_X,
                    CHAR_B_V_1  = V_SYNC_PULSE + V_BACK_PORCH + NUM_Y;
    wire    [11:0]  char_x_1;
    wire    [11:0]  char_y_1;
    wire    [11:0]  char_x_2;
    wire    [11:0]  char_y_2;        
    wire    [11:0]  char_x_3;
    wire    [11:0]  char_y_3;
    wire    [11:0]  char_x_4;
    wire    [11:0]  char_y_4;  
    wire    [11:0]  char_x_5;
    wire    [11:0]  char_y_5;
    wire    [11:0]  char_x_6;
    wire    [11:0]  char_y_6;        
    wire    [11:0]  char_x_7;
    wire    [11:0]  char_y_7;
    wire    [11:0]  char_x_8;
    wire    [11:0]  char_y_8;    
    wire    [11:0]  char_x_9;
    wire    [11:0]  char_y_9;
    reg     [9:0]   cell_x  [8:0];
    reg     [9:0]   cell_y  [8:0];
    
    // 文字：具体的方位
    parameter       CHAR_W4     = 12'd32,
                    CHAR_H4     = 12'd32;
    parameter       CHAR_B_H4   = H_SYNC_PULSE + H_BACK_PORCH + 600,
                    CHAR_B_V4   = V_SYNC_PULSE + V_BACK_PORCH + 202;
    wire    [11:0]  char_x4;
    wire    [11:0]  char_y4;    
    
    reg     [7:0]   num_index;

    // 存储的字符码
    reg     [63:0]  char    [335:0];
    reg     [71:0]  char1   [49:0];
    reg     [71:0]  char2   [49:0];
    reg     [127:0] char3   [31:0];
    reg     [127:0] char4   [31:0];    
    
    wire    [3:0]   res     [9:0];
    wire    [3:0]   tmp_res [9:0];
    
    // 选择关卡
    DATA_Driver uut_date_driver (
    .I_new (I_new),
    .tmp_res1 (tmp_res[1]),
    .tmp_res2 (tmp_res[2]),
    .tmp_res3 (tmp_res[3]),
    .tmp_res4 (tmp_res[4]),
    .tmp_res5 (tmp_res[5]),
    .tmp_res6 (tmp_res[6]),
    .tmp_res7 (tmp_res[7]),
    .tmp_res8 (tmp_res[8]),
    .tmp_res9 (tmp_res[9])
    );
    
    // 初始化格子坐标                
    always @(posedge R_clk_25M) begin
        cell_x[0] <= 10'd147;   cell_y[0] <= 10'd67;
        cell_x[1] <= 10'd264;   cell_y[1] <= 10'd67;
        cell_x[2] <= 10'd381;   cell_y[2] <= 10'd67;
        cell_x[3] <= 10'd147;   cell_y[3] <= 10'd184;
        cell_x[4] <= 10'd264;   cell_y[4] <= 10'd184;
        cell_x[5] <= 10'd381;   cell_y[5] <= 10'd184;
        cell_x[6] <= 10'd147;   cell_y[6] <= 10'd301;
        cell_x[7] <= 10'd264;   cell_y[7] <= 10'd301;
        cell_x[8] <= 10'd381;   cell_y[8] <= 10'd301;
    end
    
    // 判断游戏是否结束
    always @(posedge R_clk_25M) begin
        if ((res[1] == 4'd1) && (res[2] == 4'd2)
        &&  (res[3] == 4'd3) && (res[4] == 4'd4)
        &&  (res[5] == 4'd5) && (res[6] == 4'd6)
        &&  (res[7] == 4'd7) && (res[8] == 4'd8)
        &&  (res[9] == 4'd0))
            O_gameover <= 1'b1;
        else
            O_gameover <= 1'b0;
    end
    
    reg [7:0]   tmp_index;  // 没啥用
    
    // 读取键盘选择的按键
     always @(posedge R_clk_25M) begin
        if (key_ascii) begin
            num_index <= key_ascii - 8'h30;
            tmp_index <= key_ascii - 8'h30;
        end
        if (num_state) begin
            num_index <= tmp_index;
        end
    end
    
    wire  [2:0] dir_index;
    
    // 读取方向
    DIRECTION_Driver  uut_direction_driver (
    .I_up (I_up),
    .I_down (I_down),
    .I_left (I_left),
    .I_right (I_right),
    .O_gameover (O_gameover),
    .dir_index (dir_index)
    );        
    
    //////////////////////////////////////////////////////////////////    
    //char_x；char_y  - 数字华容道
    assign char_x = (h_cnt >= CHAR_B_H) && (h_cnt < CHAR_B_H + CHAR_W)
                &&  (v_cnt >= CHAR_B_V) && (v_cnt < CHAR_B_V + CHAR_H)
                ?   (64 - h_cnt + CHAR_B_H) : 10'h3ff;
    assign char_y = (h_cnt >= CHAR_B_H) && (h_cnt < CHAR_B_H + CHAR_W)
                &&  (v_cnt >= CHAR_B_V) && (v_cnt < CHAR_B_V + CHAR_H)
                ?   (v_cnt - CHAR_B_V) : 10'h3ff;

    //////////////////////////////////////////////////////////////////    
    //char_x1；char_y1  - 移动的数字是
    assign char_x1 = (h_cnt >= CHAR_B_H1) && (h_cnt < CHAR_B_H1 + CHAR_W1)
                &&   (v_cnt >= CHAR_B_V1) && (v_cnt < CHAR_B_V1 + CHAR_H1)
                ?    (72 - h_cnt + CHAR_B_H1) : 10'h3ff;
    assign char_y1 = (h_cnt >= CHAR_B_H1) && (h_cnt < CHAR_B_H1 + CHAR_W1)
                &&   (v_cnt >= CHAR_B_V1) && (v_cnt < CHAR_B_V1 + CHAR_H1)
                ?    (v_cnt - CHAR_B_V1) : 10'h3ff;

    //////////////////////////////////////////////////////////////////    
    //char_x2；char_y2  - 移动的方位是
    assign char_x2 = (h_cnt >= CHAR_B_H2) && (h_cnt < CHAR_B_H2 + CHAR_W2)
                &&   (v_cnt >= CHAR_B_V2) && (v_cnt < CHAR_B_V2 + CHAR_H2)
                ?    (72 - h_cnt + CHAR_B_H2) : 10'h3ff;
    assign char_y2 = (h_cnt >= CHAR_B_H2) && (h_cnt < CHAR_B_H2 + CHAR_W2)
                &&   (v_cnt >= CHAR_B_V2) && (v_cnt < CHAR_B_V2 + CHAR_H2)
                ?    (v_cnt - CHAR_B_V2) : 10'h3ff;
                    
     //////////////////////////////////////////////////////////////////    
    //char_x3；char_y3  - 具体数字
    assign char_x3 = (h_cnt >= CHAR_B_H3) && (h_cnt < CHAR_B_H3 + CHAR_W3)
                &&   (v_cnt >= CHAR_B_V3) && (v_cnt < CHAR_B_V3 + CHAR_H3)
                &&   (key_ascii)  // &&  (num_ascii)
                ?    (128 - h_cnt + CHAR_B_H3) : 10'h3ff;
    assign char_y3 = (h_cnt >= CHAR_B_H3) && (h_cnt < CHAR_B_H3 + CHAR_W3)
                &&   (v_cnt >= CHAR_B_V3) && (v_cnt < CHAR_B_V3 + CHAR_H3)
                ?    (v_cnt - CHAR_B_V3) : 10'h3ff;

     //////////////////////////////////////////////////////////////////    
    //char_x4；char_y4  - 具体方位
    assign char_x4 = (h_cnt >= CHAR_B_H4) && (h_cnt < CHAR_B_H4 + CHAR_W4)
                &&   (v_cnt >= CHAR_B_V4) && (v_cnt < CHAR_B_V4 + CHAR_H4)
                ?    (128 - h_cnt + CHAR_B_H4 ) : 10'h3ff;
    assign char_y4 = (h_cnt >= CHAR_B_H4) && (h_cnt < CHAR_B_H4 + CHAR_W4)
                &&   (v_cnt >= CHAR_B_V4) && (v_cnt < CHAR_B_V4 + CHAR_H4)
                ?    (v_cnt - CHAR_B_V4) : 10'h3ff;
                    
     //////////////////////////////////////////////////////////////////    
    //char_x_1；char_y_1  -- 每个格子的数字
    assign char_x_1 =   (h_cnt >= CHAR_B_H_1 + cell_x[0]) && (h_cnt < CHAR_B_H_1 + cell_x[0] + CHAR_W3)
                    &&  (v_cnt >= CHAR_B_V_1 + cell_y[0]) && (v_cnt < CHAR_B_V_1 + cell_y[0] + CHAR_H3)
                    &&  (res[1])
                    ?   (128 - h_cnt +CHAR_B_H_1 + cell_x[0] + (9-res[1])*16) : 10'h3ff;
    assign char_y_1 =   (h_cnt >= CHAR_B_H_1 + cell_x[0]) && (h_cnt < CHAR_B_H_1 + cell_x[0] + CHAR_W3)
                    &&  (v_cnt >= CHAR_B_V_1 + cell_y[0]) && (v_cnt < CHAR_B_V_1 + cell_y[0] + CHAR_H3)
                    ?   (v_cnt - (CHAR_B_V_1 + cell_y[0])) : 10'h3ff;                                      

     //////////////////////////////////////////////////////////////////    
    //char_x_2；char_y_2
    assign char_x_2 =   (h_cnt >= CHAR_B_H_1 + cell_x[1]) && (h_cnt < CHAR_B_H_1 + cell_x[1] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[1]) && (v_cnt < CHAR_B_V_1 + cell_y[1] + CHAR_H3)
                   &&   (res[2])                  
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[1] + (9-res[2])*16) : 10'h3ff;
    assign char_y_2 =   (h_cnt >= CHAR_B_H_1 + cell_x[1]) && (h_cnt < CHAR_B_H_1 + cell_x[1] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[1]) && (v_cnt < CHAR_B_V_1 + cell_y[1] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[1])) : 10'h3ff;   

     //////////////////////////////////////////////////////////////////    
    //char_x_3；char_y_3
    assign char_x_3 =   (h_cnt >= CHAR_B_H_1 + cell_x[2]) && (h_cnt < CHAR_B_H_1 + cell_x[2] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[2]) && (v_cnt < CHAR_B_V_1 + cell_y[2] + CHAR_H3)
                   &&   (res[3]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[2] + (9-res[3])*16) : 10'h3ff;
    assign char_y_3 =   (h_cnt >= CHAR_B_H_1 + cell_x[2]) && (h_cnt < CHAR_B_H_1 + cell_x[2] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[2]) && (v_cnt < CHAR_B_V_1 + cell_y[2] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[2])) : 10'h3ff;   

     //////////////////////////////////////////////////////////////////    
    //char_x_4；char_y_4
    assign char_x_4 =   (h_cnt >= CHAR_B_H_1 + cell_x[3]) && (h_cnt < CHAR_B_H_1 + cell_x[3] + CHAR_W3)
                    &&  (v_cnt >= CHAR_B_V_1 + cell_y[3]) && (v_cnt < CHAR_B_V_1 + cell_y[3] + CHAR_H3)
                    &&  (res[4]) 
                    ? (128 - h_cnt +CHAR_B_H_1 + cell_x[3] + (9-res[4])*16) : 10'h3ff;
    assign char_y_4 =   (h_cnt >= CHAR_B_H_1 + cell_x[3]) && (h_cnt < CHAR_B_H_1 + cell_x[3] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[3]) && (v_cnt < CHAR_B_V_1 + cell_y[3] + CHAR_H3)
                    ?   (v_cnt - (CHAR_B_V_1 + cell_y[3])) : 10'h3ff;                      

     //////////////////////////////////////////////////////////////////    
    //char_x_5；char_y_5
    assign char_x_5 =   (h_cnt >= CHAR_B_H_1 + cell_x[4]) && (h_cnt < CHAR_B_H_1 + cell_x[4] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[4]) && (v_cnt < CHAR_B_V_1 + cell_y[4] + CHAR_H3)
                   &&   (res[5]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[4] + (9-res[5])*16) : 10'h3ff;
    assign char_y_5 =   (h_cnt >= CHAR_B_H_1 + cell_x[4]) && (h_cnt < CHAR_B_H_1 + cell_x[4] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[4]) && (v_cnt < CHAR_B_V_1 + cell_y[4] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[4])) : 10'h3ff;   

     //////////////////////////////////////////////////////////////////    
    //char_x_6；char_y_6
    assign char_x_6 =   (h_cnt >= CHAR_B_H_1 + cell_x[5]) && (h_cnt < CHAR_B_H_1 + cell_x[5] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[5])  && (v_cnt < CHAR_B_V_1 + cell_y[5] + CHAR_H3)
                   &&   (res[6]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[5] + (9-res[6])*16) : 10'h3ff;
    assign char_y_6 =   (h_cnt >= CHAR_B_H_1 + cell_x[5]) && (h_cnt < CHAR_B_H_1 + cell_x[5] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[5]) && (v_cnt < CHAR_B_V_1 + cell_y[5] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[5])) : 10'h3ff;

     //////////////////////////////////////////////////////////////////    
    //char_x_7；char_y_7
    assign char_x_7 =   (h_cnt >= CHAR_B_H_1 + cell_x[6]) && (h_cnt < CHAR_B_H_1 + cell_x[6] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[6]) && (v_cnt < CHAR_B_V_1 + cell_y[6] + CHAR_H3)
                   &&   (res[7]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[6] + (9-res[7])*16) : 10'h3ff;
    assign char_y_7 =   (h_cnt >= CHAR_B_H_1 + cell_x[6]) && (h_cnt < CHAR_B_H_1 + cell_x[6] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[6]) && (v_cnt < CHAR_B_V_1 + cell_y[6] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[6])) : 10'h3ff;

     //////////////////////////////////////////////////////////////////    
    //char_x_8；char_y_8
    assign char_x_8 =   (h_cnt >= CHAR_B_H_1 + cell_x[7]) && (h_cnt < CHAR_B_H_1 + cell_x[7] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[7]) && (v_cnt < CHAR_B_V_1 + cell_y[7] + CHAR_H3)
                   &&   (res[8]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[7] + (9-res[8])*16) : 10'h3ff;
    assign char_y_8 =   (h_cnt >= CHAR_B_H_1 + cell_x[7]) && (h_cnt < CHAR_B_H_1 + cell_x[7] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[7]) && (v_cnt < CHAR_B_V_1 + cell_y[7] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[7])) : 10'h3ff;

     //////////////////////////////////////////////////////////////////    
    //char_x_9；char_y_9
    assign char_x_9 =   (h_cnt >= CHAR_B_H_1 + cell_x[8]) && (h_cnt < CHAR_B_H_1 + cell_x[8] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[8]) && (v_cnt < CHAR_B_V_1 + cell_y[8] + CHAR_H3)
                   &&   (res[9]) 
                   ?    (128 - h_cnt +CHAR_B_H_1 + cell_x[8] + (9-res[9])*16) : 10'h3ff;
    assign char_y_9 =   (h_cnt >= CHAR_B_H_1 + cell_x[8]) && (h_cnt < CHAR_B_H_1 + cell_x[8] + CHAR_W3)
                   &&   (v_cnt >= CHAR_B_V_1 + cell_y[8]) && (v_cnt < CHAR_B_V_1 + cell_y[8] + CHAR_H3)
                   ?    (v_cnt - (CHAR_B_V_1 + cell_y[8])) : 10'h3ff;
    
    // 判断移动的是哪个格子
    reg [3:0] tmp_num_index;
    integer i;
    always @(posedge R_clk_25M) begin  // ①
    if ((num_index <=8) && (num_index >=1)) begin
        for (i = 1; i <= 9; i = i + 1) begin
            if (res[i] == num_index)
                tmp_num_index = i;
        end
    end
    end
    
    // 判断能否移动
    MOVE_Driver uut_move_driver(
    .R_clk_2M (R_clk_2M),
    .I_reset (I_reset),
    .I_up (I_up),
    .I_down (I_down),
    .I_left (I_left),
    .I_right (I_right),
    .tmp_num_index (tmp_num_index),
    .tmp_res1 (tmp_res[1]),
    .tmp_res2 (tmp_res[2]),
    .tmp_res3 (tmp_res[3]),
    .tmp_res4 (tmp_res[4]),
    .tmp_res5 (tmp_res[5]),
    .tmp_res6 (tmp_res[6]),
    .tmp_res7 (tmp_res[7]),
    .tmp_res8 (tmp_res[8]),
    .tmp_res9 (tmp_res[9]),
    .I_new (I_new),
    .O_gameover (O_gameover),
    .res1 (res[1]),
    .res2 (res[2]),
    .res3 (res[3]),
    .res4 (res[4]),
    .res5 (res[5]),
    .res6 (res[6]),
    .res7 (res[7]),
    .res8 (res[8]),
    .res9 (res[9]),
    .mus_id (music_id),
    .score (score)
    );
    
    // 游戏结束照片
    photo gameover (
      .clka (R_clk_25M),    // input wire clka
      .addra (R_rom_addr),  // input wire [13 : 0] addra
      .douta (W_rom_data)  // output wire [11 : 0] douta
    );
    
    // 数字华容道
    always @(posedge R_clk_25M) begin
        char[0]  <= 64'h0000000000000000;
        char[1]  <= 64'h0000000000000000;
        char[2]  <= 64'h0000100000800000;
        char[3]  <= 64'h00001C0000E00000;
        char[4]  <= 64'h00001F0000F80000;
        char[5]  <= 64'h00801E0200FC0000;
        char[6]  <= 64'h00C01C0300F80000;
        char[7]  <= 64'h00601C07C1F00000;
        char[8]  <= 64'h00781C0781E00000;
        char[9]  <= 64'h003C1C0F01E00000;
        char[10]  <= 64'h003C1C0E01C00000;
        char[11]  <= 64'h001E1C1C03C00000;
        char[12]  <= 64'h001E1C1803C00000;
        char[13]  <= 64'h001E1C3003800000;
        char[14]  <= 64'h000E1C3003800000;
        char[15]  <= 64'h000C1C6007800000;
        char[16]  <= 64'h00041C43070000C0;
        char[17]  <= 64'h00001C07870001E0;
        char[18]  <= 64'h0FFFFFFFCFFFFFF0;
        char[19]  <= 64'h07FFFFFFEFFFFFF8;
        char[20]  <= 64'h03007C001E003C00;
        char[21]  <= 64'h0000FC001E003C00;
        char[22]  <= 64'h0001FE001E003C00;
        char[23]  <= 64'h0003DFE01B003C00;
        char[24]  <= 64'h00039CF83B003C00;
        char[25]  <= 64'h00071C7C33003800;
        char[26]  <= 64'h000E1C3E71003800;
        char[27]  <= 64'h001C1C1E61003800;
        char[28]  <= 64'h00381C0E61007800;
        char[29]  <= 64'h00701C04C1807800;
        char[30]  <= 64'h00E01C0081807800;
        char[31]  <= 64'h03801C0181807800;
        char[32]  <= 64'h0700100101807000;
        char[33]  <= 64'h0C00700001807000;
        char[34]  <= 64'h10007C0000C0F000;
        char[35]  <= 64'h00007C0000C0F000;
        char[36]  <= 64'h0000F80000C0F000;
        char[37]  <= 64'h0000F00C00E0E000;
        char[38]  <= 64'h0FFFFFFF00E1E000;
        char[39]  <= 64'h07FFFFFF8061E000;
        char[40]  <= 64'h0201C01E0071C000;
        char[41]  <= 64'h0003C01C0073C000;
        char[42]  <= 64'h0003803C0033C000;
        char[43]  <= 64'h00078038003B8000;
        char[44]  <= 64'h00070078003F8000;
        char[45]  <= 64'h000E0070001F8000;
        char[46]  <= 64'h000F00F0001F0000;
        char[47]  <= 64'h0007F9E0001F0000;
        char[48]  <= 64'h00007FC0003F0000;
        char[49]  <= 64'h00000FF8007F8000;
        char[50]  <= 64'h00000FFE00FFC000;
        char[51]  <= 64'h00001E7F01F3E000;
        char[52]  <= 64'h00003C1F83E1F000;
        char[53]  <= 64'h0000F8078780FC00;
        char[54]  <= 64'h0003E0038F007F00;
        char[55]  <= 64'h000780001E003FC0;
        char[56]  <= 64'h001E000078001FF8;
        char[57]  <= 64'h00F80000F0000FF8;
        char[58]  <= 64'h03C00003C00007C0;
        char[59]  <= 64'h1E00000F00000100;
        char[60]  <= 64'h0000001C00000000;
        char[61]  <= 64'h0000006000000000;
        char[62]  <= 64'h0000000000000000;
        char[63]  <= 64'h0000000000000000;  // 数
        char[64]  <= 64'h0000000000000000;
        char[65]  <= 64'h0000000000000000;
        char[66]  <= 64'h0000000000000000;
        char[67]  <= 64'h0000000000000000;
        char[68]  <= 64'h0000000000000000;
        char[69]  <= 64'h0000000000000000;
        char[70]  <= 64'h0000003000000000;
        char[71]  <= 64'h0000001C00000000;
        char[72]  <= 64'h0000000F00000000;
        char[73]  <= 64'h0000000780000000;
        char[74]  <= 64'h00000007C0000000;
        char[75]  <= 64'h00000003E0000000;
        char[76]  <= 64'h00000001E0000000;
        char[77]  <= 64'h00000001E0000000;
        char[78]  <= 64'h00000001E0000000;
        char[79]  <= 64'h00100000C0000600;
        char[80]  <= 64'h0010000000000700;
        char[81]  <= 64'h003FFFFFFFFFFFC0;
        char[82]  <= 64'h003FFFFFFFFFFFE0;
        char[83]  <= 64'h0030000000000F80;
        char[84]  <= 64'h0070000000001E00;
        char[85]  <= 64'h0070000000001C00;
        char[86]  <= 64'h00F0000000003800;
        char[87]  <= 64'h01F0000000003000;
        char[88]  <= 64'h01F00000000C6000;
        char[89]  <= 64'h03E00000001E4000;
        char[90]  <= 64'h01C3FFFFFFFF0000;
        char[91]  <= 64'h0001FFFFFFFF8000;
        char[92]  <= 64'h00008000003FC000;
        char[93]  <= 64'h00000000007E0000;
        char[94]  <= 64'h0000000000F00000;
        char[95]  <= 64'h0000000001E00000;
        char[96]  <= 64'h0000000007800000;
        char[97]  <= 64'h000000000E000000;
        char[98]  <= 64'h000000001C000000;
        char[99]  <= 64'h0000000230000000;
        char[100]  <= 64'h00000003E0000000;
        char[101]  <= 64'h00000003C0000000;
        char[102]  <= 64'h00000003F0000180;
        char[103]  <= 64'h00000003E00003C0;
        char[104]  <= 64'h00000003C00007E0;
        char[105]  <= 64'h1FFFFFFFFFFFFFF0;
        char[106]  <= 64'h0FFFFFFFFFFFFFF8;
        char[107]  <= 64'h04000003C0000000;
        char[108]  <= 64'h00000003C0000000;
        char[109]  <= 64'h00000003C0000000;
        char[110]  <= 64'h00000003C0000000;
        char[111]  <= 64'h00000003C0000000;
        char[112]  <= 64'h00000003C0000000;
        char[113]  <= 64'h00000003C0000000;
        char[114]  <= 64'h00000003C0000000;
        char[115]  <= 64'h00000003C0000000;
        char[116]  <= 64'h00000003C0000000;
        char[117]  <= 64'h00000003C0000000;
        char[118]  <= 64'h00000003C0000000;
        char[119]  <= 64'h00000003C0000000;
        char[120]  <= 64'h00000003C0000000;
        char[121]  <= 64'h00000003C0000000;
        char[122]  <= 64'h00000003C0000000;
        char[123]  <= 64'h00001C03C0000000;
        char[124]  <= 64'h00000FFFC0000000;
        char[125]  <= 64'h000001FFC0000000;
        char[126]  <= 64'h0000007F80000000;
        char[127]  <= 64'h0000001F80000000;
        char[128]  <= 64'h0000000E00000000;
        char[129]  <= 64'h0000000C00000000;
        char[130]  <= 64'h0000000000000000;
        char[131]  <= 64'h0000000000000000;  // 字
        char[132]  <= 64'h0000000000000000;
        char[133]  <= 64'h0000000000000000;
        char[134]  <= 64'h0000000000000000;
        char[135]  <= 64'h0000000000000000;
        char[136]  <= 64'h0000000000000000;
        char[137]  <= 64'h0000000000000000;
        char[138]  <= 64'h0000000000000000;
        char[139]  <= 64'h0000100040000000;
        char[140]  <= 64'h0000180070000000;
        char[141]  <= 64'h00003E007C000000;
        char[142]  <= 64'h00003F0078000000;
        char[143]  <= 64'h00007C0070000000;
        char[144]  <= 64'h0000780070000800;
        char[145]  <= 64'h0000F00070001C00;
        char[146]  <= 64'h0000F00070003E00;
        char[147]  <= 64'h0001E00070007F00;
        char[148]  <= 64'h0001C0007001F800;
        char[149]  <= 64'h0003C0007003F000;
        char[150]  <= 64'h000780007007C000;
        char[151]  <= 64'h0007E000700F8000;
        char[152]  <= 64'h000FE000703E0000;
        char[153]  <= 64'h001FC000707C0000;
        char[154]  <= 64'h001DC00071F00000;
        char[155]  <= 64'h0039C00077C00000;
        char[156]  <= 64'h0071C0007F8000C0;
        char[157]  <= 64'h00E1C0007E0000C0;
        char[158]  <= 64'h01C1C000F80000C0;
        char[159]  <= 64'h0181C003F00000C0;
        char[160]  <= 64'h0201C00F700000C0;
        char[161]  <= 64'h0401C03C700000C0;
        char[162]  <= 64'h0001C1E0700000C0;
        char[163]  <= 64'h0001C700700000C0;
        char[164]  <= 64'h0001C000700000C0;
        char[165]  <= 64'h0001C000700001E0;
        char[166]  <= 64'h0001C000780001F0;
        char[167]  <= 64'h0001C0007FFFFFF0;
        char[168]  <= 64'h0001C0003FFFFFE0;
        char[169]  <= 64'h0001C0021FFFFFC0;
        char[170]  <= 64'h0001C00380000000;
        char[171]  <= 64'h0001C003E0000000;
        char[172]  <= 64'h00018003C0000000;
        char[173]  <= 64'h0002000380000000;
        char[174]  <= 64'h0000000380000000;
        char[175]  <= 64'h0000000380000180;
        char[176]  <= 64'h00000003800003C0;
        char[177]  <= 64'h00000003800007E0;
        char[178]  <= 64'h1FFFFFFFFFFFFFF0;
        char[179]  <= 64'h0FFFFFFFFFFFFFF8;
        char[180]  <= 64'h0400000380000000;
        char[181]  <= 64'h0000000380000000;
        char[182]  <= 64'h0000000380000000;
        char[183]  <= 64'h0000000380000000;
        char[184]  <= 64'h0000000380000000;
        char[185]  <= 64'h0000000380000000;
        char[186]  <= 64'h0000000380000000;
        char[187]  <= 64'h0000000380000000;
        char[188]  <= 64'h0000000380000000;
        char[189]  <= 64'h0000000380000000;
        char[190]  <= 64'h0000000380000000;
        char[191]  <= 64'h0000000380000000;
        char[192]  <= 64'h0000000380000000;
        char[193]  <= 64'h0000000380000000;
        char[194]  <= 64'h0000000380000000;
        char[195]  <= 64'h00000003C0000000;
        char[196]  <= 64'h0000000200000000;
        char[197]  <= 64'h0000000000000000;
        char[198]  <= 64'h0000000000000000;
        char[199]  <= 64'h0000000000000000;  // 华
        char[200]  <= 64'h0000000000000000;
        char[201]  <= 64'h0000000000000000;
        char[202]  <= 64'h0000000000000000;
        char[203]  <= 64'h0000000000000000;
        char[204]  <= 64'h0000000000000000;
        char[205]  <= 64'h0000000000000000;
        char[206]  <= 64'h0000003000000000;
        char[207]  <= 64'h0000001E00000000;
        char[208]  <= 64'h0000000F80000000;
        char[209]  <= 64'h00000007C0000000;
        char[210]  <= 64'h00000003E0000000;
        char[211]  <= 64'h00000003E0000000;
        char[212]  <= 64'h00200001E0000000;
        char[213]  <= 64'h00200000C0000000;
        char[214]  <= 64'h00200000C0000300;
        char[215]  <= 64'h003FFFFFFFFFFF80;
        char[216]  <= 64'h007FFFFFFFFFFFC0;
        char[217]  <= 64'h00700000000007E0;
        char[218]  <= 64'h00F0000000000F80;
        char[219]  <= 64'h00F0040000000E00;
        char[220]  <= 64'h01F00E0000001C00;
        char[221]  <= 64'h03E00F0007001800;
        char[222]  <= 64'h03E01F8003C02000;
        char[223]  <= 64'h03C03F0000F80000;
        char[224]  <= 64'h00003C01007E0000;
        char[225]  <= 64'h00007803C01F8000;
        char[226]  <= 64'h0000F007E00FE000;
        char[227]  <= 64'h0001E007E007F000;
        char[228]  <= 64'h0003C00F8003F800;
        char[229]  <= 64'h0007000FC000F800;
        char[230]  <= 64'h000E001F60007C00;
        char[231]  <= 64'h001C003E30007800;
        char[232]  <= 64'h0070007C38003800;
        char[233]  <= 64'h00C000781C001800;
        char[234]  <= 64'h018000F00E000000;
        char[235]  <= 64'h000001E007000000;
        char[236]  <= 64'h000003C003C00000;
        char[237]  <= 64'h000007C001E00000;
        char[238]  <= 64'h00000F8000F80000;
        char[239]  <= 64'h00001E00007E0000;
        char[240]  <= 64'h00003C00003F8000;
        char[241]  <= 64'h00007800000FF000;
        char[242]  <= 64'h0001F0000017FF00;
        char[243]  <= 64'h0003F8000019FFF8;
        char[244]  <= 64'h0007BFFFFFFCFFF0;
        char[245]  <= 64'h001E3FFFFFFF3FC0;
        char[246]  <= 64'h003C3C00003E0F80;
        char[247]  <= 64'h00F03C00003C0300;
        char[248]  <= 64'h03803C00003C0000;
        char[249]  <= 64'h0E003C00003C0000;
        char[250]  <= 64'h10003C00003C0000;
        char[251]  <= 64'h00003C00003C0000;
        char[252]  <= 64'h00003C00003C0000;
        char[253]  <= 64'h00003C00003C0000;
        char[254]  <= 64'h00003C00003C0000;
        char[255]  <= 64'h00003C00003C0000;
        char[256]  <= 64'h00003C00003C0000;
        char[257]  <= 64'h00003C00003C0000;
        char[258]  <= 64'h00003C00003C0000;
        char[259]  <= 64'h00003FFFFFFC0000;
        char[260]  <= 64'h00003FFFFFFC0000;
        char[261]  <= 64'h00003C00003C0000;
        char[262]  <= 64'h00003C00003C0000;
        char[263]  <= 64'h0000380000380000;
        char[264]  <= 64'h0000200000200000;
        char[265]  <= 64'h0000000000000000;
        char[266]  <= 64'h0000000000000000;
        char[267]  <= 64'h0000000000000000;  // 容
        char[268]  <= 64'h0000000000000000;
        char[269]  <= 64'h0000000000000000;
        char[270]  <= 64'h0000000000000000;
        char[271]  <= 64'h0000000000000000;
        char[272]  <= 64'h0000000000000000;
        char[273]  <= 64'h0000000000000000;
        char[274]  <= 64'h0000000000010000;
        char[275]  <= 64'h0080001800018000;
        char[276]  <= 64'h00E0000C0003E000;
        char[277]  <= 64'h0070000F0003F000;
        char[278]  <= 64'h003C00078003E000;
        char[279]  <= 64'h001E0003C0078000;
        char[280]  <= 64'h001F0003E0070000;
        char[281]  <= 64'h000F0001E00E0000;
        char[282]  <= 64'h000F8001E00C0000;
        char[283]  <= 64'h000F8000E01C0000;
        char[284]  <= 64'h00070000E0180180;
        char[285]  <= 64'h00070000803003C0;
        char[286]  <= 64'h00001FFFFFFFFFE0;
        char[287]  <= 64'h00000FFFFFFFFFF0;
        char[288]  <= 64'h000006000F000000;
        char[289]  <= 64'h000000000F000000;
        char[290]  <= 64'h000000000E000000;
        char[291]  <= 64'h000000000C001000;
        char[292]  <= 64'h000000180C003800;
        char[293]  <= 64'h0002001FFFFFFC00;
        char[294]  <= 64'h0007001FFFFFFE00;
        char[295]  <= 64'h3FFF801C00007800;
        char[296]  <= 64'h1FFFC01C00007000;
        char[297]  <= 64'h0C0F801C00007000;
        char[298]  <= 64'h000F001C00007000;
        char[299]  <= 64'h000F001C00007000;
        char[300]  <= 64'h000F001C00007000;
        char[301]  <= 64'h000F001FFFFFF000;
        char[302]  <= 64'h000F001FFFFFF000;
        char[303]  <= 64'h000F001C00007000;
        char[304]  <= 64'h000F001C00007000;
        char[305]  <= 64'h000F001C00007000;
        char[306]  <= 64'h000F001C00007000;
        char[307]  <= 64'h000F001C00007000;
        char[308]  <= 64'h000F001C00007000;
        char[309]  <= 64'h000F001FFFFFF000;
        char[310]  <= 64'h000F001FFFFFF000;
        char[311]  <= 64'h000F001C00007000;
        char[312]  <= 64'h000F001C00007000;
        char[313]  <= 64'h000F001C00007000;
        char[314]  <= 64'h000F001C00007000;
        char[315]  <= 64'h000F001C00007000;
        char[316]  <= 64'h000F001C00007000;
        char[317]  <= 64'h000F001FFFFFF000;
        char[318]  <= 64'h000F001FFFFFF000;
        char[319]  <= 64'h003F801C00007000;
        char[320]  <= 64'h0070C01C00007000;
        char[321]  <= 64'h01E0601C00006000;
        char[322]  <= 64'h07C0301800000000;
        char[323]  <= 64'h0F801C0000000000;
        char[324]  <= 64'h0F000F0000000000;
        char[325]  <= 64'h0F0007C000000000;
        char[326]  <= 64'h060003FE00000038;
        char[327]  <= 64'h000000FFFFFFFFF0;
        char[328]  <= 64'h0000003FFFFFFFC0;
        char[329]  <= 64'h00000003FFFFFF80;
        char[330]  <= 64'h0000000007FFFF80;
        char[331]  <= 64'h0000000000000000;
        char[332]  <= 64'h0000000000000000;
        char[333]  <= 64'h0000000000000000;
        char[334]  <= 64'h0000000000000000;
        char[335]  <= 64'h0000000000000000;  // 道
    end
    // 移动的数字是
    always @(posedge R_clk_25M) begin
        char1[0]  <= 72'h000000000000000000;
        char1[1]  <= 72'h000000000000020100;
        char1[2]  <= 72'h000100000100030180;
        char1[3]  <= 72'h01C300000100020300;
        char1[4]  <= 72'h1F0200004100020300;
        char1[5]  <= 72'h0207F83FE100040200;
        char1[6]  <= 72'h0204180001001FE7FC;
        char1[7]  <= 72'h020A30000FFC104408;
        char1[8]  <= 72'h02536000010C104808;
        char1[9]  <= 72'h7FE1C07FF10C104808;
        char1[10]  <= 72'h06018002010C105008;
        char1[11]  <= 72'h0603C006010C104408;
        char1[12]  <= 72'h070D800401081FC308;
        char1[13]  <= 72'h0EF3FC0C8108104108;
        char1[14]  <= 72'h0A460C084308104108;
        char1[15]  <= 72'h124C08106208104008;
        char1[16]  <= 72'h121210102208104008;
        char1[17]  <= 72'h2221303FF408104008;
        char1[18]  <= 72'h420160301C08104008;
        char1[19]  <= 72'h0200800008081FC018;
        char1[20]  <= 72'h020300001198104118;
        char1[21]  <= 72'h021C000060701040F0;
        char1[22]  <= 72'h02E000008020000020;
        char1[23]  <= 72'h000000000000000000;
        char1[24]  <= 72'h000000000000000000;
        char1[25]  <= 72'h000000000000000000;
        char1[26]  <= 72'h000000000000000000;
        char1[27]  <= 72'h010100002000000000;
        char1[28]  <= 72'h11118000180001FF80;
        char1[29]  <= 72'h0911000018000100C0;
        char1[30]  <= 72'h0D2300080808010080;
        char1[31]  <= 72'h0942000FFFFC01FF80;
        char1[32]  <= 72'h3FFBFC080018010080;
        char1[33]  <= 72'h030610180010010080;
        char1[34]  <= 72'h07C61037FFE0010080;
        char1[35]  <= 72'h0526100001C001FF80;
        char1[36]  <= 72'h093A30000300010080;
        char1[37]  <= 72'h310A30000400000008;
        char1[38]  <= 72'h4101300018003FFFFC;
        char1[39]  <= 72'h030120001800020800;
        char1[40]  <= 72'h7FF1207FFFFC030800;
        char1[41]  <= 72'h0621E0001800030800;
        char1[42]  <= 72'h0420C0001800020FF0;
        char1[43]  <= 72'h0E40C0001800070800;
        char1[44]  <= 72'h01E1E0001800048800;
        char1[45]  <= 72'h01B3300018000C4800;
        char1[46]  <= 72'h06161C001800083800;
        char1[47]  <= 72'h18180C00F800100FFC;
        char1[48]  <= 72'h602000003000600078;
        char1[49]  <= 72'h000000000000000000;
    end
    // 移动的方位是
    always @(posedge R_clk_25M) begin
        char2[0]  <= 72'h000000000000000000;
        char2[1]  <= 72'h000000000000020100;
        char2[2]  <= 72'h000100000100030180;
        char2[3]  <= 72'h01C300000100020300;
        char2[4]  <= 72'h1F0200004100020300;
        char2[5]  <= 72'h0207F83FE100040200;
        char2[6]  <= 72'h0204180001001FE7FC;
        char2[7]  <= 72'h020A30000FFC104408;
        char2[8]  <= 72'h02536000010C104808;
        char2[9]  <= 72'h7FE1C07FF10C104808;
        char2[10]  <= 72'h06018002010C105008;
        char2[11]  <= 72'h0603C006010C104408;
        char2[12]  <= 72'h070D800401081FC308;
        char2[13]  <= 72'h0EF3FC0C8108104108;
        char2[14]  <= 72'h0A460C084308104108;
        char2[15]  <= 72'h124C08106208104008;
        char2[16]  <= 72'h121210102208104008;
        char2[17]  <= 72'h2221303FF408104008;
        char2[18]  <= 72'h420160301C08104008;
        char2[19]  <= 72'h0200800008081FC018;
        char2[20]  <= 72'h020300001198104118;
        char2[21]  <= 72'h021C000060701040F0;
        char2[22]  <= 72'h02E000008020000020;
        char2[23]  <= 72'h000000000000000000;
        char2[24]  <= 72'h000000000000000000;
        char2[25]  <= 72'h000000000000000000;
        char2[26]  <= 72'h000000000000000000;
        char2[27]  <= 72'h000000020800000000;
        char2[28]  <= 72'h00200003040001FF80;
        char2[29]  <= 72'h0018000206000100C0;
        char2[30]  <= 72'h001800060200010080;
        char2[31]  <= 72'h00080404020801FF80;
        char2[32]  <= 72'h7FFFFE04FFFC010080;
        char2[33]  <= 72'h0030000C0000010080;
        char2[34]  <= 72'h0020000E0020010080;
        char2[35]  <= 72'h00200014003001FF80;
        char2[36]  <= 72'h002000142060010080;
        char2[37]  <= 72'h003FE0241060000008;
        char2[38]  <= 72'h0060602410403FFFFC;
        char2[39]  <= 72'h006060441840020800;
        char2[40]  <= 72'h004040041840030800;
        char2[41]  <= 72'h00C040041880030800;
        char2[42]  <= 72'h008040040880020FF0;
        char2[43]  <= 72'h0180C0040080070800;
        char2[44]  <= 72'h0300C0040100048800;
        char2[45]  <= 72'h0200C00401040C4800;
        char2[46]  <= 72'h04188005FFFE083800;
        char2[47]  <= 72'h180780040000100FFC;
        char2[48]  <= 72'h200200040000600078;
        char2[49]  <= 72'h000000000000000000;
    end
    // 数字库
    always @(posedge R_clk_25M) begin
        char3[0]  <= 128'h00000000000000000000000000000000;
        char3[1]  <= 128'h00000000000000000000000000000000;
        char3[2]  <= 128'h00000000000000000000000000000000;
        char3[3]  <= 128'h00000000000000000000000000000000;
        char3[4]  <= 128'h00000000000000000000000000000000;
        char3[5]  <= 128'h008007C00F8000600FF803C01FF80FC0;
        char3[6]  <= 128'h0180087010E000601FF80C301FF81860;
        char3[7]  <= 128'h0F801030306000E01000183030103030;
        char3[8]  <= 128'h01802018303000E01000103020206018;
        char3[9]  <= 128'h01802018303001601000300020206018;
        char3[10]  <= 128'h01803018303002601000200000406018;
        char3[11]  <= 128'h01803018003002601000200000407018;
        char3[12]  <= 128'h01800018006004601000600000803830;
        char3[13]  <= 128'h0180003000C00C6013C067C000801C20;
        char3[14]  <= 128'h01800020038008601C706C6001000FC0;
        char3[15]  <= 128'h01800060006010601830703001000FC0;
        char3[16]  <= 128'h018000C00030106000187018010010E0;
        char3[17]  <= 128'h01800180001020600018601802003070;
        char3[18]  <= 128'h01800300001840600018601802006038;
        char3[19]  <= 128'h0180060000187FFC0018601802006018;
        char3[20]  <= 128'h01800C00301800603018601806006018;
        char3[21]  <= 128'h01800808301800603018301806006018;
        char3[22]  <= 128'h01801008301800602030301006006018;
        char3[23]  <= 128'h01802018303000602030183006003030;
        char3[24]  <= 128'h01C03FF81060006018601C6006001860;
        char3[25]  <= 128'h0FF03FF00FC003FC07C007C006000FC0;
        char3[26]  <= 128'h00000000000000000000000000000000;
        char3[27]  <= 128'h00000000000000000000000000000000;
        char3[28]  <= 128'h00000000000000000000000000000000;
        char3[29]  <= 128'h00000000000000000000000000000000;
        char3[30]  <= 128'h00000000000000000000000000000000;
        char3[31]  <= 128'h00000000000000000000000000000000;
    end 
    // 方位库
    always @(posedge R_clk_25M) begin
        char4[0]  <= 128'h00000000000000000000000000000000;
        char4[1]  <= 128'h00000000000000000000000000000000;
        char4[2]  <= 128'h00040000000000000008000000060000;
        char4[3]  <= 128'h0007000000000040000C000000070000;
        char4[4]  <= 128'h000600003FFFFFE00018000000060000;
        char4[5]  <= 128'h00060000000600000018000000060000;
        char4[6]  <= 128'h0006000000060000001800C0000C0060;
        char4[7]  <= 128'h00060000000600001FFFFFE03FFFFFF0;
        char4[8]  <= 128'h000600000006000000180000000C0000;
        char4[9]  <= 128'h00060000000600000010000000180000;
        char4[10]  <= 128'h00060000000600000030000000180000;
        char4[11]  <= 128'h00060300000700000030000000300000;
        char4[12]  <= 128'h0007FF800006E0000020000000300000;
        char4[13]  <= 128'h0006000000063C000060000000600000;
        char4[14]  <= 128'h0006000000061E000060000000600100;
        char4[15]  <= 128'h000600000006070000C0020000FFFF80;
        char4[16]  <= 128'h000600000006030000FFFF0000A00300;
        char4[17]  <= 128'h00060000000603000080C00001200300;
        char4[18]  <= 128'h00060000000600000180C00003200300;
        char4[19]  <= 128'h00060000000600000300C00006200300;
        char4[20]  <= 128'h00060000000600000200C0000C200300;
        char4[21]  <= 128'h00060000000600000600C00018200300;
        char4[22]  <= 128'h00060000000600000C00C00030200300;
        char4[23]  <= 128'h00060000000600000800C00040200300;
        char4[24]  <= 128'h00060000000600001000C00000200300;
        char4[25]  <= 128'h00060060000600002000C0C0003FFF00;
        char4[26]  <= 128'h3FFFFFF00006000003FFFFE000200300;
        char4[27]  <= 128'h00000000000600000000000000200200;
        char4[28]  <= 128'h00000000000600000000000000000000;
        char4[29]  <= 128'h00000000000000000000000000000000;
        char4[30]  <= 128'h00000000000000000000000000000000;
        char4[31]  <= 128'h00000000000000000000000000000000;
    end
    
    //////////////////////////////////////////////////////////////////
    // 功能：产生行时序
    always @(posedge R_clk_25M or negedge I_rst_n) begin
        if (!I_rst_n)
            h_cnt <=  12'd0;
        else if (h_cnt == H_LINE_PERIOD - 1'b1)
            h_cnt <=  12'd0;
        else
            h_cnt <=  h_cnt + 1'b1;                
    end
    assign O_hs = (h_cnt < H_SYNC_PULSE) ? 1'b0 : 1'b1; 
    
    //////////////////////////////////////////////////////////////////
    // 功能：产生场时序
    always @(posedge R_clk_25M or negedge I_rst_n) begin
        if (!I_rst_n)
            v_cnt <=  12'd0   ;
        else if (v_cnt == V_FRAME_PERIOD - 1'b1)
            v_cnt <=  12'd0   ;
        else if (h_cnt == H_LINE_PERIOD - 1'b1)
            v_cnt <=  v_cnt + 1'b1  ;
        else
            v_cnt <=  v_cnt ;                        
    end
    assign O_vs = (v_cnt < V_SYNC_PULSE) ? 1'b0 : 1'b1; 
    
    //////////////////////////////////////////////////////////////////
    // 功能：输出场同步和行同步    
    assign active_flag =  (h_cnt >= (H_SYNC_PULSE + H_BACK_PORCH))  
                                && (h_cnt <= (H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE_TIME))  
                                && (v_cnt >= (V_SYNC_PULSE + V_BACK_PORCH))  
                                && (v_cnt <= (V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE_TIME));

    //////////////////////////////////////////////////////////////////
    // 功能：输出数字华容道格子
    always @(posedge R_clk_25M or negedge I_rst_n) begin
        if (!I_rst_n) begin
            O_red       <=  4'b0000;
            O_green     <=  4'b0000;
            O_blue      <=  4'b0000;
            R_rom_addr  <=  14'd0 ;
        end
        else if (active_flag) begin
            // 红色外边框
            if (h_cnt >=    (H_SYNC_PULSE + H_BACK_PORCH + B_X_MIN)
                && h_cnt <  (H_SYNC_PULSE + H_BACK_PORCH + B_X1)
                && v_cnt >= (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MIN)
                && v_cnt <= (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MAX)) begin
                if (!O_gameover) begin
                    O_red   <=  4'b1111;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;
                end
                else begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b1111;
                    O_blue  <=  4'b0000;
                end
            end
            else if (h_cnt >= (H_SYNC_PULSE + H_BACK_PORCH + B_X1)
                && h_cnt  <=  (H_SYNC_PULSE + H_BACK_PORCH + B_X2)
                && v_cnt  >=  (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MIN)
                && v_cnt  <   (V_SYNC_PULSE + V_BACK_PORCH + B_Y1)) begin
                if (!O_gameover) begin
                    O_red   <=  4'b1111;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;
                end
                else begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b1111;
                    O_blue  <=  4'b0000;
                end
            end
            else if (h_cnt > (H_SYNC_PULSE + H_BACK_PORCH + B_X2)
                && h_cnt  <= (H_SYNC_PULSE + H_BACK_PORCH + B_X_MAX)
                && v_cnt  >= (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MIN)
                && v_cnt  <= (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MAX)) begin
                if (!O_gameover) begin
                    O_red   <=  4'b1111;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;
                end
                else begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b1111;
                    O_blue  <=  4'b0000;
                end
            end
            else if (h_cnt >= (H_SYNC_PULSE + H_BACK_PORCH + B_X1)
                &&   h_cnt <= (H_SYNC_PULSE + H_BACK_PORCH + B_X2)
                &&   v_cnt >  (V_SYNC_PULSE + V_BACK_PORCH + B_Y2)
                &&   v_cnt <= (V_SYNC_PULSE + V_BACK_PORCH + B_Y_MAX)) begin
                if (!O_gameover) begin
                    O_red   <=  4'b1111;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;
                end
                else begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b1111;
                    O_blue  <=  4'b0000;
                end
            end                   
            // 内边框
            else if (h_cnt >= (H_SYNC_PULSE + H_BACK_PORCH + B_X1) 
                &&  h_cnt  <= (H_SYNC_PULSE + H_BACK_PORCH + B_X2) 
                &&  v_cnt  >= (V_SYNC_PULSE + V_BACK_PORCH + B_Y1)
                &&  v_cnt  <= (V_SYNC_PULSE + V_BACK_PORCH + B_Y2)) begin
                if    ((h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[0]) 
                ||    ((h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[1])
                &&     (h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[0] + CELL))
                ||    ((h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[2])
                &&     (h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[1] + CELL))
                ||     (h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[2] + CELL) 
                ||     (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[0]) 
                ||    ((v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[3])
                &&     (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[0] + CELL))               
                ||    ((v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[6])
                &&     (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[3] + CELL))
                ||     (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[6] + CELL)) begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b1111;
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[0] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[0] + 65)
                    &&   (v_cnt  > V_SYNC_PULSE + V_BACK_PORCH + cell_y[0] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[0] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[0] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[0] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[0])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[0] + CHAR_H3)
                    &&   (char3[char_y_1][char_x_1] == 1'b1)) begin  // 第一个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin  // 米褐色背景
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[1] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[1] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[1] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[1] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[1] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[1] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[1])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[1] + CHAR_H3)
                    &&   (char3[char_y_2][char_x_2] == 1'b1)) begin  // 第二个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[2] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[2] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[2] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[2] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[2] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[2] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[2])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[2] + CHAR_H3)
                    &&   (char3[char_y_3][char_x_3] == 1'b1)) begin  // 第三个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[3] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[3] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[3] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[3] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[3] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[3] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[3])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[3] + CHAR_H3)
                    &&   (char3[char_y_4][char_x_4] == 1'b1)) begin  // 第四个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[4] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[4] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[4] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[4] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[4] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[4] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[4])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[4] + CHAR_H3)
                    &&   (char3[char_y_5][char_x_5] == 1'b1)) begin  // 第五个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[5] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[5] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[5] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[5] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[5] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[5] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[5])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[5] + CHAR_H3)
                    &&   (char3[char_y_6][char_x_6] == 1'b1)) begin  // 第六个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[6] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[6] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[6] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[6] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[6] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[6] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[6])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[6] + CHAR_H3)
                    &&   (char3[char_y_7][char_x_7] == 1'b1)) begin  // 第七个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[7] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[7] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[7] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[7] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[7] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[7] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[7])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[7] + CHAR_H3)
                    &&   (char3[char_y_8][char_x_8] == 1'b1)) begin  // 第八个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else if ((h_cnt >  H_SYNC_PULSE + H_BACK_PORCH + cell_x[8] + 45)
                    &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + cell_x[8] + 65)
                    &&   (v_cnt >  V_SYNC_PULSE + V_BACK_PORCH + cell_y[8] + 35)
                    &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + cell_y[8] + 70)) begin
                    if  ((h_cnt >  CHAR_B_H_1 + cell_x[8] - 1)
                    &&   (h_cnt <= CHAR_B_H_1 + cell_x[8] + CHAR_W3 - 1)
                    &&   (v_cnt >= CHAR_B_V_1 + cell_y[8])
                    &&   (v_cnt <  CHAR_B_V_1 + cell_y[8] + CHAR_H3)
                    &&   (char3[char_y_9][char_x_9] == 1'b1)) begin  // 第九个空格
                        O_red      <=  4'b0000;
                        O_green    <=  4'b0000;
                        O_blue     <=  4'b0000;
                    end
                    else begin
                        O_red      <=  4'b1111;
                        O_green    <=  4'b0110;
                        O_blue     <=  4'b0101;
                    end
                end
                else begin  // 米褐色
                    O_red   <=  4'b1111;
                    O_green <=  4'b0110;
                    O_blue  <=   4'b0101;
                end
             end
            else if ((h_cnt >= H_SYNC_PULSE + H_BACK_PORCH + 30)
                &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + 95)
                &&   (v_cnt >= V_SYNC_PULSE + V_BACK_PORCH + 65)
                &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + 420)) begin
                if  ((h_cnt >= CHAR_B_H - 1) && (h_cnt < CHAR_B_H + CHAR_W - 1)
                &&   (v_cnt >= CHAR_B_V)     && (v_cnt < CHAR_B_V + CHAR_H)
                &&   (char[char_y][char_x] == 1'b1)) begin  // 数字华容道
                    O_red   <=  4'b0000;  // 青色
                    O_green <=  4'b1111;
                    O_blue  <=  4'b1111;
                end
                else begin  // 黑色
                    O_red   <=  4'b0000;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;            
                end
            end
            else if ((h_cnt >= H_SYNC_PULSE + H_BACK_PORCH + 510)
                &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + 585)
                &&   (v_cnt >= V_SYNC_PULSE + V_BACK_PORCH + 75)
                &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + 125)) begin
                if  ((h_cnt >= CHAR_B_H1 - 1) && (h_cnt < CHAR_B_H1 + CHAR_W1 - 1)
                &&   (v_cnt >= CHAR_B_V1)     && (v_cnt < CHAR_B_V1 + CHAR_H1)
                &&   (char1[char_y1][char_x1] == 1'b1)) begin  // 移动的数字是
                    O_red   <=  4'b1111;  // 白色
                    O_green <=  4'b1111;
                    O_blue  <=  4'b1111;
                end
                else begin  // 黑色
                    O_red   <=  4'b0000;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;            
                end
            end
            else if ((h_cnt >= H_SYNC_PULSE + H_BACK_PORCH + 600)
                &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + 630)
                &&   (v_cnt >= V_SYNC_PULSE + V_BACK_PORCH + 80)
                &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + 115)) begin
                if  ((h_cnt >= CHAR_B_H3 - 1) && (h_cnt < CHAR_B_H3 + CHAR_W3 - 1)
                &&   (v_cnt >= CHAR_B_V3)     && (v_cnt < CHAR_B_V3 + CHAR_H3)
               //  && (num_ascii >= 1) && (num_ascii <= 8)
                &&   (char3[char_y3][char_x3 + 16 * (9 - num_index)] == 1'b1)) begin  // 具体数字为
                    O_red   <=  4'b1111;  // 白色
                    O_green <=  4'b1111;
                    O_blue  <=  4'b1111;
                end
                else begin  // 灰色
                    O_red   <=  4'b0011;
                    O_green <=  4'b0011;
                    O_blue  <=  4'b0011;              
                end
            end            
            else if ((h_cnt >= H_SYNC_PULSE + H_BACK_PORCH + 510)
                &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + 585)
                &&   (v_cnt >= V_SYNC_PULSE + V_BACK_PORCH + 190)
                &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + 245)) begin
                if  ((h_cnt >= CHAR_B_H2 - 1) && (h_cnt < CHAR_B_H2 + CHAR_W2 - 1)
                &&   (v_cnt >= CHAR_B_V2)     && (v_cnt < CHAR_B_V2 + CHAR_H2)
                &&   (char2[char_y2][char_x2] == 1'b1)) begin  // 移动的方位是
                    O_red   <=  4'b1111;  // 白色
                    O_green <=  4'b1111;
                    O_blue  <=  4'b1111;
                end
                else begin  // 黑色
                    O_red   <=  4'b0000;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;            
                end
            end                
            else if ((h_cnt >= H_SYNC_PULSE + H_BACK_PORCH + 600)
                &&   (h_cnt <= H_SYNC_PULSE + H_BACK_PORCH + 630)
                &&   (v_cnt >= V_SYNC_PULSE + V_BACK_PORCH + 202)
                &&   (v_cnt <= V_SYNC_PULSE + V_BACK_PORCH + 237)) begin
                if  ((h_cnt >= CHAR_B_H4 - 1) && (h_cnt < CHAR_B_H4 + CHAR_W4 - 1)
                &&   (v_cnt >= CHAR_B_V4)     && (v_cnt < CHAR_B_V4 + CHAR_H4)
                &&   (dir_index)
                &&   (char4[char_y4][char_x4 + 32 * (5 - dir_index)] == 1'b1)) begin  // 具体方位为
                    O_red   <=  4'b1111;  // 白色
                    O_green <=  4'b1111;
                    O_blue  <=  4'b1111;
                end
                else begin  // 灰色
                    O_red   <=  4'b0011;
                    O_green <=  4'b0011;
                    O_blue  <=  4'b0011;              
                end
            end
            else if  (h_cnt >= (H_SYNC_PULSE + H_BACK_PORCH + 515)  
                &&    h_cnt <= (H_SYNC_PULSE + H_BACK_PORCH + 515 + C_IMAGE_WIDTH - 1'b1)  
                &&    v_cnt >= (V_SYNC_PULSE + V_BACK_PORCH + 300)  
                &&    v_cnt <= (V_SYNC_PULSE + V_BACK_PORCH + 300 + C_IMAGE_HEIGHT - 1'b1)) begin
                if (O_gameover) begin  // 闯关成功图片
                    O_red       <= W_rom_data[11:8];  // Rom中的数据
                    O_green     <= W_rom_data[7:4];
                    O_blue      <= W_rom_data[3:0];
                    // if (R_rom_addr == C_IMAGE_PIX_NUM - 1'b1)
                    //     R_rom_addr  <=  14'd0;  // Rom 地址
                    // else
                    //     R_rom_addr  <=  R_rom_addr + 1'b1;        
                end
                else begin
                    O_red       <=  4'b0000;
                    O_green     <=  4'b0000;
                    O_blue      <=  4'b0000;
                    //R_rom_addr  <=  14'd0;
                end
                if  (R_rom_addr == C_IMAGE_PIX_NUM - 1'b1)
                        R_rom_addr  <=  14'd0;  // Rom 地址
                else
                    R_rom_addr  <=  R_rom_addr + 1'b1; 
            end     
            else begin
                    O_red   <=  4'b0000;
                    O_green <=  4'b0000;
                    O_blue  <=  4'b0000;
                    R_rom_addr  <=  R_rom_addr;  // 不可以给0       
            end         
        end
        else begin
            O_red   <=  4'b0000;
            O_green <=  4'b0000;
            O_blue  <=  4'b0000;
            R_rom_addr  <=  R_rom_addr;  // 不可以给0
        end
    end

    endmodule
