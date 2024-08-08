#!/bin/bash

set -euo pipefail

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

# Fetch the release information
RELEASE=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases")

DOWNLOAD_URL=$(printf "%s" "$RELEASE" | jq -r "[
    .[].assets[] |
    select(.name |
        test(\"($ARCH_VARIANTS)\"; \"i\") and
        test(\"linux\"; \"i\")) |
    { url: .browser_download_url } +
    (.name | capture(\"\\\\.(?<ext>deb|zip|tar\\\\.gz|tgz|xz)$\"; \"i\")) |
    select(isempty(.ext) | not)
] | first | \"\(.url) \(.ext)\"")

read -r DOWNLOAD_URL EXT <<<"$DOWNLOAD_URL"

if [[ -z "$DOWNLOAD_URL" || -z "$EXT" ]]; then
    echo "No suitable file found for architecture: $ARCH (variants: $ARCH_VARIANTS)"
    exit 1
fi

# Download asset
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

ASSET="asset.$EXT"
curl -sfLo "$ASSET" "$DOWNLOAD_URL"

# Install asset
case $EXT in
deb)
    dpkg -i "$ASSET"
    ;;
zip)
    unzip -o "$ASSET"
    find . -type f -executable -exec install {} "$INSTALL_DIR" \;
    ;;
tar.gz | tgz | xz)
    tar xf "$ASSET"
    find . -type f -executable -exec install {} "$INSTALL_DIR" \;
    ;;
esac

echo "Successfully installed binaries"
cd /
rm -rf "$TMPDIR"
