module MUX (
   input  in0, in1,
   input  select,
   output out
);

   assign out = (~select & in0) | (select & in1);
endmodule 


module MUX_4_to_1 (
   input in0, in1, in2, in3,
   input [1:0] select,
   output wire out
);

   wire out_0, out_1;

   MUX mux_0(
         .in0(in0),
         .in1(in1),
         .select(select[0]),
         .out(out_0)
         );

   MUX mux_1(
         .in0(in2),
         .in1(in3),
         .select(select[0]),
         .out(out_1)
         );

   MUX mux(
       .in0(out_0),
       .in1(out_1),
       .select(select[1]),
       .out(out)
       );

endmodule


module MUX_logic(
   input [7:0] in0, in1, in2,
   input [1:0] select,
   output [7:0] out
);

   generate
      genvar i;
      for(i=0; i < 8; i = i + 1) begin: mux
     MUX_4_to_1 mux(
		.in0(in0[i]), 
            	.in1(in1[i]),
            	.in2(in2[i]),
            	.in3(1'bx),
            	.select(select), 
            	.out(out[i])
	);
      end

   endgenerate

endmodule