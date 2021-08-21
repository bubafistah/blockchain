ARG BUILD_TARGET=x86_64-unknown-linux-gnu
ARG TOOLCHAIN_IMAGE=lthn/build:depends-${BUILD_TARGET}

FROM ${TOOLCHAIN_IMAGE} as depends
FROM lthn/build:compile as build
ARG BUILD_TARGET=x86_64-unknown-linux-gnu
ARG PACKAGE="python3 gperf g++-arm-linux-gnueabihf"
ARG THREADS=1

RUN apt-get update && apt-get install -y ${PACKAGE}

RUN if [ ${BUILD_TARGET} = x86_64-w64-mingw32 ] || [ ${BUILD_TARGET} = i686-w64-mingw32 ]; then \
    update-alternatives --set ${BUILD_TARGET}-g++ $(which ${BUILD_TARGET}-g++-posix) && \
    update-alternatives --set ${BUILD_TARGET}-gcc $(which ${BUILD_TARGET}-gcc-posix); \
    fi

WORKDIR /lethean

COPY . .
COPY --from=depends --chown=root:root / /lethean/chain/contrib/depends

RUN git submodule update --init --force

RUN make -j${THREADS} -C /lethean/chain depends target=${BUILD_TARGET};

FROM scratch as export-image
COPY --from=build  /lethean/chain/build/release/bin /


