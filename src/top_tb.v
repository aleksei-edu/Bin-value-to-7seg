`timescale 1ns / 1ps
`include "binval27seg/src/top.v"

module top_tb;
  reg clk = 0;
  reg rst_n = 1;
  reg en = 1;
  reg set_i = 0;
  reg get_i = 0;
  reg [15:0] switch = 0;
  wire [7:0] anode;
  wire [7:0] cathode;
  wire mru_busy;
  wire bcd_cvt_busy;
  wire refreshclk;

  top uut (
      .clk          (clk),
      .rst_n        (rst_n),
      .en           (en),
      .set_i        (set_i),
      .get_i        (get_i),
      .switch       (switch),
      .anode        (anode),
      .cathode      (cathode),
      .mru_busy     (mru_busy),
      .bcd_cvt_busy (bcd_cvt_busy),
      .refresh_clock(refreshclk)
  );
  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    en = 1;
    @(posedge refreshclk) rst_n = 1;
    @(posedge refreshclk) switch = 16'd65233;
    @(posedge refreshclk) set_i = 1;
    @(posedge refreshclk) set_i = 0;
    @(posedge refreshclk);
    while (mru_busy == 1) begin
      @(posedge refreshclk);
    end
    @(posedge refreshclk) switch = 0;
    @(posedge refreshclk) get_i = 1;
    @(posedge refreshclk) get_i = 0;
    @(posedge refreshclk);
    while (mru_busy == 1) begin
      @(posedge refreshclk);
    end
    @(posedge refreshclk);
    while (bcd_cvt_busy == 1) begin
      @(posedge refreshclk);
    end
    $finish;
  end

endmodule


