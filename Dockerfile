ARG ARCH=
ARG UBUNTU_VERSION=rolling
FROM ${ARCH}ubuntu:${UBUNTU_VERSION}

ARG CERTIGO_VERSION=1.14.1

# ARG so it won't be set in image
ARG DEBIAN_FRONTEND=noninteractive

# Currently certigo is only avialable prebuilt to amd64
RUN apk add --no-cache fish bind-tools busybox-extras iproute2 curl mtr openssl openssl3 openssh libc6-compat \
    && curl -Lo /usr/local/bin/certigo https://github.com/square/certigo/releases/download/v${CERTIGO_VERSION}/certigo-linux-amd64

# openssl3

RUN apt update && \
    apt install -y curl iproute2 bind9-dnsutils mtr-tiny openssh-client

CMD ["/usr/bin/fish", "-l"]
