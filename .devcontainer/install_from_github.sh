#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 <owner> <repo> [install_dir]"
    echo "Example: $0 cli cli /usr/local/bin"
    echo "If install_dir is not provided, binaries will be installed in /usr/local/bin."
    exit 1
}

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
    usage
fi

OWNER="$1"
REPO="$2"
INSTALL_DIR="${3:-/usr/local/bin}"

# Determine host architecture and OS
ARCH=$(uname -m)

# Map architecture variants
case $ARCH in
x86_64)
    ARCH_VARIANTS="amd64|x86_64"
    ;;
aarch64 | arm64)
    ARCH_VARIANTS="arm64|aarch64"
    ;;
*)
    ARCH_VARIANTS=$ARCH
    ;;
esac

# Fetch the latest release information
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases/latest")

# Function to download and install .deb package
install_deb() {
    local DEB_URL="$1"
    local DEB_FILE="${REPO}_latest_${ARCH}.deb"

    echo "Downloading .deb file from: $DEB_URL"
    curl -sfLo "$DEB_FILE" "$DEB_URL"

    echo "Installing the package..."
    dpkg -i "$DEB_FILE"

    if [ $? -eq 0 ]; then
        echo "Package installed successfully."
        rm "$DEB_FILE"
    else
        echo "Package installation failed. The .deb file is still in the current directory."
        exit 1
    fi
}

# Function to download and install from .zip
install_zip() {
    local ZIP_URL="$1"
    local ZIP_FILE="${REPO}_latest_${ARCH}.zip"

    echo "Downloading .zip file from: $ZIP_URL"
    curl -sfLo "$ZIP_FILE" "$ZIP_URL"

    echo "Extracting the .zip file..."
    unzip -o "$ZIP_FILE" -d "$INSTALL_DIR"

    if [ $? -eq 0 ]; then
        echo "Binaries extracted successfully to $INSTALL_DIR"
        rm "$ZIP_FILE"
    else
        echo "Extraction failed. The .zip file is still in the current directory."
        exit 1
    fi
}

# Function to download and install from .tar.gz
install_tgz() {
    local TGZ_URL="$1"
    local TGZ_FILE="${REPO}_latest_${ARCH}.tar.gz"

    echo "Downloading .tar.gz file from: $TGZ_URL"
    curl -sfLo "$TGZ_FILE" "$TGZ_URL"

    echo "Extracting the .tar.gz file..."
    install -d "$INSTALL_DIR"
    tar xf "$TGZ_FILE" -C "$INSTALL_DIR"

    if [ $? -eq 0 ]; then
        echo "Binaries extracted successfully to $INSTALL_DIR"
        rm "$TGZ_FILE"
    else
        echo "Extraction failed. The .tar.gz file is still in the current directory."
        exit 1
    fi
}

# Try to find a .deb file first
DEB_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | test(\"(${ARCH_VARIANTS})\\\\.deb$\"; \"i\")) | .browser_download_url")
if [ -n "$DEB_URL" ]; then
    install_deb "$DEB_URL"
    exit
fi

# If no .deb file, look for a .zip file
ZIP_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | test(\"-linux-(${ARCH_VARIANTS})\\\\.zip$\"; \"i\")) | .browser_download_url")
if [ -n "$ZIP_URL" ]; then
    install_zip "$ZIP_URL"
    exit
fi

# If no .deb or .zip file, look for a .tar.gz or .tgz file
TGZ_URL=$(echo "$LATEST_RELEASE" | jq -r ".assets[] | select(.name | test(\"-linux-(${ARCH_VARIANTS})\\\\.(tar\\\\.gz|tgz)$\"; \"i\")) | .browser_download_url")
if [ -n "$TGZ_URL" ]; then
    install_tgz "$TGZ_URL"
    exit
fi

echo "No suitable .deb or .zip or .tar.gz file found for architecture: $ARCH (variants: $ARCH_VARIANTS)"
exit 1
