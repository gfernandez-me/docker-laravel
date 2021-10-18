#!/bin/sh

# Cache
php artisan route:cache --quiet
php artisan config:cache --quiet

# Permissions
chown -R ubuntu:www-data /var/www/api
chmod -R ug+rwx /var/www/api/storage/
chmod -R ug+rwx /var/www/api/bootstrap/cache/

# Launch the httpd in foreground
rm -rf /run/apache2/* || true && /usr/sbin/httpd -DFOREGROUND