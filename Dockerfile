
FROM ubuntu:22.04

LABEL maintainer="Lapio Plays"

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV GOTTY_TAG_VER=v1.0.1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        bash \
        tar \
        passwd \
        locales && \
    locale-gen en_US.UTF-8 && \
    curl -fsSL \
        "https://github.com/yudai/gotty/releases/download/${GOTTY_TAG_VER}/gotty_linux_amd64.tar.gz" \
        -o /tmp/gotty.tar.gz && \
    tar -xzf /tmp/gotty.tar.gz -C /usr/local/bin && \
    curl -fsSL https://sshx.io/get | sh && \
    install -m 755 /root/.local/bin/sshx /usr/local/bin/sshx && \
    rm -f /tmp/gotty.tar.gz && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash terminal

COPY lapio-plays.sh /lapio-plays.sh

RUN chmod 755 /lapio-plays.sh

WORKDIR /home/terminal

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "/lapio-plays.sh"]
