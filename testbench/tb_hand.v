`timescale 1ns/100ps
`define CYCLE 10


//**************************** wire & reg**********************//
wire enable_t, enable_f;
wire clr_t, clr_f;
reg [7:0] slave_q_t, slave_q_f;
wire [7:0] out_t, out_f

//**************************** module **********************//
// module combinational_part0 cp0(
// .enable_t(enable_t), 
// .enable_f(enable_f),
// .clr_t(clr_t), 
// .clr_f(clr_f), 
// .slave_q_t(slave_q_t), 
// .slave_q_f(slave_q_f),
// .out_t(out_t),
// .out_f(out_f)
// );

//**************************** clock gen **********************//

//**************************** initial and wavegen **********************//
// initial begin
//  $dumpfile("montgomery.vcd");
//  $dumpvars;
// end

//**************************** testdata **********************//
initial begin
    enable_f = 1;
    $display("enable_f", enable_f);
//  #1 n_rst = 1'b1;
//  A = 256'h4;
//  B = 256'h8;
//  N = 256'd13;
//  #100 n_start = 1'b0;
//  #10 n_start = 1'b1;
//  #100000 $finish;
end

endmodule