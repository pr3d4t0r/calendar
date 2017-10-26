FROM ubuntu:16.04

LABEL author="pr3d4t0r - Eugene Ciurana"
LABEL copyright="(c) Copyright 2015, 2016 by CIME Software Ltd."
LABEL description="Baikal / SabreDAV robust calendar and address book server with scheduling and email notifications"
LABEL license="See: LICENSE.txt for complete licensing information."
LABEL support="caldav AT cime.net"
LABEL version="2.1"

### "configure-apt"
RUN echo "APT::Get::Assume-Yes true;" >> /etc/apt/apt.conf.d/80custom \
 && echo "APT::Get::Quiet true;" >> /etc/apt/apt.conf.d/80custom \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

### Set some environment variables
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm \
    DEBIAN_FRONTEND=noninteractive

### Weird bug where this needs to be installed before the locales package
RUN apt-get update && apt-get install -y --no-install-recommends --assume-yes apt-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
### Install the locales package first before the main set of packages    
RUN apt-get update && apt-get install -y --no-install-recommends --assume-yes locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
### Generate the locales for the system
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales \
    && update-locale LANG=en_US.UTF-8 \
    && update-locale LANGUAGE=en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8

### Configure Postfix options prior to installing the package to prevet the config screen from appearing
#
# These parameters are specific to your own Postfix relay!  Use your host and domain
# names.
RUN echo "postfix postfix/mailname string calendar.example.org" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Satellite system'" | debconf-set-selections && \
    echo "postfix postfix/relayhost string smtpcal.example.org" | debconf-set-selections && \
    echo "postfix postfix/root_address string cal-bounce@example.org" | debconf-set-selections

### Install the main set of system requirements
RUN apt-get update && apt-get install -y \
    apache2 \
    curl \
    postfix \
    mailutils \ 
    rsyslog \
    sqlite3 \
    php \
    libapache2-mod-php \
    php-date \
    php-dom \
    php-mbstring \
    php-sqlite3 \
    unzip \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

### "Baikal-installation"

RUN cd /tmp/ && curl --silent -LO https://github.com/fruux/Baikal/releases/download/0.4.6/baikal-0.4.6.zip \
 && unzip /tmp/baikal-0.4.6.zip -d /var/www/ \
 && rm -Rvf /var/www/baikal/Specific/db/.empty && rm -f /tmp/baikal-0.4.6.zip 

# Scheduling and email delivery.  See:
# http://sabre.io/dav/scheduling/
# https://groups.google.com/forum/#!searchin/sabredav-discuss/scheduling|sort:relevance/sabredav-discuss/CrGZXqw4sRw/vsHYq6FDcnkJ
# This needs to be patched on the Baikal start up Server.php, NOT in the SabreDAV server.
COPY resources/Server.php /var/www/baikal/Core/Frameworks/Baikal/Core/Server.php
COPY resources/baikal.apache2 /var/www/baikal/Specific/virtualhosts/baikal.apache2
COPY cal_infox.php /var/www/baikal/html/

# The Baikal administration wizard creates these two config files when first run.  Preserve them
# and save them to the resources/ directory.  These files must be preserved for upgrades.
# Both files are already in the .gitignore file.
#
# To use them:  uncomment these two lines and copy them to the Specific/ directory, per the
# Baikal upgrade instructions at:  http://sabre.io/baikal/upgrade/
# COPY resources/config.php /var/www/calendar_server/Specific/
# COPY resources/config.system.php /var/www/calendar_server/Specific/

RUN chown -Rf www-data:www-data /var/www/baikal/Specific \
 && /etc/init.d/apache2 stop \
 && a2enmod rewrite \
 && rm /etc/apache2/sites-available/000-default.conf \
 && rm /etc/apache2/sites-enabled/000-default.conf \
 && cp /var/www/baikal/Specific/virtualhosts/baikal.apache2 /etc/apache2/sites-enabled/000-default.conf \
 && echo "error_log = syslog" >> /etc/php/7.0/apache2/php.ini

# httpoxy vulnerability fix:
RUN awk '/vim: syntax/ { printf("# Poxy; CVE-2016-5387\nLoadModule headers_module /usr/lib/apache2/modules/mod_headers.so\nRequestHeader unset Proxy early\n%s\n", $0); next; } { print; }' /etc/apache2/apache2.conf > /tmp/apache2.conf
RUN cat /tmp/apache2.conf > /etc/apache2/apache2.conf && rm /tmp/apache2.conf

### "web-server-configuration-and-launch"
WORKDIR /
COPY bin/runapache2 /

ENTRYPOINT [ "/runapache2" ]
