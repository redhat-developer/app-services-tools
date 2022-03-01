#!/bin/sh

set -uo pipefail

tag=${TAG}
release_name=${tag/#"v"}
os="${OS:-linux}" # linux, macOS
arch="${ARCH:-amd64}" # amd64, arm64
asset_name=rhoas_${release_name}_${os}_${arch}
tarball_name=${asset_name}.tar.gz
org_name="redhat-developer"
repo_name="app-services-cli"
binary_name="rhoas"
binary_path=${RHOAS_CLI_PATH:-/usr/local/bin/rhoas}
tmp_dir="/tmp/${binary_name}-${tag}-$(date +%s)"

mkdir -p $tmp_dir && cd $tmp_dir

wget https://github.com/${org_name}/${repo_name}/releases/download/${tag}/$tarball_name
tar -xvzf $tarball_name

mv $tmp_dir/${asset_name}/${binary_name} $binary_path