## "Incremental" backups
This leverages an rsync feature to back up files but hardlink any files that rsync thinks have not changed. This is not a block level thing, a file is either copied in its entirety, or hardlinked to the last version.
TODO: Document how rsync figure out whether files have changed or not.
## Configuration options
This script is configured through environment variables. Additionally a file `last_backup_suffix.txt` must be present in the same directory as the script that says the name of the last backup to link against. The script will update this as it goes.
- `SOURCE_FOLDER`: the folder whose contents should be backed up
- `SSH_COMMAND`: options for how rsync should invoke ssh (paradigmatically used for flags not positional arguments), given to rsync -e flag, e.g. `SSH_COMMAND='ssh -p 9001'`
- `DEST_FOLDER`: the folder on the remote server where backups should be stored, e.g. `DEST_FOLDER=/home/blzbrg/backups`. Don't put trailing slash.
- `DEST_USER`: user on the remote server that you intend to authenticate as, e.g. `DEST_USER=blzbrg`
