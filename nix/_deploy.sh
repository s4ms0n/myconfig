#!/usr/bin/env bash
# Copyright 2017 Maximilian Huber <oss@maximilian-huber.de>
# SPDX-License-Identifier: MIT
set -e

echo "* $(tput bold)deploy nix configuration$(tput sgr0) ..."
SRC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

[[ ! -L /etc/nix/pkgs ]] && \
    sudo ln -s "$SRC/pkgs" /etc/nix/pkgs
[[ ! -L /etc/nix/overlays ]] && \
    sudo ln -s "$SRC/overlays" /etc/nix/overlays

config=/etc/nix/nixpkgs-config.nix
echo "* $(tput bold)generate $config$(tput sgr0) ..."
if [[ ! -f $config ]] || [[ $(wc -l <$config) -eq 1 ]]; then
    echo "import $SRC/nixpkgs-config.nix" | sudo tee $config
else
    echo "$config contains unexpected content"
    exit 1
fi