module clkspec_v2arbtst_4shared (y,r0,a0,b0,r1,a1,b1,r2,a2,b2,r3,a3,b3,clk,reset);

output [3:0] y;
input clk,reset;
input [3:0] a0,b0,a1,b1,a2,b2,a3,b3;
input r0,r1,r2,r3;

`define s0 'b0
`define s1 'b1

 reg rd_din,wr_dout;


 wire [3:0] a_mrg,b_mrg;
 wire [3:0] a_q,b_q;
 wire [3:0] y_add;
 reg [3:0] y_q;
 reg  nstate, pstate;

 wire [3:0] a01_mrg,b01_mrg;
 wire [3:0] a23_mrg,b23_mrg;

 wire s0_01, s1_01;
 wire s0_23, s1_23;
 wire s0,s1;

 wire arbout0,arbout1;

 arb2 g0 (.r(arbout0),.s0(s0_01),.s1(s1_01),.r0(r0),.r1(r1));
 arb2_muxmrg_n #(.WIDTH(4)) amm0 (.s0(s0_01),.s1(s1_01),.d0(a0),.d1(a1),.y(a01_mrg));
 arb2_muxmrg_n #(.WIDTH(4)) amm1 (.s0(s0_01),.s1(s1_01),.d0(b0),.d1(b1),.y(b01_mrg));

 arb2 g1 (.r(arbout1),.s0(s0_23),.s1(s1_23),.r0(r2),.r1(r3));
 arb2_muxmrg_n #(.WIDTH(4)) amm2 (.s0(s0_23),.s1(s1_23),.d0(a2),.d1(a3),.y(a23_mrg));
 arb2_muxmrg_n #(.WIDTH(4)) amm3 (.s0(s0_23),.s1(s1_23),.d0(b2),.d1(b3),.y(b23_mrg));

 arb2 g2 (.s0(s0),.s1(s1),.r0(arbout0),.r1(arbout1));
 arb2_muxmrg_n #(.WIDTH(4)) amm4 (.s0(s0),.s1(s1),.d0(a01_mrg),.d1(a23_mrg),.y(a_mrg));
 arb2_muxmrg_n #(.WIDTH(4)) amm5 (.s0(s0),.s1(s1),.d0(b01_mrg),.d1(b23_mrg),.y(b_mrg));

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
   wr_dout = 0;
   rd_din = 0;
   nstate = pstate;

   case (pstate)
    `s0: begin rd_din=1; nstate = `s1;  end
    `s1: begin wr_dout = 1; nstate = `s0; end
     default: nstate = `s0;
   endcase
 end // end always

endmodule




