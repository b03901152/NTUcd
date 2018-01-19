
//two clients, one shared resource, all in one file.
//Requires use of the fork2 component in addition to the
// arb2/arb2_muxmrg components

module clkspec_forktst(clk,reset, c0_yout, c0_ain, c0_bin, c1_yout, c1_ain, c1_bin);

input clk,reset;
input [3:0]  c0_bin,c0_ain;
input [3:0]  c1_bin,c1_ain;
output [3:0] c0_yout;
output [3:0] c1_yout;


`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11

`define sh_s0 'b0
`define sh_s1 'b1


 reg [3:0] c0_yin;  //from fork component
 reg [1:0] c0_nstate, c0_pstate;

 reg c0_req_d;
 reg c0_wr_sub,c0_rd_sub;
 reg c0_rd_din,c0_wr_dout;

 wire [3:0] c0_a_q,c0_b_q, c0_yin_q;
 reg [3:0] c0_areg,c0_breg;
 wire [3:0] c0_aout,c0_bout;
 wire c0_req; 

 //a readport for the a, b inputs
 readport_n #(.WIDTH(4)) c0_rp0 (.clk(clk),.d(c0_ain),.q(c0_a_q),.rd(c0_rd_din));
 readport_n #(.WIDTH(4)) c0_rp1 (.clk(clk),.d(c0_bin),.q(c0_b_q),.rd(c0_rd_din));

 //writeport for result returned by shared resource to 
 writeport_n #(.WIDTH(4)) c0_wp3 (.d(c0_areg),.q(c0_yout),.wr(c0_wr_dout));

 //write port for arbiter request
 writeport  c0_wp0 (.d(c0_req_d),.q(c0_req),.wr(c0_wr_sub));

 //write port to shared port
 writeport_n #(.WIDTH(4)) c0_wp1 (.d(c0_areg),.q(c0_aout),.wr(c0_wr_sub));
 writeport_n #(.WIDTH(4)) c0_wp2 (.d(c0_breg),.q(c0_bout),.wr(c0_wr_sub));

 //readport for result from shared resource
 readport_n #(.WIDTH(4)) c0_rp2 (.clk(clk),.d(c0_yin),.q(c0_yin_q),.rd(c0_rd_sub));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     c0_pstate <= `s0;
     c0_areg <= 0;
     c0_breg <= 0;
   end else begin
     c0_pstate <= c0_nstate;
     if (c0_rd_din) begin  //get inputs
       c0_areg <= c0_a_q;
       c0_breg <= c0_b_q;
     end
     if (c0_rd_sub) begin
       c0_areg <= c0_yin_q; //overwrite areg with the result from shared resource
     end
   end
 end

 always @(*) begin

  c0_req_d = 0;
  c0_wr_sub = 0;c0_rd_sub = 0;
  c0_rd_din =0; c0_wr_dout = 0;
  c0_nstate = c0_pstate;

   case (c0_pstate)
    `s0: begin    // get inputs
          c0_rd_din = 1; 
	  c0_nstate = `s1;  
         end
    `s1: begin c0_wr_sub = 1; c0_req_d = 1; c0_nstate = `s2; end    //write values to shared resource
    `s2: begin c0_rd_sub = 1; c0_nstate = `s3; end    //get result
    `s3: begin c0_wr_dout = 1; c0_nstate = `s0; end    //pass result back
     default: c0_nstate = `s0;
   endcase
 end // end always


 reg [3:0] c1_yin;  //from fork component

 reg [1:0] c1_nstate, c1_pstate;

 reg c1_req_d;
 reg c1_wr_sub,c1_rd_sub;
 reg c1_rd_din,c1_wr_dout;

 wire [3:0] c1_a_q,c1_b_q, c1_yin_q;
 reg [3:0] c1_areg,c1_breg;
 wire [3:0] c1_aout,c1_bout;
 wire c1_req;

 //a readport for the a, b inputs
 readport_n #(.WIDTH(4)) c1_rp0 (.clk(clk),.d(c1_ain),.q(c1_a_q),.rd(c1_rd_din));
 readport_n #(.WIDTH(4)) c1_rp1 (.clk(clk),.d(c1_bin),.q(c1_b_q),.rd(c1_rd_din));

 //writeport for result returned by shared resource to 
 writeport_n #(.WIDTH(4)) c1_wp3 (.d(c1_areg),.q(c1_yout),.wr(c1_wr_dout));

 //write port for arbiter request
 writeport  c1_wp0 (.d(c1_req_d),.q(c1_req),.wr(c1_wr_sub));

 //write port to shared port
 writeport_n #(.WIDTH(4)) c1_wp1 (.d(c1_areg),.q(c1_aout),.wr(c1_wr_sub));
 writeport_n #(.WIDTH(4)) c1_wp2 (.d(c1_breg),.q(c1_bout),.wr(c1_wr_sub));

 //readport for result from shared resource
 readport_n #(.WIDTH(4)) c1_rp2 (.clk(clk),.d(c1_yin),.q(c1_yin_q),.rd(c1_rd_sub));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     c1_pstate <= `s0;
     c1_areg <= 0;
     c1_breg <= 0;
   end else begin
     c1_pstate <= c1_nstate;
     if (c1_rd_din) begin  //get inputs
       c1_areg <= c1_a_q;
       c1_breg <= c1_b_q;
     end
     if (c1_rd_sub) begin
       c1_areg <= c1_yin_q; //overwrite areg with the result from shared resource
     end
   end
 end

 always @(*) begin

  c1_req_d = 0;
  c1_wr_sub = 0;c1_rd_sub = 0;
  c1_rd_din =0; c1_wr_dout = 0;
  c1_nstate = c1_pstate;

   case (c1_pstate)
    `s0: begin    // get inputs
          c1_rd_din = 1; 
	  c1_nstate = `s1;  
         end
    `s1: begin c1_wr_sub = 1; c1_req_d = 1; c1_nstate = `s2; end    //write values to shared resource
    `s2: begin c1_rd_sub = 1; c1_nstate = `s3; end    //get result
    `s3: begin c1_wr_dout = 1; c1_nstate = `s0; end    //pass result back
     default: c1_nstate = `s0;
   endcase
 end // end always


//shared resource

 reg [3:0] yin;  //shared resource bus

 wire sh_arbout,sh_arb_q;
 reg sh_rd_din,sh_wr_dout;


 wire [3:0] sh_a_mrg,sh_b_mrg;
 wire [3:0] sh_a_q,sh_b_q;
 wire [3:0] sh_y_add;
 reg [3:0] sh_y_q;
 reg sh_nstate, sh_pstate;
 wire sh_s0,sh_s1;

 //fork this bus out to client0, client1
 //this will cause the acks  from the y0/y1 destinations to be low-true or'ed as required
 arb_fork2_n #(.WIDTH(4)) g1 (.y0(c0_yin),.y1(c1_yin),.a(yin));

 arb2 g0 (.s0(sh_s0),.s1(sh_s1),.r0(c0_req),.r1(c1_req));
   
 arb2_muxmrg_n #(.WIDTH(4)) amm0 (.s0(sh_s0),.s1(sh_s1),.d0(c0_aout),.d1(c1_aout),.y(sh_a_mrg));
 arb2_muxmrg_n #(.WIDTH(4)) amm1 (.s0(sh_s0),.s1(sh_s1),.d0(c0_bout),.d1(c1_bout),.y(sh_b_mrg));

 //now have a readport for the a, b inputs
 readport_n #(.WIDTH(4)) sh_rp1 (.clk(clk),.d(sh_a_mrg),.q(sh_a_q),.rd(sh_rd_din));
 readport_n #(.WIDTH(4)) sh_rp2 (.clk(clk),.d(sh_b_mrg),.q(sh_b_q),.rd(sh_rd_din));

 //compute
 assign sh_y_add = sh_a_q + sh_b_q;

 //write port for result
 writeport_n #(.WIDTH(4)) sh_wp0 (.d(sh_y_q),.q(yin),.wr(sh_wr_dout));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     sh_pstate <= `sh_s0;
     sh_y_q <= 0;
   end else begin
     sh_pstate <= sh_nstate;
     if (sh_rd_din) sh_y_q <= sh_y_add;
   end
 end

 always @(*) begin
   sh_wr_dout = 0; sh_rd_din = 0;
   sh_nstate = sh_pstate;

   case (sh_pstate)
    `s0: begin sh_rd_din=1; sh_nstate = `sh_s1;  end
    `s1: begin sh_wr_dout = 1; sh_nstate = `sh_s0; end
     default: sh_nstate = `sh_s0;
   endcase
 end // end always

endmodule

