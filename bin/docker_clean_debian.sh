#!/bin/sh -eux

cd /
apt-mark auto '.*' > /dev/null
find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual
find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | sort -u  | xargs -r apt-mark manual
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then
    grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker
    sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker
    ! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker
fi
apt-get install -y --no-install-recommends \
    ca-certificates \
    gosu \
    locales \
    tzdata \
;
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
locale-gen --lang ru_RU.UTF-8
dpkg-reconfigure locales
rm -rf /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig
