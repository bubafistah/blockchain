FROM ubuntu:20.04 as base
# This sets the build target, you can pick from:
# 64: x86_64-unknown-linux-gnu, x86_64-unknown-freebsd, x86_64-w64-mingw32
# 32: i686-pc-linux-gnu, i686-w64-mingw32, arm-linux-gnueabihf
# arm: aarch64-linux-gnu, riscv64-linux-gnu
ARG BUILD=x86_64-unknown-linux-gnu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends build-essential g++ gcc libtool libtool-bin cmake autotools-dev automake pkg-config \
      git ca-certificates python3 libssl-dev make gperf xutils-dev bison autopoint curl \
      doxygen graphviz g++-aarch64-linux-gnu g++-arm-linux-gnueabihf g++-x86-64-linux-gnu g++-riscv64-linux-gnu g++-mingw-w64


# 1 thread needs 2gb ram, to adjust add this to the docker build cmd: --build-arg THREADS=20
ARG THREADS=20

WORKDIR /build

FROM base as depends-windows
RUN apt-get install -y --no-install-recommends qttools5-dev-tools
# Windows needs a posix alternative to compile
RUN update-alternatives --set x86_64-w64-mingw32-g++ $(which x86_64-w64-mingw32-g++-posix) && \
    update-alternatives --set x86_64-w64-mingw32-gcc $(which x86_64-w64-mingw32-gcc-posix);
COPY ./contrib/depends /build/contrib/depends
RUN cd /build/contrib/depends && make download-win
RUN cd /build/contrib/depends && make HOST=x86_64-w64-mingw32 -j${THREADS} && cd ../.. && mkdir -p /build/build/x86_64-w64-mingw32/release

FROM base as depends-linux
RUN apt-get install -y --no-install-recommends python3-zmq libdbus-1-dev libharfbuzz-dev crossbuild-essential-amd64
COPY ./contrib/depends /build/contrib/depends
RUN cd /build/contrib/depends && make download-linux
RUN cd /build/contrib/depends && make HOST=x86_64-unknown-linux-gnu -j${THREADS} && cd ../.. && mkdir -p /build/build/x86_64-unknown-linux-gnu/release

FROM depends-linux as depends-macos


FROM depends-windows as build-windows
COPY . .
RUN cd build/x86_64-w64-mingw32/release && cmake -D MANUAL_SUBMODULES=1 -D CMAKE_TOOLCHAIN_FILE=/build/contrib/depends/x86_64-w64-mingw32/share/toolchain.cmake ../../.. && make -j${THREADS}


FROM depends-linux as build-linux
COPY . .
RUN cd build/x86_64-unknown-linux-gnu/release && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-x64" -D DEVELOPER_LOCAL_TOOLS=1 -D MANUAL_SUBMODULES=1 -D CMAKE_TOOLCHAIN_FILE=/build/contrib/depends/x86_64-unknown-linux-gnu/share/toolchain.cmake ../../.. && make -j${THREADS}

FROM depends-macos as build-macos
COPY . .
RUN cd build/x86_64-unknown-linux-gnu/release && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="mac-x64" -D DEVELOPER_LOCAL_TOOLS=1 -D MANUAL_SUBMODULES=1 -D CMAKE_TOOLCHAIN_FILE=/build/contrib/depends/x86_64-unknown-linux-gnu/share/toolchain.cmake ../../.. && make -j${THREADS}


FROM scratch as x86_64-linux-gnu
COPY --from=build-linux /build/build/x86_64-unknown-linux-gnu/release/bin /
FROM scratch as x86_64-w64-mingw32
COPY --from=build-windows /build/build/x86_64-w64-mingw32/release/bin /
FROM scratch as x86_64-apple-darwin11
COPY --from=build-macos /build/build/* /

FROM scratch as final
COPY --from=x86_64-linux-gnu / /linux
COPY --from=x86_64-w64-mingw32 / /windows
COPY --from=x86_64-apple-darwin11 / /macos