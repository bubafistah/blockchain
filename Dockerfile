FROM ubuntu:16.04 as builder

RUN apt-get update && apt-get install -y build-essential cmake libboost-all-dev pkg-config libssl-dev libzmq3-dev \
                       libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev \
                       libldns-dev libexpat1-dev doxygen graphviz libpgm-dev qttools5-dev-tools \
                       libhidapi-dev libusb-1.0-0-dev libprotobuf-dev protobuf-compiler libudev-dev \
                       ca-certificates git

ARG THREADS=3
ARG RELEASE_TYPE=release-static-linux-x86_64
# this is only in the build layers,
WORKDIR /lethean

COPY . .

RUN make ${RELEASE_TYPE} -j${THREADS}

FROM scratch as final
COPY --from=builder /lethean/build/release/bin /
