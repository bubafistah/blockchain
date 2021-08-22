ARG BUILD_TARGET=x86_64-unknown-linux-gnu
ARG TOOLCHAIN_IMAGE=lthn/build:depends-${BUILD_TARGET}
FROM ${TOOLCHAIN_IMAGE} as depends
# docker cant handle variable subsitution within string subon a COPY, but can take a whole variable
# So we need to make lthn/build:depends-${BUILD_TARGET} then pass it to FROM as a complete string

FROM lthn/build:compile as build

# Makefile has all the vaiations
ARG BUILD_TARGET=x86_64-unknown-linux-gnu
ARG PACKAGE="python3 gperf g++-arm-linux-gnueabihf"

# 1 thread needs 2gb ram, to adjust add this to docker build cmd: --build-arg THREADS=20
ARG THREADS=1

# nothing stopping you adding more packages here, ubuntu:bionic
RUN apt-get update && apt-get install -y ${PACKAGE}

# Windows needs a posix alternative to compile
RUN if [ ${BUILD_TARGET} = x86_64-w64-mingw32 ] || [ ${BUILD_TARGET} = i686-w64-mingw32 ]; then \
    update-alternatives --set ${BUILD_TARGET}-g++ $(which ${BUILD_TARGET}-g++-posix) && \
    update-alternatives --set ${BUILD_TARGET}-gcc $(which ${BUILD_TARGET}-gcc-posix); \
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
RUN git submodule update --init --force

# -C runs this command inside the set folder, the same as: cd /lethean/chain && make -j20 depends target=x86_64-w64-mingw32;
RUN make -j${THREADS} -C /lethean/chain depends target=${BUILD_TARGET};

# now we remove the whole operating system using the "scratch" image, this is a special docker image to crate
# a blank virtual filesystem, this image is not to be used directly, but included in other docker images
# or just used to extract or compile the arch you desire.
FROM scratch as export-image

# our final image has the bin dir as the root / , literally nothing else.
COPY --from=build  /lethean/chain/build/release/bin /


