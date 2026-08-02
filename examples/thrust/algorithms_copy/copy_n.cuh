#include "util/common.cuh"

namespace copy_n {

void demo() {
  std::cout << "\n##### Calling void copy_n::demo() #####\n";

  int values[10] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
  thrust::device_vector<int> d_src(values, values + 10);

  {
    std::cout << "\ncopy_n(exec, first, n, result)\n";
    thrust::device_vector<int> d_dst(10, 1);
    thrust::copy_n(thrust::device, d_src.begin(), 5, d_dst.begin());

    thrust_cout::print_vector("d_src", d_src);
    thrust_cout::print_vector("d_dst", d_dst);
    // d_dst      = [0, 1, 2, 3, 4, 1, 1, 1, 1, 1]
  }
  {
    std::cout << "\ncopy_n(first, n, result)\n";
    thrust::device_vector<int> d_dst(10, 1);
    thrust::copy_n(d_src.begin(), 5, d_dst.begin());

    thrust_cout::print_vector("d_src", d_src);
    thrust_cout::print_vector("d_dst", d_dst);
    // d_dst      = [0, 1, 2, 3, 4, 1, 1, 1, 1, 1]
  }
}
} // namespace copy_n