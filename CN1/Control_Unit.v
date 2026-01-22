module Control_Unit(

   input clk, reset, begin_sig, A7, Q0, Q_1, count7,
   input [1:0] op,
   output reg end_sig,
   output [17:0] c
);

   wire [4:0]cycle;
   wire	cyk0, cyk1, cyk2, cyk3, cyk4;
   assign cyk0 = cycle[0];
   assign cyk1 = cycle[1];
   assign cyk2 = cycle[2];
   assign cyk3 = cycle[3];
   assign cyk4 = cycle[4];

   wire stg0, stg1_8, stg9; //stages
   wire	reset_stage_0, reset_stage_1_8; 
   assign reset_stage_0 = cyk4 & stg0; //suntem in stage0 si se ajunge in ciclul 4=> se da reset la stage 0 (reset se pune pe 1)
   assign reset_stage_1_8 = (stg1_8 & count7 & cyk4) | ((~op[1]) & cyk4); 
//suntem in stage 1-8 si count7 este 1 si suntem in ciclul 4 SAU avem op de adunare/scadere si suntem in ciclul 4 => se da reset la stage 1-8

   Modulo5_Sequence_Counter sc(.clk(clk), .reset(reset), .begin_sig(begin_sig), .end_sig(end_sig), .cycle(cycle));

//in cycle vom primi ciclul activ codificat de genul 00100, asadar cyk2 va fi activ, iar restul inactive si tot asa pana se trece prin toate
//si primeste semnalul de eng_sig pentru a opri numaratoarea din sequence counter

   SR_FF stage_0 (.s(begin_sig), .r(reset_stage_0), .clk(clk), .q(stg0)); //stg0=1 cand primim begin signal
   SR_FF stage_1_8 (.s(reset_stage_0), .r(reset_stage_1_8), .clk(clk), .q(stg1_8)); //daca s-a trecut prin stage0 (<=> reset stage0 e activ), stg1_8=1
   SR_FF stage_9 (.s(reset_stage_1_8), .r(end_sig), .clk(clk), .q(stg9)); //daca s-a trecut prin stage 1-8 (reset stage1-8 e activ), stg9=1

   assign c[0] = stg0 & cyk0;
   assign c[1] = stg0 & cyk1;
   assign c[2] = stg0 & cyk2 & (~op[1]);	// se activeaza la addition, subtraction
   assign c[3] = stg0 & cyk2 & (~op[1] & op[0]);	// subtraction
   assign c[10] = stg0 & cyk2 & (op[1] & op[0]);	// division
   assign c[11] = (stg0 | stg1_8) & cyk3 & (op[1] & op[0]);	// division
   assign c[4] = (stg1_8 | stg9) & cyk0 & (~Q0 & Q_1 | Q0 & ~Q_1) & (op[1] & ~op[0]);	// 01 sau 10 la multiplication
   assign c[5] = (stg1_8 | stg9) & cyk0 & (Q0 & ~Q_1) & (op[1] & ~op[0]);	// 10 la multiplication
   assign c[12] = stg1_8 & cyk0 & (op[1] & op[0]);	// division
   assign c[13] = stg1_8 & cyk1 & A7 & (op[1] & op[0]);	// division
   assign c[14] = stg1_8 & cyk1 & ~A7 & (op[1] & op[0]);	// division
   assign c[7] = stg1_8 & cyk2 & ~count7;	// division, multiplication
   assign c[8] = stg9 & ( (cyk2 & op[1] & ~op[0]) | (cyk0 & ~(op[1] & ~op[0])) ); //load
   assign c[9] = stg9 & ( (cyk2 & op[1] & ~op[0]) | (cyk1 & ~op[1]) ); //load
   assign c[15] = stg9 & cyk1 & (op[1] & op[0]); //load la division
   assign c[6] = ( stg1_8 & cyk1 & (op[1] & ~op[0]) ) | ( stg9 & cyk1 & count7 & (op[1] & ~op[0]));	// multiplication

   always @(posedge clk) begin
      if (!reset)
        end_sig <= 1'b0;
      else
        end_sig <= c[9] | c[15];
   end

endmodule 