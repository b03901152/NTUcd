//simple GCD using subtraction

module gcd4bit (reset, a, b, dout);
`define WIDTH 4

 input reset;
 input [(`WIDTH-1):0]a,b;
 output [(`WIDTH-1):0] dout;


 wire t_aeqb_flagin,f_aeqb_flagin, rd_aeqb_flag;
 wire t_agb_flagin,f_agb_flagin, rd_agb_flag;

 wire s0,s1,s3,s4,s5;

 wire [(`WIDTH-1):0] a_port,b_port;
 wire[(`WIDTH-1):0] anew,bnew;
 
 //read ports for inputs
 vreadport_n #(.WIDTH(`WIDTH)) rdport_a (.d(a),.q(a_port),.rd(s0));
 vreadport_n #(.WIDTH(`WIDTH)) rdport_b (.d(b),.q(b_port),.rd(s0));

 reg[(`WIDTH-1):0] ain,bin;
 wire agb,agb_d;
 wire aneqb;
 wire [(`WIDTH-1):0] aval,bval;
 wire [(`WIDTH-1):0] acmp,bcmp;
 wire[(`WIDTH-1):0] ad,bd;

 merge2_n #(.WIDTH(`WIDTH)) mrga1 (.y(ain),.a(anew), .b(a_port));
 merge2_n #(.WIDTH(`WIDTH)) mrgb1 (.y(bin),.a(bnew), .b(b_port));

 //master regs
 dreg2port_n #(.WIDTH(`WIDTH)) a_master (.q0(acmp),.rd0(rd_aeqb_flag),.q1(ad),.rd1(s1),.d(ain));   
 dreg3port_n #(.WIDTH(`WIDTH)) b_master (.q0(bcmp),.rd0(rd_aeqb_flag),.q1(bd),.rd1(s1), .q2(dout),.rd2(s5),.d(bin));      

 assign aneqb= (acmp!=bcmp);


 agb_4 agb0 (.a(ad),.b(bd),.agb(agb_d));


 wire[(`WIDTH-1):0] y0_a,y1_a;
 wire[(`WIDTH-1):0] y0_b,y1_b;

 //slave regs
 dreg2port_n #(.WIDTH(`WIDTH)) a_slave (.q0(y0_a),.rd0(s4),.q1(y1_a),.rd1(s3),.d(ad));   
 dreg2port_n #(.WIDTH(`WIDTH)) b_slave (.q0(y0_b),.rd0(s4),.q1(y1_b),.rd1(s3),.d(bd));      

 dreg1port agtb_flag (.q(agb),.rd(rd_agb_flag),.d(agb_d));  //a>b flag
 drexpand drexpand1 (.t_y(t_agb_flagin),.f_y(f_agb_flagin),.a(agb));  

 wire[(`WIDTH-1):0] sub1,sub0;

 subripple_n #(.WIDTH(`WIDTH)) suba (.s(sub1),.a(y1_a),.b(y1_b));
 subripple_n #(.WIDTH(`WIDTH)) subb (.s(sub0),.a(y0_b),.b(y0_a));

 merge2_n #(.WIDTH(`WIDTH)) mrga0 (.y(anew),.a(sub1), .b(y0_a));
 merge2_n #(.WIDTH(`WIDTH)) mrgb0 (.y(bnew),.a(sub0), .b(y1_b));
 
 wire s0_start,loop_start;
 wire s1_start,s2_start,s2_done;
 wire s3_start,s3_done,s4_done,s3_s4_done;
 wire s5_start,s5_done;

 wire log0;

 assign log0 = 0;  //tie ackins low to supress lint messages.

 //controller
 //enable for loop
  loopen g0 (.y(s0_start),.en(reset),.a(s5_done));

  //need to use sequencers with ki inverted because datapath provides 
  //an inverted ki according to Balsa
  //state S0  
  seqelem_kib  u1 (.start(s0_start), .done(loop_start), .y(s0), .kib(log0));

  whileloop u2 (.start(loop_start),.done(s5_start), 
                .flag(aneqb),  .rd_flag(rd_aeqb_flag),
                .body_start(s1_start),.body_done(s2_done) );

  //state S1, in loop body, copies a,b to slave register, computes, agb flag.
  seqelem_kib  u3 (.start(s1_start), .done(s2_start), .y(s1), .kib(log0));

  //state S2, gates the agbflag
  seqelem  u4 (.start(s2_start), .done(s2_done), .y(rd_agb_flag), .ki(s3_s4_done));

  //state S3, a>b 
  seqdum_kib  u5 (.start(t_agb_flagin), .done(s3_done), .y(s3), .kib(log0));

  //state S4, a<b 
  seqdum_kib  u6 (.start(f_agb_flagin), .done(s4_done), .y(s4), .kib(log0));

  sror2 contmrg (.y(s3_s4_done),.a(s3_done),.b(s4_done));

  //state S5, after while loop
  seqdum_kib  u7 (.start(s5_start), .done(s5_done), .y(s5), .kib(log0));


endmodule 
