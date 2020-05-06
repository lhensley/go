#!/bin/bash
# rip.sh
# Should have owner root:$USER_NAME
# Should have permissions 770

production_mode=true
debug_mode=false
#debug_mode=true
if $debug_mode ; then
  set -x
  fi

PROGRAM_DIRECTORY=$(dirname $0)
source $PROGRAM_DIRECTORY/lhlib.sh

HANDBRAKE="HandBrakeCLI"
MKV_BASE_PATH="/mnt/bertha/mkv"
M4V_PATH="/mnt/cloteal/m4v"
PRESET='/home/lhensley/.HandBrake/Lane 1080p (BluRay).json'
MAKEMKV_PROCESS=makemkvcon

if [ $(lh_is_running "$HANDBRAKE") == "true" ] ; then
  echo "Transcode operation already running. Exiting."
  exit 1
fi

mkdir -p "$M4V_PATH"

# While $MKV_BASE_PATH is not empty
PRODUCTIVE=true
while [ $(lh_has_subdirectories "$MKV_BASE_PATH") == "true" ] \
    && [ $PRODUCTIVE == "true" ] ; do # Subdirs found under base
  echo "  Found subdirectories under $MKV_BASE_PATH"
  PRODUCTIVE=false
  for j in "$MKV_BASE_PATH/"*; do # For each subdirectory found under $MKV_BASE_PATH ...
    if [ -d "$j" ]; then # If if really is a subdirectory ...
      echo "  Confirmed that $j is a subdirectory"
      for i in "$j/"*; do # For each file in that subdirectory ...
        if [ -f "$i" ]; then # If it really is a file ...
          echo "  Recognize valid file: $i"
          if [ -n "$(lsof "$i" 2>/dev/null)" ]; then # If source file IS in use and can't be processed ...
            echo "  Source file \"$i\" is in use."
          else # Source file is NOT in use, and ready to be processed.
            echo "  Processing source file \"$i\"."
            let "VIDEOSTART = ${#MKV_BASE_PATH} + 2"
            let "VIDEOEND = ${#j}"
            VIDEONAME=$(echo $j | cut -c$VIDEOSTART-$VIDEOEND)
            let "TITLESTART = ${#i} - 5"
            let "TITLEEND = ${#i} - 4"
            n=$(echo $i | cut -c$TITLESTART-$TITLEEND)
            VIDEONAME="$M4V_PATH/$VIDEONAME - $n.m4v"
            echo "  Target pathname: $VIDEONAME"
            if [ -f "$VIDEONAME" ]; then rm -Rf "$VIDEONAME"; fi
            $HANDBRAKE --preset-import-file "$PRESET" \
              -i "$i" -o "$VIDEONAME"
            exit_status=$?
            if [ $exit_status -ne 0 ]; then # If the transcoding failed ...
              echo "    Transcoding of \"$i\" failed with error code $exit_status."
              echo "Transcoding to $VIDEONAME FAILED." | mail lanecell
              echo "$HANDBRAKE transcoded title $n returned error number $exit_status." | mail lanecell
            else
              rm "$i" # Delete source file
              PRODUCTIVE=true
              echo "Transcoding to $VIDEONAME successful." | mail lanecell
              fi # End of check for transcoding failure
            fi # End of check for source file in use or not
          fi # End of check that source file really is a file
          if find "$j" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then # If more files in subdirectory ...
            sleep 1 # Do nothing ...
          else
            rm -Rf "$j" # Delete source subdirectory
            fi # End of check for more files in source subdirectory
        done # Next file in the subdirectory ...
      fi # End of check to confirm that there are any files in the subdirectory
    done # Next subdirectory under $MKV_BASE_PATH (iterating through them)
  done # End of check to confirm that this are any subdirectories under $MKS_BASE_PATH

echo "Transcoding is complete." | mail lanecell
echo Done.
exit 0
