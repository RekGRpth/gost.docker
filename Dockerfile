FROM alpine:3.13
MAINTAINER RekGRpth
CMD [ "sh" ]
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV CFLAGS="-rdynamic -fno-omit-frame-pointer" \
    CPPFLAGS="-rdynamic -fno-omit-frame-pointer" \
    HOME=/home
WORKDIR "${HOME}"
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        ca-certificates \
        cmake \
        findutils \
        gcc \
        gettext-dev \
        git \
        libintl \
        make \
        musl-dev \
        openssl-dev \
    ; \
    mkdir -p /usr/src; \
    cd /usr/src; \
    git clone https://bitbucket.org/RekGRpth/gost.git; \
    git clone https://github.com/RekGRpth/engine.git; \
    cd /usr/src/gost; \
    cp -rf bin/* /usr/local/bin/; \
    cd /usr/src/engine; \
    git checkout openssl_1_1_1; \
    cmake .; \
    make -j"$(nproc)" install; \
    apk add --no-cache --virtual .gost-rundeps \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        musl-locales \
        openssl \
        shadow \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/bin /usr/lib /usr/local/bin /usr/local/lib -type f -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    rm -rf /usr/src /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find / -name "*.a" -delete; \
    find / -name "*.la" -delete; \
    chmod +x /usr/local/bin/docker_entrypoint.sh /usr/local/bin/update_permissions.sh; \
    sed -i '6i openssl_conf=openssl_def' /etc/ssl/openssl.cnf; \
    echo "" >> /etc/ssl/openssl.cnf; \
    echo "# OpenSSL default section" >> /etc/ssl/openssl.cnf; \
    echo "[openssl_def]" >> /etc/ssl/openssl.cnf; \
    echo "engines = engine_section" >> /etc/ssl/openssl.cnf; \
    echo "" >> /etc/ssl/openssl.cnf; \
    echo "# Engine scetion" >> /etc/ssl/openssl.cnf; \
    echo "[engine_section]" >> /etc/ssl/openssl.cnf; \
    echo "gost = gost_section" >> /etc/ssl/openssl.cnf; \
    echo "" >> /etc/ssl/openssl.cnf; \
    echo "# Engine gost section" >> /etc/ssl/openssl.cnf; \
    echo "[gost_section]" >> /etc/ssl/openssl.cnf; \
    echo "engine_id = gost" >> /etc/ssl/openssl.cnf; \
    echo "default_algorithms = ALL" >> /etc/ssl/openssl.cnf; \
    echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /etc/ssl/openssl.cnf; \
    echo done
