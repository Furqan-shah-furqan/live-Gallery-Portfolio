#!/usr/bin/env sh
# Vercel build helper for Flutter web.
#
# Vercel's build images ship no Flutter SDK, so the install step downloads a
# pinned SDK into the container cache and the build step runs the release build.
# Both steps are idempotent: the SDK is fetched only once per build container.
#
# Usage: sh ./scripts/build_web.sh [install|build]   (defaults to build)
#
# Environment overrides:
#   FLUTTER_VERSION  SDK version to fetch (default: 3.24.5)
#   FLUTTER_HOME     where SDKs are cached   (default: ~/.cache/flutter)
set -eu

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/.cache/flutter}"
SDK_DIR="$FLUTTER_HOME/$FLUTTER_VERSION"

ensure_sdk() {
  if [ ! -x "$SDK_DIR/bin/flutter" ]; then
    echo "==> Fetching Flutter $FLUTTER_VERSION SDK"
    mkdir -p "$FLUTTER_HOME"
    TARBALL="$FLUTTER_HOME/flutter-$FLUTTER_VERSION.tar.xz"
    curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o "$TARBALL"
    tar xf "$TARBALL" -C "$FLUTTER_HOME"
    mv "$FLUTTER_HOME/flutter" "$SDK_DIR"
    rm -f "$TARBALL"
  fi
  export PATH="$SDK_DIR/bin:$SDK_DIR/bin/cache/dart-sdk/bin:$PATH"
  # Flutter shells out to git; on CI the SDK can be seen as "dubiously owned".
  git config --global --add safe.directory "$SDK_DIR" 2>/dev/null || true
}

case "${1:-build}" in
  install)
    ensure_sdk
    flutter config --no-analytics >/dev/null
    flutter --version
    ;;
  build)
    ensure_sdk
    flutter pub get
    flutter build web --release
    ;;
  *)
    echo "usage: $0 [install|build]" >&2
    exit 2
    ;;
esac
