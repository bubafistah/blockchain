FROM lthn/build as builder

WORKDIR /home/lthn/src/chain

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static
ARG BUILD_THREADS=1
RUN rm -rf build && make -j${BUILD_THREADS} ${RELEASE_TYPE}

# Build stage over, now we make the end image.
FROM ubuntu:20.04 as final

RUN cd testnet || (mkdir "testnet" && cd testnet) || exit

# set network type and its difficulty

ENV NETTYPE=testnet
ENV DIFFICULT=1
ENV BASE_DIR="/home/lthn"
ENV CLI_DIR="/home/lthn/cli"
ENV DATA_DIR="/home/lthn/data/testnet"
ENV BASE_DIR="/home/lthn"
ENV IMG_TAG="chain"
ENV WALLET_DIR="${BASE_DIR}/wallet"
ENV BIN_DIR="${BASE_DIR}/cli/testnet"
ENV CONF_DIR="${BASE_DIR}/config/testnet"
ENV LOG_DIR="${BASE_DIR}/log"
ENV SRC_DIR="${BASE_DIR}/src/testnet"
ENV DATA_DIR="${BASE_DIR}/data/testnet"

RUN adduser --system --group lthn

# grab the files made in the builder stage
COPY --chown=lthn:lthn --from=lthn/sdk-shell $BASE_DIR $BASE_DIR
COPY --chown=lthn:lthn --from=builder /home/lthn/src/chain/build/release/bin $BIN_DIR
WORKDIR /home/lthn

RUN chmod +x lthn.sh cli/* && mkdir -p $DATA_DIR && chown -R lthn:lthn $DATA_DIR

# ports needed when running this image
EXPOSE 38782
EXPOSE 38772
USER lthn


ENTRYPOINT ["./lthn.sh", "testnet"]

