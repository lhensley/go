#!/bin/bash
# XXX.sh
# Revised 2020-05-07
# PURPOSE:
# IMPORTANT: Check variables at the top of the script before running it!

# Still to add:
#    wordpress
#    ssh keys
#    lets encrypt
#    turn off password
#    If a clone, make some things unique: hostname, address, keys (ssh, ssl, mysql, webmin)

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

USER_ME=lhensley
USER_UBUNTU=ubuntu

install_apache2=true
install_certbot=true
# Strongly recommended to install curl. Other installs depend on it.
install_curl=true
install_fail2ban=true
install_mailutils=true
install_mysql_server=true
install_net_tools=true
install_openssh_server=true
install_openssl=true
install_php=true
install_phpmyadmin=true
install_plexmediaserver=false
install_sysbench=true
install_tasksel=true
install_unzip=true
# Strongly recommended
install_wget=true
# NOTE: xrdp will allow remote desktop protocol. Use with care.
install_xrdp=true
enable_ufw=true

work_directory=$(pwd)

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." 1>&2
  exit 1
fi

# Do updates
apt-get update && apt -y dist-upgrade && apt -y clean && apt -y autoremove




# phpMyAdmin should be installed AFTER php and MySQL
if $install_mysql_server ; then
  apt-get install -y openssl libcurl4-openssl-dev libssl-dev
  apt-get install -y mysql-server
  mysql_secure_installation --use-default
  cp /etc/mysql/mysql.conf.d/mysqld.cnf \
  /etc/mysql/mysql.conf.d/mysqld.cnf-$(date '+%Y%m%d%H%M%S')
  cp $(dirname $0)/configs/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
  chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf
  chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
  mysql_ssl_rsa_setup
  chown -R mysql:mysql /var/lib/mysql
#  Try to avoid granting access outside localhost
#  If you do add outside access, edit /etc/mysql/mysql.conf.d/mysqld.conf
#    to expand the "listen" scope, and reset MySQL with
#      service mysql restart
#  ufw allow mysql
  fi

# phpMyAdmin should be installed AFTER php and MySQL
# ASKS QUESTIONS!
if $install_phpmyadmin ; then
  apt-get install -y phpmyadmin php-mbstring php-gettext
  cd /usr/share
  rm -R phpmyadmin
  wget -P /usr/share/ "https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip"
  unzip phpMyAdmin-latest-all-languages.zip
  rm phpMyAdmin-latest-all-languages.zip
  mv phpMyAdmin-* phpmyadmin
  mkdir phpmyadmin/tmp
  cd $work_directory
  phpenmod mbstring
  touch /usr/share/phpmyadmin/config.inc.php
  cp /usr/share/phpmyadmin/config.inc.php \
  /usr/share/phpmyadmin/config.inc.php-$(date '+%Y%m%d%H%M%S')
  cp configs/phpmyadmin.config.inc.php /usr/share/phpmyadmin/config.inc.php
  chown -R www-data:www-data /usr/share/phpmyadmin
  chmod 644 /usr/share/phpmyadmin/config.inc.php
  systemctl restart apache2
  fi

if $install_plexmediaserver ; then
  curl https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
  echo deb https://downloads.plex.tv/repo/deb public main | tee /etc/apt/sources.list.d/plexmediaserver.list
  apt-get update
  apt-get -y install apt-transport-https plexmediaserver
  apt-get -y install plexmediaserver
  ufw allow plexmediaserver
  fi

