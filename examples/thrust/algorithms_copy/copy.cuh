#pragma once

#include <thrust/copy.h>

#include "util/common.cuh"

namespace copy {
void demo() {
  std::cout << "\n##### Calling void copy::demo() #####\n";

  int values[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  thrust::device_vector<int> d_src(values, values + 10);

  {
    std::cout << "\ncopy(exec, first, last, result)\n";
    thrust::device_vector<int> d_dst(10);
    thrust::copy(thrust::device, d_src.begin(), d_src.end(), d_dst.begin());

    thrust_cout::print_vector("d_src", d_src);
    thrust_cout::print_vector("d_dst", d_dst);
    // d_dst      = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  }
  {
    std::cout << "\ncopy(first, last, result)\n";
    thrust::device_vector<int> d_dst(10);
    thrust::copy(d_src.begin(), d_src.end(), d_dst.begin());

    thrust_cout::print_vector("d_src", d_src);
    thrust_cout::print_vector("d_dst", d_dst);
    // d_dst      = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  }
}
} // namespace copy