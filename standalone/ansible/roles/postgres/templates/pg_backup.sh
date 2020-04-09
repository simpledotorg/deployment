#!/bin/bash

BACKUP_DIR="/home/deploy/backups"
FILENAME=$BACKUP_DIR"/`date +\%Y-\%m-\%d`"

if ! mkdir -p $BACKUP_DIR; then
    echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Go and fix it!" 1>&2
    exit 1;
fi;

if ! pg_dump -U {{ secrets.postgres.username }} {{ postgres.database_name }} | gzip > "$FILENAME".sql.gz.in_progress; then
    echo "[!!ERROR!!] Failed to produce backup database {{ postgres.database_name }}" 1>&2
else
    mv "$FILENAME".sql.gz.in_progress "$FILENAME".sql.gz
fi
