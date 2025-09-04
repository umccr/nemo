#!/bin/bash

export DISABLE_AUTOBREW=1
R CMD INSTALL --build .

# Copy CLI to conda bin
BIN_DIR="${PREFIX}/bin"
mkdir -p ${BIN_DIR}
cp ${SRC_DIR}/inst/cli/*.R ${BIN_DIR}
chmod +x ${BIN_DIR}/nemo.R
