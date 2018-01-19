
//simple latch pipeline that adds three numbers
module clk_pipeadd3 (clk,a,b,c,sum);
input clk;
input [15:0] a,b,c;
output [15:0] sum;

reg [15:0] sum;


wire [15:0] sum_ab;

 addripple_n #(.WIDTH(16)) sum0 (.s(sum_ab),.a(a),.b(b));

 //intermediate latch
 reg [15:0] c_lat;
 reg [15:0] sum_ab_lat;

 always @* begin
  if (clk==1) begin
    c_lat <= c;
    sum_ab_lat <= sum_ab;
  end
 end

wire [15:0] sum_abc;

 addripple_n #(.WIDTH(16)) sum1 (.s(sum_abc),.a(sum_ab_lat),.b(c_lat));

 //final stage
 always @* begin
  if (clk==1) begin
     sum <= sum_abc;
  end
 end

endmodule



  


