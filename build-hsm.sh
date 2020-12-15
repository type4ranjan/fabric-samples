#!/bin/bash

#This script clones Hyperledger fabric repos, checks out a specific tag and builds the
#required binaries.

check_error() {
  if [ $? -ne 0 ]; then
    echo "ERROR: Something went wrong!"
    exit 1
  fi
}

TAG=release-2.3

ROOT=$PWD

BUILD_DIR=$ROOT/build


if [ -d build ]; then
  rm -rf build/*
fi

mkdir -p build

cd $BUILD_DIR
check_error

export GOPATH=$PWD

GO_HL_DIR=src/github.com/hyperledger
mkdir -p $GO_HL_DIR
cd $GO_HL_DIR
git clone https://github.com/hyperledger/fabric
check_error

cd fabric
git checkout -b $TAG origin/$TAG
check_error
GO_TAGS=pkcs11 make peer orderer cryptogen configtxgen configtxlator
check_error
cd ..

git clone https://github.com/hyperledger/fabric-ca
cd fabric-ca
git checkout -b release-1.4 origin/release-1.4
check_error
make fabric-ca-client
check_error

cd $BUILD_DIR

if [ -d ../bin ]; then
  rm -rf ../bin/*
fi
mkdir -p ../bin
cp $GO_HL_DIR/fabric/.build/bin/* ../bin
cp $GO_HL_DIR/fabric-ca/bin/* ../bin

mkdir -p ../first-network-luna/bin
cp ../bin/* ../first-network-luna/bin

mkdir -p ../first-network-dpod/bin
cp ../bin/* ../first-network-dpod/bin
