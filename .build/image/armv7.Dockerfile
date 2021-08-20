FROM lthn/build:lthn-compile-armv7 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1

RUN set -ex && \
    git submodule update --init --force --depth 1  && \
    if [ -z "$NPROC" ] ; \
        then make depends target=arm-linux-gnueabihf -j$(nproc) ; \
        else make depends target=arm-linux-gnueabihf -j$NPROC ; \
    fi

FROM scratch as export-image
COPY --from=builder /lethean/chain/build/release/bin/ /