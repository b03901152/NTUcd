module clk_up_counter_rtl    (
    reset,
    ackout,
    ackin,
    f_clr,
    t_clr,
    f_enable,
    t_enable,
    f_out,
    t_out,
);

output [7:0] f_out;
output [7:0] t_out;
output ackout;
//------------Input Ports--------------
input ackin;
input f_clr, t_clr;
input f_enable, t_enable;
input reset;

reg [7:0]t_out;
reg [7:0]f_out;
reg [7:0]counter;
reg ackout;


always @(ackin, reset) begin
  if (reset == 0) begin
    t_out <= 7'b0 ;
    f_out <= 7'b0 ;
    counter <= 7'b0 ;
    ackout <= 1;
  end
  else begin
    if (ackin) begin
      if (t_clr) begin
        counter <= 7'b0 ;
      end
      else if (t_enable) begin
        counter <= counter + 1;
      end 
      t_out <= counter;
      f_out <= ~counter;
      ackout <= 0;
    end
    else if (ackin == 0) begin
      t_out = 7'b0;
      f_out = 7'b0;
      ackout <= 1;
    end
  end
end

endmodule 