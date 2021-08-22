ARG BUILD=x86_64-unknown-linux-gnu
ARG TOOLCHAIN_IMAGE=lthn/build:depends-${BUILD}
FROM ${TOOLCHAIN_IMAGE} as depends
# docker cant handle variable subsitution within string subsitution, making getting the depends assets dynamicly harder.
# we have to do import as a layer in a multistage build, then we can copy from this stage, to do that we need to make
# a variable with lthn/build:depends-${BUILD_TARGET} then pass it to FROM as a complete string

FROM lthn/build:compile as build

# This sets the build target, you can pick from:
# 64: x86_64-unknown-linux-gnu, x86_64-unknown-freebsd, x86_64-w64-mingw32
# 32: i686-pc-linux-gnu, i686-w64-mingw32, arm-linux-gnueabihf
# arm: aarch64-linux-gnu, riscv64-linux-gnu
ARG BUILD=x86_64-unknown-linux-gnu

# Package Mapping, eg: --build-arg TARGET=aarch64-linux-gnu --build-arg PACKAGE="python3 gperf g++-aarch64-linux-gnu"
#
ENV PACKAGE=""
RUN case ${BUILD} in \
    x86_64-unknown-linux-gnu) \
     PACKAGE="gperf cmake python3-zmq libdbus-1-dev libharfbuzz-dev"; \
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
     PACKAGE="cmake python3 g++-mingw-w64-x86-64 qttools5-dev-tools"; \
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
    esac \
    && apt-get update && apt-get install -y $PACKAGE;

# 1 thread needs 2gb ram, to adjust add this to the docker build cmd: --build-arg THREADS=20
ARG THREADS=1

# Windows needs a posix alternative to compile
RUN if [ ${BUILD} = x86_64-w64-mingw32 ] || [ ${BUILD} = i686-w64-mingw32 ]; then \
    update-alternatives --set ${BUILD}-g++ $(which ${BUILD}-g++-posix) && \
    update-alternatives --set ${BUILD}-gcc $(which ${BUILD}-gcc-posix); \
    fi

# main build directory
WORKDIR /lethean

# Take files from provided context (use -f path/to/Dockerfile if the source dir dosnt have this file
COPY . .

# now we inject the precompile libs for the target arch
# you can do this: lthn/build:depends-x86_64-unknown-linux-gnu but this file compiles all our binaries so has a dynamic include
# COPY --from=lthn/build:depends-x86_64-w64-mingw32 / /lethean/chain/contrib/depends
COPY --from=depends / /lethean/chain/contrib/depends

# git repo is at the top level, we need to update it before going into the chain
RUN git submodule update --init --force || true

# -C runs this command inside the set folder, the same as: cd /lethean/chain && make -j20 depends target=x86_64-w64-mingw32;
RUN make -j${THREADS} -C /lethean/chain depends target=${BUILD};

# now we remove the whole operating system using the "scratch" image, this is a special docker image to crate
# a blank virtual filesystem, this image is not to be used directly, but included in other docker images
# or just used to extract or compile the arch you desire.
FROM scratch as export-image

# our final image has the bin dir as the root / , literally nothing else.
COPY --from=build  /lethean/chain/build/release/bin /


