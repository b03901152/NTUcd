module clk_up_counter    (out     ,enable  ,clk     ,clr     ,reset    );
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
 end 
 else begin
  if (clr) begin
   out <= 8'b0 ;
  end 
  else if (enable) begin
   out <= out + 8'b1;
  end
 end
end




endmodule 

