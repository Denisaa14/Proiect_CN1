module ALU(

   input clk,
   input resetn,
   input [7:0] X, Y,
   input [7:0] A_divide,
   input [1:0] op,
   input BEGIN,

   output [15:0] OUT,
   output wire END,
   output [7:0] Q,
   output [7:0] A,
   output [2:0]  count,
   output q_1,
   output [7:0] m,
   output [7:0] sum_out,
   output [17:0] control
);
   
   wire	A_Din;
   wire	Q_1;
   wire	Q_Din;
   wire [7:0] sum;
   wire	cout;
   wire [2:0] count7;
   wire [17:0] c;
   wire [7:0] M;

   reg [1:0] shift_A;
   reg [1:0] shift_Q;
   reg sum_in;

   assign count = count7;
   assign q_1 = Q_1; 
   assign m = M;
   assign sum_out = sum;
   assign control = c;

   always @(*) begin
      sum_in = (c[2] | c[4] | c[12] | c[13]);
      
      shift_A = { c[0] | (c[11]) | sum_in | c[10], c[0] | c[6] | sum_in | c[10] };
      shift_Q = { c[0] | (c[11]), c[0] | c[6] };
   end
   

   MUX_4_to_1 A_Din_mux( //pentru shiftare, ce valoare va lua noul A[7] (daca e shiftare dreapta) sau A[0] (daca e shiftare stanga)
		       .in0(1'bx),
		       .in1(A[7]), 
		       .in2(Q[7]),
		       .in3(1'bx),
		       .select(shift_A), //pentru 01 shiftare dreapta / pentru 10 shiftare stanga
		       .out(A_Din)
		       );

   Register A_Register(
		  .clk(clk),
		  .resetn(resetn),
		  .load_data((c[0]) ? {8{1'b0}} : (c[10] ? A_divide : sum)),
		  .shift(shift_A),
		  .load_Din(1'b0),
		  .Din(A_Din),
		  .Q(A)
		  );

   D_FF Q_1_FlipFlop(
			  .clk(clk),
			  .resetn(resetn),
			  .enable(c[0] | c[6]),
			  .D(c[0] ? 1'b0 : Q[0]), 
			  .Q(Q_1)
			  );

   MUX_4_to_1 Q_Din_mux(
     		       .in0(1'bx),
		       .in1(A[0]),//01=shift dreapta
		       .in2(1'b0),//10=shift stanga
		       .in3(1'bx),
		       .select(shift_Q),
		       .out(Q_Din)
		       );

   reg load_S;

   always @(*) begin
      load_S = c[13] | c[14]; //pentru division
   end

   
   Register Q_Register(
		  .clk(clk),
		  .resetn(resetn),
		  .load_data(X),
		  .shift(shift_Q),
		  .load_Din(load_S),
		  .Din(load_S ? ~A[7] : Q_Din),
		  .Q(Q)
		  );

   Register M_Register(
		  .clk(clk),
		  .resetn(resetn),
		  .load_data(Y),
		  .shift({ c[0], c[0] }),
		  .load_Din(1'b0),
		  .Din(1'b0),
		  .Q(M)
		  );

   RippleCarryAdder RCA(
		      .a(c[2] ? Q : A),
		      .b(M),
		      .cin(c[3] | c[12] | c[5]),
		      .enable(c[2] | c[4] | c[12] | c[13]),
		      .cout(cout),
		      .sum(sum)
		      );



   Counter counter(
		   .clk(clk),
		   .resetn(resetn | c[0]),
		   .count_up(c[7]),
		   .count(count7)
		   );
   
   Control_Unit CU(
		   .clk(clk),
		   .reset(resetn),
		   .begin_sig(BEGIN),
		   .Q0(Q[0]),
		   .Q_1(Q_1),
		   .A7(A[7]),
		   .count7(count7[0] & count7[1] & count7[2]),
		   .op(op),
		   .c(c),
		   .end_sig(END)
		   );

   reg [7:0] OUT_1;
   reg [7:0] OUT_2;

   always @(*) begin
      OUT_1 = c[8] ? A : OUT_1;
      OUT_2 = c[9] | c[15] ? Q[7:0] : Q[7:0];
   end
   
   assign OUT = { OUT_1, OUT_2 };
endmodule 