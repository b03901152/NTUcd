//this version expects data to be sent with request

module clkspec_v2arbtst_2shared (y,r0,a0,b0,r1,a1,b1,clk,reset);

output [3:0] y;
input clk,reset;
input [3:0] a0,b0,a1,b1;
input r0,r1;

`define s0 'b0
`define s1 'b1

 wire arbout,arb_q;
 reg rd_din,wr_dout;


 wire [3:0] a_mrg,b_mrg;
 wire [3:0] a_q,b_q;
 wire [3:0] y_add;
 reg [3:0] y_q;
 reg nstate, pstate;
 wire s0,s1;

 arb2 g0 (.s0(s0),.s1(s1),.r0(r0),.r1(r1));
   
 arb2_muxmrg_n #(.WIDTH(4)) amm0 (.s0(s0),.s1(s1),.d0(a0),.d1(a1),.y(a_mrg));
 arb2_muxmrg_n #(.WIDTH(4)) amm1 (.s0(s0),.s1(s1),.d0(b0),.d1(b1),.y(b_mrg));

 //now have a readport for the a, b inputs
 readport_n #(.WIDTH(4)) rp1 (.clk(clk),.d(a_mrg),.q(a_q),.rd(rd_din));
 readport_n #(.WIDTH(4)) rp2 (.clk(clk),.d(b_mrg),.q(b_q),.rd(rd_din));

 //compute
 assign y_add = a_q + b_q;

 //write port for result
 writeport_n #(.WIDTH(4)) wp0 (.d(y_q),.q(y),.wr(wr_dout));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     pstate <= `s0;
     y_q <= 0;
   end else begin
     pstate <= nstate;
     if (rd_din) y_q <= y_add;
   end
 end


 always @(*) begin
   wr_dout = 0; rd_din = 0;
   nstate = pstate;

   case (pstate)
    `s0: begin rd_din=1; nstate = `s1;  end
    `s1: begin wr_dout = 1; nstate = `s0; end
     default: nstate = `s0;
   endcase
 end // end always

endmodule




