FROM php:5.4

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install libxslt1.1 libxslt1-dev wget git unzip zlib1g-dev apt-utils libcurl4-openssl-dev libicu-dev -y

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN docker-php-ext-install xsl zip mbstring pdo_mysql curl intl

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
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee -a /etc/apt/sources.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update -y
RUN apt-get -y install libxpm4 libxrender1 libgtk2.0-0 libnss3 libgconf-2-4
RUN apt-get -y install google-chrome-stable

# Dependencies to make "headless" chrome/selenium work:
RUN apt-get -y install xvfb gtk2-engines-pixbuf
RUN apt-get -y install xfonts-cyrillic xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable
RUN apt-get -y install default-jre

# Install NodeJS packages
RUN npm -g install bower grunt-cli

# Install Capifony
RUN apt-get -y install ruby
RUN gem install capifony

EXPOSE 4444
