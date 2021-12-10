FROM ubuntu:20.04 as base

EXPOSE 80
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        tzdata \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        supervisor \
        unzip \
        php8.1-gmp \
        php8.1-pgsql \
        php8.1-fpm \
        php8.1-cli \
        php8.1-xml \
#        php8.0-gd \
#        php8.0-mbstring \
#        php8.0-curl \
        php8.1-zip \
        php8.1-redis \
#        php8.0-intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /run/php
COPY docker/app/entrypoint.sh /entrypoint.sh
COPY docker/app/nginx.conf /etc/nginx/nginx.conf
COPY docker/app/default.conf /etc/nginx/sites-available/default
COPY docker/app/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY docker/app/supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord"]


FROM base AS dev

ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer:2.1 /usr/bin/composer /usr/bin/composer
RUN apt-get update \
    && apt-get install -y --no-install-recommends php8.1-xdebug \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
