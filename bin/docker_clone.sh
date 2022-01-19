#!/bin/sh -eux

mkdir -p "$HOME/src"
cd "$HOME/src"
git clone -b openssl_1_1_1 https://github.com/RekGRpth/engine.git
