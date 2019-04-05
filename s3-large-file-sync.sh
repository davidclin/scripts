#!/usr/bin/env bash

echo "============= START S3 SYNC=========" > result.txt

source_bucket="david-lin-ctr-source-bucket-us-east-1"
destination_bucket="david-lin-ctr-destination-bucket-us-east-1"

aws s3 sync s3://$source_bucket/1/READ.txt s3://$destination_bucket/1/READ.txt >> result.txt    <--- Example of 1:1 object copy
aws s3 sync s3://$source_bucket/ s3://$destination_bucket/ >> result.txt    <--- Example of bucket to bucket copy (recurses directories)


echo "============= COMPLETED ===========" >> result.txt
