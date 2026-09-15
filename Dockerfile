FROM debian:bookworm-slim
LABEL maintainer="SavageCore (talk at savagecore dot uk)"

ARG S6_OVERLAY_VERSION=v2.2.0.3

### Set defaults
ENV ASTERISK_VERSION=22 \
    FREEPBX_VERSION=17.0 \
    PHP_VERSION=8.2 \
    RTP_START=18000 \
    RTP_FINISH=20000

### Bootstrap fetch tools (stock slim image ships without them), s6-overlay v2, Sangoma repo
RUN apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates curl gnupg wget && \
    curl -sSLk https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-amd64.tar.gz -o /tmp/s6-overlay.tar.gz && \
    tar --extract --gzip --file=/tmp/s6-overlay.tar.gz --keep-directory-symlink --strip=0 --directory=/ && \
    rm -f /usr/bin/execlineb && \
    tar --extract --gzip --file=/tmp/s6-overlay.tar.gz --keep-directory-symlink --strip=0 --directory=/ ./bin/execlineb && \
    rm -f /tmp/s6-overlay.tar.gz && \
    ln -s /usr/bin /command && \
    wget -O - http://deb.freepbx.org/gpg/aptly-pubkey.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/freepbx.gpg && \
    echo "deb [arch=amd64] http://deb.freepbx.org/freepbx17-prod bookworm main" >> /etc/apt/sources.list && \
    printf 'Package: *\nPin: origin deb.freepbx.org\nPin-Priority: 900\n' > /etc/apt/preferences.d/99sangoma-fpbx-repository && \
    printf 'DPkg::options { "--force-confdef"; "--force-confold"; }\n' > /etc/apt/apt.conf.d/00freepbx && \
    if [ -f /etc/apt/sources.list.d/debian.sources ]; then sed -i 's/^Components: main.*/& contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources; else echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" >> /etc/apt/sources.list; fi && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=TRUE && \
    \
### Install dependencies
    set -x && \
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" upgrade -y && \
    \
### Install runtime dependencies (stock Bookworm plus Sangoma repo, no extra repos)
    apt-get install --no-install-recommends -y \
                    apache2 \
                    cron \
                    curl \
                    dbus \
                    fail2ban \
                    ffmpeg \
                    flite \
                    g++ \
                    ghostscript \
                    git \
                    imagemagick \
                    incron \
                    ipset \
                    iptables \
                    iptables-persistent \
                    lame \
                    libapache2-mod-php8.2 \
                    libavahi-client3 \
                    libavdevice59 \
                    libbluetooth3 \
                    libc-client2007e \
                    libgmime-3.0-0 \
                    libical3 \
                    libicu-dev \
                    libiksemel3 \
                    libncurses5 \
                    libneon27 \
                    libresample1 \
                    libsnmp40 \
                    libspandsp2 \
                    libspeexdsp1 \
                    libsrtp2-1 \
                    libsybdb5 \
                    libtiff-tools \
                    libtonezone \
                    libunbound8 \
                    liburiparser1 \
                    locales \
                    locales-all \
                    logrotate \
                    make \
                    mariadb-client \
                    mariadb-server \
                    mpg123 \
                    msmtp \
                    net-tools \
                    netcat-openbsd \
                    nmap \
                    nodejs \
                    npm \
                    odbc-mariadb \
                    php8.2 \
                    php8.2-bcmath \
                    php8.2-bz2 \
                    php8.2-cli \
                    php8.2-common \
                    php8.2-curl \
                    php8.2-gd \
                    php8.2-intl \
                    php8.2-ldap \
                    php8.2-mbstring \
                    php8.2-mysql \
                    php8.2-redis \
                    php8.2-soap \
                    php8.2-sqlite3 \
                    php8.2-ssh2 \
                    php8.2-xml \
                    php8.2-zip \
                    php-pear \
                    pkg-config \
                    python3-mysqldb \
                    python-is-python3 \
                    redis-server \
                    rsync \
                    rsyslog \
                    sngrep \
                    socat \
                    sox \
                    sqlite3 \
                    ssl-cert \
                    sudo \
                    tcpdump \
                    unixodbc \
                    uuid \
                    vim \
                    wget \
                    whois \
                    zabbix-agent \
                    zip && \
    \
### Add users
    addgroup --gid 2600 asterisk && \
    adduser --uid 2600 --gid 2600 --gecos "Asterisk User" --disabled-password asterisk && \
    \
