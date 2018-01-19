
#include "Util.h"
#include <functional>

void filterStr(string& v, function<bool(char)>& func) {
  unsigned j = 0;
  for (unsigned i = 0; i < v.size(); i++)
    if (func(v[i])) v[j++] = v[i];
  v.resize(j);
  v.shrink_to_fit();
};