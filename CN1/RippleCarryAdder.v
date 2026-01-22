module RippleCarryAdder(
   input [7:0] a, b,
   input cin,
   input enable,
   output cout,
   output [7:0] sum
);

   wire [7:0] bit_sum;
   wire	final_cout;
   wire [7:0] cout_aux;
   wire [7:0] b_xor; 

   assign b_xor= b ^ {8{cin}}; // daca cin=1 (deci daca trebuie scadere) se vor inversa toti bitii lui b, altfel raman la fel

   generate
      genvar i;
      for(i = 0; i < 8; i = i + 1) begin: v

         if(i == 0)
           FAC f1(.a(a[0]), .b(b_xor[0]), .cin(cin), .cout(cout_aux[0]), .sum(bit_sum[0]));
         else
           FAC f2(.a(a[i]), .b(b_xor[i]), .cin(cout_aux[i-1]), .cout(cout_aux[i]), .sum(bit_sum[i]));
      end
      
   endgenerate
   
   assign final_cout = cout_aux[7];
   assign sum = enable ? bit_sum : 8'b0;
   assign cout = enable ? final_cout : 1'b0;
   
endmodule