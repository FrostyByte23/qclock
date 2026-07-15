#!/usr/bin/env bash

set -euo pipefail

APP_NAME="qclock"
OUTPUT_DIR="./build"

echo "Building $APP_NAME..."

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

echo "Detected architecture: $ARCH"
echo "Using runtime: $RID"

if ! command -v dotnet &> /dev/null; then
    echo "Error: .NET SDK is not installed."
    echo "Install it from https://dotnet.microsoft.com/download"
    exit 1
fi

rm -rf "$OUTPUT_DIR"

dotnet publish \
    -c Release \
    -r "$RID" \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    -o "$OUTPUT_DIR"s

echo
echo "Build complete!"
echo "Executable: $OUTPUT_DIR/$APP_NAME"
