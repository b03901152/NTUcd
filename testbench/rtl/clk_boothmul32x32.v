
//unsigned booth multiplier with latch on output

`include "rtl/boothmul32x32.v"

module clk_boothmul32x32 (a,b,pq,clk);

input [31:0] a,b;
output [63:0] pq;
input clk;

reg [63:0] pq;
wire [63:0] p;

 mult32x32 mul (.a(a),.b(b),.p(p));

 always @* begin
  if (clk == 1) pq <= p;
 end 

endmodule


