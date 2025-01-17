ARG GOLANG_VERSION=latest
ARG UBUNTU_VERSION=rolling


# Go builder
FROM golang:${GOLANG_VERSION} AS builder

RUN echo "TARGETARCH is set to ${TARGETARCH:-EMPTY}"
ARG TARGETARCH
ARG CERTIGO_VERSION="1.16.0"
ARG BAT_VERSION="0.21.0"

# ARCH specific for now
ADD https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_${TARGETARCH}.deb /bat.deb
ADD https://github.com/square/certigo/archive/refs/tags/v${CERTIGO_VERSION}.tar.gz .

# Build certigo
RUN tar xaf v${CERTIGO_VERSION}.tar.gz && \
    cd certigo-${CERTIGO_VERSION} && \
    bash build && mv bin/certigo /


# Real Image
FROM ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
WORKDIR /root

COPY --from=builder /bat.deb .
COPY --from=builder /certigo /usr/local/bin/

ADD https://starship.rs/install.sh .
ADD https://raw.githubusercontent.com/xaocon/grml-etc-core/mine/etc/zsh/zshrc .zshrc

COPY starship.toml .config/starship.toml
COPY zshrc.local .zshrc.local

# TODO: add certigo and get a better shell in
RUN --mount=type=cache,target=/var/cache/apt \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt upgrade -y && \
    apt install -y curl vim iproute2 bind9-dnsutils mtr-tiny \
        openssh-client ripgrep fd-find bash-completion zsh && \
    dpkg -i bat.deb && \
    sh install.sh -y && \
    starship init --print-full-init zsh > .starship-init.zsh && \
    zsh -c 'zcompile -U .zshrc && zcompile .zshrc.local' && \
    rm bat.deb && rm install.sh && \
    rm -rf /var/lib/apt/lists/*

CMD ["zsh", "-l"]
