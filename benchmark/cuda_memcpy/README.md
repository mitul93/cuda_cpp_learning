### Profiling

```shell
$ cd build/
$ cmake -DBUILD_BENCHMARKS=ON ..
$ make -j $(nproc)
$ nsys profile --trace=cuda --output=report_cuda_memcpy ./benchmark/cuda_memcpy/cuda_memcpy 
```

Open Nsight Systems. File -> Import -> report_cuda_memcpy.qdstrm

### Troubleshooting

benchmark was killed

```text
-------------------------------------------------------------------------------------------
Benchmark                                 Time             CPU   Iterations UserCounters...
-------------------------------------------------------------------------------------------
BM_cuda_h2d<uint8_t>/10000             4394 ns         4394 ns       157340 bytes_per_second=2.11954Gi/s H2D
BM_cuda_h2d<uint8_t>/32768             5408 ns         5408 ns       128121 bytes_per_second=5.64282Gi/s H2D
BM_cuda_h2d<uint8_t>/262144           15024 ns        15023 ns        46711 bytes_per_second=16.2509Gi/s H2D
BM_cuda_h2d<uint8_t>/2097152         124625 ns       124619 ns         5555 bytes_per_second=15.6728Gi/s H2D
BM_cuda_h2d<uint8_t>/16777216       1018687 ns      1018642 ns          688 bytes_per_second=15.339Gi/s H2D
BM_cuda_h2d<uint8_t>/134217728      7799656 ns      7799168 ns           90 bytes_per_second=16.0274Gi/s H2D
BM_cuda_h2d<uint8_t>/1073741824    60621917 ns     60620325 ns           12 bytes_per_second=16.4961Gi/s H2D
Killed                     ./benchmark/cuda_memcpy/cuda_memcpy
```

Benchmarking code

```cpp
BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->Range(10e3, 10e9);
BENCHMARK_TEMPLATE(BM_cuda_h2d, int)->Range(10e3, 10e9);
BENCHMARK_TEMPLATE(BM_cuda_h2d, float)->Range(10e3, 10e9);
BENCHMARK_TEMPLATE(BM_cuda_h2d, double)->Range(10e3, 10e9);
```


Output of `dmesg` (outside container)

```shell
$ sudo dmesg | tail
...
[13039.815152] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=user.slice,mems_allowed=0,oom_memcg=/user.slice/user-1000.slice/user@1000.service/user.slice/libpod-fffd37123f33f09b0d26b19bdb5012786a5ebf28c905e436ec5ca1dbf188bcea.scope,task_memcg=/user.slice/user-1000.slice/user@1000.service/user.slice/libpod-fffd37123f33f09b0d26b19bdb5012786a5ebf28c905e436ec5ca1dbf188bcea.scope/container,task=cuda_memcpy,pid=69821,uid=1000
[13039.815161] Memory cgroup out of memory: Killed process 69821 (cuda_memcpy) total-vm:13235352kB, anon-rss:12608kB, file-rss:71616kB, shmem-rss:3326904kB, UID:1000 pgtables:6828kB oom_score_adj:200
[13039.828701] Cannot map memory with base addr 0x75fb76000000 and size of 0x200000 pages
...
```

Following Solution did not work
```cpp
BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->Range(10e3, 10e9);->Repetitions(1);
BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->Range(10e3, 1e9);->Repetitions(1);
```

It is clear from `dmesg` (`oom-kill:constraint=CONSTRAINT_MEMCG container was out of memory`) that the container cgroup **was out of reserved memory**. 

The devcontaienr memory limit is set to `4G`.

Benchmark range *loops over number of elements, not number of bytes!* Hence it goes out of required RAM for data type `int`

Easy solution is to just reduce the number of elements in range.
