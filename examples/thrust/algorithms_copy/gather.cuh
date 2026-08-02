#pragma once

#include "util/common.cuh"

#include <thrust/gather.h>

namespace gather {
// Gathering
// https://nvidia.github.io/cccl/unstable/thrust/api/group__gathering_1ga9e0862c6d03cd02b9b47083043cdb129.html#thrust-gather
void demo() {
  std::cout << "\n##### Calling gather::demo() #####\n";
  // mark even indices with a 1; odd indices with a 0
  int values[10] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0};

  thrust::device_vector<int> d_input(values, values + 10);

  // gather all even indices into the first half of the range
  // and odd indices to the last half of the range
  int map[10] = {0, 2, 4, 6, 8, 1, 3, 5, 7, 9};
  thrust::device_vector<int> d_map(map, map + 10);

  {
    std::cout << "\ngather(exec, map_first, map_last, input_first, result)\n";
    thrust::device_vector<int> d_output(10);
    thrust::gather(thrust::device, d_map.begin(), d_map.end(), d_input.begin(),
                   d_output.begin());

    thrust_cout::print_vector("d_input", d_input);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {1, 1, 1, 1, 1, 0, 0, 0, 0, 0}
  }
  {
    std::cout << "\ngather(map_first, map_last, input_first, result)\n";
    thrust::device_vector<int> d_output(10);
    thrust::gather(d_map.begin(), d_map.end(), d_input.begin(),
                   d_output.begin());

    thrust_cout::print_vector("d_input", d_input);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {1, 1, 1, 1, 1, 0, 0, 0, 0, 0}
  }
}
} // namespace gather
