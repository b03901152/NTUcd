//sends data with request

module clkspec_v2arbtst_client (yout, req, ain,bin, aout,bout,yin, clk, reset);

output [3:0] yout,aout,bout;
input [3:0] yin,bin,ain;
output req;
input clk,reset;

`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11
 reg [1:0] nstate, pstate;

 reg req_d;
 reg wr_sub,rd_sub;
 reg rd_din,wr_dout;

 wire [3:0] a_q,b_q, yin_q;
 reg [3:0] areg,breg;

 //a readport for the a, b inputs
 readport_n #(.WIDTH(4)) rp0 (.clk(clk),.d(ain),.q(a_q),.rd(rd_din));
 readport_n #(.WIDTH(4)) rp1 (.clk(clk),.d(bin),.q(b_q),.rd(rd_din));

 //writeport for result returned by shared resource to 
 writeport_n #(.WIDTH(4)) wp3 (.d(areg),.q(yout),.wr(wr_dout));

 //write port for arbiter request
 writeport  wp0 (.d(req_d),.q(req),.wr(wr_sub));

 //write port to shared port
 writeport_n #(.WIDTH(4)) wp1 (.d(areg),.q(aout),.wr(wr_sub));
 writeport_n #(.WIDTH(4)) wp2 (.d(breg),.q(bout),.wr(wr_sub));

 //readport for result from shared resource
 readport_n #(.WIDTH(4)) rp2 (.clk(clk),.d(yin),.q(yin_q),.rd(rd_sub));

//state
 always @(negedge reset or posedge clk) begin
   if (reset == 0) begin
     pstate <= `s0;
     areg <= 0;
     breg <= 0;
   end else begin
     pstate <= nstate;
     if (rd_din) begin  //get inputs
       areg <= a_q;
       breg <= b_q;
     end
     if (rd_sub) begin
       areg <= yin_q; //overwrite areg with the result from shared resource
     end
   end
 end


 always @(*) begin

  req_d = 0;
  wr_sub = 0;rd_sub = 0;
  rd_din =0; wr_dout = 0;
  nstate = pstate;

   case (pstate)
    `s0: begin    // get inputs
          rd_din = 1; 
	  nstate = `s1;  
         end
    `s1: begin wr_sub = 1; req_d = 1; nstate = `s2; end    //write values to shared resource
    `s2: begin rd_sub = 1; nstate = `s3; end    //get result
    `s3: begin wr_dout = 1; nstate = `s0; end    //pass result back
     default: nstate = `s0;
   endcase
 end // end always

endmodule




