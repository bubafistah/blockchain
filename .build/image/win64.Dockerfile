FROM lthn/build:lthn-compile-win64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1

RUN set -ex && \
    git submodule update --init --force --depth 1  && \
    if [ -z "$NPROC" ] ; \
        then make depends target=x86_64-w64-mingw32 tag=win-x64 -j$(nproc) ; \
        else make depends target=x86_64-w64-mingw32 tag=win-x64 -j$NPROC ; \
    fi

FROM scratch as export-image
COPY --from=builder /lethean/chain/build/release/bin/ /