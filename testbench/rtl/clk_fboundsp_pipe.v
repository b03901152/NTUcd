
module clk_fboundsp_pipe_s1(clk, reset,a,init,start,a_lt_b,low_bnd,high_bnd,dout);

input clk,reset;
input [31:0] a;
input init,start;
output a_lt_b;
output [31:0] low_bnd,high_bnd,dout;

reg [31:0] low_bnd,high_bnd,dout;
reg a_lt_b;
reg a_lt_b_sig;


`define s0 'b0
`define s1 'b1

wire  [7:0] b_exp;
wire  [7:0] a_exp;
wire  [22:0] b_man;
wire  [22:0] a_man;
wire  sign_lt;
wire  sign_eq;
reg  exp_lt;
reg  exp_gt;
reg  man_lt;
reg  man_gt;
reg  state_reg;


wire  [31:0] b;

assign  b = low_bnd;

assign  b_exp = b[30:23];

assign  a_exp = a[30:23];

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


assign  sign_lt = (a[31] & ~b[31]);
assign  sign_eq = ~(a[31]^b[31]);



always @(sign_lt or sign_eq or exp_lt or exp_gt  or  a[31])
begin
  a_lt_b_sig = 0;
  if (sign_lt == 1) begin
   a_lt_b_sig = 1;
  end
  else if (sign_eq == 1  &&
           ( ((a[31] == 0) && exp_lt == 1) ||
               ((a[31] == 1) && exp_gt == 1))) begin
        a_lt_b_sig = 1; 
      end
end

// ctrl portion
always @(posedge clk or negedge reset) begin

  if (reset == 0) begin
     state_reg <= `s0;
     low_bnd <= 0;
     high_bnd <= 0;
     dout <= 0;
     a_lt_b <= 0;
  end
  else begin
     a_lt_b <= a_lt_b_sig;
     case (state_reg) 
       `s0: begin
          if (init == 1) begin
            state_reg <= `s1;
	    low_bnd <= a;
	  end
	  if (start == 1) begin
             dout <= a;
           end
        end
       `s1: begin
           high_bnd <= a;
	   state_reg <= `s0;
          end
      default: state_reg <= `s0;
    endcase
  
  end
  
end //end always


endmodule


module clk_fboundsp_pipe_s2(clk, reset,a,b,a_lt_b_s1,high_bnd_in,a_lt_b_s2,high_bnd,dout,finished);
input clk,reset;
input [31:0] a,b;
input a_lt_b_s1;
input [31:0] high_bnd_in;
output a_lt_b_s2;
output [31:0] high_bnd,dout;
output finished;


reg a_lt_b_s2;
reg a_lt_b;
reg [31:0] high_bnd,dout;
reg finished;


wire  [7:0] b_exp;
wire  [7:0] a_exp;
wire  [22:0] b_man;
wire  [22:0] a_man;

wire  [7:0] high_bnd_exp;
wire sign_eq_s2;
wire sign_lt_s2;
reg exp_lt_s2,exp_gt_s2;
reg a_lt_b_s2_sig;

reg man_lt,man_gt, exp_eq;

assign  b_exp = b[30:23];
assign  b_man = b[22:0];

assign  a_exp = a[30:23];
assign  a_man = a[22:0];

assign  high_bnd_exp = high_bnd_in[30:23];
assign  sign_eq_s2 = ~(a[31]^high_bnd_in[31]);
assign  sign_lt_s2 = (a[31] & ~high_bnd_in[31]);

always @(a_exp or high_bnd_exp) begin
  exp_lt_s2 = 0;
  if (a_exp < high_bnd_exp) exp_lt_s2 = 1;
end

always @(a_exp or high_bnd_exp) begin
  exp_gt_s2 = 0;
  if (high_bnd_exp < a_exp) exp_gt_s2 = 1;
end




always @(sign_lt_s2 or sign_eq_s2 or exp_lt_s2 or exp_gt_s2 or a[31])
begin
  a_lt_b_s2_sig = 0;
  if (sign_lt_s2 == 1) begin
   a_lt_b_s2_sig = 1;
  end
  else if (sign_eq_s2 == 1  &&
           ( ((a[31] == 0) && exp_lt_s2 == 1) ||
               ((a[31] == 1) && exp_gt_s2 == 1))) begin
        a_lt_b_s2_sig = 1; 
      end
end

assign  sign_eq = ~(a[31]^b[31]);

always @(a_exp or b_exp) begin
  exp_eq = 0;
  if (a_exp == b_exp) exp_eq = 1;
end


always @(a_man or b_man) begin
  man_lt = 0;
  if (a_man < b_man) man_lt = 1;
end

always @(a_man or b_man) begin
  man_gt = 0;
  if (b_man < a_man) man_gt = 1;
end


