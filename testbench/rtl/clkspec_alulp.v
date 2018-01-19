

module clkspec_alulp (a,b,op,clk,reset,y);
input [15:0] a,b;
input [1:0] op;
input clk,reset;
output [31:0] y;

reg [31:0] y;
reg [31:0] y_d;
reg [15:0] a_q, b_q;
reg [1:0] op_q;

wire [15:0] y_sum,y_and,y_or;
wire [31:0] y_prod;



wire [15:0] a_y0,a_y1,a_y2,a_y3;
wire [15:0] b_y0,b_y1,b_y2,b_y3;

`define op_mul 'b00
`define op_add 'b01
`define op_and 'b10
`define op_or  'b11

 //input dffs
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     a_q <= 0;
     b_q <= 0;
     op_q <= 0;
   end else begin
     a_q <= a;
     b_q <= b;
     op_q <= op;
   end
 end //end always

 //demux 

 demux4_n #(.WIDTH(16)) demux_a (.y0(a_y0),.y1(a_y1),.y2(a_y2),.y3(a_y3),.a(a_q),.s(op_q));
 demux4_n #(.WIDTH(16)) demux_b (.y0(b_y0),.y1(b_y1),.y2(b_y2),.y3(b_y3),.a(b_q),.s(op_q));

assign y_prod = a_y0 * b_y0;
assign y_sum = a_y1 + b_y1;
assign y_and = a_y2 & b_y2;
assign y_or = a_y3 | b_y3;

 //merge blocks
 merge4_n  #(.WIDTH(16)) m1 (.y(y_d[15:0]),.a(y_prod[15:0]),.b(y_sum),.c(y_and),.d(y_or));
 merge4_n  #(.WIDTH(16)) m2 (.y(y_d[31:16]),.a(y_prod[31:16]),.b(y_sum),.c(y_and),.d(y_or));

 //output dffs
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     y <= 0;
   end else begin
     y <= y_d;
   end
 end //end always


endmodule
