
module clkspec_ncr_mul8x8 (clk, reset, a, b, dout);

parameter WIDTH = 8;

`define s0 'b0
`define s1 'b1

input clk,reset;
input [WIDTH-1:0] a,b;
output [(2*WIDTH)-1:0] dout;

reg state_fsm1;
reg state_fsm2;

wire [WIDTH-1:0]  ain_y0,ain_y1;
wire [WIDTH-1:0] bin_y0,bin_y1;

reg  [WIDTH-1:0] ain_y0_q,ain_y1_q;
reg  [WIDTH-1:0] bin_y0_q,bin_y1_q;


wire [(2*WIDTH)-1:0] dout_y0,dout_y1;
reg [(2*WIDTH)-1:0] dout_y0_q,dout_y1_q;

wire [(2*WIDTH)-1:0] dout_y0_mrg,dout_y1_mrg;
wire [(2*WIDTH)-1:0] dout_d;
reg [(2*WIDTH)-1:0] dout;

//input demuxes
demux2_n #(.WIDTH(WIDTH))  demux_ain (.y1(ain_y1),.y0(ain_y0),.a(a),.s(state_fsm1));
demux2_n #(.WIDTH(WIDTH))  demux_bin (.y1(bin_y1),.y0(bin_y0),.a(b),.s(state_fsm1));

reg [WIDTH-1:0]  ain_y0_q0,bin_y0_q0;
reg [WIDTH-1:0]  ain_y0_q1,bin_y0_q1;


//three sets of latches for demux, y0 path, these latches are reset to null
//these three match the DFF in the other datapath that expands to three latches

 always @* begin
    if (clk == 1) begin
     ain_y0_q0 <= ain_y0;
     ain_y0_q1 <= ain_y0_q0;
     ain_y0_q <= ain_y0_q1;

     bin_y0_q0 <= bin_y0;
     bin_y0_q1 <= bin_y0_q0;
     bin_y0_q <= bin_y0_q1;
    end
  end

//DFF for demux, y1 path, this has have initial data, reset to data0

 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     ain_y1_q <= 0;
     bin_y1_q <= 0;
   end else begin
    ain_y1_q <= ain_y1;
    bin_y1_q <= bin_y1;
   end
 
 end



// NCR computation block
assign dout_y0 = ain_y0_q * bin_y0_q;
assign dout_y1 = ain_y1_q * bin_y1_q;

//output latch for y0 block
 always @* begin
   if (clk == 1) dout_y0_q <= dout_y0;
 end

//output latch for y1 block
 always @* begin
   if (clk == 1) dout_y1_q <= dout_y1;
 end

//demux block ack gates, note these are enabled opposite of the input demuxes

demux2_half1_noack_n #(.WIDTH(2*WIDTH)) half1_g0 (.y1(dout_y0_mrg),.s(state_fsm2),.a(dout_y0_q));
demux2_half0_noack_n #(.WIDTH(2*WIDTH)) half0_g0 (.y0(dout_y1_mrg),.s(state_fsm2),.a(dout_y1_q));

//final merge
merge2_n #(.WIDTH(2*WIDTH))  m1 (.y(dout_d),.a(dout_y0_mrg), .b(dout_y1_mrg));

//final latch
 always @* begin
    if (clk == 1) dout <= dout_d;
 end

//sequencers  for demuxes
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     state_fsm1 <= 0;
     state_fsm2 <= 0;
   end else begin
     state_fsm1 <= ~state_fsm1;
     state_fsm2 <= ~state_fsm2;
   end
 end

endmodule





