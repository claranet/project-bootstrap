
FROM alpine:3.7

ENV WORKDIR=/app

WORKDIR ${WORKDIR}

COPY . ${WORKDIR}/

RUN    apk add --no-cache \
            bash \
            python \
            py-pip \
            jq \
            curl \
            git \
    && pip install yamale yq \
    && curl -o /usr/local/bin/gomplate -sSL https://github.com/hairyhenderson/gomplate/releases/download/v2.4.0/gomplate_linux-amd64-slim \
    && chmod 755 /usr/local/bin/gomplate \
    && rm -rf /var/cache/apk/*

ENTRYPOINT [ "./bootstrap" ]
