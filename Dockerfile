ARG ARCH=
ARG GOLANG_VERSION=latest
ARG UBUNTU_VERSION=rolling
FROM ${ARCH}golang:${UBUNTU_VERSION} AS builder

ARG CERTIGO_VERSION=1.14.1

RUN curl -LO https://github.com/square/certigo/archive/refs/tags/v${CERTIGO_VERSION}.tar.gz && \
    tar xaf v${CERTIGO_VERSION}.tar.gz && cd certigo-${CERTIGO_VERSION} && \
    bash build && mv bin/certigo /

FROM ${ARCH}ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /certigo /usr/local/bin/

# TODO: add certigo and get a better shell in
RUN apt update && \
    apt install -y curl iproute2 bind9-dnsutils mtr-tiny openssh-client
