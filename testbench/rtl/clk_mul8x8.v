
module clk_mul8x8 ( a, b, clk, y );
input [7:0] a,b;
input clk;
output [15:0] y;

reg [7:0] a_q,b_q;
reg [15:0] y;

wire [15:0] y_prod;

 //dlatches
 always @* begin
   if (clk == 1) begin
     a_q <= a;
     b_q <= b;
     y <= y_prod;
   end
 end //end always

assign y_prod = a_q * b_q;

endmodule
