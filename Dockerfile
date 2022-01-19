ARG DOCKER_FROM=alpine:latest
FROM "$DOCKER_FROM"
ADD bin /usr/local/bin
ARG DOCKER_BUILD=build
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV HOME=/home
MAINTAINER RekGRpth
WORKDIR "${HOME}"
RUN set -eux; \
    export DOCKER_BUILD="$DOCKER_BUILD"; \
    export DOCKER_TYPE="$(cat /etc/os-release | grep -E '^ID=' | cut -f2 -d '=')"; \
    if [ $DOCKER_TYPE = "alpine" ]; then \
        ln -fs su-exec /sbin/gosu; \
    else \
        export DEBIAN_FRONTEND=noninteractive; \
    fi; \
    chmod +x /usr/local/bin/*.sh; \
    "docker_${DOCKER_BUILD}_$DOCKER_TYPE.sh"; \
    docker_clone.sh; \
    "docker_$DOCKER_BUILD.sh"; \
    "docker_clean_$DOCKER_TYPE.sh"; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    echo done
