#include "vector_add.h"

#include <concepts> // <-- for std::integral / std::floating_point
#include <cstdio>
#include <cuda.h>

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
    throw std::invalid_argument("Vector sizes must match.");
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

// Explicit instantiation — generates actual code for these two types,
// so their symbols exist in the compiled .cu object for the linker to find.
// Slightly larger binary.
template std::vector<int> vectorAdd<int>(const std::vector<int> &,
                                         const std::vector<int> &);
template std::vector<float> vectorAdd<float>(const std::vector<float> &,
                                             const std::vector<float> &);