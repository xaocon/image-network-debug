ARG ARCH=
ARG UBUNTU_VERSION=rolling
FROM ${ARCH}ubuntu:${UBUNTU_VERSION}

ARG CERTIGO_VERSION=1.14.1

# ARG so it won't be set in image
ARG DEBIAN_FRONTEND=noninteractive

# TODO: add certigo and get a better shell in
RUN apt update && \
    apt install -y curl iproute2 bind9-dnsutils mtr-tiny openssh-client
