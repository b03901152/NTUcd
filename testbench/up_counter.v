
//uses S-element for control
module up_counter    (out, enable,clr,reset);
output [7:0] out;
input enable, reset,clr;


wire enable_port;
wire clr_port;
wire [7:0] out_now;
reg [7:0] next_out;
wire s0,s1;

//read ports for inputs
vreadport rdport_en  (.d(enable),.q(enable_port),.rd(s0));
vreadport rdport_clr (.d(clr),.q(clr_port),.rd(s0));

//registers
dreg1port_n #(.WIDTH(8)) dout_master (.q(out),.rd(s1),.d(next_out));   
dreg1port_n #(.WIDTH(8)) dout_slave (.q(out_now),.rd(s0),.d(out));   

//computation

always @* begin
 next_out = out_now;
 if (enable_port) next_out = out_now + 1;
 if (clr_port) next_out = 0;
end


wire s0_start, s1_start, s1_done;
wire log0;

assign log0=0;

//enable for loop
loopen g0 (.y(s0_start),.en(reset),.a(s1_done));

//State s0
seqelem_kib  u1 (.start(s0_start), .done(s1_start), .y(s0), .kib(log0));

//state s1
seqdum_kib  u2 (.start(s1_start), .done(s1_done), .y(s1), .kib(log0));


endmodule 
