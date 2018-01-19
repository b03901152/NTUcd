//simple GCD using subtraction

module clkspec_gcdsimple (clk, reset, a, b, dout);
 input reset;
 input clk;
 input [15:0]a,b;
 output [15:0] dout;


 wire[15:0] ad,bd;

 reg rd, wr;

 reg [15:0] aq,bq;

 //read port for a,b
 readport_n  #(.WIDTH(16)) rp_x (.clk(clk),.d(a),.q(ad), .rd(rd));
 readport_n  #(.WIDTH(16)) rp_y (.clk(clk),.d(b),.q(bd), .rd(rd));
 //write port for dout
 writeport_n  #(.WIDTH(16)) wp0 (.d(bq),.q(dout), .wr(wr));


`define s0 'b00
`define s1 'b01
`define s2 'b10

 reg [1:0] pstate, nstate;

 wire [15:0] aq_val, bq_val;

 wire a_gt_b, a_eq_b, a_lt_b;

// assign a_lt_b = (aq < bq);
// assign a_eq_b = (aq == bq);
 compare_16 compmod (.a(aq),.b(bq),.agb(a_gt_b),.aeqb(a_eq_b));
 assign a_lt_b = ~(a_gt_b | a_eq_b);

 wire [15:0] sub_a_b, sub_b_a;
 subripple_n #(.WIDTH(16)) subcompa (.s(sub_a_b),.a(aq),.b(bq));
 subripple_n #(.WIDTH(16)) subcompb (.s(sub_b_a),.a(bq),.b(aq));


// assign  aq_val = (a_gt_b) ? (sub_a_b) : aq;
// assign  bq_val = (a_lt_b) ? (sub_b_a) : bq;
 mux2_n #(.WIDTH(16)) u_mux0 (.y(aq_val),.a(sub_a_b),.b(aq),.s(a_gt_b));
 mux2_n #(.WIDTH(16)) u_mux1 (.y(bq_val),.a(sub_b_a),.b(bq),.s(a_lt_b));

 wire [15:0] aq_rd, bq_rd;
 mux2_n #(.WIDTH(16)) u_mux2 (.y(aq_rd),.a(ad),.b(aq_val),.s(rd));
 mux2_n #(.WIDTH(16)) u_mux3 (.y(bq_rd),.a(bd),.b(bq_val),.s(rd));
  
 always @(posedge clk or negedge reset) begin
  if (reset == 0) begin
    pstate <= `s0;
    aq <= 0; bq <= 0;
  end
  else begin
    pstate <= nstate;
    aq <= aq_rd; bq <= bq_rd;
  end
 end //end always

//fsm logic
always @(*) begin
   wr = 0; rd = 0;
   nstate = pstate;
   case (pstate)
    `s0: begin
          rd = 1;
	  nstate = `s1;
	 end
    `s1: begin
          if (a_eq_b) nstate = `s2;
	 end
    `s2: begin
	  wr = 1;
          nstate = `s0;
         end
     default: nstate = `s0;
   endcase
 end // end always


endmodule 
    





