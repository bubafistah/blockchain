FROM lthn/build:lthn-compile-base as builder

WORKDIR /home/lthn/chain/src
WORKDIR /home/lthn/chain/src

COPY . .
WORKDIR /home/lthn/chain/src/chain


ENV USE_SINGLE_BUILDDIR=1
ARG NPROC=1
RUN set -ex && \
    git submodule init && git submodule update --depth 1 && \
    rm -rf chain/build

RUN set -ex && \
     if [ -z "$NPROC" ] ; \
        then make -j$(nproc) release-static-linux-x86_64 ; \
        else make -j$NPROC release-static-linux-x86_64 ; \
    fi

FROM ubuntu:16.04 as final

ENV BASE_DIR="/home/lthn/chain"
ENV IMG_TAG="chain"
ENV WALLET_DIR="${BASE_DIR}/wallet"
ENV BIN_DIR="${BASE_DIR}/bin"
ENV CONF_DIR="${BASE_DIR}/conf"
ENV LOG_DIR="${BASE_DIR}/log"
ENV SRC_DIR="${BASE_DIR}/sr"
ENV DATA_DIR="${BASE_DIR}/data"

# clean up this new ubuntu
RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates sudo libreadline6 && \
    apt-get clean && \
    rm -rf /var/lib/apt

# a copy of the binaries for extraction.
WORKDIR $BASE_DIR

# Create lethean user
RUN adduser --system --no-create-home --group --disabled-password lthn && \
	mkdir -p $DATA_DIR/lmdb $WALLET_DIR $LOG_DIR $BIN_DIR $CONF_DIR && \
	chown -R lthn:lthn $BASE_DIR ; \
    echo "lthn ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers;

COPY --from=lthn/sdk-shell:latest --chown=lthn:lthn /home/lthn $BASE_DIR
# grab the files made in the builder stage
#COPY --from=lthn/chain $BIN_DIR $BIN_DIR
COPY --from=builder --chown=lthn:lthn /home/lthn/chain/src/chain/build/release/bin $BIN_DIR
COPY --from=builder --chown=lthn:lthn /home/lthn/chain/src/chain/build/release/bin /usr/local/bin


RUN chmod +x $BASE_DIR/lthn.sh $BIN_DIR/*
# ports needed when running this image
# zmq
EXPOSE 48792
# rpc
EXPOSE 48782
# p2p
EXPOSE 48772

# switch to lethean
USER lthn

ENTRYPOINT ["./lthn.sh", "daemon"]
