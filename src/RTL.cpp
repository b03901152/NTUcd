#include <sstream>
#include <fstream>
#include <functional>
#include <iostream>
#include <cassert>
#include <string>
#include <map>
#include <boost/algorithm/string.hpp>
#include "RTL.h"
#include "Util.h"

using namespace boost;
void RTL::parse(string inputPath) {
  cout << "parse\n";
  // string inputString("One!Two,Three:Four");
  // string delimiters("|,:");
  // vector<string> parts;
  // boost::split(parts, inputString, boost::is_any_of(delimiters));
  // for (auto& i : parts) {
  //   cerr << "i " << i << endl;
  // }

  ifstream ifs(inputPath, ifstream::in);
  assert(ifs.is_open());
  string line;

  Module* mod;

  while (1) {
    streampos oldpos = ifs.tellg();  // stores the position
    if (!getline(ifs, line)) break;
    continue;
    string delimiters("(),; ");
    vector<string> tokens;
    split(tokens, line, is_any_of(delimiters));
    cerr << "line " << line << endl;
    filter(tokens, [](string& s) { return s.size(); });
    if (tokens.empty())
      continue;
    else if (tokens[0] == "module") {
      mod = new Module();
      mod->_name = tokens[1];
    } else if (tokens[0] == "reg" || tokens[0] == "input" ||
               tokens[0] == "output") {
      delimiters = ", ;";
      split(tokens, line, is_any_of(delimiters));
      filter(tokens, [](string& s) { return s.size(); });
      tokens.erase(tokens.begin());
      int bits = 0;
      for (auto& str : tokens) {
        cerr << "str " << str << endl;
        if (bits) {
          if (tokens[0] == "reg")
            mod->_pins.emplace(str, new Register(bits));
          else if (tokens[0] == "input")
            mod->_pins.emplace(str, new Input(bits));
          else if (tokens[0] == "output")
            mod->_pins.emplace(str, new Output(bits));
          bits = 0;
        } else if (str[0] != '[') {
          if (tokens[0] == "reg")
            mod->_pins.emplace(str, new Register(1));
          else if (tokens[0] == "input")
            mod->_pins.emplace(str, new Input(1));
          else if (tokens[0] == "output")
            mod->_pins.emplace(str, new Output(1));
        } else {
          delimiters = "[:]";
          vector<string> tmp;
          split(tmp, str, is_any_of(delimiters));
          filter(tmp, [](string& s) { return s.size(); });
          bits = max(stoi(tmp[0]), stoi(tmp[1]));
        }
      }
    } else if (tokens[0] == "always") {
      ifs.seekg(oldpos);
    } else if (tokens[0] == "//") {
    } else {
      cerr << "non-handle line: " << line << endl;
    }

    // else if (tokens[0] == "wire") {
    //   mod->_wires.push_back(Wire(wireNum++));
    //   idMap[tokens[1]] = pinNum;
    // } else if (tokens[0] == "input") {
    //   mod->_pins.push_back(Input(pinNum++));
    //   idMap[tokens[1]] = pinNum;
    // } else if (tokens[0] == "output") {
    //   idMap[tokens[1]] = pinNum;
    //   mod->_pins.push_back(Output(pinNum++));
    // } else if (tokens[0] == "assign") {
    // } else if (tokens[0] == "always") {
    // } else if (tokens[0] == "casez") {
    // } else if (tokens[0] == "default") {
    // } else if (tokens[0] == "endcase") {
    // } else if (tokens[0] == "end") {
    // }
    // int a, b;
    // if (!(ss >> a >> b)) {
    //   break;
    // }  // error

    // process pair (a,b)
  }
}