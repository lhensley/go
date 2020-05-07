#!/bin/bash
# install-110-basic.sh
# Revised 2020-05-06
# PURPOSE: Sets up some basic things. See comments for details.
# IMPORTANT: Check variables at the top of the script before running it!
# vi commands to delete all: :1,$d

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
# Strongly recommended to install curl. Other installs depend on it.
install_certbot=true
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
# NOTE: xrdp will allow remote desktop protocol. Use with care.
install_webmin=true
# Strongly recommended
install_wget=true
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

# Add custom application definitions for ufw
cp $PROGRAM_DIRECTORY/configs/lane-applications /etc/ufw/applications.d/
chown root:root /etc/ufw/applications.d/lane-applications
chmod 644 /etc/ufw/applications.d/lane-applications
ufw app update lane-applications
echo Special LANE applications installed to ufw.

# CRITICAL: Install this first.
if $install_curl ; then
  apt-get install -y curl
  echo curl installed.
  fi

# Install this early.
if $install_unzip ; then
  apt-get install -y unzip
  echo unzip installed.
  fi

# Install this early.
if $install_wget ; then
  apt-get install -y wget
  echo wget installed.
  fi

if $install_apache2 ; then
  apt-get install -y apache2
  ufw allow 'Apache'
  ufw allow 'Apache Full'
  ufw allow http
  ufw allow https
  echo wget installed.
  fi

if $install_fail2ban ; then
  apt-get install -y fail2ban
  echo fail2ban installed.
  fi
exit

# ASKS QUESTIONS! Choose Smart Host: mail.twc.com
if $install_mailutils ; then
  apt-get install -y mailutils
  ufw allow mail
  fi

# phpMyAdmin should be installed AFTER php and MySQL
if $install_mysql_server ; then
  apt-get install -y openssl
  apt-get install -y mysql-server
  mysql_secure_installation
  cp /etc/mysql/mysql.conf.d/mysqld.cnf \
  /etc/mysql/mysql.conf.d/mysqld.cnf-$(date '+%Y%m%d%H%M%S')
  cp configs/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf
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

if $install_net_tools ; then
  apt-get install -y net-tools
  fi

if $install_openssh_server ; then
  apt-get install -y openssh-server
  ufw allow ssh
  ufw limit ssh
  cp /var/local/git/go/ssh/$USER_ME/authorized_keys /home/$USER_ME/.ssh
  cp /var/local/git/go/ssh/$USER_UBUNTU/authorized_keys /home/$USER_ME/.ssh
  chown $USER_ME:$USER_ME /home/$USER_ME/.ssh/authorized_keys
  chown $USER_UBUNTU:$USER_UBUNTU /home/$USER_UBUNTU/.ssh/authorized_keys
  chmod 644 /home/$USER_ME/.ssh/authorized_keys
  chmod 644 /home/$USER_UBUNTU/.ssh/authorized_keys
  fi

if $install_openssl ; then
  apt-get install -y openssl
  fi

# phpMyAdmin should be installed AFTER php and MySQL Server
# BUG: mcrypt module missing. Also, what to do as php value changes. TBD
if $install_php ; then
  apt-get install -y php libapache2-mod-php
  apt-get install -y php-mysql php-gd php-curl php-imap php-ldap
  apt-get install -y libmcrypt-dev php7.2-mbstring
  apt-get install -y php-dev php-pear
  pecl channel-update pecl.php.net
  pecl install mcrypt-1.0.1
  phpenmod gd curl imap ldap mbstring
  service apache2 restart
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

if $install_sysbench ; then
  apt-get install -y sysbench
  fi

if $install_tasksel ; then
  apt-get install -y tasksel
  fi

if $install_xrdp ; then
  apt-get install -y xrdp
  ufw allow from 192.168.1.0/24 to any port 3389 proto tcp
  fi

# NOTE: Install Webmin last, so it picks up on installed applications.
if $install_webmin ; then
  wget http://www.webmin.com/download/deb/webmin-current.deb
  apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl \
  libpam-runtime libio-pty-perl apt-show-versions python
  dpkg --install webmin-current.deb
  rm webmin-current.deb
  ufw allow webmin
  fi

if $enable_ufw ; then
  echo FROM LANE: Please answer YES to the this:
  ufw enable
  ufw reload
  fi

# Edit .vimrc settings
touch /home/$USER_ME/.vimrc && cp /home/$USER_ME/.vimrc /home/$USER_ME/.vimrc.backup.$(date "+%Y.%m.%d-%H.%M.%S") && echo "set background=dark" > /home/$USER_ME/.vimrc && echo "set visualbell" >> /home/$USER_ME/.vimrc

# Make $USER_ME and $USER_UBUNTU users and give them sudo access and ssh access
useradd $USER_ME
useradd $USER_UBUNTU
usermod -aG sudo $USER_ME
usermod -aG sudo $USER_UBUNTU
printf "\n\nAllowUsers $USER_ME $USER_UBUNTU\n\n" >> vi /etc/ssh/sshd_config
# read -p "Press [Enter] key to start backup..."
# vi /etc/ssh/sshd_config
systemctl restart sshd

if $enable_certbot ; then
  add-apt-repository ppa:certbot/certbot
  apt install -y python-certbot-apache
  fi
