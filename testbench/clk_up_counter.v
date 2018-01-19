module clk_up_counter    (
out     ,  // Output of the counter
enable  ,  // enable for counter
clk     ,  // clock Input
clr     ,  //synchronous clear
reset      // asynchronous clear
);
//----------Output Ports--------------
    output [7:0] out;
//------------Input Ports--------------
    input enable, clk, reset,clr;
//------------Internal Variables--------
    reg [7:0] out;
//-------------Code Starts Here-------

always @(posedge clk or negedge reset) begin
 if (reset == 0) begin
   out <= 8'b0 ;
 end else begin
    
  if (clr) begin
   out <= 8'b0 ;
  end else if (enable) begin
   out <= out + 1;
  end
 end
end




endmodule 

