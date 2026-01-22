module Modulo5_Sequence_Counter(
   input clk, reset, begin_sig, end_sig,
   output [4:0] cycle
);

    wire q;
    wire [2:0] count;

    SR_FF sr_ff (.s(begin_sig), .r(end_sig), .clk(clk), .q(q)); // daca begin_sig=1 porneste numararea (q=1), daca end_sig=1, opreste numararea (q=0)
    Modulo5_Counter counter (.clk(clk), .reset(reset), .count_up(q), .count(count)); //numara de la 0 la 4 cand q e activ, deci se trece in ciclul urmator
    Decoder_one_hot decoder (.count(count), .cycle(cycle)); // transforma valoarea contorului count intr-un semnal de iesire one-hot
// count=000 deci 0 => cycle=00001; count=010 deci 2 => cycle=00100 

endmodule