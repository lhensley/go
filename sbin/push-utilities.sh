#!/bin/bash
# push-utilities.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

# This should go BEFORE header so nothing runs on the wrong server.
ONLY_SERVER="nuc01"
if [[ $(/bin/hostname -s) != $ONLY_SERVER ]]; then
    echo "$0 runs ONLY on server $ONLY_SERVER."
    exit
fi

# Include header file
PRODUCTION_DIRECTORY="/usr/local/sbin"
PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/source.sh


SOURCE_DIRECTORY=$PRODUCTION_DIRECTORY
TARGET_SERVER=red.local
TARGET_PORT=22
TARGET_DIRECTORY=/usr/local
# rsync options used
#    -a = archive mode, equivalent to -rlptgoD
#    -g = preserve group ownership
#    -l = recreate symlinks on destination
#    -o = preserve owner
#    -p = preserve permissions
#    -q = quiet
#    -r = recursive (includes subdirectories)
#    -t = preserve modification times
#    -z = compress file data during transfer
#    -D = preserve device files and special files
#    -E = preserve executability
#    --delete = delete extraneous files from dest dirs
RSYNC="rsync -gopqrzE --delete"
RSYNC="$RSYNC -e 'ssh -p $TARGET_PORT'"
RSYNC="$RSYNC '$SOURCE_DIRECTORY'"
RSYNC="$RSYNC '$TARGET_SERVER:$TARGET_DIRECTORY'"

# Sync to target server
# su options used
#    -c = Pass command to the shell
echo $TARGET_SERVER
echo $RSYNC
su -c "$RSYNC" $USER_NAME


SOURCE_DIRECTORY=/usr/local/sbin
TARGET_SERVER=pearl.stmargarets.org
TARGET_PORT=22
TARGET_DIRECTORY=/usr/local
# rsync options used
#    -a = archive mode, equivalent to -rlptgoD
#    -g = preserve group ownership
#    -l = recreate symlinks on destination
#    -o = preserve owner
#    -p = preserve permissions
#    -q = quiet
#    -r = recursive (includes subdirectories)
#    -t = preserve modification times
#    -z = compress file data during transfer
#    -D = preserve device files and special files
#    -E = preserve executability
#    --delete = delete extraneous files from dest dirs
RSYNC="rsync -gopqrzE --delete"
RSYNC="$RSYNC -e 'ssh -p $TARGET_PORT'"
RSYNC="$RSYNC '$SOURCE_DIRECTORY'"
RSYNC="$RSYNC '$TARGET_SERVER:$TARGET_DIRECTORY'"

# Sync to target server
# su options used
#    -c = Pass command to the shell
echo $TARGET_SERVER
echo $RSYNC
echo NOT EXECUTED.
# su -c "$RSYNC" $USER_NAME
