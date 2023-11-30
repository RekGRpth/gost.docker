FROM alpine:latest
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV HOME=/home
MAINTAINER RekGRpth
WORKDIR "$HOME"
RUN set -eux; \
    ln -fs su-exec /sbin/gosu; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build \
        ca-certificates \
        cmake \
        findutils \
        gcc \
        gettext-dev \
        git \
        libintl \
        make \
        musl-dev \
        openssl1.1-compat-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone --branch openssl_1_1_1 --recurse-submodules https://github.com/RekGRpth/engine.git; \
    cd "$HOME/src/engine"; \
    cmake .; \
    make -j"$(nproc)" install; \
    apk add --no-cache --virtual .gost \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        musl-locales \
        shadow \
        su-exec \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e libcrypto | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    strip /usr/lib/engines*/gost.so*; \
    apk del --no-cache .build; \
    docker_gost.sh /etc/ssl/openssl.cnf; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    echo done
