"""

Create analytics configurations for an S3 bucket.

Boto3 Doc: 
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/
services/s3.html#S3.Client.put_bucket_analytics_configuration

AWS CLI: 
aws s3api put-bucket-analytics-configuration --bucket test_bucket 
--analytics-configuration '{"Id": "report","StorageClassAnalysis": 
{}}' --id "report"


"""

import boto3

bucketname = "david-lin-ctr-analytics"

config = {"Id": "report",
          "StorageClassAnalysis": {
              'DataExport': {
                  'OutputSchemaVersion': 'V_1',
                  'Destination': {
                      'S3BucketDestination': {
                          'Format': 'CSV',
                          'Bucket': 'arn:aws:s3:::david-lin-ctr-test',
                          'Prefix': 'rewrite'}
                    }
                }
            }
          }

client = boto3.client('s3')
analytics_config = client.put_bucket_analytics_configuration(Bucket=bucketname, Id="report", AnalyticsConfiguration=config)
print analytics_config
