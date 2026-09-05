#!/usr/bin/env bash
# Vendor the upstream CivicNet source into ./civicnet and apply local patches.
# Usage: ./patch.sh [upstream-url]
set -euo pipefail

UPSTREAM="${1:-https://github.com/CivicLight/CivicNet.git}"
SRC_DIR="civicnet"

if [ ! -d "$SRC_DIR/.git" ]; then
  echo "Cloning upstream $UPSTREAM into $SRC_DIR/ ..."
  git clone "$UPSTREAM" "$SRC_DIR"
else
  echo "Refreshing $SRC_DIR from upstream ..."
  git -C "$SRC_DIR" fetch origin
  git -C "$SRC_DIR" reset --hard origin/master
fi

echo "Applying patches from patches/ ..."
for p in patches/*.patch; do
  echo "  $p"
  patch -p1 -d "$SRC_DIR" < "$p" || { echo "FAILED: $p"; exit 1; }
done
echo "Patches applied."
echo "Build with: ./build.sh"
