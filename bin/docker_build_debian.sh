#!/bin/sh -eux

apt-get update
apt-get full-upgrade -y --no-install-recommends
apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    cmake \
    gcc \
    git \
    libc-dev \
    libssl-dev \
    make \
    pkg-config \
;
