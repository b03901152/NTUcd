module srdregsr_8 ( rsb, sb, f_d,  t_d,  ackout,  f_q,  t_q);
  parameter WIDTH = 8;

  input [WIDTH-1:0] rsb;
  input [WIDTH-1:0] sb;
  input [WIDTH-1:0] f_d;
  input [WIDTH-1:0] t_d;
  output [WIDTH-1:0] f_q;
  output [WIDTH-1:0] t_q;
  wire [7:0] ackout_n;
  output ackout;

  genvar i;
  generate
    for(i=0; i<WIDTH; i=i+1)
      srdregsr s0(rsb[i], sb[i], f_d[i],  t_d[i],  ackout_n[i],  f_q[i],  t_q[i]);
    end
  endgenerate

  wire ackout_0,ackout_1;
  th44 th0(
    .y(ackout_0),
    .a(ackout_n[0])
    .b(ackout_n[1])
    .c(ackout_n[2])
    .d(ackout_n[3])
    );
  th44 th1(
    .y(ackout_1),
    .a(ackout_n[4])
    .b(ackout_n[5])
    .c(ackout_n[6])
    .d(ackout_n[7])
    );
  th2 th2(.y(ackout), .a(ackout_0), .b(ackout_1));

    
endmodule


//uses S-element for control
module generate_sample    (out_t,out_f, enable_t,_enable_f,clr_t,clr_f,reset,ackin,ackout);
output [7:0] out_t, out_f;
input enable_t,enable_f;
input reset, clr_t, clr_f;

wire enable_port_t, enable_port_f;
wire out_port_t, out_port_f;
wire clr_port_t, clr_port_f;

wire master_d_t, master_d_f;
wire master_q_t, master_q_f;
wire master_out_t, master_out_f;
wire master_rd_t, master_rd_f;
wire master_ko;

wire slave_d_t, slave_d_f;
wire slave_q_t, slave_q_f;
wire slave_out_t, slave_out_f;
wire slave_rd_t, slave_rd_f;
wire slave_ko;

wire logic0;


reg [7:0] master;
reg [7:0] slave;


wire [7:0] out_now;
reg [7:0] next_out;
wire s0,s1;

vreadport vr1  (.d(enable_t),.q(enable_port_t),.rd(s0));
vreadport vr2  (.d(enable_f),.q(enable_port_f),.rd(s0));

vreadport vr3 (.d(clr_t),.q(clr_port_t),.rd(s0));
vreadport vr4 (.d(clr_f),.q(clr_port_f),.rd(s0));

wire cp_t,cp_f;
combinational_part0 cp0(
.enable_t(enable_port_t), 
.enable_f(enable_port_f),
.clr_t(clr_port_t), 
.clr_f(clr_port_f), 
.slave_q_t(slave_q_t), 
.slave_q_f(slave_q_f),
.out_t(cp_t),
.out_f(combinational_part0_out_f)
);

assign logic0 = 0;
wire[7:0] rsb,sb;

genvar i;
generate        
  for (i = 0; i < 8 ; i++)
    assign rsb[i] = reset;
    assign sb[i] = logic0;
endgenerate 

srdregsr_8 master( .rsb(rsb), .sb(sb), .f_d(cp_f),  .t_d(cp_t),  .ackout(master_ko),  .f_q(master_q_f),  .t_q(master_q_t));
and2 g0(.y(master_out_f), .a(master_q_f), .b(s1));
and2 g1(.y(master_out_t), .a(master_q_t), .b(s1));

srdregsr_8 slave(  .rsb(rsb), .sb(sb), .f_d(master_q_f),  .t_d(master_q_t),  .ackout(slave_ko),  .f_q(slave_q_f),  .t_q(slave_q_t));
and2 g2(.y(slave_out_f), .a(master_q_f), .b(s0));
and2 g3(.y(slave_out_t), .a(master_q_t), .b(s0));

th22r cr0(.y(th22r_wire), .a(master_ko), .b(s0));
wire th22r_wire;
inv vr1(.y(ackout), .a(th22r_wire));

wire ko_s1;
th22 th22_g0(.y(ko_s1), .a(ackin), .b(slave_ko));

// always @* begin
//  next_out = out_now;
//  if (enable_port) next_out = out_now + 1;
//  if (clr_port) next_out = 0;
// end


wire s0_start, s1_start, s1_done;


loopen g0 (.y(s0_start),.en(reset),.a(s1_done));

seqelem_kib  u1 (.start(s0_start), .done(s1_start), .y(s0), .kib(log0));

seqdum_kib  u2 (.start(s1_start), .done(s1_done), .y(s1), .kib(log0));


endmodule 
