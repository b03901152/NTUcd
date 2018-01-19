// 16 bit/16 bit unsigned integer GCD, uses an external
// 16/16 modulus operation that is also a data-driven design
// (see clkspec_mod16_16.v)

// this is a data driven design. The input ports (a,b) accepts
// data, and then only accepts a new input once the output (dout)
// has been produced and consumed.  The output ports (dout) are
// only active when a result  is ready


module clkspec_gcd16_16 (clk, reset, a, b, dout, dd,dv, rm);

 input reset;
 input clk;

 input [15:0] a,b;  //operands
 output [15:0] dout;  //result

//connection to external modulus block
 output [15:0] dd;   //dividend
 output [15:0] dv;   //divisor
 input [15:0] rm;  //remainder


`define s0 'b000     //start
`define s1 'b001     // output to modulus
`define s2 'b010     // input from modulus
`define s3 'b011     //check if modulo result is zero
`define s4 'b100     //loop body, update a,b values
`define s5 'b101     //output result

 reg rd_din, rd_subin;
 reg wr_dout, wr_subout;
  reg xfer;

  reg unsigned [15:0] a_q, b_q;
  reg unsigned [15:0] a_swap, b_swap, a_swap_q, b_swap_q;

  reg unsigned [15:0] areg,breg;
  reg [2:0] nstate,pstate;
  reg unsigned [15:0] rm_q;

  wire mod_is_zero;

  //swap block at front end to ensure that A > B
  //front end latches
  always @* begin
    if (clk == 1) begin
      a_q <= a; b_q <= b;
    end
  end

   //swap combo logic
   always @*  begin
    a_swap = a_q; b_swap = b_q;
    if (a_q < b_q) begin
      a_swap = b_q;
      b_swap = a_q;
    end
   end

   //read ports for a_swap, b_swap inputs

   //read ports for the a_swap, b_swap inputs
   readport_n  #(.WIDTH(16)) rp1 (.clk(clk),.d(a_swap),.q(a_swap_q), .rd(rd_din));
   readport_n  #(.WIDTH(16)) rp2 (.clk(clk),.d(b_swap),.q(b_swap_q), .rd(rd_din));


   //write port to modulo block
  writeport_n  #(.WIDTH(16)) wp1  (.d(areg),.q(dd), .wr(wr_subout));
  writeport_n  #(.WIDTH(16)) wp2  (.d(breg),.q(dv), .wr(wr_subout));

  //read port for modulo result
   readport_n  #(.WIDTH(16)) rp3 (.clk(clk),.d(rm),.q(rm_q), .rd(rd_subin));

  //write port for final result, b reg has final result
  writeport_n  #(.WIDTH(16)) wp3  (.d(breg),.q(dout), .wr(wr_dout));

 //zero comparison
  assign mod_is_zero = (areg == 0);

 //registers
 always @(posedge clk or negedge reset) begin
  if (reset == 0) begin
    pstate <= `s0;
    areg <= 0;
    breg <= 0;
  end else begin
    pstate <= nstate;
    if (rd_din) begin
       areg <= a_swap_q;
       breg <= b_swap_q;
    end
    if (rd_subin) begin
      areg <= rm_q;
    end 
    if (xfer) begin
      breg <= areg;    //modulo value becomes new b
      areg <= breg;    //a becomes old b
    end
  end
 end


  //logic for fsm
  always @*  begin
    nstate = pstate;
    rd_din = 0; rd_subin = 0;
    wr_dout = 0; wr_subout = 0;
    xfer = 0;

    case (pstate)
          `s0: begin rd_din= 1; nstate = `s1;   end     //input the data
          `s1: begin wr_subout = 1; nstate = `s2;  end  //send data to modulo operator
          `s2: begin rd_subin = 1; nstate = `s3;  end   //read data from modulo operator
          `s3: begin 
                 if (mod_is_zero == 1) nstate = `s5;  
                  else nstate = `s4;  
               end
          `s4: begin xfer=1; nstate = `s1;  end     //loop to do modulo again
          `s5: begin wr_dout=1; nstate = `s0;  end
     default:  nstate = `s0;
    endcase
  end //end always

endmodule 

