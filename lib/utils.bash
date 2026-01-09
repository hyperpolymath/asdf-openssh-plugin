#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="openssh"
BINARY_NAME="ssh"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  curl -sL "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/" 2>/dev/null | \
    grep -oE 'openssh-[0-9]+\.[0-9]+p[0-9]+' | sed 's/openssh-//' | sort -V | uniq
}

download_release() {
  local version="$1" download_path="$2"
  local url="https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${version}.tar.gz"

  echo "Downloading OpenSSH $version..."
  mkdir -p "$download_path"
  curl -fsSL "$url" -o "$download_path/openssh.tar.gz" || fail "Download failed"
  tar -xzf "$download_path/openssh.tar.gz" -C "$download_path" --strip-components=1
  rm -f "$download_path/openssh.tar.gz"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"

  cd "$ASDF_DOWNLOAD_PATH"
  ./configure --prefix="$install_path" || fail "Configure failed"
  make -j"$(nproc)" || fail "Build failed"
  make install || fail "Install failed"
}
