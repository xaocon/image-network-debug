ARG ARCH=
ARG GOLANG_VERSION=latest
ARG RUST_VERSION=latest
ARG UBUNTU_VERSION=rolling


# Go builder
FROM ${ARCH}golang:${GOLANG_VERSION} AS go-builder

ARG CERTIGO_VERSION=1.14.1

RUN curl -LO https://github.com/square/certigo/archive/refs/tags/v${CERTIGO_VERSION}.tar.gz && \
    tar xaf v${CERTIGO_VERSION}.tar.gz && cd certigo-${CERTIGO_VERSION} && \
    bash build && mv bin/certigo /


# Real Image
FROM ${ARCH}ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
WORKDIR /root

ARG BAT_VERSION="0.20.0"

COPY --from=go-builder /certigo /usr/local/bin/

# ARCH specific for now
ADD https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb /

COPY bashrc /root/.bashrc
COPY starship.toml /root/.config/starship.toml

# TODO: add certigo and get a better shell in
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl vim iproute2 bind9-dnsutils mtr-tiny \
        openssh-client ripgrep fd-find bash-completion && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    starship init --print-full-init bash > /root/.starship-init.sh && \
    dpkg -i /bat_${BAT_VERSION}_amd64.deb && rm /bat_${BAT_VERSION}_amd64.deb
