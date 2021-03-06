#!/bin/bash

if [ ! -e /var/www/html/shopware.php ]; then
    echo -n "Shopware not found, installing..."
    wget -q http://releases.s3.shopware.com.s3.amazonaws.com/install_$SHOPWARE_VERSION.zip -O /tmp/shopware.zip
    rm -f /var/www/html/index.html && unzip -d /var/www/html /tmp/shopware.zip && chown -R www-data /var/www/html/* || exit 1
    echo "done"
fi

echo -n "Setting permissions..."
for i in config.php \
    var/log/ \
    var/cache/ \
    web/cache/ \
    files/documents/ \
    files/downloads/ \
    recovery/ \
    engine/Shopware/Plugins/Community/ \
    engine/Shopware/Plugins/Community/Frontend \
    engine/Shopware/Plugins/Community/Core \
    engine/Shopware/Plugins/Community/Backend \
    engine/Shopware/Plugins/Default/ \
    engine/Shopware/Plugins/Default/Frontend \
    engine/Shopware/Plugins/Default/Core \
    engine/Shopware/Plugins/Default/Backend \
    themes/Frontend \
    media/archive/ \
    media/image/ \
    media/image/thumbnail/ \
    media/music/ \
    media/pdf/ \
    media/unknown/ \
    media/video/ \
    media/temp/ \
    recovery/install/data; do
        chmod 777 /var/www/html/$i
done
echo "done"

if [ ! -d "/var/www/html/vendor/vlucas/phpdotenv" ] && [ ! -f "/var/www/html/config.php" ]
then
    echo "preparing the shopware configuration"
    substitute-env-vars.sh /var/www/html/ /config.php.tmpl
fi

if [ ! -e "/etc/ssl/certs/shopware.pem" ] || [ ! -e "/etc/ssl/certs/shopware.key" ]
then
  echo "generating self signed cert"
  openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=$SERVERNAME" \
  -keyout "/etc/ssl/certs/shopware.key" \
  -out "/etc/ssl/certs/shopware.pem" \
  -days 3650 -nodes -sha256
fi

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
