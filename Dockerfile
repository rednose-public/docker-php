FROM php:5.6

# Remove the cached packeges from the apt-cache before rebuilding the container
RUN rm -Rf /var/cache/apt/archives/*

RUN apt-get update -y
RUN apt-get install wget git unzip zlib1g-dev libxslt1-dev libcurl4-openssl-dev libicu-dev libldap2-dev graphviz libjpeg62-turbo-dev libpng12-dev libfreetype6-dev libjpeg-dev libpng-dev -y

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN docker-php-ext-install xsl zip mbstring pdo_mysql curl intl

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

# Memory Limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs build-essential

# Install Chrome
RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
RUN apt-get -y install libasound2 libpango1.0-0 libx11-xcb1 libxss1 libxtst6 libappindicator1 xdg-utils

RUN wget http://www.slimjetbrowser.com/chrome/lnx/chrome64_54.0.2840.71.deb
RUN dpkg -i chrome64_54.0.2840.71.deb
RUN rm -f chrome64_54.0.2840.71.deb

# Dependencies to make "headless" chrome/selenium work:
RUN apt-get -y install xvfb gtk2-engines-pixbuf
RUN apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable
RUN apt-get -y install default-jre

# Install selenium and chromedriver
RUN curl http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar > bin/selenium.jar
RUN curl http://chromedriver.storage.googleapis.com/2.27/chromedriver_linux64.zip > chromedriver.zip && unzip chromedriver.zip -d bin

# Install NodeJS packages
RUN npm -g install bower grunt-cli

# Install Capifony
RUN apt-get -y install ruby
RUN gem install capifony
RUN gem uninstall net-ssh --force
RUN gem install net-ssh --version 3.1.1

EXPOSE 4444
