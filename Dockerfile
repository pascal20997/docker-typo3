FROM php:7.2-apache

ENV SERVER_ADMIN pleaseSetTheEnvironment@variable.tld
ENV SURF_DOWNLOAD_URL https://github.com/TYPO3/Surf/releases/download/2.0.0-beta7/surf.phar
ENV DOCUMENT_ROOT /home/crynton/htdocs/public
ENV APACHE_RUN_USER crynton
ENV INSTALL_TYPO3 true
ENV START_SSHD true

# apache
RUN a2enmod rewrite && a2enmod deflate

# php
RUN apt-get update && apt-get install -y imagemagick git nano libwebp-dev libjpeg-dev libfreetype6-dev libicu-dev \
libzzip-dev openssh-server libpq-dev \
                   && yes '' | pecl install -f apcu \
                   && docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include \
                   && docker-php-ext-install gd mbstring opcache mysqli json intl zip pdo pdo_pgsql pgsql

# from https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/01-opcache-recommended.ini

# from https://github.com/TYPO3/TYPO3.CMS/blob/v9.3.0/INSTALL.md
RUN { \
		echo 'upload_max_filesize=100M'; \
		echo 'post_max_size=100M'; \
		echo 'max_execution_time=240'; \
		echo 'memory_limit=512M'; \
		echo 'max_input_vars=1500'; \
        echo 'output_buffering = 4096'; \
		echo 'opcache.save_comments=1'; \
		echo 'opcache.load_comments=1'; \
		echo 'opcache.validate_timestamps=0'; \
        echo 'expose_php = Off'; \
	} > /usr/local/etc/php/conf.d/02-typo3-recommended.ini

# configure apache2
RUN echo "\nServerTokens Prod\nServerSignature Off\n" >> /etc/apache2/apache2.conf

# configure openssh-server
RUN echo "\nPermitRootLogin no\nPasswordAuthentication no\nUsePAM no\n" >> /etc/ssh/sshd_config

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

# install surf
RUN mkdir /usr/local/surf \
    && curl -L ${SURF_DOWNLOAD_URL} -o /usr/local/surf/surf.phar \
    && chmod +x /usr/local/surf/surf.phar \
    && ln -s /usr/local/surf/surf.phar /usr/local/bin/surf

# add user crynton to group www-data
RUN useradd -g www-data -m -s "/bin/bash" crynton

# change ownership to crynton:www-data
RUN chown -R crynton:www-data /var/www

COPY 000-default.conf /etc/apache2/sites-available
COPY crynton-start.sh /usr/local/bin/crynton-start
RUN chmod +x /usr/local/bin/crynton-start

# cleanup
RUN apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/crynton
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["crynton-start"]
