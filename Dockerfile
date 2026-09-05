# CivicNet Core node with ZMQ enabled
# Adapted from radiant-node's Docker.vipor (Litecoin-fork template).
# Builds from the LOCAL civicnet/ source tree (vendored in this repo).
# Build with: ./build.sh
FROM ubuntu:24.04 AS builder

LABEL description="CivicNet Core node (with ZMQ)"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV PACKAGES="\
  build-essential \
  pkg-config \
  libtool \
  git \
  autoconf \
  automake \
  libevent-dev \
  libboost-chrono-dev \
  libboost-filesystem-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libssl-dev \
  libzmq3-dev \
  libdb++-dev \
  libsqlite3-dev \
  libfmt-dev \
  help2man \
  bsdmainutils \
  python3 \
  patch \
"

RUN apt-get update && apt-get install --no-install-recommends -y $PACKAGES && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Build CivicNet Core from the LOCAL source tree (vendored in this repo),
# so local edits are picked up on every build.
WORKDIR /src
COPY civicnet/ /src/
COPY patches/ /patches/

# Apply local patches (bump outbound full-relay connections 8 -> 32)
RUN for p in /patches/*.patch; do \
      echo "Applying $p"; \
      patch -p1 -d /src < "$p" || exit 1; \
    done

WORKDIR /src
RUN ./autogen.sh && \
    ./configure --disable-tests --without-gui --enable-zmq --with-incompatible-bdb --disable-upnp --prefix=/build && \
    make -j$(nproc) -C src civicnet-node civicnet-cli civicnet-wallet && \
    mkdir -p /build/bin && \
    cp src/civicnet-node src/civicnet-cli src/civicnet-wallet /build/bin/

FROM ubuntu:24.04

WORKDIR /usr/local/
COPY --from=builder /build/ /usr/local/

RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates \
  libboost-chrono1.83.0 \
  libboost-filesystem1.83.0 \
  libboost-thread1.83.0 \
  libevent-2.1-7t64 \
  libevent-pthreads-2.1-7t64 \
  libssl3t64 \
  libzmq5 \
  libdb5.3++t64 \
  libfmt9 \
  libsqlite3-0 \
  && rm -rf /var/lib/apt/lists/*

VOLUME ["/data", "/root/.civicnet/civicnet.conf"]

EXPOSE 9332 9333 28332 28333 28334 28335

ENTRYPOINT ["/usr/local/bin/civicnet-node", "-conf=/root/.civicnet/civicnet.conf", "-server", "-zmqpubhashblock=tcp://0.0.0.0:28332", "-zmqpubhashtx=tcp://0.0.0.0:28333", "-zmqpubrawblock=tcp://0.0.0.0:28334", "-zmqpubrawtx=tcp://0.0.0.0:28335"]
