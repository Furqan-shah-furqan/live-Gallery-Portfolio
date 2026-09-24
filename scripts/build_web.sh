#!/usr/bin/env bash
set -e

FLUTTER_VERSION="3.24.5"
CACHE_DIR="$HOME/.cache/flutter"
FLUTTER_BIN="$CACHE_DIR/$FLUTTER_VERSION/bin/flutter"

case "$1" in
  install)
    if [ ! -f "$FLUTTER_BIN" ]; then
      mkdir -p "$CACHE_DIR"
      curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ -C "$CACHE_DIR"
      mv "$CACHE_DIR/flutter" "$CACHE_DIR/$FLUTTER_VERSION"
    fi
    "$FLUTTER_BIN" doctor -v
    ;;
  build)
    export PATH="$CACHE_DIR/$FLUTTER_VERSION/bin:$PATH"
    flutter pub get
    flutter build web --release
    ;;
  *)
    exit 1
    ;;
esac