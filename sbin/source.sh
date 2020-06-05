#!/bin/bash
# /usr/local/sbin/source-2019-03-20.sh
# Source file for lane scripts
# Should have owner root:$USER_NAME
# Should have permissions 770
#

debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

# Basic setup
logger Begin $0
logger $0 invoking source.sh
source /etc/os-release
# /etc/os-release defines a lot of environment variables 
# Sample:
#    NAME="Ubuntu"
#    VERSION="18.04.4 LTS (Bionic Beaver)"
#    ID=ubuntu
#    ID_LIKE=debian
#    PRETTY_NAME="Ubuntu 18.04.4 LTS"
#    VERSION_ID="18.04"
#    HOME_URL="https://www.ubuntu.com/"
#    SUPPORT_URL="https://help.ubuntu.com/"
#    BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
#    PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
#    VERSION_CODENAME=bionic
#    UBUNTU_CODENAME=bionic

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Start timestamps
START_DATESTAMP=$(/bin/date '+%Y-%m-%d')
START_DAYSTAMP=$(/bin/date '+%d')
START_MONTHSTAMP=$(/bin/date '+%Y-%m')
START_TIMESTAMP=$(/bin/date)
START_WEEKDAYSTAMP=$(/bin/date '+%a')

# Information about Lane
USER_ME="lhensley"
HOME_ME="/home/$USER_ME"
LANE_EMAIL="lane.hensley@alumni.duke.edu"
LANE_CELL="7608514641@vtext.com"

# General local and program variables
PROGRAM_DIRECTORY=$(dirname $0)
HOST_NAME=$(/bin/hostname -s)
USER_NAME=$USER_ME
HOME_DIRECTORY=$HOME_ME
LANE_SCRIPTS_PREFIX="lane-scripts"
UUID=$(uuidgen)
logger UUID $UUID
HOME_RELATIVE=home/$USER_NAME
HOME_DIR=$HOME_DIRECTORY
SBIN_PARENT="/usr/local"
SBIN_DIR="$SBIN_PARENT/sbin"
TEMP_DATABASES="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-databases.tmp"
TEMP_PASSWORD_INCLUDE="/tmp/passwords.sh"
TEMP_INCLUDES="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-includes.tmp"
TEMP_LOG="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-log.tmp"
SCRIPTS_DIRECTORY=$SBIN_DIR
# As of 2020-06-05, $SCRIPTS_INCLUDES still us used by backup.sh
SCRIPTS_INCLUDES=$SCRIPTS_DIRECTORY/include


# Host-specific deinitions. These need to come earlier because other definitions below use them.
case $HOST_NAME in
  red )
    ADDRESS=192.168.168.23
    USER_NAME=lhensley
    OFFSITE_SERVER=nuc01.local
    OFFSITE_PORT=22
    OFFSITE_PATH=/var/local/archives
    ;;
  nuc01 )
    ADDRESS=192.168.168.31
    USER_NAME=lhensley
    OFFSITE_SERVER=oz.lanehensley.org
    OFFSITE_PORT=10104
    OFFSITE_PATH=/var/local/archives
    ;;
  oz )
    # ADDRESS=192.168.168.31
    USER_NAME=lhensley
    OFFSITE_SERVER=lane.is-a-geek.org
    OFFSITE_PORT=10103
    OFFSITE_PATH=/var/local/archives
    ;;
esac

