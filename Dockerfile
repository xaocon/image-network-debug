ARG GOLANG_VERSION=latest
ARG UBUNTU_VERSION=rolling


# Go builder
FROM --platform=$TARGETPLATFORM golang:${GOLANG_VERSION} AS go-builder

ARG CERTIGO_VERSION=1.15.1

RUN curl -LO https://github.com/square/certigo/archive/refs/tags/v${CERTIGO_VERSION}.tar.gz && \
    tar xaf v${CERTIGO_VERSION}.tar.gz && cd certigo-${CERTIGO_VERSION} && \
    bash build && mv bin/certigo /


# Real Image
FROM --platform=$TARGETPLATFORM ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
WORKDIR /root

ARG BAT_VERSION="0.20.0"

COPY --from=go-builder /certigo /usr/local/bin/

# ARCH specific for now
ADD https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${TARGETARCH}.deb .
ADD https://starship.rs/install.sh .
ADD https://raw.githubusercontent.com/xaocon/grml-etc-core/mine/etc/zsh/zshrc .zshrc

COPY starship.toml /root/.config/starship.toml

# TODO: add certigo and get a better shell in
RUN --mount=type=cache,target=/var/cache/apt \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt upgrade -y && \
    apt install -y curl vim iproute2 bind9-dnsutils mtr-tiny \
        openssh-client ripgrep fd-find bash-completion zsh && \
    dpkg -i bat_${BAT_VERSION}_${TARGETARCH}.deb && \
    sh install.sh -y && \
    starship init --print-full-init zsh > .starship-init.zsh && \
    rm bat_${BAT_VERSION}_${TARGETARCH}.deb && rm install.sh && \
    rm -rf /var/lib/apt/lists/*
