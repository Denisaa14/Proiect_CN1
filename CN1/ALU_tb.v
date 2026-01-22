`timescale 1ns/1ps

module ALU_tb;
   reg clk, resetn;
   reg [7:0] X, Y, A_divide;
   reg signed [7:0] X_signed, Y_signed;
   reg [1:0] op;
   reg BEGIN;
   
   wire [15:0] OUT;
   wire END;   
   wire [7:0] Q;
   wire [7:0] A;
   wire [2:0] count;
   wire	q_1;
   wire [7:0] m;
   wire [7:0] sum_out;
   wire [17:0] c;
   
   ALU DUT (
	    .clk(clk), 
	    .resetn(resetn), 
	    .X(X), 
	    .Y(Y),
     	    .A_divide(A_divide),
	    .op(op),
	    .BEGIN(BEGIN),
	    .OUT(OUT),
	    .END(END),
	    .A(A),
	    .Q(Q),
	    .count(count),
	    .q_1(q_1),
	    .m(m),
	    .sum_out(sum_out),
     	    .control(c)
	    );

   always #5 clk = ~clk;

   always @(*) begin
      X_signed = X;
      Y_signed = Y;
   end

   initial begin
      $dumpfile("ALU_tb.vcd");
      $dumpvars(0, ALU_tb);

      // 31000 : 123 = 252 R 4
      //A_divide = 8'b01111001;

      // 4876 : 71 = 68 R 38
      A_divide = 8'b00010011;
   
      clk = 0;
      resetn = 0;
      #10 
      resetn = 1;
      BEGIN = 1;
      #10 
      BEGIN = 0;


      // 67 +- 16
      //X = 8'b01000011; //for add/sub
      //Y = 8'b00010000; //for add/sub

      // 85 +- 23
      X = 8'b01010101; //for add/sub
      Y = 8'b00010111; //for add/sub
      
      // 53 * 19 = 1007
      //X = 8'b00110101; //for multiplication
      //Y = 8'b00010011; //for multiplication

      // (-100) * (-3) = 300
      //X = 8'b10011100; //for multiplication
      //Y = 8'b11111101; //for multiplication

      // 31000 : 123 = 252 R 4
      //X = 8'b00011000; //for division
      //Y = 8'b01111011; //for division

      // 4876 : 71 = 68 R 48
      //X = 8'b00001100; //for division
      //Y = 8'b01000111; //for division
      
      //operation selection
      //op = 2'b00; // ADD
      op = 2'b01; // SUB
      //op = 2'b10; // MUL
      //op = 2'b11; // DIV

      #1000;
      $finish;
   end

   reg [150:1] c_bits_str; 

   task build_c_bits_str;
      input [17:0] c;
      output [150:1] str;
      integer	     i, k;
      reg [8*5:1]    temp; 
      begin
         str = "";
         for (i = 0; i <= 17; i = i + 1) begin
            if (c[i]) begin
               $sformat(temp, "c%0d ", i);
               for (k = 8*5; k >= 1; k = k - 8) begin
		  str = {str, temp[k -: 8]};
	       end
            end
         end
      end
   endtask 

   always @(*) begin
      build_c_bits_str(c, c_bits_str);
   end

   initial begin
	#50
	if(op == 2'b10) begin
      		$monitor("COUNT=%b | A=%b %b | Q=%b %b | Q[-1]=%b | M=%b %b | C_ACTIVE=%s",
		count, A[7 : 4], A[3 : 0], Q[7 : 4], Q[3 : 0], q_1, m[7 : 4], m[3 : 0], c_bits_str);
	end
	else begin
		$monitor("COUNT=%b | A=%b %b | Q=%b %b | M=%b %b | C_ACTIVE=%s",
		count, A[7 : 4], A[3 : 0], Q[7 : 4], Q[3 : 0], m[7 : 4], m[3 : 0], c_bits_str);
	end
   end
   
   always @(count) begin
      $display("\n"); 
   end

   always @(posedge clk) begin
      @(posedge END);
      
      if(op == 2'b11) begin       
	 $display("\n\n\033[1;32m\n\nX = \t%d (%b) \t Y = \t%d (%b %b) \t | REST = \t%d (%b %b) \t QUOTIENT = \t%d (%b %b)\033[0m", 
		  {A_divide, X}, {A_divide, X}, Y, Y[7:4], Y[3:0], OUT[15:8], OUT[15:12], OUT[11:8], OUT[7:0], OUT[7:4], OUT[3:0]);
	 $display("\n\n\033[1;31m>>> END signal activated at T=%0t. Simulation ends.\033[0m", $time);
      end
      else begin
      if(op== 2'b10) begin
	$display("\n\n\033[1;32m\n\nX = \t%d (%b %b) \t Y = \t%d (%b %b) \t | OUT = \t%d (%b)\033[0m", 
		  X_signed, X[7:4], X[3:0], Y_signed, Y[7:4], Y[3:0], OUT, OUT);
	 $display("\n\n\033[1;31m>>> END signal activated at T=%0t. Simulation ends.\033[0m", $time);
      end
	else begin 
	 $display("\n\n\033[1;32m\n\nX = \t%d (%b %b) \t Y = \t%d (%b %b) \t | OUT_A = \t%d (%b %b) \t \033[0m", 
		  X_signed, X[7:4], X[3:0], Y_signed, Y[7:4], Y[3:0], OUT[15:8], OUT[15:12], OUT[11:8]);
	 $display("\n\n\033[1;31m>>> END signal activated at T=%0t. Simulation ends.\033[0m", $time);
      end
      end
      $finish;
   end

endmodule