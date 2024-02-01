`timescale 1ns / 1ps

module mp3_tb;

    reg         R_clk_2M = 0;
    reg         I_rst_n;
    reg         play;     
    reg [1:0]   mus_id;
    reg         DREQ;     
    wire        XCS;      
    wire        XDCS;     
    wire        SCK;      
    wire        SI;       
    wire        XRESET;

    always #10 R_clk_2M = ~R_clk_2M;
    always #10 DREQ = ~DREQ;

    initial begin
        play = 0;
        I_rst_n = 0;
        DREQ    = 0;
        mus_id  = 2'b01;
        #10 I_rst_n = 1;    play = 1;
        #10 DREQ = 1;
        #10 mus_id  = 2'b10;
        #10 mus_id  = 2'b11;
        #10 play = 0;
        #10 play = 1;
    end

    MP3_Driver mp3_driver_tb (
    .R_clk_2M (R_clk_2M),     
    .I_rst_n (I_rst_n),
    .play (play),
    .mus_id (mus_id),
    .DREQ (DREQ),     
    .XCS (XCS),        
    .XDCS (XDCS),     
    .SCK (SCK),  
    .SI (SI),      
    .XRESET (XRESET)
    );

endmodule