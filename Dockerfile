
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PORT=10000

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
        procps \
        python3 && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

# Install GoTTY
RUN set -eux; \
    mkdir -p /tmp/gotty; \
    curl -fsSL \
        https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz \
        -o /tmp/gotty.tar.gz; \
    tar -xzf /tmp/gotty.tar.gz -C /tmp/gotty; \
    install -m 755 /tmp/gotty/gotty /usr/local/bin/gotty; \
    /usr/local/bin/gotty --version; \
    rm -rf /tmp/gotty /tmp/gotty.tar.gz

# Install SSHX
RUN set -eux; \
    curl -fsSL https://sshx.io/get -o /tmp/sshx-install.sh; \
    bash /tmp/sshx-install.sh; \
    test -x /usr/local/bin/sshx; \
    /usr/local/bin/sshx --help || true; \
    rm -f /tmp/sshx-install.sh

# Create terminal user
RUN useradd -m -s /bin/bash terminal

# Copy application files
COPY lapio-plays.sh /lapio-plays.sh
COPY health_server.py /health_server.py

# Permissions
RUN chmod 755 /lapio-plays.sh /health_server.py

WORKDIR /home/terminal

EXPOSE 10000

ENTRYPOINT ["/lapio-plays.sh"]
