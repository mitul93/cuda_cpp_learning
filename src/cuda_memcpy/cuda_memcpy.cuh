#include <cuda_runtime.h>

namespace cuda_memcpy {

template <typename T>
void copy_h2d(T *d_dst, const T *h_src, std::size_t count) {
  cudaMemcpy(d_dst, h_src, count * sizeof(T), cudaMemcpyHostToDevice);
}

template <typename T>
void copy_d2h(T *d_dst, const T *h_src, std::size_t count) {
  cudaMemcpy(d_dst, h_src, count * sizeof(T), cudaMemcpyDeviceToHost);
}

} // namespace cuda_memcpy