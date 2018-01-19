module clkspec_arbtst_4shared (y,r0,a0,b0,r1,a1,b1,r2,a2,b2,r3,a3,b3,clk,reset);

output [3:0] y;
input clk,reset;
input [3:0] a0,b0,a1,b1,a2,b2,a3,b3;
input r0,r1,r2,r3;

`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11


 wire arbout,arb_q;
 reg rd_arb,rd_din,wr_dout;


 wire [3:0] a_mrg,b_mrg;
 wire [3:0] a_q,b_q;
 wire [3:0] y_add;
 reg [3:0] y_q;
 reg [1:0] nstate, pstate;

 wire arbout0,arbout1;

 arb2 g0 (.r(arbout0),.r0(r0),.r1(r1));
 arb2 g1 (.r(arbout1),.r0(r2),.r1(r3));
 arb2 g2 (.r(arbout),.r0(arbout0),.r1(arbout1));
 readport rp0 (.clk(clk),.d(arbout),.q(arb_q),.rd(rd_arb));

 //merge the data inputs
 merge4_n #(.WIDTH(4)) ma (.y(a_mrg),.a(a0),.b(a1),.c(a2),.d(a3));
 merge4_n #(.WIDTH(4)) mb (.y(b_mrg),.a(b0),.b(b1),.c(b2),.d(b3));

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
   rd_arb = 0;
   nstate = pstate;

   case (pstate)
    `s0: begin 
          rd_arb = 1; 
	  //have to use arb_q in logic so that it has a destination.
          if (arb_q) nstate = `s1;   
         end
    `s1: begin rd_din = 1; nstate = `s2; end
    `s2: begin wr_dout = 1; nstate = `s0; end
     default: nstate = `s0;
   endcase
 end // end always

endmodule




