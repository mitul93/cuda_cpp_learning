#pragma once
#include <ostream>
#include <string_view>
#include <thrust/device_vector.h>
#include <thrust/host_vector.h>

namespace thrust_cout {

constinit int label_width = 10;

template <typename T>
std::ostream &operator<<(std::ostream &os, const thrust::host_vector<T> &v) {
  os << '[';
  for (size_t i = 0; i < v.size(); ++i) {
    if (i != 0) {
      os << ", ";
    }
    os << v[i];
  }
  return os << ']';
}

template <typename T>
std::ostream &operator<<(std::ostream &os, const thrust::device_vector<T> &v) {
  os << '[';
  for (size_t i = 0; i < v.size(); ++i) {
    if (i != 0) {
      os << ", ";
    }
    os << v[i]; // Copies one element from device to host
  }
  return os << ']';
}

template <typename T>
void print_vector(std::string_view vec_name,
                  const thrust::device_vector<T> &vec) {
  std::cout << std::left;
  std::cout << std::setw(label_width) << vec_name << " = " << vec << '\n';
}

} // namespace thrust_cout