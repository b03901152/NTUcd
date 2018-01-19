
module clk_add32 (clk,a,b,sum);
input clk;
input [31:0] a,b;
output [31:0] sum;

reg [31:0] sum;
//put two sets of latches on the front to decouple the input

reg [31:0] a1_lat,a2_lat;
reg [31:0] b1_lat,b2_lat;

 always @* begin
  if (clk==1) begin
    a1_lat <= a;
    b1_lat <= b;
  end
 end

 always @* begin
  if (clk==1) begin
    a2_lat <= a1_lat;
    b2_lat <= b1_lat;
  end
 end

 wire [31:0] sum_d;
 assign  sum_d = a2_lat+b2_lat;

 always @* begin
  if (clk==1) begin
     sum <= sum_d;
  end
 end

endmodule



  


