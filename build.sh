#!/bin/bash

if [ -z $VERSION ]
then
    echo '$VERSION: Chromium version is undefined.'
    return
fi

if [ -z $BUILD ]
then
    echo '$BUILD: Chromium build working path is undefined.'
    return
fi

function iferr { if [ ! $? -eq '0' ] then exit fi }

WD=$(pwd)
BUILD_HOME=$(dirname $(realpath $BASH_SOURCE))

cd $BUILD_HOME

rm -rf $BUILD
mkdir -p $BUILD
iferr
cp ${BUILD_HOME}/args.gn $BUILD/args.gn
iferr

df -h

echo
echo "Version  : $VERSION"
echo "Build in : $BUILD"
echo

PATH=${PATH}:${BUILD_HOME}/depot_tools

cd $BUILD_HOME

if [ ! -d depot_tools ]
then
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    iferr
    rm -rf depot_tools/.git
fi

if [ ! -d src ]
then
    git clone https://chromium.googlesource.com/chromium/src.git --branch $VERSION --depth 1
    iferr
fi

if [ ! -a .gclient ]
then
    gclient config --spec 'solutions = [
  {
    "name": "src",
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "custom_deps": {},
    "custom_vars": {},
  },
]'
    iferr
fi

gclient sync
iferr
gclient runhooks
iferr

cd src

gn gen $BUILD
iferr

autoninja -C $BUILD chrome
iferr

rm -f $BUILD/*_deps

cd $WD
