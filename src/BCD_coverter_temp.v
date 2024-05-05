module BCD_converter (
    input clk,
    input en,
    input [15:0] data_i,
    output reg [19:0] data_o = 0,
    output reg rdy_o
);



  localparam [2:0] IDLE = 3'b000, SETUP = 3'b001, ADD = 3'b010, SHIFT = 3'b011, DONE = 3'b100;
  reg busy;
  reg [35:0] bcd_data = 0;
  reg [2:0] state = 0;
  reg [2:0] add_counter = 0;
  reg [3:0] sh_counter = 0;

  always @(posedge clk) begin
    if (en) begin
      if (~busy) begin
        bcd_data <= {20'b0, data_i};
        rdy_o <= 0;
        state <= SETUP;
      end
    end

    case (state)
      IDLE: begin
        busy <= 0;
      end
      SETUP: begin
        busy  <= 1;
        state <= ADD;
      end
      ADD: begin
        case (add_counter)
          0: begin
            if (bcd_data[19:16] > 4) bcd_data[35:16] <= bcd_data[35:16] + 3;
            add_counter <= add_counter + 1;
          end
          1: begin
            if (bcd_data[23:20] > 4) bcd_data[35:20] <= bcd_data[35:20] + 3;
            add_counter <= add_counter + 1;
          end
          2: begin
            if (bcd_data[27:24] > 4) bcd_data[35:24] <= bcd_data[35:24] + 3;
            add_counter <= add_counter + 1;
          end
          3: begin
            if (bcd_data[31:28] > 4) bcd_data[35:28] <= bcd_data[35:28] + 3;
            add_counter <= add_counter + 1;
          end
          4: begin
            if (bcd_data[35:32] > 4) bcd_data[35:32] <= bcd_data[35:32] + 3;
            add_counter <= 0;
            state <= SHIFT;
          end
        endcase
      end
      SHIFT: begin
        sh_counter <= sh_counter + 1;
        bcd_data   <= bcd_data << 1;
        if (sh_counter == 15) begin
          sh_counter <= 0;
          state <= DONE;
        end else begin
          state <= ADD;
        end
      end
      DONE: begin
        rdy_o  <= 1;
        state  <= IDLE;
        data_o <= bcd_data[35:16];
      end
      default: state <= IDLE;
    endcase
  end
endmodule
