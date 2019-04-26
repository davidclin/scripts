#!/bin/bash

# See cheatsheet for tips and tricks
# Don't forget to set ulimit
# Use 250 workers
# Pipe to file with name: IE-1300-TRI-NA-929292782238-s3-acl-bucket-owner-full-control-miru-us-east-1.md

#ulimit -n 1048576

SCRIPT_PATH="/home/ec2-user/go/src/github.com/miru-us-east-1/bucket-owner-full-control"
WORKERS="250"

ACCOUNT_NAME="TRI-NA"
PROFILE="miru"
ACCOUNT_ID="929292782238"
REGION="us-east-1"
# BUCKET_NAME="david-lin-ctr-foobar"
BUCKET_NAME="miru-us-east-1"

NOW=$( date '+%F_%H:%M:%S' )
echo "# $ACCOUNT_NAME - $ACCOUNT_ID"
echo "<p> STARTED $NOW"
echo "<pre>"
echo "-----------------------------"
$SCRIPT_PATH --profile $PROFILE --bucket $BUCKET_NAME --region $REGION --fix --workers $WORKERS

echo "</pre>"


NOW=$( date '+%F_%H:%M:%S' )
echo ""
echo "COMPLETED $NOW"

