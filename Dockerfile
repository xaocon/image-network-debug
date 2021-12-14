ARG ALPINE_VERSION=3.15
FROM alpine:${ALPINE_VERSION}

ARG CERTIGO_VERSION=1.13.0

RUN apk add --no-cache fish bind-tools busybox-extras iproute2 curl mtr openssl openssl3 openssh libc6-compat \
    && curl -Lo /usr/local/bin/certigo https://github.com/square/certigo/releases/download/v${CERTIGO_VERSION}/certigo-linux-amd64

CMD ["/usr/bin/fish", "-l"]
