FROM alpine:3.12

# APK INSTALL DEPENDENCIES
RUN apk add supervisor sudo curl gcc g++ git make autoconf automake libtool openssl redis gnupg musl-dev ; \
    apk add py3-setuptools py3-redis py3-virtualenv python3-dev py3-lxml py3-pip py3-pyzmq; \
    apk add apache2 apache2-utils apache2-ssl apache2-ldap php7-apache2 php7-pdo_pgsql php7-pdo_mysql ; \
    apk add php7 php7-mbstring php7-json php7-xml php7-opcache php7-session php-ldap php7-pgsql php7-mysqli php7-pecl-redis php7-simplexml ; \
    apk add libpq libjpeg ruby ; \
    apk add jq imagemagick tesseract-ocr ; \
    apk add libxml2 libxslt zlib zlib-dev jpeg-dev ; \
    apk add poppler-dev libffi-dev ; \
    apk add composer php7-pcntl php7-dom

# INSTALL MISP PROJECT
WORKDIR /var/www/MISP
RUN chown -R apache:apache /var/www/MISP ; \
    sudo -u apache -H git clone https://github.com/MISP/MISP.git /var/www/MISP ; \
    sudo -u apache -H git submodule update --init --recursive ; \
    sudo -u apache -H git submodule foreach --recursive git config core.filemode false ; \
    sudo -u apache -H git config core.filemode false ; \
    pip3 install --upgrade pip

WORKDIR /var/www/MISP/app/files/scripts
RUN sudo -u apache -H git clone https://github.com/CybOXProject/python-cybox.git ; \
    sudo -u apache -H git clone https://github.com/STIXProject/python-stix.git ; \
    sudo -u apache -H git clone https://github.com/MAECProject/python-maec.git ; \
    sudo -u apache -H git clone https://github.com/CybOXProject/mixbox.git

WORKDIR /var/www/MISP/app/files/scripts/mixbox
RUN pip3 install .

WORKDIR /var/www/MISP/app/files/scripts/python-cybox
RUN pip3 install .

WORKDIR /var/www/MISP/app/files/scripts/python-stix
RUN pip3 install .

WORKDIR /var/www/MISP/app/files/scripts/python-maec
RUN pip3 install .

WORKDIR /var/www/MISP/cti-python-stix2
RUN pip3 install .

#WORKDIR /var/www/MISP/PyMISP
#RUN pip3 install .
#    BUILD_LIB=1 pip3 install ssdeep ; \
#    pip3 install https://github.com/lief-project/packages/raw/lief-master-latest/pylief-0.9.0.dev.zip


WORKDIR /var/www/MISP
RUN sudo -u apache -H git submodule init ; \
    sudo -u apache -H git submodule update ; \
    pip3 install jsonschema ; \
    pip3 install reportlab ; \
    pip3 install python-magic ; \
    pip3 install pyzmq ; \
    pip3 install redis

# PHP COMPOSER INSTALL
WORKDIR /var/www/MISP/app
RUN mkdir /var/www/.composer && chown -R apache:apache /var/www/.composer ; \
    sudo -u apache -H php composer.phar config vendor-dir Vendor ; \
    sudo -u apache -H composer install ; \
    sudo -u apache -H cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php ; \
    chown -R apache:apache /var/www/MISP ; \
    chmod -R 750 /var/www/MISP ; \
    chmod -R g+ws /var/www/MISP/app/tmp ; \
    chmod -R g+ws /var/www/MISP/app/files ; \
    chmod -R g+ws /var/www/MISP/app/files/scripts/tmp ; \
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/misp.local.key -out /etc/ssl/private/misp.local.crt -batch ; \
    sudo -u apache cp -a /var/www/MISP/app/Config/bootstrap.default.php /var/www/MISP/app/Config/bootstrap.php ; \
    sudo -u apache cp -a /var/www/MISP/app/Config/database.default.php /var/www/MISP/app/Config/database.php ; \
    sudo -u apache cp -a /var/www/MISP/app/Config/core.default.php /var/www/MISP/app/Config/core.php ; \
    sudo -u apache cp -a /var/www/MISP/app/Config/config.default.php /var/www/MISP/app/Config/config.php ; \
    cp /var/www/MISP/INSTALL/apache.24.misp.ssl /etc/apache2/conf.d/misp-ssl.conf ; \
    sed -i "s/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/" /etc/apache2/httpd.conf ; \
    sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php7/php.ini ; \
    sed -i "s/memory_limit = 128M/memory_limit = 4096M/" /etc/php7/php.ini ; \
    sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 4096M/" /etc/php7/php.ini ; \
    sed -i "s/post_max_size = 8M/post_max_size = 4096M/" /etc/php7/php.ini ; \
    sed -i "s/;extension=ldap/extension=ldap/" /etc/php7/php.ini ; \
    apk del curl gcc g++ git make autoconf automake

COPY run.sh /run.sh
RUN chmod +x /run.sh
CMD /run.sh
