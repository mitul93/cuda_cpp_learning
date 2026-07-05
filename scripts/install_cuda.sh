#!/usr/bin/env bash
# Downloads nvcc and other required package
#
# Instructions for installing debian pacakge is available at
# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#network-repo-installation-for-ubuntu
#
# The debian packages can be found at
# https://developer.download.nvidia.com/compute/cuda/repos
#

set -euo pipefail

# --- Sudo handling ---
SUDO=""
setup_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    else
        echo "Error: not running as root and 'sudo' is not available." >&2
        exit 1
    fi
}

# --- Detect architecture ---
detect_arch() {
    local arch_raw
    arch_raw="$(uname -m)"
    case "$arch_raw" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="sbsa"   # NVIDIA uses "sbsa" for server-class arm64 (not "jetson")
            ;;
        *)
            echo "Unsupported architecture: $arch_raw" >&2
            exit 1
            ;;
    esac
}

# --- Detect distro ---
detect_distro() {
    if [ ! -f /etc/os-release ]; then
        echo "Cannot detect distro: /etc/os-release not found" >&2
        exit 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    local id="${ID:-}"
    local version_id="${VERSION_ID:-}"

    case "$id" in
        ubuntu)
            # e.g. 24.04 -> ubuntu2404
            DISTRO="ubuntu$(echo "$version_id" | tr -d '.')"
            ;;
        debian)
            # e.g. 12 -> debian12
            DISTRO="debian${version_id%%.*}"
            ;;
        *)
            echo "Unsupported or unrecognized distro: $id" >&2
            echo "This script only supports debian-based distros" >&2
            exit 1
            ;;
    esac
}

# --- Install the CUDA apt repo keyring ---
install_cuda_keyring() {
    local url="https://developer.download.nvidia.com/compute/cuda/repos/${DISTRO}/${ARCH}/cuda-keyring_1.1-1_all.deb"
    local deb_path="/tmp/cuda-keyring_1.1-1_all.deb"

    echo "(*) Downloading: $url"
    wget -nv "$url" -O "$deb_path"

    if ! command -v dpkg >/dev/null 2>&1; then
        echo "This system doesn't use dpkg — you're likely on an rpm-based distro." >&2
        echo "NVIDIA provides an .rpm equivalent for those; adjust the URL/package accordingly." >&2
        exit 1
    fi

    echo "(*) Installing keyring package ${deb_path}"
    $SUDO dpkg -i "$deb_path"
    rm -f "$deb_path"
}

# --- Install nvcc / toolkit ---
install_cuda_toolkit() {
    : "${__CUDA_TOOLKIT_VER:?__CUDA_TOOLKIT_VER must be set (e.g. 12.4)}"

    local cuda_pkg_ver
    cuda_pkg_ver="$(echo "${__CUDA_TOOLKIT_VER}" | sed -E 's/^([0-9]+)\.([0-9]+)(\..*)?$/\1-\2/')"

    local cuda_nvcc_ver="${__CUDA_NVCC_DEB_PKG_VER:-""}"

    $SUDO apt-get update

    local cuda_nvcc_pkg="cuda-nvcc-${cuda_pkg_ver}"

    if [ -n "${cuda_nvcc_ver}" ]; then
        cuda_nvcc_pkg="${cuda_nvcc_pkg}=${cuda_nvcc_ver}"
    fi

    echo "(*) Using CUDA Toolkit debian package version=${cuda_pkg_ver}"
    echo "(*) Installing NVCC deb package version=${cuda_nvcc_ver}"

    $SUDO apt-get install -y --no-install-recommends "cuda-nvcc-${cuda_pkg_ver}=${cuda_nvcc_ver}"
}

main() {
    setup_sudo
    detect_arch
    detect_distro

    echo "(*) install_cuda.sh script"
    echo "    repo os  : ${DISTRO}"
    echo "    arch     : ${ARCH}"
    echo ""

    install_cuda_keyring
    install_cuda_toolkit

    echo "(*) Update following environment variables"
    # shellcheck disable=SC2016
    echo '    PATH=${PATH}:/usr/local/cuda/bin'
    # shellcheck disable=SC2016
    echo '    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64'
}

main "$@"