#!/usr/bin/env bash

set -eu
set -o pipefail

cd "$(dirname "$0")"

RELEASE="$PWD/release"

rm -r "$RELEASE" || true
mkdir -p "$PWD/target" "$RELEASE"


builds=(
  x86_64-unknown-linux-gnu
  x86_64-unknown-linux-musl
  # x86_64-pc-windows-gnu
)


cross_build() {
  local ARCH="$1"
  local OUT="$RELEASE/$ARCH"
  cross build --release --target="$ARCH"
  local ARTIFACT="$PWD/target/$ARCH/release/sad"
  if [[ ! -f "$ARTIFACT" ]]
  then
    ARTIFACT="$PWD/target/$ARCH/release/sad.exe"
  fi
  zip -j "$OUT" "$ARTIFACT"
}


macos_build() {
  if [[ "$(uname)" = 'Darwin' ]]
  then
    local ARCH="x86_64-apple-darwin"
    local OUT="$RELEASE/$ARCH"
    local DIST="$PWD/target/$ARCH"
    cargo build --release --target-dir="$DIST"
    zip -j "$OUT" "$DIST/release/sad"
  fi
}


macos_build

for build in "${builds[@]}"
do
  cross_build "$build"
done
