module Register(

   input clk,
   input resetn,
   input Din,
   input load_Din, //daca e activ, D_FF se incarca cu Din
   input [7:0] load_data, 
   input [1:0] shift, 

   output wire [7:0] Q 
);

   wire [7:0] D;

   generate
      genvar i;
      for (i = 0; i < 8; i = i + 1) begin: v
         if (i == 0)
	   MUX_4_to_1 mux_0(
			.in0(Q[0]), //00=ramane neschimbat
			.in1(Q[1]), //01=shiftare dreapta
			.in2(Din), //10=shiftare stanga, bitul 0 devine Din
			.in3(load_data[0]), //11 load
			.select(shift),
			.out(D[0])
	);
	 
	 else if(i == 7)
	   MUX_4_to_1 mux_7(
			.in0(Q[7]), //00=ramane neschimbat
			.in1(Din), //01=shiftare dreapta, bitul 7 devine Din
			.in2(Q[6]), //10=shiftare stanga
			.in3(load_data[7]), //11 load
			.select(shift),
			.out(D[7])
	);
	 
         else
           MUX_4_to_1 mux_i (
			.in0(Q[i]),
			.in1(Q[i+1]),
			.in2(Q[i-1]),
			.in3(load_data[i]), 
			.select(shift), 
			.out(D[i])
	);
	 if(i == 0)
           D_FF flip_flop_0 ( //incarca in Q ori Din, ori valoarea selectata de MUX
			.clk(clk), 
			.resetn(resetn), 
			.enable( shift[0] | shift[1] | load_Din ), 
			.D(load_Din ? Din : D[i]), //load_Din va fi pe 1 la division, cand trebuie sa punem Q[0]=~A[7]
			.Q(Q[i])  
		);
	 
	 else
	   D_FF flip_flop_i (
			.clk(clk), 
			.resetn(resetn), 
			.enable( shift[0] | shift[1] ), 
			.D(D[i]), 
			.Q(Q[i])  
		);
	 
      end
   endgenerate

endmodule