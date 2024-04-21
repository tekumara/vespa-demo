#!/usr/bin/env bash

set -euo pipefail

echo "install https://github.com/vespa-engine/vespa cli"
tmp_dir=$(mktemp -d) && pushd "$tmp_dir"

version=8.331.34
case "$(uname -sm)" in
    "Linux aarch64") sha256=07ce8344d13e6c3739b2ad8b46d000341bd0745f891f591f975c9c2ec5166136 && arch=arm64 ;;
    "Linux x86_64")  sha256=287faba4e0f2b70861350d25c5abad61e06498c130cb2c0804843c5325af8695 && arch=amd64 ;;
    *) echo "error: unknown arch $(uname -sm)" && exit 42;;
esac

curl -fsSLo vespa.tar.gz "https://github.com/vespa-engine/vespa/releases/download/v${version}/vespa-cli_${version}_linux_${arch}.tar.gz"
sha256sum vespa.tar.gz
echo "$sha256  vespa.tar.gz"  | sha256sum --check

tar -zxf vespa.tar.gz
install vespa-*/bin/vespa /usr/local/bin
popd && rm -rf "$tmp_dir"
