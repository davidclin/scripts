#!/usr/bin/env bash

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


