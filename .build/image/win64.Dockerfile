FROM lthn/build:lthn-compile-win64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG THREADS=20

RUN set -ex && \
    git submodule update --init --force --depth 1  && \
    make depends target=x86_64-w64-mingw32 tag=win-x64 -j$THREADS ;


FROM scratch as export-image
COPY --from=builder /lethean/chain/build/x86_64-w64-mingw32/bin/ /