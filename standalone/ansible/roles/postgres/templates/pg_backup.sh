#!/bin/bash

BACKUP_DIR={{ backups_dir }}
FILENAME=$BACKUP_DIR"`date +\%Y-\%m-\%d`"
HOSTNAME=`hostname`
DAYS_TO_KEEP={{ backups_days_to_keep }}

if ! mkdir -p $BACKUP_DIR; then
    echo "Cannot create backup directory in $BACKUP_DIR. Go and fix it!" 1>&2
    exit 1;
fi;

if ! pg_dump -U {{ secrets.postgres.username }} {{ postgres.database_name }} | gzip > "$FILENAME".sql.gz.in_progress; then
    echo "[!!ERROR!!] Failed to produce backup database {{ postgres.database_name }}" 1>&2
else
    mv "$FILENAME".sql.gz.in_progress "$FILENAME".sql.gz
  {% for server in groups.storage %}
    rsync -a "$BACKUP_DIR"* {{ deploy_user }}@{{ server }}:{{ backups_destination_dir }}/$HOSTNAME/ --log-file="$FILENAME"-rsync.log
  {% endfor %}
fi

find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -exec rm -rf '{}' ';'
