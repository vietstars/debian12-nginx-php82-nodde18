FROM scratch
ADD rootfs.tar.xz /

RUN apt-get update -y

RUN apt-get install -y vim supervisor nginx curl dirmngr unzip gnupg2 ca-certificates wget ufw
RUN apt-get install -y software-properties-common apt-transport-https lsb-release debian-archive-keyring
RUN apt-get install -y php-fpm php-cli php-mysql php-mbstring php-xml php-gd php-xdebug
RUN apt-get install -y php-ctype php-curl php-dom php-exif php-fileinfo php-iconv php-intl
RUN apt-get install -y php-mysqli php-opcache php-phar php-simplexml php-soap php-xml
RUN apt-get install -y php-xmlreader php-zip php-pdo php-xmlwriter php-tokenizer
RUN apt-get install -y nodejs npm

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configure certs
COPY ./config/certs /etc/nginx/certs

# Configure nginx
COPY ./config/web/nginx/sites-enabled /etc/nginx/sites-enabled

# Configure php
COPY ./config/web/php/pool.d/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./config/web/php/php.ini /etc/php/8.2/fpm/php.ini

# Configure supervisord
COPY ./config/web/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure demo nginx
COPY ./src /var/www/dev.org

RUN chmod -R 755 /var/www/dev.org
RUN chmod -R 755 /var/log/

WORKDIR /var/www/dev.org

RUN nginx -t
RUN service php8.2-fpm start
RUN service nginx start

# USER www-data

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]