
FROM ubuntu:22.04

LABEL maintainer="Lapio Plays"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV GOTTY_TAG_VER=v1.0.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        bash \
        tar \
        gzip \
        locales \
        findutils \
        procps && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Install GoTTY
RUN set -eux; \
    curl -fSL \
      "https://github.com/yudai/gotty/releases/download/${GOTTY_TAG_VER}/gotty_linux_amd64.tar.gz" \
      -o /tmp/gotty.tar.gz; \
    mkdir -p /tmp/gotty; \
    tar -xzf /tmp/gotty.tar.gz -C /tmp/gotty; \
    GOTTY_BIN="$(find /tmp/gotty -type f -name gotty -print -quit)"; \
    test -n "$GOTTY_BIN"; \
    install -m 755 "$GOTTY_BIN" /usr/local/bin/gotty; \
    /usr/local/bin/gotty --version; \
    rm -rf /tmp/gotty /tmp/gotty.tar.gz

# Install SSHX
RUN set -eux; \
    curl -fsSL https://sshx.io/get -o /tmp/sshx-install.sh; \
    bash /tmp/sshx-install.sh; \
    test -x /usr/local/bin/sshx; \
    /usr/local/bin/sshx --help || true; \
    rm -f /tmp/sshx-install.sh

# Create user
RUN useradd -m -s /bin/bash terminal

# Startup script
COPY lapio-plays.sh /lapio-plays.sh

RUN chmod 755 /lapio-plays.sh

WORKDIR /home/terminal

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "/lapio-plays.sh"]
