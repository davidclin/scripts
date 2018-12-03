#!/usr/bin/env bash
#
# Prints output of bucket names and associated analytics filter name(s)
#
# Example artifact:
#
#  Bucket Name             Analytics Filter Name(s)
#  bucket_name_1           foo test
#  bucket_name_2           test
#  ...



buckets=$(aws s3api list-buckets --query Buckets[].Name --output text)

printf "%-50s %s\n" "Bucket Name" "Analytics Filter Name(s)" 
printf "%-50s %s\n" "Bucket Name" "Analytics Filter Name(s)" > output 

for bucket in $buckets; do
  analytics=$(aws s3api list-bucket-analytics-configurations --bucket $bucket --query AnalyticsConfigurationList[].Id --output text)
  printf "%-50s %s %s %s\n" $bucket $analytics
  printf "%-50s %s %s %s\n" $bucket $analytics >> output 
done


