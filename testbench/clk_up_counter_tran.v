module clk_up_counter(out, enable, clk, clr, reset);
  reg _0_;
  wire [31:0] _1_;
  wire _2_;
  input clk;
  input clr;
  input enable;
  output out;
  reg out;
  input reset;
  assign _1_ = out + 32'd1;
  assign _2_ = reset == 32'd0;
  always @* begin
    _0_ = out;
    casez (_2_)
      1'b1:
          _0_ = 1'b0;
      default:
          casez (clr)
            1'b1:
                _0_ = 1'b0;
            default:
                casez (enable)
                  1'b1:
                      _0_ = _1_[0];
                  default:
                      /* empty */;
                endcase
          endcase
    endcase
  end
  always @(posedge clk) begin
      out <= _0_;
  end
  always @(negedge reset) begin
      out <= _0_;
  end
endmodule
