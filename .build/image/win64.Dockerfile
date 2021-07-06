FROM lthn/build:lthn-compile-win64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1

RUN set -ex && \
    git submodule update --init --force && \
    if [ -z "$NPROC" ] ; \
        then make depends target=x86_64-w64-mingw32 tag=win-x64 -j$(nproc) ; \
        else make depends target=x86_64-w64-mingw32 tag=win-x64 -j$NPROC ; \
    fi && \
    (cd /lethean/chain/build/release/bin && tar -cvzf lethean-chain-windows-x86_64.tar.gz *)

FROM alpine
COPY --from=builder /lethean/chain/build/release/bin/ /