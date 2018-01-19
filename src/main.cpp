#include <iostream>
#include <string>
#include <cassert>
#include "Util.h"
#include "RTL.h"

using namespace std;

int main(int argc, char* argv[]) {
  string inputPath;
  string outputPath;
  if (argc == 1) {
    inputPath = "testbench/rtl/clk_up_counter.v";
    outputPath = "output/ncl_clk_up_counter.v";
  } else {
    assert(argc == 3 || argc == 4);
    inputPath = (string)argv[1];
    outputPath = (string)argv[2];
  }
  RTL rtl;
  rtl.parse(inputPath);
}
