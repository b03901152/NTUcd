/*
Single precision floating point clipper fsmd --
clips SP-FP input data to between two bounds (low/high)
that are contained internal registers.  

The FSM has four states:

 S0 - reset state,load the low bound register
 S1 - load the high bound register

 S2, S3 - normal operation mode, requires two
clocks to input a value and clip it. The 'finished'
output is asserted when done, the 'in_bounds' output
is asserted if the data input was in-bounds.

*/

module clk_fboundsp_1blk(clk,reset,din,init,start,dout,in_bounds,finished);

input clk,reset;
input   [31:0] din;
input init,start;
output  [31:0] dout;
output in_bounds, finished;


`define s0 'b00
`define s1 'b01
`define s2 'b10
`define s3 'b11

reg in_bounds, finished;
reg   [31:0] dout;

reg bnd_sel;
reg  [31:0] high_bnd_reg;
reg  [31:0] low_bnd_reg;
reg  [1:0] state_reg;
wire  [31:0] b;
wire  [31:0] a;
reg  [31:0] a_reg;
reg  a_lt_b;

wire  [7:0] b_exp;
wire  [7:0] a_exp;
wire  [22:0] b_man;
wire  [22:0] a_man;
wire  sign_lt;
wire  sign_eq;
reg  exp_lt;
reg  exp_gt;
reg  exp_eq;
reg  man_lt;
reg  man_gt;

//dpath
//                         ==1            ==0
assign  b = bnd_sel ? high_bnd_reg : low_bnd_reg;

assign  a = a_reg;

assign  b_exp = b[30:23];
assign  b_man = b[22:0];

assign  a_exp = a[30:23];
assign  a_man = a[22:0];

assign  sign_lt = (a[31] & ~b[31]);
assign  sign_eq = ~(a[31]^b[31]);

//assign  exp_lt = (a_exp < b_exp)? 1 : 0;
always @(a_exp or b_exp) begin
  exp_lt = 0;
  if (a_exp < b_exp) exp_lt = 1;
end

//assign  exp_gt = (b_exp < a_exp)? 1 : 0;
always @(a_exp or b_exp) begin
  exp_gt = 0;
  if (b_exp < a_exp) exp_gt = 1;
end

//assign  exp_eq = (a_exp == b_exp)? 1 : 0;
always @(a_exp or b_exp) begin
  exp_eq = 0;
  if (a_exp == b_exp) exp_eq = 1;
end

//  man_lt <=  '1' when (a_man < b_man) else '0';

always @(a_man or b_man) begin
  man_lt = 0;
  if (a_man < b_man) man_lt = 1;
end

//  man_gt <=  '1' when (b_man < a_man) else '0';
always @(a_man or b_man) begin
  man_gt = 0;
  if (b_man < a_man) man_gt = 1;
end



always @(sign_lt or sign_eq or exp_lt or exp_gt or exp_eq or man_lt or man_gt or a[31])
begin
  a_lt_b = 0;
  if (sign_lt == 1) begin
   a_lt_b = 1;
  end
  else if (sign_eq == 1  &&
           ( ((a[31] == 0) && exp_lt == 1) ||
               ((a[31] == 1) && exp_gt == 1))) begin
        a_lt_b = 1; 
      end
   else if (sign_eq == 1 && exp_eq == 1 &&
             (((a[31] == 0) && (man_lt == 1)) ||
              ((a[31] == 1) && (man_gt == 1))) ) begin
        a_lt_b = 1;   
      end       
end

//ctrl

//all outputs are on dffs

always @(posedge clk or negedge reset) begin

  if (reset == 0) begin
     state_reg <= 0;
     low_bnd_reg <= 0;
     high_bnd_reg <= 0;
     finished <= 1;
     in_bounds <= 0 ;
     bnd_sel <= 0;
     dout <= 0;
     a_reg <= 0;
  end
  else begin
  //state machine
    case (state_reg) 
      `s0: begin
            bnd_sel <= 0;
            if (init == 1) begin
              state_reg <= `s1;
              low_bnd_reg <= din;
            end
            if (start == 1) begin
             finished <= 0;
             in_bounds <= 0;
             a_reg <= din;
             state_reg <= `s2;
            end
          end
      `s1: begin
            high_bnd_reg <= din;
	    state_reg <= `s0;
           end
      `s2: begin
             bnd_sel <= 1;
             if (a_lt_b == 1) begin
               finished <= 1;
               dout <= b;
               state_reg <= `s0;
             end
             else begin
               state_reg <= `s3;
             end
           end
      `s3: begin
            finished <= 1;
            state_reg <= `s0;
            if (a_lt_b == 1) begin
             in_bounds <= 1;
             dout <= din;
            end
            else begin
              dout <= b;
            end
           end
      default: state_reg <= `s0;
    endcase
  
  end
  
end //end always




endmodule
