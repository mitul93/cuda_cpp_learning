#pragma once

#include "util/common.cuh"

#include <thrust/scatter.h>

namespace scatter {

void demo() {
  std::cout << "\n##### Calling void scatter::demo() #####\n";

  // mark even indices with a 1; odd indices with a 0
  int values[10] = {10, 1, 20, 2, 30, 3, 40, 4, 50, 5};
  thrust::device_vector<int> d_values(values, values + 10);

  // scatter all even indices into the first half of the
  // range, and odd indices vice versa
  int map[10] = {0, 5, 1, 6, 2, 7, 3, 8, 4, 9};
  thrust::device_vector<int> d_map(map, map + 10);

  {
    std::cout << "\nscatter(exec, first, last, map, result)\n";
    thrust::device_vector<int> d_output(10);
    thrust::scatter(thrust::device, d_values.begin(), d_values.end(),
                    d_map.begin(), d_output.begin());

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    // d_output is now {10, 20, 30, 40, 50, 1, 2, 3, 4, 5}
    thrust_cout::print_vector("d_output", d_output);
  }
  {
    std::cout << "\nscatter(first, last, map, result)\n";
    thrust::device_vector<int> d_output(10);
    thrust::scatter(d_values.begin(), d_values.end(), d_map.begin(),
                    d_output.begin());

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    // d_output is now {10, 20, 30, 40, 50, 1, 2, 3, 4, 5}
    thrust_cout::print_vector("d_output", d_output);
  }
}
} // namespace scatter
