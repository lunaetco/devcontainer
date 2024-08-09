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
echo "[$OWNER/$REPO] Detected architecture $ARCH"

# Map architecture variants
case $ARCH in
x86_64 | amd64)
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
echo "[$OWNER/$REPO] Downloading release data"
RELEASE=$(wget --https-only -nv -O - "https://api.github.com/repos/$OWNER/$REPO/releases")

PARSED=$(printf "%s" "$RELEASE" | jq -r "
map(
    .assets | map(
        { name: .name, url: .browser_download_url } +
        (.name | capture(\"\\\\.(?<ext>deb|tar\\\\.(gz|xz)|tgz|zip)$\"; \"i\"))
    ) | sort_by(.ext) | .[] | select(
        .name | (
            test(\"($ARCH_VARIANTS)\"; \"i\") and
            test(\"linux\"; \"i\") and
            (test(\"musl\"; \"i\") | not)
        )
    )
) | flatten | map(
    select(
        (isempty(.url) or isempty(.ext)) | not
    )
) | first | \"\(.url) \(.ext)\"")

read -r DOWNLOAD_URL EXT <<<"$PARSED"
echo "[$OWNER/$REPO] Parsed release data: $DOWNLOAD_URL $EXT"

if [[ -z "$DOWNLOAD_URL" || "$DOWNLOAD_URL" == "null" || -z "$EXT" || "$EXT" == "null" ]]; then
    echo "[$OWNER/$REPO] No suitable file found for architecture: $ARCH (variants: $ARCH_VARIANTS)"
    exit 1
fi

# Download asset
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

ASSET="asset.$EXT"
echo "[$OWNER/$REPO] Downloading $DOWNLOAD_URL"
wget --https-only -nv -O "$ASSET" "$DOWNLOAD_URL"

# Install asset
case $EXT in
deb)
    dpkg -i "$ASSET"
    ;;
zip)
    unzip -o "$ASSET"
    find . -type f -executable -exec install {} "$INSTALL_DIR" \;
    ;;
*)
    tar xf "$ASSET"
    find . -type f -executable -exec install {} "$INSTALL_DIR" \;
    ;;
esac

echo "[$OWNER/$REPO] Successfully installed binaries"
cd /
rm -rf "$TMPDIR"
