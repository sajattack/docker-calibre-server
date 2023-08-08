FROM --platform=linux/amd64 debian:bookworm-slim AS base
LABEL maintainer="Robert Loomans <robert@loomans.org>"

ARG APT_HTTP_PROXY

RUN if [ -n "$APT_HTTP_PROXY" ]; then printf 'Acquire::http::Proxy "%s";\n' "${APT_HTTP_PROXY}" > /etc/apt/apt.conf.d/apt-proxy.conf; fi

RUN export DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

FROM base AS download

ARG CALIBRE_RELEASE="6.24.0"

RUN export DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        xz-utils && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

RUN curl -o /tmp/calibre-tarball.txz -L "https://download.calibre-ebook.com/${CALIBRE_RELEASE}/calibre-${CALIBRE_RELEASE}-x86_64.txz" && \
    mkdir -p /opt/calibre && \
    tar xvf /tmp/calibre-tarball.txz -C /opt/calibre && \
    rm -rf /tmp/*

FROM base AS runtime

RUN export DEBIAN_FRONTEND="noninteractive" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        hicolor-icon-theme \
        iproute2 \
        libegl1 \
        libfontconfig \
        libglx0 \
        libnss3 \
        libopengl0 \
        libxcomposite1 \
        libxkbcommon0 \
        libxkbfile1 \
        libxrandr2 \
        libxrandr2 \
        libxtst6 \
        libxdamage1 \
        xdg-utils && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

COPY --from=download /opt/calibre /opt/calibre

RUN ln -s /bin/true /usr/local/bin/xdg-desktop-menu && \
    ln -s /bin/true /usr/local/bin/xdg-mime && \
    /opt/calibre/calibre_postinstall --make-errors-fatal && \
    mkdir /library && \
    touch /library/metadata.db

COPY start-calibre-server.sh .

EXPOSE 8080

CMD [ "/start-calibre-server.sh" ]
