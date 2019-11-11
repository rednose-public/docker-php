FROM php:7.2-apache

RUN echo "deb http://ftp.de.debian.org/debian stretch contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://ftp.de.debian.org/debian stretch-updates contrib non-free" >> /etc/apt/sources.list

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections

RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    ghostscript \
    git \
    gnupg \
    graphviz \
    libasound2 \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgconf-2-4 \
    libgtk2.0-0 \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libmagick++-dev \
    libnotify-dev \
    libnss3 \
    libpng-dev \
    libxslt1-dev \
    libxss1 \
    make \
    rubygems \
    ttf-mscorefonts-installer \
    unzip \
    wget \
    xvfb \
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

# Install Chrome
RUN curl -sS -L https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list

RUN apt-get update -q -y \
    && apt-get install -y \
    google-chrome-stable

# Install ChromeDriver
RUN BASE_URL=https://chromedriver.storage.googleapis.com \
    && VERSION=$(curl -sL "$BASE_URL/LATEST_RELEASE") \
    && curl -sL "$BASE_URL/$VERSION/chromedriver_linux64.zip" -o /tmp/driver.zip \
    && unzip /tmp/driver.zip \
    && chmod 755 chromedriver \
    && mv chromedriver /usr/local/bin/ \
    && rm -rf /tmp/driver.zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - \
    && apt-get -y install \
    nodejs

RUN npm -g install yarn

RUN gem install capistrano \
    && gem install capistrano-symfony -v 2.0.0.pre.alfa2
