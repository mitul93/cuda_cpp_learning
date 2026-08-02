#include <nvbench/nvbench.cuh>

#include <cuda_runtime.h>

#include <vector>

void bench_h2d(nvbench::state &state) {
  const std::size_t bytes = state.get_int64("bytes");

  // Allocate host memory
  std::vector<float> h_data(bytes / sizeof(float), 1.0f);

  // Allocate device memory
  float *d_data = nullptr;
  cudaMalloc(&d_data, bytes);

  // Warmup
  cudaMemcpy(d_data, h_data.data(), bytes, cudaMemcpyHostToDevice);

  state.exec(nvbench::exec_tag::sync, [&](nvbench::launch &launch) {
    cudaMemcpyAsync(d_data, h_data.data(), bytes, cudaMemcpyHostToDevice,
                    launch.get_stream());

    cudaStreamSynchronize(launch.get_stream());
  });

  cudaFree(d_data);
}

NVBENCH_BENCH(bench_h2d)
    .set_name("host_to_device_copy")
    .add_int64_axis("bytes", {1 << 20, 16 << 20, 64 << 20, 256 << 20});