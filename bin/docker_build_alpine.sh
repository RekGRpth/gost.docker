#!/bin/sh -eux

apk update --no-cache
apk upgrade --no-cache
apk add --no-cache --virtual .build-deps \
    ca-certificates \
    cmake \
    findutils \
    gcc \
    gettext-dev \
    git \
    libintl \
    make \
    musl-dev \
    openssl-dev \
;
