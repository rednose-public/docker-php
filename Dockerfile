FROM php:7.2-apache

RUN echo "deb http://ftp.de.debian.org/debian stretch contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://ftp.de.debian.org/debian stretch-updates contrib non-free" >> /etc/apt/sources.list

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    graphviz \
    libmagick++-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libpng-dev \
    libxslt1-dev \
    make \
    mysql-server \
    ttf-mscorefonts-installer \
    unzip \
    wget \
    zlib1g-dev

RUN docker-php-ext-configure \
    ldap --with-libdir=lib/x86_64-linux-gnu

RUN docker-php-ext-configure \
    gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
    curl \
    gd \
    intl \
    ldap \
    mbstring \
    opcache \
    pdo_mysql \
    soap \
    xsl \
    zip

RUN pecl install \
    imagick

RUN docker-php-ext-enable \
    imagick

# Configure OPcache
RUN echo "opcache.max_accelerated_files=10000" > $PHP_INI_DIR/conf.d/opcache.ini
RUN echo "opcache.enable=1" >> $PHP_INI_DIR/conf.d/opcache.ini
RUN echo "opcache.enable_cli=1" >> $PHP_INI_DIR/conf.d/opcache.ini
RUN echo "opcache.interned_strings_buffer=16" >> $PHP_INI_DIR/conf.d/opcache.ini
RUN echo "opcache.memory_consumption=512" >> $PHP_INI_DIR/conf.d/opcache.ini

# Memory Limit
RUN echo "memory_limit=5G" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install Redis caching service
RUN mkdir /tmp/redis
RUN wget http://download.redis.io/redis-stable.tar.gz -O /tmp/redis/redis.tar.gz
RUN cd /tmp/redis && tar -zxvf redis.tar.gz
RUN cd /tmp/redis/redis-stable
RUN cd /tmp/redis/redis-stable && make
RUN cd /tmp/redis/redis-stable && make install
RUN mkdir /etc/redis
COPY config/redis.conf /etc/redis/redis.conf

# Install Chrome
RUN curl -sS -L https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

RUN apt-get update -q -y \
    && apt-get install -y \
    google-chrome-stable

# Install ChromeDriver
RUN wget -q https://chromedriver.storage.googleapis.com/2.46/chromedriver_linux64.zip \
    && unzip chromedriver_linux64.zip -d /usr/local/bin \
    && rm -f chromedriver_linux64.zip

#RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4 libappindicator3-1 libatk-bridge2.0-0 libgtk-3-0
#RUN apt-get -y install libasound2 libpango1.0-0 libx11-xcb1 libxss1 libxtst6 libappindicator1 xdg-utils

## See https://www.slimjet.com/chrome/google-chrome-old-version.php
#RUN wget http://www.slimjetbrowser.com/chrome/files/70.0.3538.77/google-chrome-stable_current_amd64.deb
#RUN dpkg -i google-chrome-stable_current_amd64.deb
#RUN rm -f google-chrome-stable_current_amd64.deb

## Install selenium and chromedriver
#RUN apt-get -y install default-jre
#RUN curl https://selenium-release.storage.googleapis.com/3.14/selenium-server-standalone-3.14.0.jar > /bin/selenium.jar
#RUN curl https://chromedriver.storage.googleapis.com/2.45/chromedriver_linux64.zip > chromedriver.zip && unzip chromedriver.zip -d /bin

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash - \
    && apt-get -y install \
    nodejs

# Install Node.js packages
RUN npm -g install bower
