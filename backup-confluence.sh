#!/usr/bin/env bash

set -euo pipefail
PATH=$PATH:/usr/local/bin

{

echo "Creating tarball (this will take some time)..."
tar --totals -C /var/atlassian/application-data/confluence -czf /tmp/confluence_backup.tgz .

echo "Encrypting..."
/usr/local/bin/kmstool.py -e -f /tmp/confluence_backup.tgz -o /tmp/confluence_backup.tgz.enc -k <encryption_key_string> 
rm -v /tmp/confluence_backup.tgz

echo "Syncing to S3..."
aws s3 cp /tmp/confluence_backup.tgz.enc s3://bucket_name/backups/atlassian/ > /dev/null && \
rm -v /tmp/confluence_backup.tgz.enc

echo 'Backup complete!'

} |& ts '[%F][%T]' |& tee --append /var/log/backup.log
