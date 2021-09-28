FROM ubuntu:20.04 as base
# This sets the build target, you can pick from:
# 64: x86_64-unknown-linux-gnu, x86_64-unknown-freebsd, x86_64-w64-mingw32
# 32: i686-pc-linux-gnu, i686-w64-mingw32, arm-linux-gnueabihf
# arm: aarch64-linux-gnu, riscv64-linux-gnu
ARG BUILD=x86_64-unknown-linux-gnu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y build-essential libtool cmake autotools-dev automake pkg-config \
      bsdmainutils curl git ca-certificates ccache wget gettext python libssl-dev make automake  \
      gettext gperf libpthread-stubs0-dev libtool-bin xutils-dev bison autopoint \
      libzmq3-dev libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev \
      libexpat1-dev libpgm-dev qttools5-dev-tools libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
      libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev \
      libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev \
      libboost-thread-dev ccache doxygen graphviz

RUN apt-get install -y libgtest-dev && cd /usr/src/gtest && cmake . && make && mv /usr/src/gtest/* /usr/lib/
# Package Mapping, eg: --build-arg TARGET=aarch64-linux-gnu --build-arg PACKAGE="python3 gperf g++-aarch64-linux-gnu"
#
ENV PACKAGE=""
RUN case ${BUILD} in \
    x86_64-unknown-linux-gnu) \
     PACKAGE=""; \
    ;; \
    i686-pc-linux-gnu) \
     PACKAGE="gperf cmake g++-multilib python3-zmq"; \
    ;; \
    arm-linux-gnueabihf) \
     PACKAGE="python3 gperf g++-arm-linux-gnueabihf"; \
    ;; \
    aarch64-linux-gnu) \
     PACKAGE="python3 gperf g++-aarch64-linux-gnu"; \
    ;; \
    x86_64-w64-mingw32) \
     PACKAGE=""; \
    ;; \
    i686-w64-mingw32) \
     PACKAGE="python3 g++-mingw-w64-i686 qttools5-dev-tools"; \
    ;; \
    riscv64-linux-gnu) \
     PACKAGE="python3 gperf g++-riscv64-linux-gnu"; \
    ;; \
    x86_64-unknown-freebsd) \
     PACKAGE="clang-8 gperf cmake python3-zmq libdbus-1-dev libharfbuzz-dev"; \
    ;; \
    esac

# 1 thread needs 2gb ram, to adjust add this to the docker build cmd: --build-arg THREADS=20
ARG THREADS=20

WORKDIR /build

FROM base as depends-windows
RUN apt-get install -y python3 g++-mingw-w64 qttools5-dev-tools
# Windows needs a posix alternative to compile
RUN update-alternatives --set x86_64-w64-mingw32-g++ $(which x86_64-w64-mingw32-g++-posix) && \
    update-alternatives --set x86_64-w64-mingw32-gcc $(which x86_64-w64-mingw32-gcc-posix);
COPY . .
RUN cd contrib/depends && make HOST=x86_64-w64-mingw32 -j${THREADS} && cd ../.. && mkdir -p build/x86_64-w64-mingw32/release

FROM depends-windows as build-windows
RUN cd build/x86_64-w64-mingw32/release && cmake -D MANUAL_SUBMODULES=1 -D CMAKE_TOOLCHAIN_FILE=/build/contrib/depends/x86_64-w64-mingw32/share/toolchain.cmake ../../.. && make -j${THREADS}

FROM base as depends-linux
RUN apt-get install -y gperf python3-zmq libdbus-1-dev libharfbuzz-dev
COPY . .
RUN cd contrib/depends && make HOST=x86_64-unknown-linux-gnu -j${THREADS} && cd ../.. && mkdir -p build/x86_64-unknown-linux-gnu/release

FROM depends-linux as build-linux
RUN cd build/x86_64-unknown-linux-gnu/release && cmake -D MANUAL_SUBMODULES=1 -D CMAKE_TOOLCHAIN_FILE=/build/contrib/depends/x86_64-unknown-linux-gnu/share/toolchain.cmake ../../.. && make -j${THREADS}

FROM scratch as final-linux
COPY --from=build-linux /build/build/x86_64-unknown-linux-gnu/release/bin /
FROM scratch as final-windows
COPY --from=build-windows /build/build/x86_64-w64-mingw32/release/bin /

FROM scratch as final
COPY --from=final-linux / /linux
COPY --from=final-windows / /windows