module Counter(
   input clk, resetn,
   input count_up,
   output [2:0] count
 );

   wire [2:0] c;

   T_FF t0(
         .clk(clk),
         .resetn(resetn),
         .T(count_up),
         .Q(c[0])
         );

   T_FF t1(
         .clk(clk),
         .resetn(resetn),
         .T(count_up & c[0]),
         .Q(c[1])
         );

   T_FF t2(
         .clk(clk),
         .resetn(resetn),
         .T(count_up & c[1] & c[0]),
         .Q(c[2])
         );

   assign count = c;


endmodule