#include "util/common.cuh"

#include <ranges>
#include <thrust/binary_search.h>
#include <thrust/sequence.h>

namespace binary_search {
void demo() {
  std::cout << "\n##### Calling void binary_search::demo() #####\n";
  thrust::device_vector<int> input{0, 2, 5, 7, 8};

  {
    std::cout << "\nbinary_search(exec, first, last, value)\n";
    thrust_cout::print_vector("input", input);

    for (const auto val : std::views::iota(1, 10)) {
      const auto found = thrust::binary_search(thrust::device, input.begin(),
                                               input.end(), val);
      std::cout << "val = " << val << ", Found in input\? = " << std::boolalpha
                << found << "\n";
    }
  }
  {
    std::cout << "\nbinary_search(first, last, value, comp)\n";
    thrust::device_vector<int> data = {10, 8, 6, 4, 2};

    thrust_cout::print_vector("data", data);

    for (const auto val : std::views::iota(1, 10) | std::views::reverse) {
      const auto found = thrust::binary_search(data.begin(), data.end(), val,
                                               ::cuda::std::greater<int>());
      std::cout << "val = " << val << ", Found in data\? = " << std::boolalpha
                << found << "\n";
    }
  }
  {
    // Instead of query one by one, you can query entire array 'values'
    std::cout
        << "\nbinary_search(exec, first, last, values_first, values_last, "
           "result)\n";
    thrust::device_vector<int> values(10);
    thrust::sequence(values.begin(), values.end(), 1);

    thrust_cout::print_vector("input", input);
    thrust_cout::print_vector("values", values);

    thrust::device_vector<bool> result(10);

    thrust::binary_search(thrust::device, input.begin(), input.end(),
                          values.begin(), values.end(), result.begin());

    thrust_cout::print_vector("result", result);
    // result = [ false, true, false, false, true, false, true, true, false,
    // false ]
  }
  {
    std::cout
        << "\nbinary_search(exec, first, last, values_first, values_last, "
           "result, comp)\n";
    thrust::device_vector<int> data = {10, 8, 6, 4, 2};
    thrust::device_vector<int> values(10);
    thrust::sequence(values.begin(), values.end(), 1);

    thrust_cout::print_vector("data", data);
    thrust_cout::print_vector("values", values);

    thrust::device_vector<bool> result(10);

    const auto found = thrust::binary_search(
        thrust::device, data.begin(), data.end(), values.begin(), values.end(),
        result.begin(), ::cuda::std::greater<int>());

    thrust_cout::print_vector("result", result);
    // result     = [false, true, false, true, false, true, false, true, false,
    // true]
  }
}
} // namespace binary_search