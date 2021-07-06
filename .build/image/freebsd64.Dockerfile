FROM lthn/build:lthn-compile-base as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1

RUN set -ex && \
    git submodule update --init --force && \
    if [ -z "$NPROC" ] ; \
        then make -j$(nproc) release-static-freebsd-x86_64 ; \
        else make -j$NPROC release-static-freebsd-x86_64 ; \
    fi && \
    (cd /lethean/chain/build/release/bin && tar -cvzf lethean-chain-freebsd-x86_64.tar.gz *)

FROM alpine
COPY --from=builder /lethean/chain/build/release/bin/ /