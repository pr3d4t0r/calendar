#!/bin/sh

set -e
set -x

if [ "$ENVIRONMENT" == "development"  ] && [ "$ENVIRONMENT" == "test" ];then
    echo "skipping loggly"
    exit 0
fi

mkdir -pv /var/spool/rsyslog

#if [ "$(lsb_release -ds | grep Ubuntu)" != "" ]; then
 chown -R syslog:adm /var/spool/rsyslog
#fi

cat > /etc/rsyslog.d/21-apache2-loggly.conf << EOF
\$ModLoad imfile
\$InputFilePollInterval 10
\$PrivDropToGroup adm
\$WorkDirectory /var/spool/rsyslog

# Apache access file:
\$InputFileName /var/log/apache2/calendar_access.log
\$InputFileTag apache-access:
\$InputFileStateFile stat-apache-access
\$InputFileSeverity info
\$InputFilePersistStateInterval 20000
\$InputRunFileMonitor

#Apache Error file:
\$InputFileName /var/log/apache2/calendar_error.log
\$InputFileTag apache-error:
\$InputFileStateFile stat-apache-error
\$InputFileSeverity error
\$InputFilePersistStateInterval 20000
\$InputRunFileMonitor

#Add a tag for apache events
\$template LogglyFormatApache,"<%pri%>%protocol-version% %timestamp:::date-rfc3339% %HOSTNAME% %app-name% %procid% %msgid% [f5fb802f-8fd5-41c2-a31d-a1a5a6f753df@41058 tag=\"apache2\"] %msg%\n"

if \$programname == 'apache-access' then @@logs-01.loggly.com:514;LogglyFormatApache
if \$programname == 'apache-access' then ~
if \$programname == 'apache-error' then @@logs-01.loggly.com:514;LogglyFormatApache
if \$programname == 'apache-error' then ~
EOF

service rsyslog stop
rm -f /var/run/rsyslogd.pid
pkill rsyslog
service rsyslog start