# Backup definitions
# THESE VARIABLES NEED TO BE DEFINED BEFORE THIS SECTION RUNS:
# $HOST_NAME $LANE_SCRIPTS_PREFIX $OFFSITE_PORT $START_DATESTAMP $START_WEEKDAYSTAMP $UUID
DIRECTORY_FROM=/
ARCHIVE_DIRECTORY=/var/local/archives/$HOST_NAME
SOCKETS_TEMP_FILE="/tmp/$LANE_SCRIPTS_PREFIX-$UUID-socket-files.tmp"
ARCHIVE_TAR_FILE="$HOST_NAME-$START_DATESTAMP.gz"
ARCHIVE_TAR_FULL="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_FILE"
ARCHIVE_TAR_WEEKDAY_FILE="$HOST_NAME-weekday-$START_WEEKDAYSTAMP.gz"
ARCHIVE_TAR_FULL_WEEKDAY="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_WEEKDAY_FILE"
ARCHIVE_TAR_DAY_FILE="$HOST_NAME-day-$START_DAYSTAMP.gz"
ARCHIVE_TAR_FULL_DAY="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_DAY_FILE"
ARCHIVE_TAR_MONTH_FILE="$HOST_NAME-month-$START_MONTHSTAMP.gz"
ARCHIVE_TAR_FULL_MONTH="$ARCHIVE_DIRECTORY/$ARCHIVE_TAR_MONTH_FILE"
ARCHIVE_MYSQL_FILE="$HOST_NAME-$START_DATESTAMP.sql"
ARCHIVE_MYSQL_FULL="$ARCHIVE_DIRECTORY/$ARCHIVE_MYSQL_FILE"
ARCHIVE_MYSQL_LITURGY="$ARCHIVE_DIRECTORY/$HOST_NAME-liturgy.sql"
ARCHIVE_MYSQL_DB="$ARCHIVE_DIRECTORY/$HOST_NAME-$START_DATESTAMP-"
TAR="/bin/tar"
EXEC_BACKUP="$TAR --create --gzip --auto-compress --preserve-permissions"
EXEC_BACKUP="$EXEC_BACKUP --file=$ARCHIVE_TAR_FULL_WEEKDAY"
EXEC_BACKUP="$EXEC_BACKUP --exclude-backups"
EXEC_BACKUP="$EXEC_BACKUP --exclude-vcs --exclude-caches"
EXEC_BACKUP="$EXEC_BACKUP --totals"
# EXEC_BACKUP="$EXEC_BACKUP --verbose"
EXEC_BACKUP="$EXEC_BACKUP --exclude-from=$SOCKETS_TEMP_FILE"
EXEC_BACKUP="$EXEC_BACKUP /etc /home /root /usr/local/sbin /var/www"
# EXEC_BACKUP="$EXEC_BACKUP /var/local/archives/*.sql"
# NOTE: -t flag removed from next line 3/28/19. Generates error.
RSYNC_NO_DELETE="rsync -aopqrzE -e 'ssh -p $OFFSITE_PORT'"
RSYNC_SU="$RSYNC_NO_DELETE '$ARCHIVE_DIRECTORY'"
RSYNC_SU="$RSYNC_SU $OFFSITE_SERVER:$OFFSITE_PATH"
BACKUPLOG=$ARCHIVE_DIRECTORY/$HOST_NAME-backup.log

# Apache2
WEB_ROOTS="/var/www"
THIS_WEB_ROOT="$WEB_ROOTS/html"

# Passwords
LENGTH_OF_PASSWORDS=63
MAX_MYSQL_PASSWORD_LENGTH=32
EXCLUDED_PASSWORD_CHARACTERS=" \$\'\"\\\#\|\<\>\;\*\&\~\!\I\l\1\O\0\`\/\?"

# cron
TEMP_CRON="/tmp/cron-$UUID.tmp"

# Git
GIT=/var/local/git
GO=$GIT/go
GO_CONFIGS=$GO/configs
GO_SBIN=$GO/sbin
GO_SETUP=$GO_SBIN/setup

# MySQL
MYSQL_ADMIN_NAME="admin"
MYSQL_CLIENT_CERTS_DIR="$HOME_DIRECTORY/certs"
MYSQL_CONFIGS="/etc/mysql/conf.d"
MYSQL_DUMP_DIR=$HOME_DIR/mysql-dumps
MYSQL_SERVER_BIN_DIR="/var/lib/mysql"

# phpMyAdmin
PHPMYADMIN_DIR="/usr/share/phpmyadmin"

# ssh
SSHD_CONFIG="/etc/ssh/sshd_config"

# System User (Amazon AWS servers only)
USER_UBUNTU="ubuntu"

# Mail
MAILNAME=$HOST_NAME

# Basically, this section means look for *.sh in the "includes" directory and invoke them.
find $SCRIPTS_INCLUDES -name "*.sh" -type f | while read INFILE
  do
    source "$INFILE"
  done

# Set key file ownerships #############################################
/bin/chown root:root $MYSQL_CONFIGS/mysqldump.cnf >> /dev/null 2>&1
/bin/chown -R root:$USER_NAME $SCRIPTS_DIRECTORY >> /dev/null 2>&1
/bin/chown -R www-data:www-data $THIS_WEB_ROOT/ >> /dev/null 2>&1

# Set key file permissions ############################################
/bin/chmod 600 $MYSQL_CONFIGS/mysqldump.cnf >> /dev/null 2>&1
/bin/chmod -R 770 $SCRIPTS_DIRECTORY >> /dev/null 2>&1

# Echo variable values in debug mode
#
if $debug_mode ; then
  echo $(date)
  env
  fi
