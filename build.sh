#!/bin/sh -x

docker build --tag rekgrpth/gost . | tee build.log
