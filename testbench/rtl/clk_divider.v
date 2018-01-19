// 32 bit/16 unsigned integer non-restoring division
// 1 clock to input vectors
// 16 clocks to compute result
// 1 clock to signal output ready
// this is standard FSM design, all inputs/outputs are
// active all of the time

module clk_divider (clk, reset, dd, dv,irdy,qt,rm,ordy);

 input [31:0] dd;   //dividend
 input [15:0] dv;   //divisor
 input irdy;       //asserted
 input reset;
 input clk;
 output [15:0] qt;  //quotient
 output [15:0] rm;  //remainder
 output ordy;      //asserted when output is rdy

 wire [15:0] qt;  //quotient
 wire [15:0] rm;  //remainder


`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11


 reg [1:0] pstate, nstate;
 reg [31:0] ireg, ireg_nstate;
 reg [15:0] dvreg;

 reg [3:0] kreg;
 reg ordy,ordy_nstate;
 reg [15:0] diff;

 reg ld_kreg, dec_kreg, ld_ireg, ld_dvreg;

 assign rm = ireg[31:16];
 assign qt = ireg[15:0];

always @(posedge clk or negedge reset) begin

  if (reset == 0) begin
    pstate <= `s0;
    ordy <= 0;
    kreg <= 0;
    ireg <= 0;
    dvreg <= 0;
  end
  else begin
    ordy <=  ordy_nstate;
    pstate <= nstate;
    if (ld_kreg) kreg <= 15;
    else if (dec_kreg) kreg <= kreg - 1;
    if (ld_ireg) ireg <= ireg_nstate;
    if (ld_dvreg) dvreg <= dv;
  end

end

always @(*) begin

   ordy_nstate = 0;
   ld_kreg = 0;
   dec_kreg = 0;
   ld_ireg = 0;
   ireg_nstate = 0;
   ld_dvreg = 0;
   nstate = pstate;
   diff = 0;
   
   case (pstate)
    `s0: begin
           ld_kreg = 1;   //init counter to 15
	   ld_dvreg = 1;
           ld_ireg = 1;
           ireg_nstate = dd;
           if (irdy) nstate = `s1;
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
              ordy_nstate = 1;
           end
         end
    `s2: begin
          nstate = `s0;
         end
     default: nstate = `s0;
   endcase
  
 end // end always


endmodule 

