#!/bin/bash
# Should have owner root:$USER_NAME
# Should have permissions 770
#

status=/tmp/last-known-public-ip-address.txt
touch "$status"
str=$( wget -q -O - checkip.dyndns.org | sed -e 's/.*Current IP Address: //;s/<.*$//' )
if { IFS= read -r line1 &&
     [[ $line1 != $str ]] ||
     IFS= read -r $line2
   } < "$status" ; then
  echo "$str" | mail -s "DDNS Update" lane lanecell
  echo "$str" > "$status"
fi



