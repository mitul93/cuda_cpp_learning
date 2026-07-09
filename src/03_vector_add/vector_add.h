#pragma once

#include <concepts> // <-- for std::integral / std::floating_point
#include <stdexcept>
#include <vector>

template <typename T>
  requires(std::integral<T> || std::floating_point<T>)
std::vector<T> vectorAdd(const std::vector<T> &a, const std::vector<T> &b);
