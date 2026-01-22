module D_FF(
   input      clk,
   input      resetn,
   input      enable,
   input      D,

   output reg Q
);
   
   always@(posedge clk or negedge resetn) begin
      if(resetn == 0)
	Q <= 0;
      else if(enable)
	  Q <= D;
   end

endmodule 