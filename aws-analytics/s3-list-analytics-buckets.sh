#!/usr/bin/env bash
#
# This script should be run within a virtual environment with
# latest version of awscli and boto3 using python2.7
#
# Tested using:
#   (aws-cli-virtualenv) ubuntu@ip-10-100-3-147:~/scripts$ aws --version
#   aws-cli/1.16.65 Python/2.7.12 Linux/4.4.0-138-generic botocore/1.12.55


buckets=$(aws s3api list-buckets --query Buckets[].Name --output text)

printf "%-55s %-15s %-10s %-50s %-50s\n" "Bucket Name" "Region" "Filter" "Analytics Bucket" "Bucket Prefix" 
printf "%-55s %-15s %-10s %-50s %-50s\n" "Bucket Name" "Region" "Filter" "Analytics Bucket" "Bucket Prefix" > output 

for bucket in $buckets; do
  region=$(aws s3api get-bucket-location --bucket $bucket --query LocationConstraint --output text)
  analytics=$(aws s3api list-bucket-analytics-configurations --bucket $bucket --query AnalyticsConfigurationList[].Id --output text)
  destination_bucket=$(aws s3api list-bucket-analytics-configurations --bucket $bucket --query AnalyticsConfigurationList[].StorageClassAnalysis.DataExport.Destination.S3BucketDestination.Bucket --output text)
  destination_prefix=$(aws s3api list-bucket-analytics-configurations --bucket $bucket --query AnalyticsConfigurationList[].StorageClassAnalysis.DataExport.Destination.S3BucketDestination.Prefix --output text)
#  if [ $analytics == "None" ]; then
#  if [ $analytics != "None" ]; then
  if [ $analytics != "get-complete-list" ] ; then
    printf "%-55s %-15s %-10s %-50s %-50s\n" $bucket $region $analytics $destination_bucket $destination_prefix 
    printf "%-55s %-15s %-10s %-50s %-50s\\n" $bucket $region $analytics $destination_bucket $destination_prefix >> output 
  fi
done


