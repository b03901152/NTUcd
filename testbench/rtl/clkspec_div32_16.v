// 32 bit/16 unsigned integer non-restoring division
// 1 clock to input vectors
// 16 clocks to compute result
// 1 clock to signal output ready

// this is a data driven design. The input ports (dd/dv) accepts
// data, and then only accepts a new input once the output (qt,rm)
// has been produced and consumed.  The output ports (qt, rm) are
// only active when a result  is ready


module clkspec_div32_16 (clk, reset, dd, dv,qt,rm);

 input [31:0] dd;   //dividend
 input [15:0] dv;   //divisor
 input reset;
 input clk;
 output [15:0] qt;  //quotient
 output [15:0] rm;  //remainder

 wire [15:0] qt;  //quotient
 wire [15:0] rm;  //remainder



`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11

 reg rd;
 reg wr;



 reg [1:0] pstate, nstate;
 reg [31:0] ireg, ireg_nstate, dd_q, dout;
 reg [15:0] dvreg;

 reg [3:0] kreg;
 reg [16:0] diff;

 reg ld_kreg, dec_kreg, ld_ireg, ld_dvreg;

 reg cbit,cbit_nstate;
 wire [31:0] ireg_d;
 wire [15:0] dv_d;

 assign rm = dout[31:16];
 assign qt = dout[15:0];

//dd datapath
//read port for dd
readport_n  #(.WIDTH(32)) rp_dd (.clk(clk),.d(dd),.q(ireg_d), .rd(rd));
//write port for dout
writeport_n  #(.WIDTH(32)) wp0 (.d(ireg),.q(dout), .wr(wr));


//dv datapath
//read port for dv
readport_n  #(.WIDTH(16)) rp_dv (.clk(clk),.d(dv),.q(dv_d), .rd(rd));


always @(posedge clk or negedge reset) begin
  if (reset == 0) begin
    pstate <= `s0;
    kreg <= 0;
    ireg <= 0;
    dvreg <= 0;
    cbit <= 0;
  end
  else begin
    pstate <= nstate;
    if (ld_kreg) kreg <= 15;
    else if (dec_kreg) kreg <= kreg - 1;
    if (ld_ireg) begin
        ireg <= ireg_nstate;
	cbit <= cbit_nstate;
    end
    if (ld_dvreg) dvreg <= dv_d;
  end
end
 


//fsm logic
always @(*) begin
   ld_kreg = 0;
   dec_kreg = 0;
   ld_ireg = 0;
   ireg_nstate = ireg;
   ld_dvreg = 0;
   nstate = pstate;
   diff = 0;
   wr = 0;
   rd = 0;
   cbit_nstate = cbit;
   
   case (pstate)
    `s0: begin
           rd = 1;
           ld_kreg = 1;   //init counter to 15
	   ld_dvreg = 1;
           ld_ireg = 1;
           ireg_nstate = ireg_d;
	   cbit_nstate = 0;
           nstate = `s1;
          end
    `s1: begin
           dec_kreg = 1;
	   ld_ireg = 1;
           if (~cbit)  diff = ireg[31:15] - {1'b0,dvreg};
	    else diff = ireg[31:15] + {1'b0,dvreg};
	   ireg_nstate = {diff[15:0],ireg[14:0],~diff[16]};
	   cbit_nstate = diff[16];
	   if (kreg == 0) begin
	      nstate = `s2;
           end
         end
    `s2: begin
          //post correct remainder if necessary
          ld_ireg = 1;
          if (cbit) begin
            diff = {1'b0,ireg[31:16]} + {1'b0,dvreg};
	    ireg_nstate = {diff[15:0],ireg[15:0]};
	  end
	  nstate = `s3;
	 end
    `s3: begin
	  wr = 1;
          nstate = `s0;
         end
     default: nstate = `s0;
   endcase
 end // end always


endmodule 

