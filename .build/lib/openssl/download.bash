#!/bin/bash

if [ ! -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
  cd "${SRC_DIR}" &&
  curl -s -O "https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_${OPENSSL_VERSION}.zip" &&
    echo "${OPENSSL_HASH}  OpenSSL-${OPENSSL_VERSION}.tar.gz" | sha256sum -c
fi

if [ ! -d "$OPENSSL_INSTALL_DIR_AMD64" ] && [ -f "$SRC_DIR/Openssl-${OPENSSL_VERSION}.zip" ]; then

  mkdir -p "${OPENSSL_SRC_DIR_AMD64}" &&  cd "${OPENSSL_SRC_DIR_AMD64}" && unzip  "${SRC_DIR}/OpenSSL-${OPENSSL_VERSION}.zip"

fi

if [ ! -d "$BOOST_INSTALL_DIR_ARM8" ] && [ -f "$SRC_DIR/OpenSSL-${OPENSSL_VERSION}.zip" ]; then

  mkdir -p "${OPENSSL_SRC_DIR_ARM8}" && cd "${OPENSSL_SRC_DIR_ARM8}" && unzip "${SRC_DIR}/OpenSSL-${OPENSSL_VERSION}.zip"

fi
