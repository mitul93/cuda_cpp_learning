#include <benchmark/benchmark.h>
#include <cuda_runtime.h>

#include "cuda_memcpy/cuda_memcpy.cuh"

template <typename T> static void BM_cuda_h2d(benchmark::State &state) {
  size_t elements = state.range(0);
  size_t bytes = elements * sizeof(T);

  T *h_data = nullptr;
  T *d_data = nullptr;

  cudaMallocHost(&h_data, bytes);
  cudaMalloc(&d_data, bytes);

  for (size_t i = 0; i < elements; i++) {
    h_data[i] = static_cast<T>(i);
  }

  // warmup
  cuda_memcpy::copy_h2d<T>(d_data, h_data, elements);
  cudaDeviceSynchronize();

  for (auto _ : state) {
    cuda_memcpy::copy_h2d<T>(d_data, h_data, elements);
  }

  state.SetBytesProcessed(static_cast<int64_t>(state.iterations()) *
                          static_cast<int64_t>(bytes));
  state.SetLabel("H2D");

  cudaFreeHost(h_data);
  cudaFree(d_data);
}

// Range 10^6 to 10^9 elementds
BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->Range(1e3, 1e6)->Repetitions(1);
BENCHMARK_TEMPLATE(BM_cuda_h2d, int)->Range(1e3, 1e6)->Repetitions(1);
BENCHMARK_TEMPLATE(BM_cuda_h2d, float)->Range(1e3, 1e6)->Repetitions(1);
BENCHMARK_TEMPLATE(BM_cuda_h2d, double)->Range(1e3, 1e6)->Repetitions(1);

BENCHMARK_MAIN();