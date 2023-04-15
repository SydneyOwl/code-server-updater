FROM debian:11

ARG CODE_RELEASE
ARG TARGETARCH
ARG DEBIAN_FRONTEND="noninteractive"

LABEL maintainer="MrOwl"

VOLUME [ "/app" ]

RUN apt-get update && apt-get install -y \
tar \
nano \
curl && \
if [ "${TARGETARCH}" = "arm" ];then \
    TARGETARCH=armv7l; \
fi && \
if [ -z ${CODE_RELEASE+x} ]; then \
  CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
fi && \
mkdir -p /etc/update-vs-pkg && \
echo "${CODE_RELEASE}" > /etc/update-vs-pkg/version && \
curl -o \
    /etc/update-vs-pkg/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-${TARGETARCH}.tar.gz"

COPY /root /

ENTRYPOINT ["/bin/bash", "/etc/scripts/update.sh"]