#!/bin/bash
redis-server --daemonize yes
sudo -u apache -H bash /var/www/MISP/app/Console/worker/start.sh
httpd -D FOREGROUND
