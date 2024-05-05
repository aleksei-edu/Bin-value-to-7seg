`include "binval27seg/src/BCD_converter.v"
`include "binval27seg/src/BCD_control.v"
`include "binval27seg/src/BCD_to_Cathodes.v"
`include "binval27seg/src/anode_control.v"
`include "binval27seg/src/freq_div.v"
`include "binval27seg/src/refreshcounter.v"

module top (
    input wire clk,
    input wire enable,
    input wire read_enable,
    input wire [19:0] buff_out,
    output wire [7:0] anode,
    output wire [7:0] cathode
);
  localparam DATA_IN_WIDTH = 20, DATA_OUT_WIDTH = 24;
  wire refresh_clock;
  wire [2:0] refreshcounter;
  wire [3:0] ONE_DIGIT;

  reg rst = 0;
  wire [DATA_OUT_WIDTH - 1:0] bcd_digits;

  wire [3:0] ones;
  wire [3:0] tens;
  wire [3:0] thd;
  wire [3:0] tsd;
  wire [3:0] tntsd;

  freq_div refreshclk_wapper (
      .clk    (clk),
      .rst    (rst),
      .enable (enable),
      .div_clk(refresh_clock)
  );

  wire bcdcvt_rdy;
  BCD_converter #(
      .DATA_IN_WIDTH (DATA_IN_WIDTH),
      .DATA_OUT_WIDTH(DATA_OUT_WIDTH)
  ) bcdcvt_wapper (
      .clk   (refresh_clock),
      .en    (read_enable),
      .data_i(buff_out),
      .data_o(bcd_digits),
      .rdy_o (bcdcvt_rdy)
  );

  refreshcounter refreshcnt_wapper (
      .refresh_clock (refresh_clock),
      .refreshcounter(refreshcounter)
  );

  anode_control anode_ctrl_wapper (
      .refreshcounter(refreshcounter),
      .anode         (anode)
  );


  BCD_control BCD_ctrl_wapper (
      .digit1        (bcd_digits[3:0]),
      .digit2        (bcd_digits[7:4]),
      .digit3        (bcd_digits[11:8]),
      .digit4        (bcd_digits[15:12]),
      .digit5        (bcd_digits[19:16]),
      .digit8        (bcd_digits[23:20]),
      .en            (enable),
      .refreshcounter(refreshcounter),
      .ONE_DIGIT     (ONE_DIGIT)
  );

  BCD_to_Cathodes BCD2Ctds (
      .digit  (ONE_DIGIT),
      .cathode(cathode)
  );

endmodule
/*
*                                  ______________               _____________                ____________
*                                 |     BCD      |   digit1    |             |              |            |
*                                 |   converter  |-------------|             |              |            |
*                                 |              |   digit2    |    BCD      |  4           |   BCD to   |   8             ____
*                ____             |              |-------------|   Control   |--/-----------|  Cathodes  |---/------------|____| cathode[7:0]
*  switch[15:0] |____|------------| data_i       |   digit3    |             |ONE_DIGIT[3:0]|            |                 
*                                 |              |-------------|             |              |            |
*                                 |              |   digit4    |             |              |____________|
*                                 |              |-------------|             |
*                                 |              |   digit5    |             |
*                              ___| clk          |-------------|             |
*                             |   |______________|             |_____________|            
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                                       |
*                             |                       __________      |
*                             |                      |          |     |
*                             |        refresh_clock |  Refresh |  2  |
*                             |                 _____|  Counter |__/__| refreshcounter[1:0]
*                             |                |     |__________|     |
*                             |                |                      |   
*                             |                |__________            |
*                             |                           |           |
*                 _________   |                           |     ______|_____      
*       ____     |  Freq   |  |                           |    |  Anode     |                     4 anode[3:0]          ____
*  clk |____|____|  Div    |__|___________________________|    |  Control   |---------------------/--------------------|____| anode[3:0]
*                |_________|                                   |____________|                                           
*                     
*/
