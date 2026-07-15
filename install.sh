#!/usr/bin/env bash

set -euo pipefail

APP_NAME="qclock"
REPO="https://github.com/FrostyByte23/qclock.git"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR="/tmp/$APP_NAME-build"

echo "Installing $APP_NAME..."

# Check dependencies
for cmd in git dotnet; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# Remove any previous temporary build
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

dotnet publish \
    -c Release \
    -r "$RID" \
    --self-contained true \
    -p:PublishSingleFile=true \
    -o ./build

# Install executable
mkdir -p "$INSTALL_DIR"

cp "./build/quick-clock" "$INSTALL_DIR/qclock"
chmod +x "$INSTALL_DIR/qclock"

# Install config directory if it exists
if [ -d "./build/config" ]; then
    mkdir -p "$INSTALL_DIR/config"
    cp -r ./build/config/* "$INSTALL_DIR/config/"
fi

# Cleanup
cd /
rm -rf "$TMP_DIR"

echo
echo "✅ $APP_NAME installed!"

if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo
    echo "⚠️  $INSTALL_DIR is not in your PATH."
    echo "Add this line to your shell configuration:"
    echo
    echo 'export PATH="$HOME/.local/bin:$PATH"'
fi

echo
echo "Run it with:"
echo "  qclock"
