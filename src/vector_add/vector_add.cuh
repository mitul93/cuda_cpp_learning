#pragma once
#include <concepts> // <-- for std::integral / std::floating_point
#include <cuda_runtime.h>
#include <format>
#include <stdexcept>
#include <vector>

template <typename T>
__global__ void vectorAddKernel(const T *a, const T *b, T *c, std::size_t n) {
  const auto idx =
      static_cast<std::size_t>(blockIdx.x * blockDim.x + threadIdx.x);

  if (idx < n) {
    c[idx] = a[idx] + b[idx];
  }
}

template <typename T>
  requires(std::integral<T> || std::floating_point<T>)
std::vector<T> vectorAdd(const std::vector<T> &a, const std::vector<T> &b) {
  if (a.size() != b.size()) {
    throw std::invalid_argument(std::format(
        "Vector sizes must match. len(a)={}, len(b)={}", a.size(), b.size()));
  }

  const auto n = a.size();

  std::vector<T> c(n);

  T *dA = nullptr;
  T *dB = nullptr;
  T *dC = nullptr;

  cudaMalloc(&dA, n * sizeof(T));
  cudaMalloc(&dB, n * sizeof(T));
  cudaMalloc(&dC, n * sizeof(T));

  cudaMemcpy(dA, a.data(), n * sizeof(T), cudaMemcpyHostToDevice);
  cudaMemcpy(dB, b.data(), n * sizeof(T), cudaMemcpyHostToDevice);

  constexpr int threadsPerBlock = 256;
  const int blocks =
      static_cast<int>((n + threadsPerBlock - 1) / threadsPerBlock);

  vectorAddKernel<<<blocks, threadsPerBlock>>>(dA, dB, dC, n);

  cudaDeviceSynchronize();

  cudaMemcpy(c.data(), dC, n * sizeof(T), cudaMemcpyDeviceToHost);

  cudaFree(dA);
  cudaFree(dB);
  cudaFree(dC);

  return c;
}