module tb_ncl_up_counter ;
  reg reset ;
  wire ackout ;
  reg ackin ;
  reg f_clr ;
  reg t_clr ;
  reg clr ;
  reg f_enable ;
  reg t_enable ;
  reg enable ;
  wire [7:0] f_out ;
  wire [7:0] t_out ;
  reg [7:0] out ;
  reg i_clk;
  wire [7:0] bits_ordy;
  wire all_data,all_null;
  reg o_rdy;
  wire i_rdy;

  integer i;

  integer state_reached;


    ncl_up_counter dut (
           .reset(reset),
           .ackout(ackout),
           .ackin(ackin),
           .f_clr(f_clr),
           .t_clr(t_clr),
           .f_enable(f_enable),
           .t_enable(t_enable),
           .f_out(f_out),
           .t_out(t_out));



   initial begin
    //add user code here

    $dumpfile("ncl_up_counter.vcd");
    $dumpvars(1, tb_ncl_up_counter);
    i_clk = 0;
    enable = 0;
    clr = 0;
    state_reached = 0;
    reset = 1;  //low true
    #1 reset = 0;  //assert async reset
    #100 reset = 1;  //negate async reset

    //at this point, data is ready 
    enable = 1;
    for (i=0; i < 511; i = i + 1) begin
     ncl_clk;
    end
    enable = 0;
    ncl_clk;  //hold
    ncl_clk;
    ncl_clk;
    clr = 1;
    ncl_clk;
    ncl_clk;
    enable = 1;
    ncl_clk;
    ncl_clk;
    clr = 0;
    ncl_clk;
    ncl_clk;
    ncl_clk;

    #100 $display("done");
    //assume that if we reach state 7 during this test then the test design is working
    if (state_reached == 1) $display("ALL_PASSED");


    $finish;

   end

   //input generation
   always @(i_clk or reset) begin
     if (i_clk == 1 && reset ==1 ) begin
      //active outputs
        f_clr = ~clr;
        t_clr = clr;
        f_enable = ~enable;
        t_enable = enable;
     end
     else begin
        f_clr = 0;
        t_clr = 0;
        f_enable = 0;
        t_enable = 0;
     end
   end //end always
   task ncl_clk;
    begin
     i_clk = 1;
     @(negedge i_rdy);    //wait for input to consume
     i_clk = 0;           //return inputs to null
     @(posedge i_rdy);    //wait for system to be ready for inputs
    end
   endtask
   
   always @(ackin) o_rdy = ~ackin;
   assign #1 bits_ordy = {t_out}|{f_out};
   assign #1 all_null = ~|(bits_ordy); 
   assign #1 all_data = &(bits_ordy);

   //output cgate
   always @(reset or all_null or all_data) begin
    if (reset == 0) #1 ackin = 1;
     else if (all_data) #1 ackin = 0;
     else if (all_null) #1 ackin = 1;   
    end  

  assign i_rdy = ackout;
  //output capture
  always @(posedge o_rdy) begin
   out = t_out;
   #1 $display("Time: %t/ enable=%b clr=%b out=%b",
          $time,enable,clr,out);

  if (out == 7) state_reached = 1;
  end //end always
endmodule