### Install Asterisk 22 and FreePBX 17 from Sangoma packages
    apt-get install -y --ignore-missing -o Dpkg::Options::="--force-confnew" -o Dpkg::Options::="--force-overwrite" \
        asterisk${ASTERISK_VERSION} \
        asterisk${ASTERISK_VERSION}-addons \
        asterisk${ASTERISK_VERSION}-addons-bluetooth \
        asterisk${ASTERISK_VERSION}-addons-core \
        asterisk${ASTERISK_VERSION}-addons-mysql \
        asterisk${ASTERISK_VERSION}-addons-ooh323 \
        asterisk${ASTERISK_VERSION}-core \
        asterisk${ASTERISK_VERSION}-curl \
        asterisk${ASTERISK_VERSION}-doc \
        asterisk${ASTERISK_VERSION}-odbc \
        asterisk${ASTERISK_VERSION}-ogg \
        asterisk${ASTERISK_VERSION}-flite \
        asterisk${ASTERISK_VERSION}-g729 \
        asterisk${ASTERISK_VERSION}-resample \
        asterisk${ASTERISK_VERSION}-snmp \
        asterisk${ASTERISK_VERSION}-speex \
        asterisk${ASTERISK_VERSION}-sqlite3 \
        asterisk${ASTERISK_VERSION}-res-digium-phone \
        asterisk${ASTERISK_VERSION}-voicemail \
        asterisk${ASTERISK_VERSION}.0-freepbx-asterisk-modules \
        asterisk-sounds-* \
        asterisk-version-switch \
        freepbx17 \
        ioncube-loader-82 \
        sangoma-pbx17 \
        sysadmin17 \
        ffmpeg \
        libfdk-aac2 && \
    \
### Cleanup
    mkdir -p /var/run/fail2ban && \
    cd / && \
    rm -rf /usr/src/* /tmp/* /etc/cron* && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    \
### FreePBX hacks
    sed -i -e "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's/\(^expose_php = \).*/\1Off/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;max_input_vars = 1000/max_input_vars = 2000/' /etc/php/8.2/apache2/php.ini && \
    sed -i 's/;pcre.jit=1/pcre.jit=0/' /etc/php/8.2/apache2/php.ini && \
    phpenmod freepbx || true && \
    mkdir -p /var/lib/php/session && \
    mkdir -p /var/spool/asterisk/incron && \
    chown asterisk:asterisk /var/spool/asterisk/incron && \
    sed -i 's/^#dateext/dateext/' /etc/logrotate.conf && \
    sed -i -e 's/^ServerTokens .*/ServerTokens Prod/' -e 's/^ServerSignature .*/ServerSignature Off/' /etc/apache2/conf-available/security.conf && \
    a2disconf other-vhosts-access-log.conf && \
    a2enmod rewrite && \
    a2enmod headers && \
    a2enmod ssl && \
    a2enmod expires && \
    rm -f /var/www/html/index.html && \
    rm -rf /var/log/* && \
    mkdir -p /var/log/asterisk && \
    mkdir -p /var/log/apache2 && \
    mkdir -p /var/log/httpd && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    dbus-uuidgen > /etc/machine-id && \
    mkdir -p /var/lib/dbus && \
    cp /etc/machine-id /var/lib/dbus/machine-id && \
    chmod 644 /etc/machine-id /var/lib/dbus/machine-id && \
    \
### Zabbix setup
    echo '%zabbix ALL=(asterisk) NOPASSWD:/usr/sbin/asterisk' >> /etc/sudoers && \
    \
### Setup for data persistence
    ln -s x86_64-linux-gnu/asterisk /usr/lib/asterisk && \
    mkdir -p /assets/config/var/lib/ /assets/config/home/ && \
    mv /home/asterisk /assets/config/home/ && \
    mkdir -p /assets/config/var/www/ && \
    mv /var/www/html /assets/config/var/www/ && \
    ln -s /data/var/www/html /var/www/html && \
    ln -s /data/home/asterisk /home/asterisk && \
    mv /var/lib/asterisk /assets/config/var/lib/ && \
    ln -s /data/var/lib/asterisk /var/lib/asterisk && \
    ln -s /data/usr/local/fop2 /usr/local/fop2 && \
    mkdir -p /assets/config/var/run/ && \
    mv /var/run/asterisk /assets/config/var/run/ && \
    mv /var/lib/mysql /assets/config/var/lib/ && \
    mkdir -p /assets/config/var/spool && \
    mv /var/spool/cron /assets/config/var/spool/ && \
    ln -s /data/var/spool/cron /var/spool/cron && \
    mkdir -p /var/lib/redis && \
    rm -rf /var/lib/redis && \
    ln -s /data/var/lib/redis /var/lib/redis && \
    ln -s /data/var/run/asterisk /var/run/asterisk && \
    rm -rf /var/spool/asterisk && \
    ln -s /data/var/spool/asterisk /var/spool/asterisk && \
    rm -rf /etc/asterisk && \
    ln -s /data/etc/asterisk /etc/asterisk

### Networking configuration
EXPOSE 80 443 4445 4569 5060/udp 5160/udp 5061 5161 8001 8003 8008 8009 8025 ${RTP_START}-${RTP_FINISH}/udp

### Files add
ADD install-base /
ADD install /

ENTRYPOINT ["/init"]
