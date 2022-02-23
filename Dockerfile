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


# Rust builder
FROM ${ARCH}rust:${RUST_VERSION} AS rust-builder

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo install --no-default-features starship && \
    cargo install bat && \
    cp /usr/local/cargo/bin/starship / && \
    cp /usr/local/cargo/bin/bat / && \
    starship init --print-full-init bash > /starship-init.sh


# Real Image
FROM ${ARCH}ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
WORKDIR /root

COPY --from=go-builder /certigo /usr/local/bin/
COPY --from=rust-builder /starship /usr/local/bin/
COPY --from=rust-builder /bat /usr/local/bin/
COPY --from=rust-builder /starship-init.sh /root/.starship-init.sh
COPY bashrc /root/.bashrc
COPY starship.toml /root/.config/starship.toml

# TODO: add certigo and get a better shell in
RUN --mount=type=cache,target=/var/cache/apt \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt upgrade -y && \
    apt install -y curl vim iproute2 bind9-dnsutils mtr-tiny \
        openssh-client ripgrep fd-find bash-completion && \
    rm -rf /var/lib/apt/lists/*
