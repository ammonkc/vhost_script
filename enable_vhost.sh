#! /bin/bash

# Simple script to enable apache vhosts

AVAILABLE_VHOST=/etc/httpd/conf/vhosts/available/
ENABLED_VHOST=/etc/httpd/conf/vhosts/enabled/

# Verify domain 
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

VHOST="$AVAILABLE_VHOST$DOMAIN.conf"

if [[ -f "$VHOST" ]] ; then
	ln -sf $VHOST $ENABLED_VHOST$DOMAIN.conf
	echo "$DOMAIN enabled"
else
	echo "No available vhost config for $DOMAIN"
fi

# Restart apache
while true; do
    read -p "Restart Apache now (y/n)? " RELOAD
    case $RELOAD in
        [Yy]* ) $HTTPD_INIT reload; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
