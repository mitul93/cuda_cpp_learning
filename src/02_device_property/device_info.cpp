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

  constexpr int kLabelWidth = 40;

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

    std::cout << std::format(
        "{:<{}}: {} B, {} KiB\n", "shared memory per block (bytes)",
        kLabelWidth, prop.sharedMemPerBlock, prop.sharedMemPerBlock / 1024.0);

    std::cout << std::format("{:<{}}: {}\n", "warp size", kLabelWidth,
                             prop.warpSize);

    std::cout << std::format("{:<{}}: {}\n", "max pitch (bytes) in memory copy",
                             kLabelWidth, prop.memPitch);

    std::cout << std::format("{:<{}}: {}\n", "32-bit registers per block",
                             kLabelWidth, prop.regsPerBlock);

    std::cout << std::format("{:<{}}: {}\n", "max thread per block",
                             kLabelWidth, prop.maxThreadsPerBlock);

    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max thread dimension (x,y,z)", kLabelWidth,
        prop.maxThreadsDim[0], prop.maxThreadsDim[1], prop.maxThreadsDim[2]);

    std::cout << std::format("{:<{}}: ({}, {}, {})\n", "max grid size (x,y,z)",
                             kLabelWidth, prop.maxGridSize[0],
                             prop.maxGridSize[1], prop.maxGridSize[2]);

    std::cout << std::format("{:<{}}: {}\n", "total constant memory (bytes)",
                             kLabelWidth, prop.totalConstMem);

    std::cout << std::format("{:<{}}: {}\n", "compute capability major",
                             kLabelWidth, prop.major);

    std::cout << std::format("{:<{}}: {}\n", "capability minor", kLabelWidth,
                             prop.minor);

    std::cout << std::format("{:<{}}: {}\n",
                             "alignment requirement for texture", kLabelWidth,
                             prop.textureAlignment);

    std::cout << std::format("{:<{}}: {}\n", "texture pitch alignment",
                             kLabelWidth, prop.texturePitchAlignment);

    std::cout << std::format("{:<{}}: {}\n", "multiprocessor count",
                             kLabelWidth, prop.multiProcessorCount);

    std::cout << std::format("{:<{}}: {}\n", "device is integrated",
                             kLabelWidth, prop.integrated);

    std::cout << std::format("{:<{}}: {}\n", "can map host memory", kLabelWidth,
                             prop.canMapHostMemory);

    std::cout << std::format("{:<{}}: {}\n", "max texture 1D", kLabelWidth,
                             prop.maxTexture1D);

    std::cout << std::format("{:<{}}: {}\n", "max texture 1D mipmapped",
                             kLabelWidth, prop.maxTexture1DMipmap);

    std::cout << std::format("{:<{}}: ({}, {})\n", "max texture 2D (x,y)",
                             kLabelWidth, prop.maxTexture2D[0],
                             prop.maxTexture2D[1]);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 2D mipmapped (x,y)", kLabelWidth,
        prop.maxTexture2DMipmap[0], prop.maxTexture2DMipmap[1]);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 2D linear (x, y, pitch)",
        kLabelWidth, prop.maxTexture2DLinear[0], prop.maxTexture2DLinear[1],
        prop.maxTexture2DLinear[2]);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 2D gather (x,y)", kLabelWidth,
        prop.maxTexture2DGather[0], prop.maxTexture2DGather[1]);

    std::cout << std::format("{:<{}}: ({}, {}, {})\n", "max texture 3D (x,y,z)",
                             kLabelWidth, prop.maxTexture3D[0],
                             prop.maxTexture3D[1], prop.maxTexture3D[2]);

    std::cout << std::format("{:<{}}: ({}, {}, {})\n",
                             "max texture 3D Alt (x,y,z)", kLabelWidth,
                             prop.maxTexture3DAlt[0], prop.maxTexture3DAlt[1],
                             prop.maxTexture3DAlt[2]);

    std::cout << std::format("{:<{}}: {}\n", "max texture cubemap", kLabelWidth,
                             prop.maxTextureCubemap);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture 1D layered (x,y)", kLabelWidth,
        prop.maxTexture1DLayered[0], prop.maxTexture1DLayered[1]);

    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max texture 2D layered (x,y,z)", kLabelWidth,
        prop.maxTexture2DLayered[0], prop.maxTexture2DLayered[1],
        prop.maxTexture2DLayered[2]);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max texture cubemap layered (x,y)", kLabelWidth,
        prop.maxTextureCubemapLayered[0], prop.maxTextureCubemapLayered[1]);

    std::cout << std::format("{:<{}}: {}\n", "max 1D surface size", kLabelWidth,
                             prop.maxSurface1D);

    std::cout << std::format("{:<{}}: ({}, {})\n", "max 2D surface size (x,y)",
                             kLabelWidth, prop.maxSurface2D[0],
                             prop.maxSurface2D[1]);

    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max 3D surface size (x,y,z)", kLabelWidth,
        prop.maxSurface3D[0], prop.maxSurface3D[1], prop.maxSurface3D[2]);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max surface 1D layered (x,y)", kLabelWidth,
        prop.maxSurface1DLayered[0], prop.maxSurface1DLayered[1]);

    std::cout << std::format(
        "{:<{}}: ({}, {}, {})\n", "max surface 2D layered (x,y,z)", kLabelWidth,
        prop.maxSurface2DLayered[0], prop.maxSurface2DLayered[1],
        prop.maxSurface2DLayered[2]);

    std::cout << std::format("{:<{}}: {}\n", "max cubemap surface dim",
                             kLabelWidth, prop.maxSurfaceCubemap);

    std::cout << std::format(
        "{:<{}}: ({}, {})\n", "max cubemap layered dim (x,y)", kLabelWidth,
        prop.maxSurfaceCubemapLayered[0], prop.maxSurfaceCubemapLayered[1]);

    std::cout << std::format("{:<{}}: {}\n", "surface alignment reqruirement",
                             kLabelWidth, prop.surfaceAlignment);

    std::cout << std::format("{:<{}}: {}\n", "max concurrent kernels",
                             kLabelWidth, prop.concurrentKernels);

    std::cout << std::format("{:<{}}: {}\n", "ECC support enabled", kLabelWidth,
                             prop.ECCEnabled);

    std::cout << std::format("{:<{}}: {}\n", "pci bus id", kLabelWidth,
                             prop.pciBusID);

    std::cout << std::format("{:<{}}: {}\n", "pci device id", kLabelWidth,
                             prop.pciDeviceID);

    std::cout << std::format("{:<{}}: {}\n", "pci domain id", kLabelWidth,
                             prop.pciDomainID);

    std::cout << std::format("{:<{}}: {}\n", "asynchronous engine count",
                             kLabelWidth, prop.asyncEngineCount);

    std::cout << std::format("{:<{}}: {}\n", "unified addressing", kLabelWidth,
                             prop.unifiedAddressing);

    std::cout << std::format("{:<{}}: {}\n", "Memory Bus Width (bits)",
                             kLabelWidth, prop.memoryBusWidth);

    std::cout << std::format("{:<{}}: {} KiB, {} MiB\n", "L2 cache size",
                             kLabelWidth, prop.l2CacheSize / 1024.0,
                             prop.l2CacheSize / 1024.0 / 1024.0);

    std::cout << std::format("{:<{}}: {} Bytes\n", "Max L2 persisting lines",
                             kLabelWidth, prop.persistingL2CacheMaxSize);

    std::cout << std::format("{:<{}}: {}\n", "max thread per multiprocessor",
                             kLabelWidth, prop.maxThreadsPerMultiProcessor);

    std::cout << std::format("{:<{}}: {}\n", "support stream priorities",
                             kLabelWidth, prop.streamPrioritiesSupported);

    std::cout << std::format("{:<{}}: {}\n", "support caching globals in L1",
                             kLabelWidth, prop.globalL1CacheSupported);

    std::cout << std::format("{:<{}}: {}\n", "support caching locals in L1",
                             kLabelWidth, prop.localL1CacheSupported);

    std::cout << std::format("{:<{}}: {} B, {} KiB, {} MiB\n",
                             "shared memory per multiprocessor", kLabelWidth,
                             prop.sharedMemPerMultiprocessor,
                             prop.sharedMemPerMultiprocessor / 1024.0,
                             prop.sharedMemPerMultiprocessor / 1024.0 / 1024.0);

    std::cout << std::format("{:<{}}: {}\n", "register per multiprocessor",
                             kLabelWidth, prop.regsPerMultiprocessor);

    std::cout << std::format("{:<{}}: {}\n",
                             "supports allocating managed memory", kLabelWidth,
                             prop.managedMemory);

    std::cout << std::format("{:<{}}: {}\n", "device is on a multi-GPU board",
                             kLabelWidth, prop.isMultiGpuBoard);

    std::cout << std::format("{:<{}}: {}\n", "multi gpu board group ID",
                             kLabelWidth, prop.multiGpuBoardGroupID);

    std::cout << std::format("{:<{}}: {}\n",
                             "supports native atomic operations", kLabelWidth,
                             prop.hostNativeAtomicSupported);

    std::cout << std::format("{:<{}}: {}\n", "supports pageable memory access",
                             kLabelWidth, prop.pageableMemoryAccess);

    std::cout << std::format("{:<{}}: {}\n", "concurrent managed memory access",
                             kLabelWidth, prop.concurrentManagedAccess);

    std::cout << std::format("{:<{}}: {}\n", "supports compute preemption",
                             kLabelWidth, prop.computePreemptionSupported);

    std::cout << std::format("{:<{}}: {}\n",
                             "canUseHostPointerForRegisteredMem", kLabelWidth,
                             prop.canUseHostPointerForRegisteredMem);

    std::cout << std::format("{:<{}}: {}\n", "cooperative launch", kLabelWidth,
                             prop.cooperativeLaunch);

    std::cout << std::format("{:<{}}: {}\n", "shared memory per block (opt-in)",
                             kLabelWidth, prop.sharedMemPerBlockOptin);

    std::cout << std::format(
        "{:<{}}: {}\n", "pageableMemoryAccessUsesHostPageTables", kLabelWidth,
        prop.pageableMemoryAccessUsesHostPageTables);

    std::cout << std::format("{:<{}}: {}\n",
                             "direct managed memory access from host",
                             kLabelWidth, prop.directManagedMemAccessFromHost);

    std::cout << std::format("{:<{}}: {}\n", "max blocks per multiprocessor",
                             kLabelWidth, prop.maxBlocksPerMultiProcessor);

    std::cout << std::format("{:<{}}: {}\n", "access policy max window size",
                             kLabelWidth, prop.accessPolicyMaxWindowSize);

    std::cout << std::format("{:<{}}: {}\n", "reserved shared memory per block",
                             kLabelWidth, prop.reservedSharedMemPerBlock);

    std::cout << std::format("{:<{}}: {}\n", "host register supported",
                             kLabelWidth, prop.hostRegisterSupported);

    std::cout << std::format("{:<{}}: {}\n", "sparse CUDA array supported",
                             kLabelWidth, prop.sparseCudaArraySupported);

    std::cout << std::format("{:<{}}: {}\n",
                             "host register read-only supported", kLabelWidth,
                             prop.hostRegisterReadOnlySupported);

    std::cout << std::format(
        "{:<{}}: {}\n", "timeline semaphore interop supported", kLabelWidth,
        prop.timelineSemaphoreInteropSupported);

    std::cout << std::format("{:<{}}: {}\n", "memory pools supported",
                             kLabelWidth, prop.memoryPoolsSupported);

    std::cout << std::format("{:<{}}: {}\n", "GPUDirect RDMA supported",
                             kLabelWidth, prop.gpuDirectRDMASupported);

    std::cout << std::format("{:<{}}: {}\n",
                             "GPUDirect RDMA flush writes options", kLabelWidth,
                             prop.gpuDirectRDMAFlushWritesOptions);

    std::cout << std::format("{:<{}}: {}\n", "GPUDirect RDMA writes ordering",
                             kLabelWidth, prop.gpuDirectRDMAWritesOrdering);

    std::cout << std::format("{:<{}}: {}\n",
                             "memory pool supported handle types", kLabelWidth,
                             prop.memoryPoolSupportedHandleTypes);

    std::cout << std::format(
        "{:<{}}: {}\n", "deferred mapping CUDA array supported", kLabelWidth,
        prop.deferredMappingCudaArraySupported);

    std::cout << std::format("{:<{}}: {}\n", "IPC event supported", kLabelWidth,
                             prop.ipcEventSupported);

    std::cout << std::format("{:<{}}: {}\n", "cluster launch", kLabelWidth,
                             prop.clusterLaunch);

    std::cout << std::format("{:<{}}: {}\n", "unified function pointers",
                             kLabelWidth, prop.unifiedFunctionPointers);

    std::cout << std::format("{:<{}}: {}\n", "device NUMA config", kLabelWidth,
                             prop.deviceNumaConfig);

    std::cout << std::format("{:<{}}: {}\n", "device NUMA ID", kLabelWidth,
                             prop.deviceNumaId);

    std::cout << std::format("{:<{}}: {}\n", "MPS enabled", kLabelWidth,
                             prop.mpsEnabled);

    std::cout << std::format("{:<{}}: {}\n", "host NUMA ID", kLabelWidth,
                             prop.hostNumaId);

    std::cout << std::format("{:<{}}: {}\n", "GPU PCI device ID", kLabelWidth,
                             prop.gpuPciDeviceID);

    std::cout << std::format("{:<{}}: {}\n", "GPU PCI subsystem ID",
                             kLabelWidth, prop.gpuPciSubsystemID);

    std::cout << std::format("{:<{}}: {}\n",
                             "host NUMA multinode IPC supported", kLabelWidth,
                             prop.hostNumaMultinodeIpcSupported);

    std::cout << std::format("{:<{}}: {} KHz, {} MHz, {} GHz\n",
                             "Peak Memory Clock Rate (KHz)", kLabelWidth,
                             memoryClockRate, memoryClockRate / 1e3,
                             memoryClockRate / 1e6);
    std::cout << std::format(
        "{:<{}}: {:.2f}\n", "Peak Memory Bandwidth (GB/s)", kLabelWidth,
        2.0 * memoryClockRate * (prop.memoryBusWidth / 8) / 1.0e6);
    std::cout << std::format("{:<{}}: {}\n", "max clock rate (MHz)",
                             kLabelWidth, clockRate / 1024);
    std::cout << std::format("{:<{}}: {}\n", "max texture 1D linear",
                             kLabelWidth, maxTexture1DLinear);
  }
}