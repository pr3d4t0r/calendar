#!/bin/sh


cat > /etc/logrotate.d/apache2 << EOF
/var/log/apache2/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 www-data
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi \
    endscript
    postrotate
        service apache2 reload >/dev/null 2>&1
    endscript
}
EOF
