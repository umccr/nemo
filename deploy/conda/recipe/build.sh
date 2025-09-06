#!/bin/bash

export DISABLE_AUTOBREW=1
R CMD INSTALL --build .

# Copy CLI to conda bin
PKG_NAME="nemo"
BIN_DIR="${PREFIX}/bin"
mkdir -p ${BIN_DIR}
cp ${SRC_DIR}/inst/cli/${PKG_NAME}.R ${BIN_DIR}
chmod +x ${BIN_DIR}/${PKG_NAME}.R
