#!/bin/sh -ex

docker build --tag rekgrpth/gost . | tee build.log
