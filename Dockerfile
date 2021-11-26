FROM alpine
MAINTAINER RekGRpth
ENTRYPOINT [ "docker_entrypoint.sh" ]
ADD bin /usr/local/bin
ENV HOME=/home
WORKDIR "${HOME}"
RUN set -eux; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
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
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    git clone -b openssl_1_1_1 https://github.com/RekGRpth/engine.git; \
    cd "${HOME}/src/engine"; \
    cmake .; \
    make -j"$(nproc)" install; \
    cd /; \
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
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    strip /usr/lib/engines*/gost.so*; \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod +x /usr/local/bin/docker_entrypoint.sh /usr/local/bin/update_permissions.sh; \
    sed -i '6i openssl_conf=openssl_def' /etc/ssl1.1/openssl.cnf; \
    echo "" >> /etc/ssl1.1/openssl.cnf; \
    echo "# OpenSSL default section" >> /etc/ssl1.1/openssl.cnf; \
    echo "[openssl_def]" >> /etc/ssl1.1/openssl.cnf; \
    echo "engines = engine_section" >> /etc/ssl1.1/openssl.cnf; \
    echo "" >> /etc/ssl1.1/openssl.cnf; \
    echo "# Engine scetion" >> /etc/ssl1.1/openssl.cnf; \
    echo "[engine_section]" >> /etc/ssl1.1/openssl.cnf; \
    echo "gost = gost_section" >> /etc/ssl1.1/openssl.cnf; \
    echo "" >> /etc/ssl1.1/openssl.cnf; \
    echo "# Engine gost section" >> /etc/ssl1.1/openssl.cnf; \
    echo "[gost_section]" >> /etc/ssl1.1/openssl.cnf; \
    echo "engine_id = gost" >> /etc/ssl1.1/openssl.cnf; \
    echo "default_algorithms = ALL" >> /etc/ssl1.1/openssl.cnf; \
    echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /etc/ssl1.1/openssl.cnf; \
    echo done
