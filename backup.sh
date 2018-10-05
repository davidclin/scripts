#!/usr/bin/env bash

set -euo pipefail
PATH=$PATH:/usr/local/bin

{

echo "Creating tarball (this will take some time)..."
tar --totals -C /var/atlassian/application-data/jira -czf /tmp/jira_backup.tgz .

echo "Encrypting..."
/usr/local/bin/kmstool.py -e -f /tmp/jira_backup.tgz -o /tmp/jira_backup.tgz.enc -k xxxxxxxx-yyyy-zzzz-1234-123456789012
rm -v /tmp/jira_backup.tgz

echo "Syncing to S3..."
aws s3 cp /tmp/jira_backup.tgz.enc s3://bucket_name/backups/atlassian/ > /dev/null && \
rm -v /tmp/jira_backup.tgz.enc

echo 'Backup complete!'

} |& ts '[%F][%T]' |& tee --append /var/log/backup.log
