# Apache vhost script v0.8.0

Ammon Casey @ammonkc


## Quick start

vhost directory structure: `/etc/httpd/conf/vhosts/{available,enabled,template}`

* Put `vhost.conf.template` into `/etc/httpd/conf/vhosts/template`
* Put `create_vhost.sh` and `enable_vhost.sh` into `/usr/local/bin`
* Make the scripts executable: `chmod +x`

## Usage

* `create_vhost domain.com`
* It will ask for the environment and web root folder name

