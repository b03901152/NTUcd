//Simple up counter that demos the full adder (fa) cell
//

module clk_cnt4fa  (cnt,clk,reset,up);

 output [3:0] cnt;
 input clk,reset,up;

 reg [3:0] cnt;
 wire up_n;
 wire [3:0] next_cnt;
 wire [4:0]  carry;


 genvar i;

  assign carry[0] = up;
  assign up_n = ~up;  

//ripple adder using FA cell  
generate
  for(i=0;i < 4; i=i+1) begin:bit
    fa g0 (.s(next_cnt[i]),.co(carry[i+1]),.a(cnt[i]), .b(up_n),.ci(carry[i]));
  end
endgenerate


always @(posedge clk or negedge reset) begin
 if (reset == 0) begin
  cnt <= 0 ;
 end else begin
  cnt <= next_cnt;
 end
end

endmodule 
