#!/usr/bin/env bash

set -euo pipefail

APP_NAME="qclock"
REPO="https://github.com/FrostyByte23/qclock.git"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/$APP_NAME-build"

echo "Installing $APP_NAME..."

# Check dependencies
for cmd in git dotnet; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Clean old temp build
rm -rf "$TMP_DIR"

echo "Cloning repository..."
git clone "$REPO" "$TMP_DIR"

cd "$TMP_DIR"

# Detect architecture
ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        RID="linux-x64"
        ;;
    aarch64|arm64)
        RID="linux-arm64"
        ;;
    armv7l)
        RID="linux-arm"
        ;;
    i386|i686)
        RID="linux-x86"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Building for $RID..."

# Build
dotnet publish \
    -c Release \
    -r "$RID" \
    --self-contained true \
    -p:PublishSingleFile=true \
    -o ./build

# Install
mkdir -p "$INSTALL_DIR"

cp "./build/$APP_NAME" "$INSTALL_DIR/$APP_NAME"

chmod +x "$INSTALL_DIR/$APP_NAME"

# Cleanup
rm -rf "$TMP_DIR"

echo
echo "$APP_NAME installed!"
echo "Run it with: $APP_NAME"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo
    echo "Add this to your shell config:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi
