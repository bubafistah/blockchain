FROM lthn/chain as builder

ENV SRC_DIR /usr/local/src/chain

RUN set -x \
  && buildDeps=' \
      ca-certificates \
      cmake \
      g++ \
      git \
      libboost1.58-all-dev \
      libssl-dev \
      make \
      pkg-config \
  ' \
  && apt-get -qq update \
  && apt-get -qq --no-install-recommends install $buildDeps

WORKDIR $SRC_DIR
COPY . .
RUN make -j5 release-static
FROM ubuntu:20.04

COPY --from=builder build/release/bin/* /usr/local/bin/

RUN  rm -r $SRC_DIR \
  && apt-get -qq --auto-remove purge $buildDeps

# Contains the blockchain
VOLUME /home/lthn/data/chain

# Generate your wallet via accessing the container and run:
# cd /wallet
# lethean-wallet-cli
VOLUME /wallet

ENV LOG_LEVEL 0
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 18080
ENV RPC_BIND_IP 127.0.0.1
ENV RPC_BIND_PORT 18081

EXPOSE 18080
EXPOSE 18081

CMD letheand --log-level=$LOG_LEVEL --p2p-bind-ip=$P2P_BIND_IP --p2p-bind-port=$P2P_BIND_PORT --rpc-bind-ip=$RPC_BIND_IP --rpc-bind-port=$RPC_BIND_PORT
