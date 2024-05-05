`timescale 1ns / 1ps
`include "binval27seg/src/mru.v"
module mru_tb;
  reg clk = 0;
  reg rst_n = 1;
  reg set;
  reg [15:0] data;
  reg getData;
  reg enable;
  wire [19:0] dataToOut;

  mru #(
      .MAX_RATE(0)
  ) uut (
      .clk      (clk),
      .rst_n    (rst_n),
      .set      (set),
      .data     (data),
      .getData  (getData),
      .enable   (enable),
      .dataToOut(dataToOut)
  );

  always #5 clk = ~clk;

  initial begin
    rst_n  = 0;
    enable = 1;
    #10 rst_n = 1;
    #10 data = 16'd65233;
    #10 set = 1;
    #10 set = 0;
    #10 getData = 1;
    #10 getData = 0;
  end

endmodule
