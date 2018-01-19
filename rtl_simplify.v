module clk_up_counter(out, enable, clk, clr, reset);
  wire _0_;
  wire _1_;
  wire _2_;
  input clk;
  input clr;
  input enable;
  output out;
  reg out;
  input reset;
  assign _1_ = out + 1'b1;
  always @(posedge clk or negedge reset)
    if (!reset)
      out <= 1'b0;
    else
      out <= _0_;
  assign _2_ = enable ? _1_ : out;
  assign _0_ = clr ? 1'b0 : _2_;
endmodule
