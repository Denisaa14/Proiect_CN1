module Modulo5_Counter(
   input clk, reset, count_up,
   output reg [2:0] count
);

    always @(posedge clk)
    begin
        if (!reset)
            count <= 0;
        else if (count_up)
    begin
        if(count == 3'b100) count <= 3'b000;
                else count <= count + 1;
    end
    end
endmodule
