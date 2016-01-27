FROM php:5.6

RUN apt-get update -y
RUN apt-get install git zlib1g-dev -y

RUN curl -sS https://getcomposer.org/installer | php
RUN chmod +x composer.phar
RUN mv composer.phar /usr/local/bin/composer

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server

RUN docker-php-ext-install zip mbstring pdo_mysql

# Memory Limit
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini

# Time Zone
RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs build-essential

# Install PhantomJS deps
#RUN apt-get install wget libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev -y

# Install Chrome
RUN apt-get update
RUN apt-get install -y -q wget unzip dpkg libnss3-1d
RUN wget --no-check-certificate -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
ADD http://chromedriver.storage.googleapis.com/2.13/chromedriver_linux64.zip /srv/
RUN unzip /srv/chromedriver_linux64.zip -d /srv
RUN echo deb http://dl.google.com/linux/chrome/deb/ stable main >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
#RUN apt-get install -q -y openjdk-7-jre-headless google-chrome-stable xvfb
RUN apt-get install -q -y google-chrome-stable xvfb

ADD ./install /

EXPOSE 4444
