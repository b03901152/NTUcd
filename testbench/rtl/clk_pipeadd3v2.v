
//simple latch pipeline that adds three numbers
//these have registers at end so that latch optimization can push them.
module clk_pipeadd3v2 (clk,a,b,c,sum);
input clk;
input [15:0] a,b,c;
output [15:0] sum;

reg [15:0] sum;
wire [15:0] sum_ab;

 addripple_n #(.WIDTH(16)) sum0 (.s(sum_ab),.a(a),.b(b));

reg [15:0] c_lat;

 always @* begin
  if (clk==1) begin
    c_lat <= c;
  end
 end

wire [15:0] sum_abc;

 addripple_n #(.WIDTH(16)) sum1 (.s(sum_abc),.a(sum_ab),.b(c_lat));

reg [15:0] sump;
 //final stage
 always @* begin
  if (clk==1) begin
     sump <= sum_abc;
  end
 end


 //final stage
 always @* begin
  if (clk==1) begin
     sum <= sump;
  end
 end

endmodule



  


