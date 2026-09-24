#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/tmp/flutter_sdk"

if [ ! -d "$FLUTTER_DIR/bin" ]; then
  echo "Downloading Flutter SDK $FLUTTER_VERSION..."
  mkdir -p "$FLUTTER_DIR"
  curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ -C /tmp/
  mv /tmp/flutter/* "$FLUTTER_DIR/" 2>/dev/null || true
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export FLUTTER_ROOT="$FLUTTER_DIR"

echo "Checking Flutter..."
flutter --version

echo "Building Flutter Web..."
flutter pub get
flutter build web --release --base-href /