FROM lthn/build:lthn-chain-next as builder
RUN apt-get update && apt-get install -y curl python3 g++-mingw-w64-x86-64 bc

ARG THREADS=1
WORKDIR /depends
COPY ./chain/contrib/depends .

RUN make -j$THREADS -C /depends HOST=x86_64-w64-mingw32 NO_QT=1