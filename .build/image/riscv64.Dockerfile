FROM lthn/build:lthn-compile-riscv64 as builder

WORKDIR /lethean

COPY . .
WORKDIR /lethean/chain
ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1

RUN set -ex && \
    git submodule update --init --force --depth 1  && \
    if [ -z "$NPROC" ] ; \
        then make depends target=riscv64-linux-gnu -j$(nproc) ; \
        else make depends target=riscv64-linux-gnu -j$NPROC ; \
    fi && \
    (cd /lethean/chain/build/release/bin && tar -cvzf lethean-chain-riscv64.tar.gz *)

FROM alpine
COPY --from=builder /lethean/chain/build/release/bin/ /