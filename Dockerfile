FROM php:7.0-apache

# Remove the cached packeges from the apt-cache before rebuilding the container
RUN rm -Rf /var/cache/apt/archives/*

RUN echo "deb http://gce_debian_mirror.storage.googleapis.com jessie contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://gce_debian_mirror.storage.googleapis.com jessie-updates contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/ jessie/updates contrib non-free" >> /etc/apt/sources.list

RUN apt-get update -y
RUN apt-get install gnupg wget git unzip zlib1g-dev libxslt1-dev libcurl4-openssl-dev libicu-dev libldap2-dev graphviz libjpeg62-turbo-dev libpng-dev libfreetype6-dev libjpeg-dev libpng-dev -y

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections

RUN apt-get install ttf-mscorefonts-installer -y

# Install MYSQL57
RUN echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7" >> /etc/apt/sources.list
RUN wget -O /tmp/RPM-GPG-KEY-mysql https://repo.mysql.com/RPM-GPG-KEY-mysql
RUN apt-key add /tmp/RPM-GPG-KEY-mysql
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN docker-php-ext-install xsl zip mbstring pdo_mysql curl intl soap

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
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs build-essential

# Install Chrome
RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
RUN apt-get -y install libasound2 libpango1.0-0 libx11-xcb1 libxss1 libxtst6 libappindicator1 xdg-utils

RUN wget http://www.slimjetbrowser.com/chrome/lnx/chrome64_54.0.2840.71.deb
RUN dpkg -i chrome64_54.0.2840.71.deb
RUN rm -f chrome64_54.0.2840.71.deb

# DEBIAN-SLIM bugfix (Delete this line in the future, I expect the parent docker container to be fixed by then).
RUN mkdir -p /usr/share/man/man1

# Dependencies to make "headless" chrome/selenium work:
RUN apt-get -y install xvfb gtk2-engines-pixbuf
RUN apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable
RUN apt-get -y install default-jre

# Install selenium and chromedriver
RUN curl http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar > /bin/selenium.jar
RUN curl http://chromedriver.storage.googleapis.com/2.27/chromedriver_linux64.zip > chromedriver.zip && unzip chromedriver.zip -d /bin

# Install redis caching service
RUN mkdir /tmp/redis
RUN wget http://download.redis.io/redis-stable.tar.gz -O /tmp/redis/redis.tar.gz
RUN cd /tmp/redis && tar -zxvf redis.tar.gz
RUN cd /tmp/redis/redis-stable
RUN cd /tmp/redis/redis-stable && make
RUN cd /tmp/redis/redis-stable && make install
RUN mkdir /etc/redis
COPY config/redis.conf /etc/redis/redis.conf

# Install NodeJS packages
RUN npm -g install bower grunt-cli

# Install Capifony
RUN apt-get -y install ruby
RUN gem uninstall net-ssh --force
RUN gem install net-ssh --version 3.1.1
RUN gem install capifony

# Allow mysql root user to connect over the loopback adapter
RUN service mysql start && mysql -e "use mysql; update user set plugin = 'mysql_native_password';" && service mysql stop

EXPOSE 4444
