#!/bin/sh -eux

cd "$HOME/src/engine"
cmake .
make -j"$(nproc)" install
