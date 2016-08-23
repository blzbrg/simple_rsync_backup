#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# find the most recent firefox automatic bookmark backup
echo -n "finding firefox bookmarks..." | tee -a simple_rsync_backup.log
PROFILE_PATH=~/.mozilla/firefox/`grep "Path" ~/.mozilla/firefox/profiles.ini | sed -r 's/Path=(.+)/\1/'`
TARGET_BACKUP=$PROFILE_PATH"/bookmarkbackups/"`ls -1t $PROFILE_PATH"/bookmarkbackups" | head -n 1`
# copy it to home folder
cp $TARGET_BACKUP ~/most_recent_bookmark_backup.jsonlz4
echo "done" | tee -a simple_rsync_backup.log

# the suffix for the previous backup, so we can link against it
LAST_BACKSUFF=`cat last_backup_suffix.txt`
# the suffix for this backup, include a date
NEW_BACKSUFF="incremental_backup_"`date +%F`
echo "old: $LAST_BACKSUFF, new: $NEW_BACKSUFF" | tee -a simple_rsync_backup.log

# use the rsync command to actually copy the files over the network
find $SOURCE_FOLDER -maxdepth 1 -mindepth 1 ! -name '.*' -printf '%f\n' \
| rsync -tpogh -e "$SSH_COMMAND" --progress --verbose --recursive --link-dest=$DEST_FOLDER/$LAST_BACKSUFF \
--files-from='-' $SOURCE_FOLDER $DEST_USER@$DEST_IP:$DEST_FOLDER/$NEW_BACKSUFF 2>&1 \
| tee -a simple_rsync_backup.log
if test "$?" != "0"
then
    echo "===================================================" 
    echo "ERROR: rsync error $?" | tee -a simple_rsync_backup.log
else
    echo "==================================================="
    # save this backup suffix 
    echo $NEW_BACKSUFF > last_backup_suffix.txt
    echo "No obvious errors!" | tee -a simple_rsync_backup.log
fi

echo "Press enter to exit"
read IGNORED_VALUE
