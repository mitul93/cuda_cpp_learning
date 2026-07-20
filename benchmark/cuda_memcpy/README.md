BENCHMARK_TEMPLATE(BM_cuda_h2d, uint8_t)->Range(10e3, 10e9);
BENCHMARK_TEMPLATE(BM_cuda_h2d, int)->Range(10e3, 10e9);

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

```shell
$ sudo dmesg | tail
...
[13039.815152] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=user.slice,mems_allowed=0,oom_memcg=/user.slice/user-1000.slice/user@1000.service/user.slice/libpod-fffd37123f33f09b0d26b19bdb5012786a5ebf28c905e436ec5ca1dbf188bcea.scope,task_memcg=/user.slice/user-1000.slice/user@1000.service/user.slice/libpod-fffd37123f33f09b0d26b19bdb5012786a5ebf28c905e436ec5ca1dbf188bcea.scope/container,task=cuda_memcpy,pid=69821,uid=1000
[13039.815161] Memory cgroup out of memory: Killed process 69821 (cuda_memcpy) total-vm:13235352kB, anon-rss:12608kB, file-rss:71616kB, shmem-rss:3326904kB, UID:1000 pgtables:6828kB oom_score_adj:200
[13039.828701] Cannot map memory with base addr 0x75fb76000000 and size of 0x200000 pages
[13052.691598] audit: type=1400 audit(1784575225.109:401): apparmor="DENIED" operation="symlink" class="file" profile="snap.firefox.firefox" name="/dev/char/195:254" pid=5866 comm="CanvasRenderer" requested_mask="c" denied_mask="c" fsuid=1000 ouid=1000

```

Following Solution did not work
->Repetitions(1);

Changing 10e9 to 1e9

Answer

oom-kill:constraint=CONSTRAINT_MEMCG container was out of memory