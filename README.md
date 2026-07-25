# CUDA C++ Learning

A personal CUDA C++ learning repository and playground for experimenting with GPU programming concepts, CUDA APIs, and development workflows.

This project serves as a self-paced environment for exploring CUDA C++, trying out small examples, validating ideas, and building familiarity with the CUDA ecosystem.

## Goals

- Learn CUDA C++
- Explore CUDA language features and programming models
- Prototype and benchmark small CUDA applications
- Investigate development and debugging workflows
- Experiment with build systems, tooling, and profiling utilities
- Automate linting, formatting, building, etc using github actions
- Keep code portable and binary as small as possible

## Development Environment

This repository is intended to be used with:

- Development Containers
- Visual Studio Code
- NVIDIA Container Runtime
- Podman

The development environment is configured to provide a reproducible setup for CUDA development without requiring a local CUDA installation on the host system.

## Tested with

- Ubuntu 24.04.4 6.8.0-124-generic
- Podman 4.9.3
- NVIDIA RTX 3060 Ti
- NVIDIA Container runtime 1.19.0
- NVIDIA Driver 580.159.03
- CUDA 13.3
- VS Code 1.112.0

## Getting Started

1. Clone this repository
2. `Ctrl + Shift + P` -> `Dev Containers: Reopen in Container`

VS Code will build the development container and provide a ready-to-use CUDA development environment.

## Build and Run Hello World example

1. Open the example source file (e.g. `main.cpp`, `.cu`, or `.h`).
2. Optionally set breakpoints for debugging.
3. Press `F5` and select **CUDA C++: Launch**.

The provided `launch.json` and `tasks.json` are configured to automatically build and launch the example corresponding to the currently opened file. Any `.cpp`, `.cu`, or `.h` file located directly under an example directory can be used to determine which example is built and executed.

> [!NOTE]
> The current configuration derives the example name from the **parent directory of the active file**. Nested source files are therefore not supported. For example, opening `src/01_hello_world/utils/helper.cu` will resolve the example as `utils` rather than `01_hello_world`.

# sudo user in devcontainer
The sudo user password is <USERNAME>_super_user, where <USERNAME> is the value of the USERNAME (defaults to devcontainer) build argument.

## vcpkg NuGet Cache Authentication

This project uses the GitHub repository [vcpkg-nuget](https://github.com/mitul93/vcpkg-nuget) as a NuGet cache for vcpkg packages.

The repository itself is public, but the GitHub NuGet Package Registry requires authentication even when reading public packages.

A GitHub Personal Access Token (PAT) with `read:packages` permission is therefore required to restore packages from the registry.

To access the vcpkg NuGet package registry, 

1. Create a GitHub PAT with the required permissions:
   - `read:packages` — required to download packages
   - `write:packages` — required only if publishing packages (not required for local development)

2. Save the token as a plain text file at: `$HOME/src/secrets/github/vcpkg-nuget/vcpkg-nuget-readonly`

# Troubleshooting Guide

## What is the password of sudo user inside devcontainer?
Please [read this section](#sudo-user-in-devcontainer)

## Can't find an answer?
Please submit an issue using the provided GitHub issue template and include as much information as possible to help reproduce the problem.