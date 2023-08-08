FROM --platform=linux/amd64 ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

ARG CALIBRE_RELEASE="6.24.0"

RUN curl -o /tmp/calibre-tarball.txz -L "https://download.calibre-ebook.com/${CALIBRE_RELEASE}/calibre-${CALIBRE_RELEASE}-x86_64.txz" && \
    mkdir -p /opt/calibre && \
    tar xvf /tmp/calibre-tarball.txz -C /opt/calibre && \
    rm -rf /tmp/*


FROM --platform=linux/amd64 debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    dnsutils \
    iproute2 \
    libfontconfig \
    libgl1 \
    libegl1 \
    libxkbcommon0 \
    python3-qtpy \
    python3-pyqt6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt/calibre /opt/calibre

RUN /opt/calibre/calibre_postinstall && \
    mkdir /library && \
    touch /library/metadata.db

COPY start-calibre-server.sh .

EXPOSE 8080
CMD [ "/start-calibre-server.sh" ]
