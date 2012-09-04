#!/bin/bash
# @author: Ammon Casey
# http://ammonkc.com
# Created:   08.30.2012

# Modify the following to match your system
VHOST_CONFIG='/etc/httpd/conf/vhosts/available'
VHOSTS_ENABLED='/etc/httpd/conf/vhosts/enabled'
VHOST_TEMPLATE='/etc/httpd/conf/vhosts/template'
HTTPD_INIT='/etc/init.d/httpd'
PHP_FPM_INIT='/etc/init.d/php-fpm'
# --------------END
SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
	echo "No domain name given"
	exit 1
fi
DOMAIN=$1

# check the domain is valid!
PATTERN="^(([a-zA-Z]|[a-zA-Z][-a-zA-Z0-9]*[a-zA-Z0-9])\.)+([A-Za-z]|[A-Za-z][-A-Za-z0-9]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating hosting for:" $DOMAIN
else
	echo "invalid domain name"
	exit 1
fi

# set environment defaults to production
read -e -p "Environment (production)? " ENV
if [ -z $ENV ]; then
	ENVIRONMENT='production'
else
	ENVIRONMENT=$ENV
fi

# Change web root directory
read -e -p "Web root directory (public)? " CHROOTDIR
if [ -z $CHROOTDIR ]; then
	WEB_ROOT='public'
else
	WEB_ROOT=$CHROOTDIR
fi

# Now we need to copy the virtual host template
CONFIG=$VHOST_CONFIG/$DOMAIN.conf
cp $VHOST_TEMPLATE/apache.vhost.conf.template $CONFIG
$SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
$SED -i "s/@@ENVIRONMENT@@/$ENVIRONMENT/g" $CONFIG
$SED -i "s/@@WEBROOT@@/$WEB_ROOT/g" $CONFIG

chmod 600 $CONFIG

ln -s $CONFIG $VHOSTS_ENABLED/$DOMAIN.conf

# set file perms and create required dirs!
mkdir -p /var/www/html/$DOMAIN/$ENVIRONMENT/$WEB_ROOT
mkdir /var/www/html/$DOMAIN/$ENVIRONMENT/_logs
chmod g+rx /var/www/html/$DOMAIN/$ENVIRONMENT
chmod 755 /var/www/html/$DOMAIN/$ENVIRONMENT -R
chmod 770 /var/www/html/$DOMAIN/$ENVIRONMENT/_logs
chmod 755 /var/www/html/$DOMAIN/$ENVIRONMENT/$WEB_ROOT
chmod g+s /var/www/html/$DOMAIN/$ENVIRONMENT/$WEB_ROOT
chown root:develop /var/www/html/$DOMAIN/$ENVIRONMENT/ -R

while true; do
    read -p "Restart Apache now (y/n)? " RELOAD
    case $RELOAD in
        [Yy]* ) $HTTPD_INIT reload; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Restart php-fpm now (y/n)? " RESTART
    case $RESTART in
        [Yy]* ) $PHP_FPM_INIT restart; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "\nSite Created for $DOMAIN with PHP support"

