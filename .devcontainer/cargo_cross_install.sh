#!/bin/bash

set -euo pipefail

# Get the Rust target triple
target_triple() {
    local target_platform="$1"
    case "$target_platform" in
    linux/amd64 | x86_64) echo x86_64-unknown-linux-gnu ;;
    linux/arm64 | aarch64) echo aarch64-unknown-linux-gnu ;;
    *)
        echo >&2 "Unsupported target platform: $target_platform"
        exit 1
        ;;
    esac
}

# Install cross-compile dependencies
install_dependencies() {
    local arch1
    local arch2
    local deps=()
    local packages
    local target="$1"

    case "$target" in
    x86_64-unknown-linux-gnu)
        arch1=x86-64
        arch2=amd64
        ;;
    aarch64-unknown-linux-gnu)
        arch1=aarch64
        arch2=arm64
        ;;
    *)
        echo >&2 "Unsupported target: $target"
        exit 1
        ;;
    esac

    # Suffix each package with :$arch2
    for pkg in $APT_DEPENDENCIES; do
        deps+=("$pkg:$arch2")
    done

    # Enable packages for the target architecture
    dpkg --add-architecture "$arch2"

    # Update the package index
    apt-get update

    # Install dependencies
    apt-get install --no-install-recommends -y \
        "g++-$arch1-linux-gnu" \
        "gcc-$arch1-linux-gnu" \
        "libc6-dev-$arch2-cross" \
        pkg-config \
        "${deps[@]}"
}

# Function to set environment variables for cross-compilation
set_cross_compile_env() {
    local arch
    local target="$1"
    local target_upper="${target^^}"

    case "$target" in
    x86_64-unknown-linux-gnu)
        arch=x86_64
        ;;
    aarch64-unknown-linux-gnu)
        arch=aarch64
        ;;
    *)
        echo >&2 "Unsupported target: $target"
        exit 1
        ;;
    esac

    export "CARGO_TARGET_${target_upper//-/_}_LINKER=${arch}-linux-gnu-gcc"
    export "CC_${target//-/_}=${arch}-linux-gnu-gcc"
    export "CXX_${target//-/_}=${arch}-linux-gnu-g++"
    export "PKG_CONFIG_PATH=/usr/lib/${arch}-linux-gnu/pkgconfig"
    export PKG_CONFIG_ALLOW_CROSS=1
}

# Main function
main() {
    local build_platform=${BUILDPLATFORM:-$(uname -m)}
    local target_platform=${TARGETPLATFORM:-$(uname -m)}

    # Convert Docker platform to Rust target triple
    build_target="$(target_triple "$build_platform")"
    target="$(target_triple "$target_platform")"

    # Install dependencies
    install_dependencies "$target"

    # Set cross-compilation environment if needed
    if [ "$build_target" != "$target" ]; then
        set_cross_compile_env "$target"
        rustup target add "$target"
    fi

    # Run cargo install with the specified target
    cargo install --target "$target" "$@"
}

main "$@"
