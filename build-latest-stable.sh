#!/bin/bash

mkdir -p ~/build

export VERSION=$(curl https://omahaproxy.appspot.com/linux)
export BUILD="/tmp/chromium-build/$VERSION"
export BUILD_HOME=$HOME
. build.sh

