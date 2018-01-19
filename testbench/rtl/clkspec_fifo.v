
module clkspec_fifo (clk, reset, last,din, dout);
parameter WIDTH = 12;
parameter DEPTH = 8;


`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11


input clk,reset;
input last;
input [WIDTH-1:0] din;
output [WIDTH-1:0] dout;


wire [WIDTH-1:0] fifo_in, fifo_out;
wire [WIDTH-1:0] din_mx,din_y0;
wire [WIDTH-1:0] din_uc, fifo_uc;
wire [WIDTH-1:0] adder_a, adder_b, adder_y;

//fsm control
reg [1:0] op;
reg rd_fifo;
reg [1:0] nstate, pstate;
reg [2:0] cnt;  //modulo-8 counter
reg [WIDTH-1:0] dout;
reg rd_din;

wire [WIDTH-1:0] fifo_out_q;

reg [WIDTH-1:0] adder_a_q, adder_b_q, din_y0_q, fifo_in_mrg_q;
reg wr_dout;
wire  last_mrg;
wire [WIDTH-1:0] fifo_in_mrg;


readport_n #(.WIDTH(WIDTH)) rp0 (.clk(clk),.d(din),.q(din_mx),.rd(rd_din));
readport  rp1 (.clk(clk),.d(last),.q(last_mrg),.rd(rd_din));

demux3_n  #(.WIDTH(WIDTH)) demux_din (.y0(din_y0),.y1(adder_a),.y2(din_uc),.a(din_mx),.s(op));
merge3_n #(.WIDTH(WIDTH))  mrg (.y(fifo_in), .a(din_y0),.b(adder_y),.c(fifo_in_mrg));
fifo_n  #(.WIDTH(WIDTH),.DEPTH(DEPTH)) m0 (.clk(clk), .d(fifo_in), .q(fifo_out) );

assign adder_y = adder_a + adder_b;

readport_n #(.WIDTH(WIDTH)) rp2 (.clk(clk),.d(fifo_out),.q(fifo_out_q),.rd(rd_fifo));
demux3_n #(.WIDTH(WIDTH)) demux_fifo (.y0(fifo_uc),.y1(adder_b),.y2(fifo_in_mrg),.a(fifo_out_q),.s(op));
writeport_n #(.WIDTH(WIDTH)) wp0 (.d(fifo_out_q),.q(dout),.wr(wr_dout));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     pstate <= `s0;
     cnt <= 0;
   end else begin
     pstate <= nstate;
     cnt <= cnt + 1;
   end
 end

 always @(*) begin
   wr_dout = 0;
   rd_din = 0;
   rd_fifo = 0;
   op = 0;
   nstate = pstate;

   case (pstate)
    `s0: begin
        if (cnt==7) begin
             nstate = `s1;
          end
       end
    `s1: begin
        op = 0;
	rd_fifo=1;
	rd_din = 1;
        if (cnt==7) begin
             nstate = `s2;
          end
       end
    `s2: begin
	rd_fifo=1;
        rd_din = 1;
        op = 1;
        if (cnt == 7 && last_mrg == 1) begin
          nstate = `s3;
        end
       end
    `s3: begin
        op = 2;
	rd_fifo=1;
	wr_dout = 1;
        if (cnt==7) begin
         nstate = `s1;
        end 
       end
     default: nstate = `s0;
   endcase
 end // end always


endmodule





