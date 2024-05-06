`include "binval27seg/src/debounce.v"
module slow_click 
#(
  parameter DEB_DELAY = 20000
)(
  input clk,
  input rst_n,
  input button,
  output reg protected
);

  wire debounced;
  reg prev_state = 0;

  debounce #(
    .DELAY(DEB_DELAY)
  ) uut (
    .clk(clk),
    .rst_n(rst_n),
    .button(button),
    .debounced(debounced)
  );

  always @(*) begin
    if (debounced != prev_state) begin
      protected <= 0;
    end else begin
      protected <= debounced;
    end
    prev_state = debounced;
  end
  
endmodule