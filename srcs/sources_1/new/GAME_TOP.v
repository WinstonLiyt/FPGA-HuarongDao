`timescale 1ns / 1ps

module GAME_TOP (
  input           I_clk_100M,     // 系统时钟
  input           I_rst_n,        // 复位按键（低电平有效�?
  input   [1: 0]  I_new,          // 关卡的�?�择
  
  /* VGA */
  input           I_up,           // NEXYS4方向按键：上
  input           I_down,         // NEXYS4方向按键：下
  input           I_left,         // NEXYS4方向按键：左
  input           I_right,        // NEXYS4方向按键：右
  input           I_reset,        // NEXYS4方向按键：游戏重�?

  output  [3: 0]  O_red,          // �?
  output  [3: 0]  O_green,        // �?
  output  [3: 0]  O_blue,         // �?
  output          O_hs,           // 行同步信�?
  output          O_vs,           // 场同步信�?
  output          O_gameover,     // 游戏是否结束
  
  /* KEYBOARD */
  input           ps2_clk,        // PS2键盘时钟输入
  input           ps2_data,       // PS2键盘数据输入
  
  /* SCORE BOARD */
  output  [7: 0]  O_shift,        // 第几个数码管
  output  [6: 0]  O_data,         // 移动步数

  /* MP3 BOARD */
  input           PLAY,           // 是否播放音乐
  input           DREQ,          	// MP3 数据请求线，显示 VS1003是否可以接受数据，高电平可以传输数据
  output          XCS,            // 片�?�输入，低电平有效（SCI 传输读写指令�?
  output          XDCS,          	// 数据片�?�，字节同步（SDI 传输数据�?
  output          SCK,            // SPI总线时钟�?12.288MHZ
  output          SI,             // 声音传感器有效信号灯（传入mp3�?
  output          XRESET        	// 复位引脚（硬件复位），低电平有效

  ); 
  
  wire R_clk_25M, R_clk_12M, R_clk_2M, R_clk_1000HZ;
  
  wire [7:0] key_ascii;
  wire key_state;
  wire num_state;
  wire [1:0] music_id;
  
  wire [15: 0] score;
  
  clk_wiz_0 clk_div (
  .clk_100m (I_clk_100M),
  .clk_25m (R_clk_25M),
  .clk_12m (R_clk_12M),
  .rst_n (I_rst_n)
  );
  
  Divider uut_divider (
  .I_CLK (R_clk_12M),
  .O_CLK1 (R_clk_2M),
  .O_CLK2 (R_clk_1000HZ)
  );
    
  VGA_Driver  uut_vga_driver (
  .R_clk_25M (R_clk_25M),
  .R_clk_2M (R_clk_2M),
  .I_rst_n (I_rst_n),
  .I_up (I_up),
  .I_down (I_down),
  .I_left (I_left),
  .I_right (I_right),
  .I_reset (I_reset),
  .O_red (O_red),
  .O_green (O_green),
  .O_blue (O_blue),
  .O_hs (O_hs),
  .O_vs (O_vs),
  .O_gameover(O_gameover),
  .key_ascii (key_ascii),
  .num_state (num_state),
  .score (score),
  .I_new (I_new),
  .music_id (music_id)
  );
  
  KEYBOARD_Driver uut_keyboard_driver(
  .I_clk_100M (I_clk_100M),
  .I_rst_n (I_rst_n),
  .ps2_clk (ps2_clk),
  .ps2_data (ps2_data),
  .key_ascii (key_ascii),
  .num_state (num_state)
  );

  SCOREBOARD_Driver uut_scoreboard_driver(
  .R_clk_1000HZ (R_clk_1000HZ),
  .score (score),
  .O_shift (O_shift),
  .O_data (O_data)
  );

  MP3_Driver uut_mp3_driver (
  .R_clk_2M (R_clk_2M),     
  .I_rst_n (I_rst_n),
  .play (PLAY),
  .mus_id (music_id),
  .DREQ (DREQ),     
  .XCS (XCS),        
  .XDCS (XDCS),     
  .SCK (SCK),  
  .SI (SI),      
  .XRESET (XRESET)
  );
      
endmodule