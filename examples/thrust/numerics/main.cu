#include "util/common.cuh"

#include <numbers> // std::numbers::pi_v
#include <thrust/complex.h>
#include <type_traits>

template <typename T> void run_tests() {
  using complex = thrust::complex<T>;

  complex ca(T{-2}, T{2});
  complex cb(T{-1}, T{1});

  constexpr int width = 18;

  auto print = [&](std::string_view name, const auto &value) {
    std::cout << std::setw(width) << std::left << name << " = " << value
              << '\n';
  };

  std::cout << "\n=== thrust::complex<"
            << (std::is_same_v<T, int> ? "int" : "float") << "> ===\n\n";

  print("real(ca)", ca.real());
  print("imag(ca)", ca.imag());
  print("ca + cb", ca + cb);
  print("ca - cb", ca - cb);
  print("ca * cb", ca * cb);

  if constexpr (std::floating_point<T>) {
    print("ca/cb", ca / cb);
  } else {
    std::cout << std::setw(width) << "ca/cb" << " = "
              << "floating point exception\n";
  }

  // dependent types must be prefixed with typename.
  print("Is int?", std::is_same_v<typename decltype(ca)::value_type, int>);
  print("Is float?", std::is_same_v<typename decltype(ca)::value_type, float>);

  // OK
  // print("Is int?", std::is_same_v<typename complex::value_type, int>);
  // OK
  // print("Is float?", std::is_same_v<typename complex::value_type, float>);

  print("abs", thrust::abs(ca));
  print("arg", thrust::arg(ca));
  print("norm", thrust::norm(ca));
  print("conj", thrust::conj(ca));
  // print("polar", thrust::polar(ca));
  // print("polar", thrust::polar(T{2}, std::numbers::pi_v<T> / T{4}));
  if constexpr (std::floating_point<T>) {
    print("polar", thrust::polar(T{2}, std::numbers::pi_v<T> / T{4}));
  } else {
    // cannot use std::numbers::pi_v<int> here
    print("polar", thrust::polar(2, 1));
  }

  print("proj", thrust::proj(ca));
  print("exp", thrust::exp(ca));
  print("log", thrust::log(ca));
  print("log10", thrust::log10(ca));

  print("pow(z,z)", thrust::pow(ca, cb));
  print("pow(z,2)", thrust::pow(ca, T{2}));

  print("sqrt", thrust::sqrt(ca));

  print("cos", thrust::cos(ca));
  print("sin", thrust::sin(ca));

  if constexpr (std::floating_point<T>) {
    print("tan", thrust::tan(ca));
  } else {
    std::cout << std::setw(width) << "tan(ca)" << " = "
              << "floating point exception\n";
  }

  print("cosh", thrust::cosh(ca));
  print("sinh", thrust::sinh(ca));
  print("tanh", thrust::tanh(ca));

  print("acos", thrust::acos(ca));
  print("asin", thrust::asin(ca));
  print("atan", thrust::atan(ca));

  print("acosh", thrust::acosh(ca));
  print("asinh", thrust::asinh(ca));
  print("atanh", thrust::atanh(ca));

  print("operator<<", ca);

  std::cout << "ca == cb = " << std::boolalpha << (ca == cb) << '\n';
  std::cout << "ca != cb = " << std::boolalpha << (ca != cb) << '\n';
}

int main() {

  run_tests<int>();
  run_tests<float>();

  return 0;
}