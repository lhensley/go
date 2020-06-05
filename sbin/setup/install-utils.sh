#!/bin/bash
# install-utils.sh
# Revised 2020-06-04
# PURPOSE: Install uncomplicated, no-down-side utilities.

# Include header file
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/../source.sh

function install() {
   logger Installing $1
   apt-get install -y $1
}

# Get to work
install ufw
install apg
install curl
install fail2ban
install filezilla
install gimp
install git && ufw allow git
install net-tools
install openssl
install openvpn
    install bridge-utils
install ssh && ufw allow ssh
install sysbench
install tasksel
install unzip
install wget
install xrdp

ufw allow http
ufw allow https
