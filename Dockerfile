ARG GOLANG_VERSION=latest
ARG UBUNTU_VERSION=rolling


# Go builder
FROM golang:${GOLANG_VERSION} AS builder

# TODO: remove this
RUN echo "TARGETARCH is set to ${TARGETARCH:-EMPTY}"
ARG TARGETARCH
ARG CERTIGO_VERSION="1.16.0"

ADD https://github.com/square/certigo/archive/refs/tags/v${CERTIGO_VERSION}.tar.gz .

# Build certigo
RUN mkdir /output && \
    tar xaf v${CERTIGO_VERSION}.tar.gz && \
    ( cd certigo-${CERTIGO_VERSION} && bash build && install bin/certigo /output/ )

# Real Image
FROM ubuntu:${UBUNTU_VERSION}

# ARG so it won't be set in image
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8

WORKDIR /root

COPY --from=builder /output/certigo /usr/local/bin/

ADD https://raw.githubusercontent.com/grml/grml-etc-core/master/etc/zsh/zshrc .zshrc

COPY zshrc.local .zshrc.local

RUN --mount=type=cache,target=/var/cache/apt \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt upgrade -y && \
    apt install -y curl neovim iproute2 bind9-dnsutils mtr-tiny \
        openssh-client ripgrep fd-find bash-completion zsh bat && \
    mkdir /root/.zsh && \
    zsh -c 'zcompile -U .zshrc && zcompile .zshrc.local' && \
    zsh -c 'for FILE in $HOME/.zsh/*(N); do zcompile -U $FILE; done' && \
    rm -rf /var/lib/apt/lists/*

CMD ["zsh", "-l"]
