#!/bin/bash
#
# This script retrieves the output of bucket policies from a list of bucket names.
# The bucket names were obtained using the 'Access analyzer for S3' feature from the S3 console.
#

BUCKET_NAME=bucket_name_example_1,bucket_name_example_2

# Output list of buckets with bucket their policies
echo '------------------------'

rm output

for i in $(echo $BUCKET_NAME | sed "s/,/ /g")
do
    # Loop through the BUCKET_NAME list
    echo '------------------------'
    echo '------------------------' >> output
    echo $i
                echo $i >> output
                aws s3api get-bucket-policy --bucket $i >> output
    echo '------------------------'
    echo '------------------------' >> output
done