always @(a_lt_b_s1 or sign_eq or exp_eq or man_lt or man_gt or a[31])
begin
  a_lt_b = 0;
  if (a_lt_b_s1 == 1) begin
   a_lt_b = 1;
  end
   else if (sign_eq == 1 && exp_eq == 1 &&
             (((a[31] == 0) && (man_lt == 1)) ||
              ((a[31] == 1) && (man_gt == 1))) ) begin
        a_lt_b = 1;   
      end       
end

//ctrl portion


always @(posedge clk or negedge reset) begin

  if (reset == 0) begin
     high_bnd <= 0;
     finished <= 0;
     dout <= 0;
     a_lt_b_s2 <= 0;
    end
  else begin
     a_lt_b_s2 <= a_lt_b_s2_sig;
     high_bnd <= high_bnd_in;
     if (a_lt_b == 1) begin
      dout <= b;
      finished <= 1;
     end
     else begin
      finished <= 0;
      dout <= a;
     end     
   end
 end // end always


endmodule

module clk_fboundsp_pipe_s3(clk,reset,a,b,a_lt_b_s2,finished_s2,dout,in_bounds,finished);
input clk,reset;
input [31:0] a,b;
input a_lt_b_s2, finished_s2;
output [31:0] dout;
output in_bounds, finished;

reg [31:0] dout;
reg in_bounds, finished;

wire  [7:0] b_exp;
wire  [7:0] a_exp;
wire  [22:0] b_man;
wire  [22:0] a_man;

wire sign_eq;
reg exp_eq;
reg man_lt, man_gt;
reg a_lt_b;

assign  b_exp = b[30:23];
assign  b_man = b[22:0];

assign  a_exp = a[30:23];
assign  a_man = a[22:0];

assign  sign_eq = ~(a[31]^b[31]);

always @(a_exp or b_exp) begin
  exp_eq = 0;
  if (a_exp == b_exp) exp_eq = 1;
end


always @(a_man or b_man) begin
  man_lt = 0;
  if (a_man < b_man) man_lt = 1;
end

always @(a_man or b_man) begin
  man_gt = 0;
  if (b_man < a_man) man_gt = 1;
end

always @(a_lt_b_s2 or sign_eq or exp_eq or man_lt or man_gt or a[31])
begin
  a_lt_b = 0;
  if (a_lt_b_s2 == 1) begin
   a_lt_b = 1;
  end
   else if (sign_eq == 1 && exp_eq == 1 &&
             (((a[31] == 0) && (man_lt == 1)) ||
              ((a[31] == 1) && (man_gt == 1))) ) begin
        a_lt_b = 1;   
      end       
end


//ctrl portion

always @(posedge clk or negedge reset) begin
  if (reset == 0) begin
     finished <= 0;
     in_bounds <= 0 ;
     dout <= 0;
  end
  else begin
    finished <= 1;
    if (finished_s2 == 1) begin
     dout <= a; //pass through
     in_bounds <= 0;
    end
    else  begin
      if (a_lt_b == 1) begin
       in_bounds <= 1;
        dout <= a;
      end
      else begin
       in_bounds <= 0;
       dout <= b;
      end
    end
  end //end else
end //end always


endmodule

module clk_fboundsp_pipe(clk,reset,din,init,start,dout,in_bounds,finished);

input clk,reset;
input   [31:0] din;
input init,start;
output  [31:0] dout;
output in_bounds, finished;

wire a_lt_b_s1;
wire [31:0] low_bnd_s1;
wire [31:0] high_bnd_s1;
wire [31:0] dout_s1;
wire a_lt_b_s2;
wire [31:0] high_bnd_s2;
wire [31:0] dout_s2;
wire finished_s2;

clk_fboundsp_pipe_s1 s1 (.clk(clk), 
                         .reset(reset),
			 .a(din),
			 .init(init),
                         .start(start),
                         .a_lt_b(a_lt_b_s1),
                         .low_bnd(low_bnd_s1),
                         .high_bnd(high_bnd_s1),
			 .dout(dout_s1));
clk_fboundsp_pipe_s2 s2 (.clk(clk), 
                         .reset(reset),
                         .a(dout_s1),
			 .b(low_bnd_s1),
			 .a_lt_b_s1(a_lt_b_s1),
			 .high_bnd_in(high_bnd_s1),
			 .a_lt_b_s2(a_lt_b_s2),
			 .high_bnd(high_bnd_s2),
                         .dout(dout_s2),
			 .finished(finished_s2));
clk_fboundsp_pipe_s3 s3 (.clk(clk),
		         .reset(reset),
			 .a(dout_s2),
			 .b(high_bnd_s2),
                         .a_lt_b_s2(a_lt_b_s2),
			 .finished_s2(finished_s2),
			 .dout(dout),
			 .in_bounds(in_bounds),
			 .finished(finished));


endmodule
