#include "util/common.cuh"

#include <string_view>
#include <thrust/binary_search.h>

namespace lower_bound {

namespace {

struct abs_less {
  __host__ __device__ bool operator()(int a, int b) const {
    return abs(a) < abs(b);
  }
};
} // namespace

void print_value_if_found(auto &&itr, auto &&vector,
                          std::string_view prefix = "") {
  if (itr != vector.end()) {
    auto index = itr - vector.begin();
    std::cout << prefix << ", index = " << index << ", value = " << *itr
              << "\n";
  } else {
    std::cout << prefix << " , index = end()\n";
  }
}

void demo() {
  std::cout << "\n##### Calling void lower_bound::demo() #####\n";

  // // Cannot brace initialize thrust::device_vector with array
  // int values[10] = {0, 2, 5, 7, 8};
  // thrust::device_vector<int> input{values};

  thrust::device_vector<int> input{0, 2, 5, 7, 8};

  {
    std::cout << "\nlower_bound(exec, first, last, value)\n";
    thrust_cout::print_vector("input", input);

    for (int i : std::array{0, 1, 2, 3, 8, 9}) {
      auto itr =
          thrust::lower_bound(thrust::device, input.begin(), input.end(), i);
      print_value_if_found(itr, input, "lower_bound " + std::to_string(i));
    }
  }

  {
    std::cout << "\nlower_bound(exec, first, last, value, comp)\n";
    thrust_cout::print_vector("input", input);

    for (int i : std::array{0, 1, 2, 3, 8, 9}) {
      auto itr = thrust::lower_bound(thrust::device, input.begin(), input.end(),
                                     i, ::cuda::std::less<int>());
      print_value_if_found(itr, input, "lower_bound " + std::to_string(i));
    }
  }
  {
    std::cout << "Custom comp : lower_bound(exec, first, last, value, comp)\n";
    thrust::device_vector<int> data = {-1, 3, -5, 8, 10};
    thrust_cout::print_vector("data", data);
    int value = -4;
    auto itr = thrust::lower_bound(thrust::device, data.begin(), data.end(),
                                   value, abs_less{});
    print_value_if_found(itr, data, "lower_bound " + std::to_string(value));
  }
  {
    // Instead of query one by one, you can query entire array 'values'
    std::cout << "\nlower_bound(exec, first, last, values_first, values_last, "
                 "result)\n";
    thrust::device_vector<int> values{0, 1, 2, 3, 8, 9};
    thrust_cout::print_vector("values", values);

    thrust::device_vector<unsigned int> result(6);

    thrust::lower_bound(thrust::device, input.begin(), input.end(),
                        values.begin(), values.end(), result.begin());
    thrust_cout::print_vector("result", result);
    // output = [ 0, 1, 1, 2, 4, 5 ]
    // Note that end of vector input.end(), written as len(input) i.e. 5
  }
  {
    std::cout << "\nlower_bound(exec, first, last, values_first, values_last, "
                 "result, comp)\n";
    thrust::device_vector<int> data = {10, 8, 6, 4, 2};
    thrust::device_vector<int> values = {9, 6, 1};

    thrust_cout::print_vector("data", data);
    thrust_cout::print_vector("values", values);

    thrust::device_vector<int> result(values.size());
    thrust::lower_bound(thrust::device, data.begin(), data.end(),
                        values.begin(), values.end(), result.begin(),
                        ::cuda::std::greater<int>());

    thrust_cout::print_vector("result", result);
    // result = [ 1, 2, 5 ]
    // Note that end of vector data.end(), written as len(data) i.e. 5
  }
}
} // namespace lower_bound