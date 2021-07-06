FROM lthn/build:lthn-compile-win64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ARG NPROC=1
ARG QT_VERSION=5.15.2
ENV SOURCE_DATE_EPOCH=1397818193

RUN set -ex && \
    git submodule update --init --force && \
    if [ -z "$NPROC" ] ; \
        then make depends target=x86_64-w64-mingw32 tag=win-x64 -j$(nproc) ; \
        else make depends target=x86_64-w64-mingw32 tag=win-x64 -j$NPROC ; \
    fi && \
    (cd /lethean/chain/release/bin && tar -cvzf lethean-chain-win64.tar.gz *)

FROM alpine
COPY --from=builder /lethean/chain/build/release/bin/ /