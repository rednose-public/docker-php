FROM php:7.2-apache

RUN echo "deb http://ftp.de.debian.org/debian stretch contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://ftp.de.debian.org/debian stretch-updates contrib non-free" >> /etc/apt/sources.list

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    git \
    gnupg \
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

# Allow MySQL root user to connect over the loopback adapter
RUN service mysql start \
    && sleep 5 \
    && mysql -e "UPDATE mysql.user SET plugin = 'mysql_native_password';" \
    && service mysql stop

# Update the Apache config
RUN cd /etc/apache2/sites-enabled \
  && sed -i -e 's/\/html/\/html\/web/g' 000-default.conf \
  && sed -i -e 's/<\/VirtualHost>/        <Directory "\/var\/www\/html\/web">\n                AllowOverride All\n        <\/Directory>\n\nLimitRequestFieldSize 65000\n\n<\/VirtualHost>/g' 000-default.conf

# Enable mod_rewrite
RUN a2enmod rewrite

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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get -y install \
    nodejs
