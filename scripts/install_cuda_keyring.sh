#!/usr/bin/env bash
#
# Checks if cuda-keyring exists. Downloads and add it if it does not.
# Supported OS : Ubuntu, Debian
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
    if dpkg -s cuda-keyring >/dev/null 2>&1; then
        echo "(*) cuda-keyring is already installed"
        return
    fi
    echo "(*) Installing cuda-keyring"

    local url="https://developer.download.nvidia.com/compute/cuda/repos/${DISTRO}/${ARCH}/cuda-keyring_1.1-1_all.deb"
    local deb_path="/tmp/cuda-keyring_1.1-1_all.deb"

    echo "(*) Downloading: $url"
    wget -nv "$url" -O "$deb_path"

    echo "(*) Installing keyring package ${deb_path}"
    $SUDO dpkg -i "$deb_path"
    # rm -f "$deb_path"
}

install_cuda_devtool_keyring() {

    local _arch="$(dpkg --print-architecture)"
    local url="https://developer.nvidia.com/w/devtools/repos/${DISTRO}/${_arch}/nvidia.pub"
    local pub_path="/tmp/nvidia.pub"
    local keyring_path="/usr/share/keyrings/cuda-devtool-keyring.gpg"
    local devtool_repo_file="/etc/apt/sources.list.d/nvidia-devtools.list"

    if [[ ! -f "$devtool_repo_file" ]]; then
        echo "(*) Downloading: $url"
    
        wget -qO- "${url}" \
            | GNUPGHOME=/tmp/gnupg gpg --dearmor --no-default-keyring \
            | tee "${keyring_path}" > /dev/null

        echo "(*) Adding NVIDIA DevTools repository"
        echo "deb [signed-by=${keyring_path}] https://developer.download.nvidia.com/devtools/repos/${DISTRO}/${_arch} /" \
            | tee "${devtool_repo_file}" >/dev/null
    else
        echo "(*) NVIDIA DevTools repository already configured"
    fi

    rm -f "$pub_path"
}

main() {
    setup_sudo
    detect_arch
    detect_distro

    echo "(*) Running install_cuda_keyring.sh script"
    echo "    repo os  : ${DISTRO}"
    echo "    arch     : ${ARCH}"
    echo ""

    install_cuda_keyring
    install_cuda_devtool_keyring
}

main "$@"