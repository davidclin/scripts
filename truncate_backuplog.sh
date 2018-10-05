#!/usr/bin/env bash

instanceid=`curl http://169.254.169.254/latest/meta-data/instance-id`
today=`date '+%Y-%m-%d-'`;

PATH=$PATH:/usr/local/bin

echo "Syncing backup.log to S3..."
aws s3 cp /var/log/backup.log s3://bucket_name/backup_logs/app_name/$
today$instanceid-backup.log


echo "Truncating /var/log/backup.log"
truncate -s0 /var/log/backup.log

