#include <iostream>
#include <numeric>

#include "vector_add/vector_add.cuh"

int main() {

  constexpr std::size_t n = 1'000'000;

  std::vector<int> a(n);
  std::vector<int> b(n);

  std::iota(a.begin(), a.end(), 0); // a = {0, 1, 2, 3, ..., n-1}
  std::iota(b.begin(), b.end(), 1); // b = {1, 2, 3, 4, ..., n}

  auto c = vectorAdd(a, b); // c = {1, 3, 5, 7, 9, ..., 2n+1}

  for (int index = 0; index < n; index++) {
    if (c.at(index) != (2 * index) + 1) {
      std::cout << "Value mismatch at index=" << index << "\n";
      break;
    }
  }

  return 0;
}