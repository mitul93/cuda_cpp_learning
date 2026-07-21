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

  cudaEvent_t start, stop;
  cudaEventCreate(&start);
  cudaEventCreate(&stop);

  cudaEventRecord(start);
  for (auto _ : state) {
    cuda_memcpy::copy_h2d<T>(d_data, h_data, elements);
  }
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);

  state.SetBytesProcessed(static_cast<int64_t>(state.iterations()) *
                          static_cast<int64_t>(bytes));
  state.SetLabel("H2D");

  float avg_cuda_ms = 0;
  cudaEventElapsedTime(&avg_cuda_ms, start, stop);

  // Tell Google Benchmark the real GPU time
  state.counters["cuda_ms"] = avg_cuda_ms / state.iterations();

  cudaEventDestroy(start);
  cudaEventDestroy(stop);
  cudaFreeHost(h_data);
  cudaFree(d_data);
}

// Range 10^3 to 10^6 elementds
#define TEST_PARAMETERS Range(1e3, 1e6)->Iterations(10)->Repetitions(1);

BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->TEST_PARAMETERS;
BENCHMARK_TEMPLATE(BM_cuda_h2d, int)->TEST_PARAMETERS;
BENCHMARK_TEMPLATE(BM_cuda_h2d, float)->TEST_PARAMETERS;
BENCHMARK_TEMPLATE(BM_cuda_h2d, double)->TEST_PARAMETERS;

BENCHMARK_MAIN();