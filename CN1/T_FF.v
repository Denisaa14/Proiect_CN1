module T_FF(
   input clk,
   input resetn,
   input T,

   output reg Q
);

   always@(posedge clk or negedge resetn) begin
      if(resetn == 0)
        Q <= 0;
      else if(T)
        Q <= ~Q;
   end

endmodule 