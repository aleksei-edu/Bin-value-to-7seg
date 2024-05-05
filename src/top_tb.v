`timescale 1ns / 1ps
`include "binval27seg/src/top.v"

module top_tb;
    reg clk = 0;
    wire [3:0] anode;
    wire [7:0] cathode;
    reg [23:0] buff_out = 0;
    reg enable = 0;
    reg read_enable = 0;
 
top uut (
    .clk(clk),
    .anode(anode),
    .cathode(cathode),
    .buff_out(buff_out),
    .enable(enable),
    .read_enable(read_enable)
);
always #5 clk = ~clk;

initial
begin
    enable = 1;
    #10000 buff_out[23:0] = 24'd865534;;
    read_enable = 1;
    #100 read_enable = 0;
    #1000000;
//    #10000 switch[7:4] = 8;
//    read_enable = 1;
//    #100 read_enable = 0;
//    #10000 switch[11:8] = 1;
//    read_enable = 1;
//    #100 read_enable = 0;
//    #10000 switch[15:12] = 3;
//    read_enable = 1;
//    #100 read_enable = 0;
end

endmodule

