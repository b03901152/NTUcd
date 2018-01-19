#pragma once

#include <vector>
#include "Util.h"
#include <string>
#include <map>

using namespace std;

class IfStatement {
 public:
  IfStatement(){};
  ~IfStatement(){};

 private:
  Signal _condition;
  vector<Process> _processes;
  vector<IfStatement> _ifStatements;
};

class Module {
 public:
  Module(){};
  ~Module(){};
  string _name;
  map<string, Pin *> _pins;

  ActionStatement _reset;
  vector<Process> _processs;
};

class RTL {
 public:
  RTL(){};
  ~RTL(){};
  void parse(string inputPath);
  void parse_all_cond(ifstream ifs, Module *mod) {
    while (1) {
      streampos oldpos = ifs.tellg();  // stores the position
      string line;
      if (!getline(ifs, line)) break;
      vector<string> tokens;
      split(tokens, line, is_any_of(delimiters));
      cerr << "line " << line << endl;
      filter(tokens, [](string &s) { return s.size(); });
      if (tokens[0] == "always")
        parse_always(ifs, mod);
      else if (tokens[0] == "if")
        parse_if(ifs, mod);
    }
  };
  AlwaysStatement parse_always(ifstream ifs) {
    AlwaysStatement alwaysStatement;
    string line;
    streampos oldpos = ifs.tellg();  // stores the position
    getline(ifs, line));
    string delimiters = "()";
    vector<string> tokens;
    split(tokens, line, is_any_of(delimiters));
    alwaysStatement._trigger = parse_signal(tokens[1]);
    while (1) {
      oldpos = ifs.tellg();  // stores the position
      if (!getline(ifs, line)) break;
      delimiters = " ";
      split(tokens, line, is_any_of(delimiters));
      if (tokens[0] == "if") {
        ifs.seekg(oldpos);
        alwaysStatement._processs.push_back(parse_if(ifs));
      }
    }
    return alwaysStatement;
  }
  IfStatement parse_if(ifstream ifs) {
    IfStatement ifStatement;
    string line;
    streampos oldpos = ifs.tellg();  // stores the position
    getline(ifs, line);
    string delimiters = "()";
    vector<string> tokens;
    split(tokens, line, is_any_of(delimiters));
    ifStatement._trigger = parse_signal(tokens[1]);
    while (1) {
      getline(ifs, line);
      delimiters = " ";
      vector<string> tokens;
      split(tokens, line, is_any_of(delimiters));
      if (tokens[0] == "if") {
        ifs.seekg(oldpos);
        IfStatement._processes.push_back(parse_if(ifs));
      } else if (tokens[0] == "end") {
        getline(ifs, line);
        split(tokens, line, is_any_of(delimiters));
        if (tokens[0] == "else")
          ifStatement._ifStatements.push_back(parse_if(ifs));
        return ifStatement;
      } else {
        ifs.seekg(oldpos);
        IfStatement._processes.push_back(parse_if(ifs));
      }
    }
  }
  Signal parse_signal(string str) {
    Signal sig;
    string delimiters = " ";
    vector<string> tokens;
    split(tokens, line, is_any_of(delimiters));
    if (tokens.size() == 1) {
      sig._type = "single";
      sig._signal = tokens[0];
    } else {
      sig._type = "composite";
      int pos;
      int max_presidence = 0;
      for (int i = 0; i < tokens.size() / 2; ++i) {
        switch (token[2 * i + 1]) {
          case "+":
            if (max_presidence < 1) {
              max_presidence = 1;
              pos = 2 * i + 1;
            }
            break;
          case "<=":
            break;
        }
      }
    }
    return;
  }
  vector<Module *> _modules;
};