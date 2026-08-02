# vcpkg Custom Port: nvbench

This is a custom [vcpkg](https://vcpkg.io) port for [NVIDIA/nvbench](https://github.com/NVIDIA/nvbench), a CUDA benchmarking library. It exists because nvbench has no official vcpkg port, and its upstream CMake build assumes an internet-connected, CPM/FetchContent-driven dependency resolution model that conflicts directly with how vcpkg builds ports (offline, dependency-graph-driven, no ad hoc network access).

Getting this working required working around several layers of mismatch between nvbench's build system and vcpkg's build model. This document records what was needed and why, both as documentation for this port and as a reference for anyone porting similar CPM/rapids-cmake-based CUDA projects.

## System Prerequisites (apt packages)

nvbench requires CUDA Toolkit development headers that aren't included in minimal/runtime-only CUDA container images. The following must be installed on the host/devcontainer **before** building this port — vcpkg does not and cannot manage the CUDA Toolkit itself:

```bash
apt-get install -y \
    cuda-cupti-dev-${CUDA_TOOLKIT_VER} \
    cuda-nvml-dev-${CUDA_TOOLKIT_VER} \
    cuda-profiler-api-$CUDA_TOOLKIT_VER}
```

Without these, the build fails partway through compilation with missing headers (e.g. `cuda_profiler_api.h: No such file or directory`) rather than failing cleanly at configure time — so it's easy to lose time here if the toolkit install is incomplete.

## Problem 1: `FetchContent` vs. vcpkg's offline build model

nvbench's CMake pulls in [rapids-cmake](https://github.com/rapidsai/rapids-cmake) via `FetchContent` at configure time. vcpkg sets `FETCHCONTENT_FULLY_DISCONNECTED=ON` during builds to guarantee no dependency is silently fetched outside of vcpkg's own dependency graph — so this fetch is blocked outright.

**Fix:** fetch `rapids-cmake`'s source ourselves in `portfile.cmake` (via `vcpkg_from_github`), then redirect nvbench's internal `FetchContent` call to that pre-populated source instead of the network, using:

```cmake
-DFETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE=${RAPIDS_CMAKE_SOURCE_PATH}
```

This is the same pattern rapids-cmake itself documents for offline/airgapped builds — it just also happens to be exactly what a vcpkg port needs.

## Problem 2: CPM-managed dependencies (fmt, nlohmann_json, ...)

Once rapids-cmake was available locally, it uses CPM internally to resolve further dependencies (`fmt`, `nlohmann_json`, etc.), which hits the same FetchContent wall for each of them individually.

**Fix:** rather than pre-fetching each one by hand, we lean on CPM's own local-package resolution:

```cmake
-DCPM_USE_LOCAL_PACKAGES=ON
```

This makes CPM try `find_package()` before attempting any download. Combined with declaring the equivalent packages as normal vcpkg dependencies in `vcpkg.json` (`fmt`, `nlohmann-json`), CPM finds them via vcpkg's toolchain-provided `find_package()` instead of ever reaching the network. This is a cleaner solution than the `FETCHCONTENT_SOURCE_DIR_*` approach used for rapids-cmake, but it only works for dependencies that actually have vcpkg ports — rapids-cmake itself does not, hence Problem 1's separate fix.

## Problem 3: CMake config file location doesn't match convention

nvbench installs its CMake package config to:
```
lib/cmake/nvbench/
```
which is the traditional `GNUInstallDirs`-style convention — but it's easy to assume the more common vcpkg convention (`share/<port>/`) and get this wrong, since that's what the *final*, fixed-up installed tree looks like after vcpkg processes it. The correct `CONFIG_PATH` for `vcpkg_cmake_config_fixup()` must match the **staging** location (`CURRENT_PACKAGES_DIR`, pre-fixup), not the final installed output:

```cmake
vcpkg_cmake_config_fixup(
    PACKAGE_NAME nvbench
    CONFIG_PATH lib/cmake/nvbench
)
```

Any manual patching of the generated config (see static/shared linkage handling below) must also happen **before** this call, since `vcpkg_cmake_config_fixup` relocates the files afterward.

## Problem 4: `nvbench-ctl` binary not installed to expected location

nvbench exports a CMake target for its `nvbench-ctl` CLI tool, but vcpkg's standard install step doesn't automatically place executables where nvbench's own exported config expects them (`tools/nvbench/`). Left unhandled, this produces a broken imported target at consume-time: `CMake Error ... references the file ".../tools/nvbench/nvbench-ctl" but this file does not exist.`

**Fix:**

```cmake
vcpkg_copy_tools(
    TOOL_NAMES nvbench-ctl
    AUTO_CLEAN
)
```

## Problem 5: Static/shared linkage mismatch in the generated config

nvbench's generated `nvbench-config.cmake` hardcodes `set(nvbench_SHARED_LIBS ON)` regardless of how the library was actually built. When building statically via vcpkg, this needs to be patched to reflect reality, or downstream consumers get an ABI/linkage mismatch:

```cmake
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/lib/cmake/nvbench/nvbench-config.cmake"
        "set(nvbench_SHARED_LIBS ON)"
        "set(nvbench_SHARED_LIBS OFF)"
    )
endif()
```

## Problem 6: Debug/Release duplication

Like most vcpkg ports, headers and CMake config content are identical between Debug and Release builds, but both configurations get built independently. Left uncleaned, this trips vcpkg's post-build lint checks:

```cmake
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
```

## Summary

| Issue | Root cause | Fix |
|---|---|---|
| CUDA headers missing | Minimal container image lacks toolkit dev packages | Install `cuda-cupti-dev`, `cuda-nvml-dev`, `cuda-profiler-api` |
| rapids-cmake fetch blocked | `FetchContent` + vcpkg's offline build mode | Pre-fetch via `vcpkg_from_github`, redirect with `FETCHCONTENT_SOURCE_DIR_RAPIDS-CMAKE` |
| CPM deps (fmt, nlohmann_json) blocked | Same FetchContent restriction, one layer down | `CPM_USE_LOCAL_PACKAGES=ON` + declare as vcpkg deps |
| Wrong `CONFIG_PATH` | vcpkg's final tree layout ≠ staging layout | Use `lib/cmake/nvbench` (staging), not `share/nvbench` (post-fixup) |
| `nvbench-ctl` missing | vcpkg doesn't auto-relocate tool binaries | `vcpkg_copy_tools(TOOL_NAMES nvbench-ctl)` |
| Static linkage mismatch | Config hardcodes `SHARED_LIBS ON` | `vcpkg_replace_string` before `config_fixup` |
| Debug/share lint failure | Duplicate config/headers across configs | `file(REMOVE_RECURSE)` on `debug/include`, `debug/share` |

None of these issues are individually exotic — each is a documented, known vcpkg pattern — but nvbench's dependency chain (rapids-cmake → CPM → multiple sub-packages, plus a non-standard install layout and an exported CLI tool) meant hitting nearly all of them in sequence before a clean, reproducible build was achieved.