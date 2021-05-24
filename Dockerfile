FROM ubuntu:16.04

RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential ca-certificates cmake pkg-config git apt-utils software-properties-common;

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && apt-get update

RUN set -ex \
    && apt-get install -y \
        libboost-all-dev libssl-dev libzmq3-dev \
        libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev \
        libldns-dev libexpat1-dev doxygen graphviz libpgm-dev qttools5-dev-tools \
        libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev;

RUN apt install -y gcc-9 g++-9 gcc-arm-none-eabi binutils-arm-none-eabi gdb-arm-none-eabi openocd

# Where all the works done.
WORKDIR /usr/local/src/lethean.io/blockchain/lethean

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static

# if you want to clear build, purge the runner cache/prune the builder
RUN rm -rf build && make ${RELEASE_TYPE}

# New image, changes output image to a fresh Ubuntu image.
FROM ubuntu:16.04

# grab the files made in the builder stage
COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/build/release/bin /home/lethean/blockchain/lethean

RUN ln -s /home/lethean/blockchain/lethean/* /usr/local/bin

# ONBUILD When used as a base to extend from, runs directly after FROM into target context
ONBUILD COPY /home/lethean/blockchain/lethean/* /home/lethean/blockchain/lethean

# clean up this new ubuntu
RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates libreadline6 && \
    apt-get clean && \
    rm -rf /var/lib/apt

# Create lethean user
RUN adduser --system --group --disabled-password lethean && \
	mkdir -p /wallet /home/lethean/.lethean /home/lethean/.intensecoin /home/lethean/bin && \
	chown -R lethean:lethean /home/lethean && \
	chown -R lethean:lethean /wallet

# a copy of the binaries for extraction.
VOLUME /home/lethean

# Generate your wallet via accessing the container and run:
# cd /wallet
# lethean-wallet-cli
VOLUME /wallet

# ports needed when running this image
EXPOSE 48782
EXPOSE 48772

# switch to lethean
USER lethean

ENTRYPOINT ["letheand", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=48772", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=48782", "--non-interactive", "--confirm-external-bind"]

