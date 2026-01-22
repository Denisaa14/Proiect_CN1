module Decoder_one_hot(
   input [2:0] count,
   output reg [4:0] cycle
);

    always @(*)
    begin
        cycle = 5'b00000; //initializare pe 0 
        if (count < 5) cycle[count] = 1'b1; //activeaza doar al "count-ulea" bit
    end
endmodule