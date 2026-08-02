#pragma once

#include <thrust/gather.h>

#include "util/common.cuh"

namespace gather_if {

namespace {

struct is_even {
  __host__ __device__ bool operator()(const int x) {
    return (x % 2) == 0;
  }
};

} // namespace

// https://nvidia.github.io/cccl/unstable/thrust/api/group__gathering_1gabe7fcb9789daffbdb2be995be1494240.html#thrust-gather-if
void demo() {

  std::cout << "\n##### Calling void gather_if::demo() #####\n";
  int values[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  thrust::device_vector<int> d_values(values, values + 10);

  // select elements at even-indexed locations
  int stencil[10] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0};
  thrust::device_vector<int> d_stencil(stencil, stencil + 10);

  // map all even indices into the first half of the range
  // and odd indices to the last half of the range
  int map[10] = {0, 2, 4, 6, 8, 1, 3, 5, 7, 9};
  thrust::device_vector<int> d_map(map, map + 10);

  {
    std::cout << "\ngather_if(exec, map_first, map_last, stencil, input_first, "
                 "result)\n";
    thrust::device_vector<int> d_output(10, 7);
    // thrust::fill(d_output.begin(), d_output.end(), 7); // also valid
    thrust::gather_if(thrust::device, d_map.begin(), d_map.end(),
                      d_stencil.begin(), d_values.begin(), d_output.begin());

    thrust_cout::print_vector("d_values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }
  {
    std::cout
        << "\ngather_if(map_first, map_last, stencil, input_first, result)\n";
    thrust::device_vector<int> d_output(10, 7);
    thrust::gather_if(d_map.begin(), d_map.end(), d_stencil.begin(),
                      d_values.begin(), d_output.begin());

    thrust_cout::print_vector("d_values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }
  {
    std::cout << "\ngather_if(exec, map_first, map_last, stencil, input_first, "
                 "result, pred)\n";
    thrust::device_vector<int> d_output(10, 7);
    thrust::gather_if(thrust::device, d_map.begin(), d_map.end(),
                      d_stencil.begin(), d_values.begin(), d_output.begin(),
                      is_even());

    thrust_cout::print_vector("d_values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }
  {
    std::cout
        << "\ngather_if(map_first, map_last, stencil, input_first, result, "
           "pred)\n";
    thrust::device_vector<int> d_output(10, 7);
    thrust::gather_if(d_map.begin(), d_map.end(), d_stencil.begin(),
                      d_values.begin(), d_output.begin(), is_even());

    thrust_cout::print_vector("d_values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }

  // predicate can be lambda, but nvcc requires --extended-lambda flag
  {
    thrust::device_vector<int> d_output(10, 7);
    thrust::gather_if(
        d_map.begin(), d_map.end(), d_stencil.begin(), d_values.begin(),
        d_output.begin(),
        [] __host__ __device__(const int x) { return (x % 2) == 0; });
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }

  {
    // error: __host__ __device__ extended lambdas cannot be generic lambdas
    // auto is_even = [] __host__ __device__(const auto x) {
    //   return (x % 2) == 0;
    // };

    auto is_even = [] __host__ __device__(const int x) { return (x % 2) == 0; };

    thrust::device_vector<int> d_output(10, 7);
    thrust::gather_if(d_map.begin(), d_map.end(), d_stencil.begin(),
                      d_values.begin(), d_output.begin(), is_even);
    // d_output is now {0, 7, 4, 7, 8, 7, 3, 7, 7, 7}
  }
}

} // namespace gather_if