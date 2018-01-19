// 16 bit/16 bit unsigned integer non-restoring modulus
// 1 clock to input vectors
// 16 clocks to compute result
// 1 clock to signal output ready

// this is a data driven design. The input ports (dd/dv) accepts
// data, and then only accepts a new input once the output (rm)
// has been produced and consumed.  The output ports (rm) are
// only active when a result  is ready


module clkspec_mod16_16 (clk, reset, dd, dv,rm);


 input [15:0] dd;   //dividend
 input [15:0] dv;   //divisor
 input reset;
 input clk;
 output [15:0] rm;  //remainder

 wire [15:0] rm;  //remainder



`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11

 reg rd;
 reg wr;

 reg [1:0] pstate, nstate;
 reg [31:0] ireg, ireg_nstate;
 reg [15:0] dvreg;

 reg [15:0] dout;

 reg [3:0] kreg;

 reg [15:0] diff;
 reg ld_kreg, dec_kreg, ld_ireg, ld_dvreg;
 wire [15:0] ireg_d;
 wire [15:0] dv_d;


 assign rm = dout;


//dd datapath
//read port for dd
readport_n  #(.WIDTH(16)) rp_dd (.clk(clk),.d(dd),.q(ireg_d), .rd(rd));
//write port for dout
writeport_n  #(.WIDTH(16)) wp0 (.d(ireg[31:16]),.q(dout), .wr(wr));

//read port for dv
readport_n  #(.WIDTH(16)) rp_dv (.clk(clk),.d(dv),.q(dv_d), .rd(rd));

always @(posedge clk or negedge reset) begin
  if (reset == 0) begin
    pstate <= `s0;
    kreg <= 0;
    ireg <= 0;
    dvreg <= 0;
  end
  else begin
    pstate <= nstate;
    if (ld_kreg) kreg <= 15;
    else if (dec_kreg) kreg <= kreg - 1;
    if (ld_ireg) ireg <= ireg_nstate;
    if (ld_dvreg) dvreg <= dv_d;
  end
end


//fsm logic
always @(*) begin
   ld_kreg = 0;
   dec_kreg = 0;
   ld_ireg = 0;
   ireg_nstate = 0;
   ld_dvreg = 0;
   nstate = pstate;
   diff = 0;
   wr = 0;
   rd = 0;
   
   case (pstate)
    `s0: begin
	   rd = 1;
           ld_kreg = 1;   //init counter to 15
	   ld_dvreg = 1;
           ld_ireg = 1;
           ireg_nstate[31:16] = 0;
           ireg_nstate[15:0] = ireg_d;
           nstate = `s1;
          end
    `s1: begin
           dec_kreg = 1;
	   ld_ireg = 1;
           if (ireg[31] || (ireg[30:15] >= dvreg)) begin
              diff = ireg[30:15] - dvreg;
	      ireg_nstate = {diff,ireg[14:0],1'b1};
           end else begin
            ireg_nstate = {ireg[30:0],1'b0};
           end     
	   if (kreg == 0) begin
	      nstate = `s2;
           end
         end
    `s2: begin
	  wr = 1;
          nstate = `s0;
         end
     default: nstate = `s0;
   endcase
  
 end // end always


endmodule 

