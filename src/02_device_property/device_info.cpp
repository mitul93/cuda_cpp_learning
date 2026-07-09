#include "device_info.h"
// this is .cpp file <cuda.h> will not work here
#include <cuda_runtime.h>
#include <format>
#include <iostream>
#include <string>

namespace {
int get_attr(cudaDeviceAttr attr, int device) {
  int value = 0;
  cudaDeviceGetAttribute(&value, attr, device);
  return value;
}
} // namespace

void print_device_info() {
  int nDevices;
  cudaGetDeviceCount(&nDevices);

  constexpr int kLabelWidth = 34;

  for (int i = 0; i < nDevices; i++) {
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, i);

    const int memoryClockRate = get_attr(cudaDevAttrMemoryClockRate, i);
    const int clockRate = get_attr(cudaDevAttrClockRate, i);
    const int maxTexture1DLinear =
        get_attr(cudaDevAttrMaxTexture1DLinearWidth, i);

    std::cout << std::format("{:<{}}: {}\n", "Device Number", kLabelWidth, i);
    std::cout << std::format("{:<{}}: {}\n", "Device name", kLabelWidth,
                             prop.name);

    // Format UUID
    std::string uuid;
    for (int j = 0; j < 16; ++j) {
      if (j != 0) {
        uuid += '-';
      }
      uuid += std::format("{:02X}", static_cast<unsigned>(prop.uuid.bytes[j]));
    }
    std::cout << std::format("{:<{}}: {}\n", "Device UUID", kLabelWidth, uuid);

    std::cout << std::format(
        "{:<{}}: {:.2f}\n", "total global memory (GBytes)", kLabelWidth,
        static_cast<double>(prop.totalGlobalMem) / 1024 / 1024 / 1024);
    std::cout << std::format("{:<{}}: {}\n", "compute capability major",
                             kLabelWidth, prop.major);
    std::cout << std::format("{:<{}}: {}\n", "capability minor", kLabelWidth,
                             prop.minor);
    std::cout << std::format(
        "{:<{}}: {} B, {} KiB\n", "shared memory per block (bytes)",
        kLabelWidth, prop.sharedMemPerBlock, prop.sharedMemPerBlock / 1024.0);
    std::cout << std::format("{:<{}}: {} KHz, {} MHz, {} GHz\n",
                             "Peak Memory Clock Rate (KHz)", kLabelWidth,
                             memoryClockRate, memoryClockRate / 1e3,
                             memoryClockRate / 1e6);
    std::cout << std::format("{:<{}}: {}\n", "Memory Bus Width (bits)",
                             kLabelWidth, prop.memoryBusWidth);
    std::cout << std::format(
        "{:<{}}: {:.2f}\n", "Peak Memory Bandwidth (GB/s)", kLabelWidth,
        2.0 * memoryClockRate * (prop.memoryBusWidth / 8) / 1.0e6);
    std::cout << std::format("{:<{}}: {}\n", "warp size", kLabelWidth,
                             prop.warpSize);
    std::cout << std::format("{:<{}}: {}\n", "max thread per block",
                             kLabelWidth, prop.maxThreadsPerBlock);
    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max thread dimension (x,y,z)", kLabelWidth,
        prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);
    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max grid size (x, y, z)", kLabelWidth,
        prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
    std::cout << std::format("{:<{}}: {}\n", "max clock rate (MHz)",
                             kLabelWidth, clockRate / 1024);
    std::cout << std::format("{:<{}}: {}\n", "total constant memory (bytes)",
                             kLabelWidth, prop.totalConstMem);
    std::cout << std::format("{:<{}}: {}\n", "max texture 1D", kLabelWidth,
                             prop.maxTexture1D);
    std::cout << std::format("{:<{}}: {}\n", "max texture 1D mipmapped",
                             kLabelWidth, prop.maxTexture1DMipmap);
    std::cout << std::format("{:<{}}: {}\n", "max texture 1D linear",
                             kLabelWidth, maxTexture1DLinear);
    std::cout << std::format("{:<{}}: ({}, {})\n", "max texture 2D (x, y)",
                             kLabelWidth, prop.maxTexture2D[0],
                             prop.maxTexture2D[1]);
    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 2D mipmapped (x, y)", kLabelWidth,
        prop.maxTexture2DMipmap[0], prop.maxTexture2DMipmap[1]);
    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 2D linear (x, y)", kLabelWidth,
        prop.maxTexture2DLinear[0], prop.maxTexture2DLinear[1]);
    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max texture 3D (x, y, z)", kLabelWidth,
        prop.maxTexture3D[0], prop.maxTexture3D[1], prop.maxTexture3D[2]);
    std::cout << std::format("{:<{}}: ({}, {}, {})\n",
                             "max texture 3D Alt (x, y, z)", kLabelWidth,
                             prop.maxTexture3DAlt[0], prop.maxTexture3DAlt[1],
                             prop.maxTexture3DAlt[2]);
    std::cout << std::format("{:<{}}: {}\n", "max texture cubemap", kLabelWidth,
                             prop.maxTextureCubemap);
    std::cout << std::format("{:<{}}: {}\n", "max concurrent kernels",
                             kLabelWidth, prop.concurrentKernels);
    std::cout << std::format("{:<{}}: {}\n", "pci bus id", kLabelWidth,
                             prop.pciBusID);
    std::cout << std::format("{:<{}}: {}\n", "pci device id", kLabelWidth,
                             prop.pciDeviceID);
    std::cout << std::format("{:<{}}: {}\n", "pci domain id", kLabelWidth,
                             prop.pciDomainID);
    std::cout << std::format("{:<{}}: {}\n", "asynchronous engine count",
                             kLabelWidth, prop.asyncEngineCount);
    std::cout << std::format("{:<{}}: {} KiB, {} MiB\n", "L2 cache size",
                             kLabelWidth, prop.l2CacheSize / 1024.0,
                             prop.l2CacheSize / 1024.0 / 1024.0);
    std::cout << std::format("{:<{}}: {}\n", "unified addressing", kLabelWidth,
                             prop.unifiedAddressing);
    std::cout << std::format("{:<{}}: {}\n", "max thread per multiprocessor",
                             kLabelWidth, prop.maxThreadsPerMultiProcessor);
    std::cout << std::format("{:<{}}: {} B, {} KiB, {} MiB\n",
                             "shared memory per multiprocessor", kLabelWidth,
                             prop.sharedMemPerMultiprocessor,
                             prop.sharedMemPerMultiprocessor / 1024.0,
                             prop.sharedMemPerMultiprocessor / 1024.0 / 1024.0);
    std::cout << std::format("{:<{}}: {}\n", "register per multiprocessor",
                             kLabelWidth, prop.regsPerMultiprocessor);
    std::cout << std::format("{:<{}}: {}\n",
                             "max resident block per multiprocessor",
                             kLabelWidth, prop.maxBlocksPerMultiProcessor);
  }
}