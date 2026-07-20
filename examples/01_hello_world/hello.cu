#include "hello.h"

#include <cstdio>
#include <cuda_runtime.h>

__global__ void helloKernel() {
  printf("Hello from thread %d, block %d\n", threadIdx.x, blockIdx.x);
}

void launchHello() {
  helloKernel<<<2, 4>>>();
  cudaDeviceSynchronize();
}