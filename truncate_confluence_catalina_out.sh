#!/usr/bin/env bash

instanceid=`curl http://169.254.169.254/latest/meta-data/instance-id`
today=`date '+%Y-%m-%d-'`;

PATH=$PATH:/usr/local/bin

echo "Dumping catalina.out to S3..."
aws s3 cp /opt/atlassian/confluence/logs/catalina.out s3://bucketname/$today$instanceid-catalina.out


echo "Truncating"
truncate -s0 /opt/atlassian/confluence/logs/catalina.out
