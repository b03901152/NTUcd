#pragma once

#include <algorithm>
#include <cassert>
#include <climits>
#include <functional>
#include <iostream>
#include <list>
#include <numeric>
#include <queue>
#include <random>
#include <stdexcept>
#include <utility>
#include <vector>
#include <vector>
#include <algorithm>
#include <string>

using namespace std;

enum Opt {  // operator
  ADD = 0,
  SUB = 1,
  BA = 2,  // blocking assignment
  NBA = 3,
};

enum Type {
  REG = 0,
  INPUT = 1,
  OUTPUT = 2,
  PIN = 3,
  WIRE = 4,
};

class Wire;
class Pin {
 public:
  Pin(int bits, Type type = PIN) : _bits(bits), _type(type){};
  ~Pin(){};

  //  protected:
  int _bits;
  Wire *_wire;
  Type _type;
};

class Register : public Pin {
 public:
  Register(int bits) : Pin(bits, REG){};
  ~Register(){};

 protected:
};

class Wire : public Pin {
 public:
  Wire(int bits) : Pin(bits, WIRE){};
  ~Wire(){};

 private:
  vector<int> _pinIds;
};

class Output : public Pin {
 public:
  Output(int bits) : Pin(bits, OUTPUT){};
  ~Output(){};

 private:
};

class Input : public Pin {
 public:
  Input(int bits) : Pin(bits, INPUT){};
  ~Input(){};

 private:
};

class Signal {
 public:
  Signal(){};
  ~Signal(){};

  //  private:
  string type;  // single, composite
  string _signal;

  string _signal0;
  Opt opt;
  string _signal1;
};

class Const {
 public:
  Const(int value) : _value(value){};
  ~Const(){};

  int _value;
};

class Process {
 public:
  Process(){};
  ~Process(){};

 private:
};

class Statement : public Process {
 public:
  Statement(){};
  ~Statement(){};

 private:
  vector<void *> _statements;
};

class ActionStatement : public Process {
 public:
  ActionStatement(){};
  ~ActionStatement(){};

 private:
  string _signal0;
  Opt opt;  // NBA
  string _signal1;
};

class AlwaysStatement : public Process {
 public:
  AlwaysStatement(){};
  ~AlwaysStatement(){};

  //  private:
  Signal _trigger;
  vector<Process> _processes;
};

vector<string> splitStr(string str, string delimiter = " ");

template <typename Obj, typename Comp>
void filter(vector<Obj> &v, Comp func) {
  unsigned j = 0;
  for (unsigned i = 0; i < v.size(); i++)
    if (func(v[i])) v[j++] = v[i];
  v.resize(j);
  v.shrink_to_fit();
};

template <typename Obj, typename Key_generator>
void copy_sort(vector<Obj> &v, Key_generator key_generator) {
  vector<double> keys(v.size());
  for (unsigned i = 0; i < keys.size(); i++) keys[i] = key_generator(v[i]);
  auto comp = [&](const unsigned &i, const unsigned &j) {
    return keys[i] < keys[j];
  };
  vector<int> order(v.size());
  iota(order.begin(), order.end(), 0);
  sort(order.begin(), order.end(), comp);
  auto tmp = v;
  v.clear();
  v.reserve(tmp.size());
  for (unsigned &odr : order) v.push_back(tmp[odr]);
}

template <typename Obj, typename Comp>
void sortRmDuplicate(vector<Obj> &v, Comp func) {
  copy_sort(v, func);
  v.erase(unique(v.begin(), v.end()), v.end());
}

template <typename Obj>
void concatenate(vector<Obj> &v1, vector<Obj> &v2) {
  v1.insert(v1.end(), v2.begin(), v2.end());
}

template <typename Obj>
void print(vector<Obj> v) {
  for (auto &e : v) cerr << e << " ";
  cerr << endl;
}

template <typename P, typename Q, typename Func>
bool transform(vector<P> &inputs, vector<Q> &outputs, Func func) {
  assert(outputs.empty());
  outputs.reserve(inputs.size());
  for (P &p : inputs) outputs.push_back(func(p));
}

template <typename Obj>
int indexOf(vector<Obj> &v, Obj obj) {
  for (unsigned i = 0; i < v.size(); i++)
    if (v[i] == obj) return i;
  assert(0);
  return -1;
}

template <typename Obj, typename Key_generator>
void copy_sort_with_threshold(vector<Obj> &v, Key_generator key_generator,
                              double threshold) {
  vector<double> keys(v.size());
  for (unsigned i = 0; i < keys.size(); i++) keys[i] = key_generator(v[i]);
  auto comp = [&](unsigned &i, unsigned &j) { return keys[i] < keys[j]; };
  vector<int> order(v.size());
  iota(order.begin(), order.end(), 0);
  sort(order.begin(), order.end(), comp);
  auto tmp = v;
  v.clear();
  v.reserve(tmp.size());
  for (unsigned &odr : order) {
    if (keys[odr] > threshold) break;
    v.push_back(tmp[odr]);
  }
  v.shrink_to_fit();
}

void filterStr(string &v, function<bool(char)> &func);
