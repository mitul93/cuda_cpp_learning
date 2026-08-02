#pragma once
#include "util/common.cuh"

#include <thrust/scatter.h>

namespace scatter_if {

namespace {
struct is_even {
  __host__ __device__ bool operator()(const int x) {
    return (x % 2) == 0;
  }
};

auto lambda_is_even_annonymous_namespace = [] __host__ __device__(const int x) {
  return (x % 2) == 0;
};

}; // namespace

namespace scatter_if_foo {
auto lambda_is_even = [] __host__ __device__(const int x) {
  return (x % 2) == 0;
};
} // namespace scatter_if_foo

void demo() {
  std::cout << "\n##### Calling void scatter_if::demo() #####\n";

  // mark even indices with a 1; odd indices with a 0
  int values[10] = {10, 1, 20, 2, 30, 3, 40, 4, 50, 5};
  thrust::device_vector<int> d_values(values, values + 10);

  // scatter all even indices into the first half of the
  // range, and odd indices vice versa
  int map[10] = {0, 5, 1, 6, 2, 7, 3, 8, 4, 9};
  thrust::device_vector<int> d_map(map, map + 10);

  // select elements at even-indexed locations
  int stencil[10] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0};
  thrust::device_vector<int> d_stencil(stencil, stencil + 10);

  {
    std::cout << "\nscatter_if(exec, first, last, map, stencil, output)\n";
    thrust::device_vector<int> d_output(10);
    thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
                       d_map.begin(), d_stencil.begin(), d_output.begin());

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output   = [10, 20, 30, 40, 50, 0, 0, 0, 0, 0]
  }
  {
    std::cout << "\nscatter_if(first, last, map, stencil, output)\n";
    thrust::device_vector<int> d_output(10);
    thrust::scatter_if(d_values.begin(), d_values.end(), d_map.begin(),
                       d_stencil.begin(), d_output.begin());

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output   = [10, 20, 30, 40, 50, 0, 0, 0, 0, 0]
  }
  {
    std::cout
        << "\nscatter_if(exec, first, last, map, stencil, output, pred)\n";
    thrust::device_vector<int> d_output(10);
    is_even pred;
    thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
                       d_map.begin(), d_stencil.begin(), d_output.begin(),
                       pred);

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output = [ 0, 0, 0, 0, 0, 1, 2, 3, 4, 5 ]

    // // is_even() functor also valid
    // thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
    //                    d_map.begin(), d_stencil.begin(), d_output.begin(),
    //                    is_even());

    // // lambda_is_even also valid
    // auto lambda_is_even = [] __host__ __device__(const int x) {
    //   return (x % 2) == 0;
    // };

    // thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
    //                    d_map.begin(), d_stencil.begin(), d_output.begin(),
    //                    lambda_is_even);

    // // inline lambdas are also valid
    // thrust::scatter_if(
    //     thrust::device, d_values.begin(), d_values.end(), d_map.begin(),
    //     d_stencil.begin(), d_output.begin(),
    //     [] __host__ __device__(const int x) { return (x % 2) == 0; });

    // // lambda_is_even_annonymous_namespace could not compile
    // /tmp/tmpxft_0000586a_00000000-6_main.cudafe1.stub.c:24:657: error:
    // 'lambda_is_even' is
    //   not a class, namespace, or enumeration
    // 24 |   ...::cuda::std::__4::identity> ,
    // ::scatter_if::_NV_ANON_NAMESPACE::lambda_is_even::[lambda(int) (inst...
    // thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
    //                    d_map.begin(), d_stencil.begin(), d_output.begin(),
    //                    lambda_is_even_annonymous_namespace);

    // // scatter_if_foo::lambda_is_even cannot compile. same problem as
    // lambda_is_even_annonymous_namespace
    // thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
    //                    d_map.begin(), d_stencil.begin(), d_output.begin(),
    //                    scatter_if_foo::lambda_is_even);
  }
  {
    std::cout << "\nscatter_if(first, last, map, stencil, output, pred)\n";
    thrust::device_vector<int> d_output(10);
    thrust::scatter_if(thrust::device, d_values.begin(), d_values.end(),
                       d_map.begin(), d_stencil.begin(), d_output.begin(),
                       is_even());

    thrust_cout::print_vector("values", d_values);
    thrust_cout::print_vector("d_map", d_map);
    thrust_cout::print_vector("d_stencil", d_stencil);
    thrust_cout::print_vector("d_output", d_output);
    // d_output = [ 0, 0, 0, 0, 0, 1, 2, 3, 4, 5 ]
  }
}
} // namespace scatter_if