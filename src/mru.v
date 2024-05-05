module mru #(
    parameter BUF_SIZE = 8,
    parameter WIDTH = 20,
    parameter MAX_RATE = 100000000
) (
    input clk,
    input rst_n,
    input set,
    input [15:0] data,
    input getData,  // flagToGetData
    input enable,
    output reg [19:0] dataToOut
);
  localparam [1:0] IDLE = 2'b00, CHECKING_HIT = 2'b01, HIT_UPDATING = 2'b10, WRITE_VALUE = 2'b11;

  reg [         15:0] dataCopy;
  reg [WIDTH - 1 : 0] outs                            [BUF_SIZE - 1:0];
  reg [          1:0] state;

  reg [          2:0] hitIndex;  // reg to counting
  reg [          2:0] index;  // last in MRU
  reg [          3:0] freeEl = 3'b0;  // first free_el
  reg [         31:0] set_counter = 0;
  reg [         31:0] getData_counter = 0;


  always @(posedge clk, negedge rst_n) begin
    if (enable) begin
      if (!rst_n) begin
        outs[0] <= 20'd0;
        outs[1] <= 20'd0;
        outs[2] <= 20'd0;
        outs[3] <= 20'd0;

        outs[4] <= 20'd0;
        outs[5] <= 20'd0;
        outs[6] <= 20'd0;
        outs[7] <= 20'd0;

        dataCopy <= 20'd0;

        hitIndex <= 3'd0;
        index <= 3'd0;
        freeEl <= 4'd0;

        dataToOut <= 20'd0;

        state <= IDLE;
      end else
        case (state)
          IDLE: begin
            if (getData && getData_counter >= MAX_RATE) begin
              case (data)
                0: dataToOut <= outs[0];
                1: dataToOut <= outs[1];
                2: dataToOut <= outs[2];
                3: dataToOut <= outs[3];
                4: dataToOut <= outs[4];
                5: dataToOut <= outs[5];
                6: dataToOut <= outs[6];
                7: dataToOut <= outs[7];
              endcase
              dataToOut[16]   <= freeEl[0];
              dataToOut[17]   <= freeEl[1];
              dataToOut[18]   <= freeEl[2];
              dataToOut[19]   <= freeEl[3];
              getData_counter <= 0;
            end else if (getData) begin
              getData_counter <= getData_counter + 1;
            end
            if (set && set_counter >= MAX_RATE) begin
              state <= CHECKING_HIT;
              dataCopy <= data;
              hitIndex <= 0;
            end else if (set) begin
              set_counter <= set_counter + 1;
            end
          end
          CHECKING_HIT: begin
            if (hitIndex > 3) begin
              state <= WRITE_VALUE;
              if (freeEl < 8) begin
                index  <= freeEl;
                freeEl <= freeEl + 1;
              end
            end else begin
              case (hitIndex)
                0: begin
                  if (outs[0] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                1: begin
                  if (outs[1] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                2: begin
                  if (outs[2] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                3: begin
                  if (outs[3] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                4: begin
                  if (outs[4] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                5: begin
                  if (outs[5] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                6: begin
                  if (outs[6] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
                7: begin
                  if (outs[7] == dataCopy) state <= HIT_UPDATING;
                  else hitIndex <= hitIndex + 1;
                end
              endcase
            end
          end
          HIT_UPDATING: begin
            index <= hitIndex;
          end
          WRITE_VALUE: begin
            case (index)
              0: outs[0] <= dataCopy;
              1: outs[1] <= dataCopy;
              2: outs[2] <= dataCopy;
              3: outs[3] <= dataCopy;
              4: outs[4] <= dataCopy;
              5: outs[5] <= dataCopy;
              6: outs[6] <= dataCopy;
              7: outs[7] <= dataCopy;
            endcase
            state <= IDLE;
          end
        endcase
    end
  end
endmodule
