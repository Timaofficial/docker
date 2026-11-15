
FROM ubuntu:22.04

LABEL maintainer="Lapio Plays"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV GOTTY_TAG_VER=v1.0.1
ENV PATH="/root/.local/bin:/usr/local/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# 1. Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        bash \
        tar \
        locales \
        findutils && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# 2. Install GoTTY
RUN set -eux; \
    curl -fSL \
      "https://github.com/yudai/gotty/releases/download/${GOTTY_TAG_VER}/gotty_linux_amd64.tar.gz" \
      -o /tmp/gotty.tar.gz; \
    tar -tzf /tmp/gotty.tar.gz; \
    tar -xzf /tmp/gotty.tar.gz -C /tmp; \
    GOTTY_BIN="$(find /tmp -type f -name gotty -print -quit)"; \
    test -n "$GOTTY_BIN"; \
    install -m 755 "$GOTTY_BIN" /usr/local/bin/gotty; \
    /usr/local/bin/gotty --version; \
    rm -rf /tmp/gotty.tar.gz "$GOTTY_BIN"

# 3. Install SSHX
RUN set -eux; \
    curl -fsSL https://sshx.io/get -o /tmp/install-sshx.sh; \
    bash /tmp/install-sshx.sh; \
    SSHX_BIN="$(command -v sshx || true)"; \
    if [ -z "$SSHX_BIN" ]; then \
        SSHX_BIN="$(find /root/.local/bin /usr/local/bin -type f -name sshx -print -quit 2>/dev/null || true)"; \
    fi; \
    test -n "$SSHX_BIN"; \
    install -m 755 "$SSHX_BIN" /usr/local/bin/sshx; \
    /usr/local/bin/sshx --help || true; \
    rm -f /tmp/install-sshx.sh

# 4. Create user
RUN useradd -m -s /bin/bash terminal

# 5. Copy startup script
COPY lapio-plays.sh /lapio-plays.sh

RUN chmod 755 /lapio-plays.sh

WORKDIR /home/terminal

EXPOSE 8080

USER terminal

ENTRYPOINT ["/bin/bash", "/lapio-plays.sh"]
