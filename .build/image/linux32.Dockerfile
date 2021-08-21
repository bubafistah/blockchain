FROM lthn/build:lthn-compile-win64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1
RUN apt-get update && apt-get install -y python3 g++-mingw-w64-i686 qttools5-dev-tools
RUN set -ex && \
    git submodule update --init --force --depth 1 && \
    make depends -j20 root=/depends target=i686-w64-mingw32

FROM scratch as export-image
COPY --from=builder /lethean/chain/build/release/bin/ /