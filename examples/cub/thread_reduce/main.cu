#include <cub/cub.cuh>

__global__ void reduce_kernel() {
  int tid = threadIdx.x;
  int array[4] = {tid, tid + 1, tid + 2, tid + 3};

  int sum = cub::ThreadReduce(array, ::cuda::std::plus<>{});

  if (tid == 0 || tid == 5) {
    printf("tid = %d, sum = %d\n", tid, sum);
  }
}

int main() {
  reduce_kernel<<<1, 8>>>();
  cudaDeviceSynchronize();
  return 0;
}