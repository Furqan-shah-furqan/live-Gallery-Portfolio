#!/usr/bin/env bash
set -eo pipefail

FLUTTER_VERSION="3.24.5"
FLUTTER_DIR="/tmp/flutter_sdk"

# A valid cache needs the flutter binary AND the SDK's .git directory.
if [ ! -x "$FLUTTER_DIR/bin/flutter" ] || [ ! -d "$FLUTTER_DIR/.git" ]; then
  echo "Downloading Flutter SDK $FLUTTER_VERSION..."
  mkdir -p "$FLUTTER_DIR"
  curl -sL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" | tar -xJ --no-same-owner -C /tmp/
  # Move the whole extracted directory: a glob like /tmp/flutter/* would skip
  # dotfiles and drop the SDK's .git, which makes the flutter tool abort with
  # "The Flutter directory is not a clone of the GitHub project".
  rm -rf "$FLUTTER_DIR"
  mv /tmp/flutter "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"
export FLUTTER_ROOT="$FLUTTER_DIR"

# Vercel build containers run as root; tar (as root) restores the tarball's
# original ownership, so git flags the SDK as "dubiously owned" and every
# flutter command fails, reporting Flutter version 0.0.0-unknown (which breaks
# pub resolution). Trust the SDK directory before invoking flutter.
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

echo "Checking Flutter..."
flutter --version

echo "Building Flutter Web..."
flutter pub get
flutter build web --release --base-href /