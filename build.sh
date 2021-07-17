#!/bin/sh -eux

DOCKER_BUILDKIT=1 docker build --progress=plain --tag rekgrpth/gost . 2>&1 | tee build.log
